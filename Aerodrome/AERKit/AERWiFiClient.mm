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

- (nullable instancetype)initWithErrorHandler:(void(^)(NSError *error))handler {
    if (!(self = [super init])) return self;
    auto err = _client.open();
    if (err != kCWNoErr) {
        auto errDomain = err < 0 ? CWErrorDoamin : NSPOSIXErrorDomain;
        auto e = [[NSError alloc] initWithDomain:errDomain
                                            code:err userInfo:nil];
        handler(e);
        return nil;
    }
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

@end
