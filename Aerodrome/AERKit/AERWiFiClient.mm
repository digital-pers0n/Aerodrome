//
//  AERWiFiManager.mm
//  Aerodrome
//
//  Created by Maxim M. on 11/18/21.
//

#import "AERWiFiClient.h"
#import "Apple80211.h"

#import <sys/ioctl.h>
#import <CoreWLAN/CoreWLAN.h>

namespace AE {
enum struct WiFiEvent {
    Power = APPLE80211_M_POWER_CHANGED,
    SSID = APPLE80211_M_SSID_CHANGED,
    BSSID = APPLE80211_M_BSSID_CHANGED,
    Link = APPLE80211_M_LINK_CHANGED,
    Mode = APPLE80211_M_MODE_CHANGED,
    Assoc = APPLE80211_M_ASSOC_DONE,
    Scan = APPLE80211_M_SCAN_DONE
}; // enum struct WiFiEvent

struct WiFiClient {
    Apple80211Ref Ref;
    NSString *IfName;
    
    WiFiClient(const WiFiClient &) = delete;
    WiFiClient operator=(const WiFiClient &) = delete;
    
    WiFiClient() {};
    ~WiFiClient() {};
    
//MARK: - Open/Close
    
    CWErr open() noexcept {
        auto err = Apple80211Open(&Ref);
        if (err != kCWNoErr) return CWErr(err);
        
        auto fail = [&] {
            Apple80211Close(Ref);
            Ref = nil;
            return CWErr(err);
        };
        
        CFArrayRef ifNameList{};
        err = Apple80211GetIfListCopy(Ref, &ifNameList);
        
        if (err != kCWNoErr) return fail();
        
        if (CFArrayGetCount(ifNameList) > 0) {
            auto ifName = CFStringRef(CFArrayGetValueAtIndex(ifNameList, 0));
            err = Apple80211BindToInterface(Ref, ifName);
            if (err != kCWNoErr) {
                CFRelease(ifNameList);
                return fail();
            }
            IfName = CFBridgingRelease(ifName);
        }
        CFRelease(ifNameList);
        return CWErr(err);
    }
    
    bool isOpen() const noexcept {
        return Ref != nil;
    }
    
    void close() noexcept {
        Apple80211Close(Ref);
        Ref = nil;
    }
    
//MARK: - Associate
    
    CWErr associate(NSString *network, NSString *password) const noexcept {
        auto scanData = @{ @"SSID_STR" : network };
        auto scanResults = CFArrayRef{};
        auto err = Apple80211Scan(Ref, &scanResults,
                                  (__bridge CFDictionaryRef)scanData);
        if (err != kCWNoErr) return CWErr(err);
        
        auto done = [&] {
            CFRelease(scanResults);
            return CWErr(err);
        };
        
        if (CFArrayGetCount(scanResults) == 0) {
            return done();
        }
        
        auto netInfo = CFDictionaryRef(CFArrayGetValueAtIndex(scanResults, 0));
        err = Apple80211Associate(Ref, netInfo, (__bridge CFStringRef)password);
        return done();
    }
    
    CWErr createIBSSNetwork(NSString *name, int channel) const noexcept {
        auto ssidData = [name dataUsingEncoding:NSUTF8StringEncoding
                           allowLossyConversion:YES];
        if (!ssidData) return kCWInvalidParameterErr;
        auto channelFlags = APPLE80211_C_FLAG_20MHZ  | APPLE80211_C_FLAG_2GHZ
                          | APPLE80211_C_FLAG_ACTIVE | APPLE80211_C_FLAG_IBSS;
        auto ibssDict = @{
            @"SSID" : name,
            @"CHANNEL" : @(channel),
            @"CHANNEL_FLAGS" : @(channelFlags),
            @"AP_MODE_AUTH_LOWER" : @(APPLE80211_AUTHTYPE_OPEN),
            @"AP_MODE_AUTH_UPPER" : @(APPLE80211_AUTHTYPE_NONE),
            @"AP_MODE_CYPHER_TYPE" : @(APPLE80211_CIPHER_NONE),
            @"AP_MODE_PHY_MODE" : @(APPLE80211_MODE_AUTO),
            @"AP_MODE_SSID_BYTES" : ssidData,
            @"AP_MODE_KEY" : @"passkey123", //doesn't work
            @"AP_MODE_IE_LIST" : ssidData
        };
        return Apple80211Set(Ref, APPLE80211_IOC_IBSS_MODE, 1,
                             (__bridge CFTypeRef)ibssDict);
    }
    
//MARK: - State

    WiFiState status() const noexcept {
        if (!isPowerOn()) return WiFiState::Off;
        if (isIBSS()) return WiFiState::IBSS;
        if (isAssociated()) return WiFiState::Running;
        return WiFiState::Idle;
    }
    
//MARK: - Event Monitor
    
    CWErr eventMonitorInit(void *userData, CFRunLoopRef runloop,
                           Apple80211EventCallback cb) const noexcept {
        return Apple80211EventMonitoringInit(Ref, cb, userData, runloop);
    }
    
