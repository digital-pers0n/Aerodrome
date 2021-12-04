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
        if (connection == -1) return kCWNotSupportedErr;
        strlcpy(cmd.req_if_name, IfName.UTF8String, IFNAMSIZ);
        cmd.req_type = req.Type;
        cmd.req_val = req.Value;
        cmd.req_data = req.Data;
        cmd.req_len = static_cast<typeof(cmd.req_len)>(req.Len);
        errno = 0;
        auto ret = ioctl(connection, ioc, &cmd, sizeof(cmd));
        if (ret < 0) {
            perror("AE::WiFiClient::getSet()");
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
    
    int powerState(apple80211_power_data *data) const noexcept {
        return get(APPLE80211_IOC_POWER, nil, data, sizeof(*data));
    }
    
    int setPowerState(apple80211_power_data *data) const noexcept {
        return set(APPLE80211_IOC_POWER, nil, data, sizeof(*data));
    }
    
    int setPowerState(bool value) const noexcept {
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
    
    bool isOn() const noexcept {
        auto data = apple80211_power_data{};
        powerState(&data);
        return (data.power_state[0] != 0);
    }
}; // struct WiFiClient
} // namespace AE

[[clang::objc_direct_members]]
@implementation AERNetwork

- (instancetype)initWithSSID:(NSString *)networkName
                       BSSID:(NSString *)bssidName
                        RSSI:(NSInteger)rssiValue
                     channel:(NSInteger)channelNumber
                      isIBSS:(BOOL)isIbss
{
    if (!(self = [super init])) return self;
    _ssid = [networkName copyWithZone:nil];
    _bssid = [bssidName copyWithZone:nil];
    _rssiValue = rssiValue;
    _channelNumber = channelNumber;
    _isIbss = isIbss;
    return self;
}

@end

@implementation AERWiFiClient

@end
