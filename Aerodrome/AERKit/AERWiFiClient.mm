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

namespace CF {
template<typename T = CFTypeRef>
struct Scope {
    T Ref {};
    Scope(T obj) : Ref{obj} {}
    ~Scope() {
        if (!Ref) return;
        CFRelease(Ref);
        Ref = nil;
    }
}; // struct Scope
} // namespace CF

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
