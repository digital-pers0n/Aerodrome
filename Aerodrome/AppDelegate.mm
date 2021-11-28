//
//  AppDelegate.mm
//  Aerodrome
//
//  Created by Maxim M. on 11/13/21.
//

#import "AppDelegate.h"
#import "Apple80211.h"
#import <CoreWLAN/CoreWLAN.h>
#import <sys/ioctl.h>

@interface AppDelegate ()
@end

namespace AE {
struct WiFiClient {
    Apple80211Ref Ref;
    NSString *IfName;
    
    WiFiClient(const WiFiClient &) = delete;
    WiFiClient operator=(const WiFiClient &) = delete;
    
    WiFiClient() {};
    ~WiFiClient() {};
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
    
    template<typename T = void(NSArray<NSDictonary*>*)>
    CWErr scan(T respond) const noexcept {
        auto scanResults = CFArrayRef{};
        auto err = Apple80211Scan(Ref, &scanResults, nil);
        if (err != kCWNoErr) return CWErr(err);
        respond(CFBridgingRelease(scanResults));
        return kCWNoErr;
    }
    
    int getSet(uint32_t ioc, uint32_t type,
               uint32_t *valuep, void *data, size_t lenght) const noexcept {
        auto cmd = apple80211req{};
        auto connection = socket(AF_INET, SOCK_DGRAM, 0);
        if (connection == -1) return kCWNotSupportedErr;
        
        strlcpy(cmd.req_if_name, IfName.UTF8String, IFNAMSIZ);
        cmd.req_type = type;
        cmd.req_val = valuep ? *valuep : 0;
        cmd.req_len = static_cast<typeof(cmd.req_len)>(lenght);
        cmd.req_data = data;
        errno = 0;
        auto ret = ioctl(connection, ioc, &cmd, sizeof(cmd));
        if (ret < 0) {
            perror("AE::WiFiClient::getSet()");
        }
        if (valuep) {
            *valuep = cmd.req_val;
        }
        ::close(connection);
        return ret;
    }
    
    
}; // struct WiFiClient
} // namespace AE

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    auto wifi = AE::WiFiClient();
    if (wifi.open() != kCWNoErr) {
        NSLog(@"Cannot open WiFi connection");
        return;
    }
    wifi.scan([](NSArray *networks){
        NSLog(@"%@", networks);
    });
    
    auto data = apple80211_sup_channel_data{};
    wifi.getSet(SIOCGA80211, APPLE80211_IOC_SUPPORTED_CHANNELS, {},
                &data, sizeof(data));
    for (const auto &value : data.supported_channels) {
        if (value.channel == 0) continue;
        printf("%u ", value.channel);
    }
    
    auto err = wifi.associate(@"Loonatic", @"48728973");
    if (err != kCWNoErr) {
        puts(Apple80211ErrToStr(err));
    }
    
    wifi.close();
    
    [NSApp terminate:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
