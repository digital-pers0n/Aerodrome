//
//  NSDictionary+AERNetwork.m
//  Aerodrome
//
//  Created by Terminator on 8/24/16.
//
//

#import "NSDictionary+AERNetwork.h"
#import <CoreWLAN/CoreWLANTypes.h>

@implementation NSDictionary (AERNetwork)

-(NSString *)ssid
{
    return [self objectForKey:@"SSID_STR"];
}

-(NSData *)ssidData
{
    return [self objectForKey:@"SSID"];
}

-(NSString *)bssid
{
    return [self objectForKey:@"BSSID"];
    
}



-(int)securityType
{
    int result = kCWSecurityNone;
    
    if (self[@"WPA_IE"]) {
    
        result = kCWSecurityWPAPersonal;
        
    }
    
    if (self[@"RSN_IE"]) {
        
        if (result == kCWSecurityWPAPersonal) {
            
            result = kCWSecurityWPAPersonalMixed;
            
        } else {
            
              result = kCWSecurityWPA2Personal;
        
        }
    
      }
    
    if (self[@"WEP"]) {
        
        result = kCWSecurityWEP;
        
    }
    
    return result;
}

-(NSString *)securityString
{
    switch ([self securityType]) {
        case kCWSecurityWPAPersonal:
            return @"WPA";
            break;
            
        case kCWSecurityWPAPersonalMixed:
            return @"WPA / WPA2";
            break;
            
        case kCWSecurityWPA2Personal:
            return @"WPA2";
            break;
            
        case kCWSecurityWEP:
            return @"WEP";
            break;
            
        case kCWSecurityNone:
            return @"Open";
            break;
            
        default:
            break;
    }
    return @"Unknown";
}

-(nullable NSString *)countryCode
{
    NSString *result;
    id data = [self objectForKey:@"80211D_IE"];
    if (data) {
        result = [data objectForKey:@"IE_KEY_80211D_COUNTRY_CODE"];
    }
    
    return result;
}

-(BOOL)isIBSS
{
    int  ap_mode = [[self objectForKey:@"AP_MODE"] intValue];
    
    return (ap_mode == 1) ? YES : NO;
}

-(int)channel
{
    return [[self objectForKey:@"CHANNEL"] intValue];
}

-(int)rssiValue
{
    return [[self objectForKey:@"RSSI"] intValue];
}

-(int)noiseMeasurement
{
    return [[self objectForKey:@"NOISE"] intValue];
}


@end