    CWErr eventMonitorHalt() const noexcept {
        return Apple80211EventMonitoringHalt(Ref);
    }
    
    CWErr eventMonitorAdd(WiFiEvent event) const noexcept {
        return Apple80211StartMonitoringEvent(Ref, uint32_t(event));
    }
    
    CWErr eventMonitorRemove(WiFiEvent event) const noexcept {
        return Apple80211StopMonitoringEvent(Ref, uint32_t(event));
    }
    
//MARK: - Scan
    
    template<typename T = void(NSArray<NSDictionary*>*)>
    CWErr scan(T respond) const noexcept {
        auto scanResults = CFArrayRef{};
        auto err = Apple80211Scan(Ref, &scanResults, nil);
        if (err != kCWNoErr) return CWErr(err);
        respond(CFBridgingRelease(scanResults));
        return kCWNoErr;
    }
    
//MARK: - IOCTL
    
    template<typename T = int32_t, typename U = void*>
    struct Req {
        uint32_t Type;
        T Value;
        U Data;
        size_t Len;
    }; // struct Req
    
    template<typename T> using ReqValue = Req<T, void*>;
    template<typename T> using ReqData = Req<int32_t, T>;
    
    template<typename T = int32_t, typename U = void*>
    int getSet(uint32_t ioc, Req<T, U> &req) const noexcept {
        auto cmd = apple80211req{};
        auto connection = socket(AF_INET, SOCK_DGRAM, 0);
        if (connection == -1) {
            perror("AE::WiFiClient::getSet() socket()");
            return kCWNotSupportedErr;
        }
        strlcpy(cmd.req_if_name, IfName.UTF8String, IFNAMSIZ);
        cmd.req_type = req.Type;
        cmd.req_val = req.Value;
        cmd.req_data = req.Data;
        cmd.req_len = static_cast<typeof(cmd.req_len)>(req.Len);
        errno = 0;
        auto ret = ioctl(connection, ioc, &cmd, sizeof(cmd));
        if (ret < 0) {
            perror("AE::WiFiClient::getSet() ioctl()");
        }
        req.Value = static_cast<T>(cmd.req_val);
        ::close(connection);
        return ret;
    }
    
    template<typename T, typename U = void*>
    int get(Req<T, U> &data) const noexcept {
        return getSet<T, U>(SIOCGA80211, data);
    }
    
    template<typename T, typename U = void*>
    int set(Req<T, U> &data) const noexcept {
        return getSet<T, U>(SIOCSA80211, data);
    }
    
    int powerState(apple80211_power_data *power) const noexcept {
        ReqData<apple80211_power_data*> data = {
            .Type = APPLE80211_IOC_POWER, .Value = 0,
            .Data = power, .Len = sizeof(apple80211_power_data)
        };
        return get(data);
    }
    
    int setPowerState(apple80211_power_data *power) const noexcept {
        ReqData<apple80211_power_data*> data = {
            .Type = APPLE80211_IOC_POWER, .Value = 0,
            .Data = power, .Len = sizeof(apple80211_power_data)
        };
        return set(data);
    }
    
    int setPowerOn(bool value) const noexcept {
        auto data = apple80211_power_data{};
        powerState(&data);
        data.version = 1;
        [&](int state) {
            for (int i = 0; i < data.num_radios; i++) {
                data.power_state[i] = state;
            }
            setPowerState(&data);
        }(value ? 1 : 0);
        return 0;
    }
    
    bool isPowerOn() const noexcept {
        auto data = apple80211_power_data{};
        powerState(&data);
        return (data.power_state[0] != 0);
    }
    
    apple80211_state state() const noexcept {
        ReqValue<apple80211_state> data = { .Type = APPLE80211_IOC_STATE };
        get(data);
        return data.Value;
    }
    
    bool isAssociated() const noexcept {
        return state() == APPLE80211_S_RUN;
    }
    
    apple80211_opmode opMode() const noexcept {
        ReqValue<apple80211_opmode> data = { .Type = APPLE80211_IOC_OP_MODE };
        get(data);
        return data.Value;
    }
    
    bool isIBSS() const noexcept {
        return opMode() == APPLE80211_M_IBSS;
    }
    
    int bssid(ether_addr *name) const noexcept {
        ReqData<ether_addr*> data = {
            .Type = APPLE80211_IOC_BSSID, .Value = 0,
            .Data = name, .Len = sizeof(ether_addr)
        };
        return get(data);
    }
    
    int disassociate() const noexcept {
        Req<> data = { .Type = APPLE80211_IOC_DISASSOCIATE };
        return set(data);
    }
}; // struct WiFiClient
} // namespace AE

[[clang::objc_direct_members]]
@implementation AERNetwork

