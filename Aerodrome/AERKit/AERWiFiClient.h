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

@end

@interface AERWiFiClient : NSObject
- (nullable instancetype)initWithErrorHandler:(void(^)(NSError *error))handler;
@end

NS_ASSUME_NONNULL_END
