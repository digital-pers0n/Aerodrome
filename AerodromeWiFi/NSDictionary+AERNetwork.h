//
//  NSDictionary+AERNetwork.h
//  Aerodrome
//
//  Created by Terminator on 8/24/16.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (AERNetwork)

-(NSString *)ssid;
-(NSString *)bssid;
-(NSData *)ssidData;

-(int)rssiValue;
-(int)noiseMeasurement;
-(int)channel;

-(NSString *)countryCode;
-(BOOL)isIBSS;

-(int)securityType;
-(NSString *)securityString;

@end