- (instancetype)initWithScanRecord:(NSDictionary *)network {
    if (!(self = [super init])) return self;
    _ssid = [network[@"SSID_STR"] copyWithZone:nil];
    _bssid = [network[@"BSSID"] copyWithZone:nil];
    _countryCode = [&] () -> NSString * {
        auto info = (NSDictionary*)network[@"80211D_IE"];
        if (!info) return @"Unknown";
        return [info[@"IE_KEY_80211D_COUNTRY_CODE"] copyWithZone:nil];
    }();
    _rssiValue = [network[@"RSSI"] integerValue];
    _channelNumber = [network[@"CHANNEL"] integerValue];
    _isIbss = [network[@"AP_MODE"] integerValue] == 1;
    
    // lousy implementation
    _security = [&] () -> CWSecurity {
        if (network[@"WEP"]) return kCWSecurityWEP;
        auto result = kCWSecurityNone;
        if (network[@"WPA_IE"]) {
            result = kCWSecurityWPAPersonal;
        }
        if (network[@"RSN_IE"] && result == kCWSecurityWPAPersonal) {
            result = kCWSecurityWPAPersonalMixed;
        } else {
            result = kCWSecurityWPA2Personal;
        }
        return result;
    }();
    
    return self;
}

@end

@implementation AERWiFiClient {
    AE::WiFiClient _client;
}

- (nullable instancetype)initWithErrorHandler:(void(^)(NSError*))handler {
    if (!(self = [super init])) return self;
    auto err = _client.open();
    auto fail = [&](CWErr code) {
        _client.close();
        return AERWiFiClientError(code, handler);
    };
    
    if (err != kCWNoErr) return AERWiFiClientError(err, handler);
    
    err = _client.eventMonitorInit((__bridge void*)self, CFRunLoopGetMain(),
    [](CWErr e, Apple80211Ref ref, uint32_t event,
       void*, uint32_t, void *ctx) {
        __unsafe_unretained auto uself = (__bridge AERWiFiClient*)ctx;
        switch (AE::WiFiEvent(event)) {
        case AE::WiFiEvent::Power:
            uself->_onPowerStateChange();
            break;
            
        case AE::WiFiEvent::SSID:
            uself->_onSSIDChange();
            break;
            
        default:
            break;
        }
    }); // eventMonitorInit
    if (err != kCWNoErr) return fail(err);
    
    err = _client.eventMonitorAdd(AE::WiFiEvent::Power);
    if (err != kCWNoErr) return fail(err);
    self.onPowerStateChange = nil;
    
    err = _client.eventMonitorAdd(AE::WiFiEvent::SSID);
    if (err != kCWNoErr) return fail(err);
    self.onSSIDChange = nil;
    
    return self;
}

- (nullable instancetype)init {
    auto const funcName = __PRETTY_FUNCTION__;
    return [self initWithErrorHandler:^(NSError *error) {
        NSLog(@"%s : %@", funcName, error);
    }];
}

- (void)dealloc {
    _client.close();
}

- (nullable NSArray<AERNetwork*>*)scan {
    return [self scanForNetworksWithName:nil];
}

- (nullable NSArray<AERNetwork*>*)
    scanForNetworksWithName:(nullable NSString*)name {
    auto const funcName = __PRETTY_FUNCTION__;
    return [self scanForNetworksWithName:nil error:^(NSError *error) {
        NSLog(@"%s : %@", funcName, error);
    }];
}

- (nullable NSArray<AERNetwork*>*)
    scanForNetworksWithName:(nullable NSString*)name
                      error:(void(^)(NSError *error))errorHandler {
    auto result = [NSMutableArray new];
    auto err = _client.scan([&](NSArray<NSDictionary*>*items) {
        auto forEach = [&](auto task) {
            for (NSDictionary<NSString*, id> *item in items) {
                @autoreleasepool { task(item); }
            }
        };
        
        auto addNetwork = [&](const auto &scanRecord) {
            [result addObject:[[AERNetwork alloc]
                               initWithScanRecord:scanRecord]];
        };
        
        if (name) {
            forEach([&](const auto &item){
                if ([item[@"SSID_STR"] isEqualToString:name]) {
                    addNetwork(item);
                }
            });
        } else {
            forEach([&](const auto &item){
                addNetwork(item);
            });
        }
    }); // scan()
    
    if (err != kCWNoErr) return AERWiFiClientError(err, errorHandler);
    return result;
}

//MARK: - Properties

- (AE::WiFiState)state {
    return _client.status();
}

- (BOOL)isPowerOn {
    return _client.isPowerOn();
}

- (void)setOnPowerStateChange:(AERWiFiClientEventHandler)block {
    _onPowerStateChange = block ? [block copy] : id(^{});
}

- (void)setOnSSIDChange:(AERWiFiClientEventHandler)block {
    _onSSIDChange = block ? [block copy] : id(^{});
}

//MARK: - Private

namespace {
template<typename T, typename Fn> _Nullable id
AERWiFiClientError(const T &code, const Fn &handler) noexcept {
    auto domain = code < 0 ? CWErrorDomain : NSPOSIXErrorDomain;
    auto e = [[NSError alloc] initWithDomain:domain code:code userInfo:nil];
    handler(e);
    return nil;
}
} // anonymous namespace

@end
