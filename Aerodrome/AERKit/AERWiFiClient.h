//
//  AERWiFiManager.h
//  Aerodrome
//
//  Created by Maxim M. on 11/18/21.
//

#import <Foundation/Foundation.h>
#import <CoreWLAN/CoreWLAN.h>

NS_ASSUME_NONNULL_BEGIN


@interface AERNetwork : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (readonly, nonatomic) NSString *ssid;
@property (readonly, nonatomic) NSString *bssid;
@property (readonly, nonatomic) NSInteger rssiValue;
@property (readonly, nonatomic) NSInteger channelNumber;
@property (readonly, nonatomic) BOOL isIbss;
@property (readonly, nonatomic, nullable) NSString *countryCode;
@property (readonly, nonatomic) CWSecurity security;
@property (readonly, nonatomic) NSDictionary *scanRecord;

@end

using AERWiFiClientEventHandler = void(^)(void);

namespace AE {
enum struct WiFiState { Off, Idle, IBSS, Running };
}

@interface AERWiFiClient : NSObject

@property (nonatomic, direct, getter=isPowerOn) BOOL powerOn;
@property (nonatomic, readonly, direct) AE::WiFiState state;
@property (nonatomic, readonly, direct) NSString *ssidName;

- (nullable instancetype)initWithErrorHandler:(void(^)(NSError *error))handler;
@property (nonatomic, copy, null_resettable, direct)
    AERWiFiClientEventHandler onPowerStateChange;
@property (nonatomic, copy, null_resettable, direct)
    AERWiFiClientEventHandler onSSIDChange;

@end

@interface AERWiFiClient (AERWiFiScan)
- (nullable NSArray<AERNetwork*>*)
    scanForNetworksWithName:(nullable NSString*)name
                      error:(void(^)(NSError *error))errorHandler;
- (nullable NSArray<AERNetwork*>*)
    scanForNetworksWithName:(nullable NSString*)name;
- (nullable NSArray<AERNetwork*>*)scan;
@end

@interface AERWiFiClient (AERWiFiAssociate)
- (void)disassociate;
- (BOOL)associateToNetwork:(AERNetwork *)network password:(NSString *)pass
                     error:(void(^)(NSError *error))handler;
@end

@interface AERWiFiClient (AERWiFiIBSS)
- (BOOL)startIBSSModeWithName:(NSString *)name channel:(NSInteger)channel
                        error:(void(^)(NSError *error))handler;
@end

@interface AERWiFiClient (AERWiFiChannels)
@property (nonatomic, readonly) NSArray<NSNumber*> *channels;
@end

NS_ASSUME_NONNULL_END
