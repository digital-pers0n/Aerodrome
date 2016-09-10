//
//  AERWLNetwork.m
//  Aerodrome
//
//  Created by Terminator on 8/22/16.
//
//

#import "AERWLNetwork.h"
#import <CoreWLAN/CoreWLANTypes.h>
#import <sys/ioctl.h>
#import "apple80211_ioctl.h"
#import "apple80211_var.h"

#define APPLE80211_DEFAULT_CHANNEL 11

char *error_to_string(int err);

@implementation AERWLNetwork

+ (id)connection
{
    static dispatch_once_t onceToken;
    static AERWLNetwork *obj;
    dispatch_once(&onceToken, ^{
        
        obj = [AERWLNetwork new];
        
        [obj apple80211Interface];
        
        
    });
    
    return obj;
}

- (NSString *)apple80211Interface
{
    long			count;
    int             error;
    CFArrayRef		if_name_list;
    CFStringRef     if_name = NULL;
    Apple80211Ref	wref;
    
    
    error = Apple80211Open(&wref);
    if (error != kCWNoErr) {
        
        
        fprintf(stderr, "Apple80211Open failed, %x %s\n", error, error_to_string(error));
        
        return (NULL);
    }
    error = Apple80211GetIfListCopy(wref, &if_name_list);
    if (error != kCWNoErr) {
        fprintf(stderr, "Apple80211GetIfListCopy failed, %x %s\n", error, error_to_string(error));
        
        goto done;
    }
    count = CFArrayGetCount(if_name_list);
    if (count > 0) {
        
        
        if_name = CFArrayGetValueAtIndex(if_name_list, 0);
        //CFShow(if_name);
        error = Apple80211BindToInterface(wref, if_name);
        if (error != kCWNoErr) {
            fprintf(stderr, "Apple80211BindToInterface failed, %x %s\n",
                    error, error_to_string(error));
            
        }
        else {
            //ret_name = CFStringGetCStringPtr(if_name, kCFStringEncodingASCII);
            
            
            
        }
    }
    
    
    
    
done:
    if (if_name == NULL) {
        Apple80211Close(wref);
        ref = NULL;
    }
    else {
        
        ref = wref;
        interface = CFBridgingRelease(if_name);
        //g_if_name = (char *)[interface UTF8String];
    }
    
    if (if_name_list != NULL) {
        
        CFRelease(if_name_list);
    }
    
    
    
    return (interface);
}

#pragma mark - old methods

- (int)joinNetworkWithName:(NSString *)network andPassword:(NSString *)pass
{
    Apple80211Disassociate(ref);
    
    int           error;
    CFMutableDictionaryRef  scan_args = NULL;
    CFArrayRef              scan_result = NULL;
    CFStringRef             ssid_str;
    
    CFDataRef               ssid;
    CFStringRef             password;
    
    if ([pass length] > 0) {
        
        password = CFBridgingRetain(pass);
    } else {
        password = NULL;
    }
    
    ssid = CFDataCreateWithBytesNoCopy(NULL, (const UInt8 *)[network UTF8String],
                                       strlen([network UTF8String]), kCFAllocatorNull);
    
    ssid_str = CFStringCreateWithBytes(NULL, CFDataGetBytePtr(ssid), CFDataGetLength(ssid), kCFStringEncodingUTF8, FALSE);
    
    scan_args = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFDictionarySetValue(scan_args, CFSTR("SSID_STR"), ssid_str);
    CFRelease(ssid_str);
    error = Apple80211Scan(ref, &scan_result, scan_args);
    CFRelease(scan_args);
    //CFShow(scan_result);
    if (error != kCWNoErr){
        fprintf(stderr, "Apple80211Scan failed, %d %s\n", error, error_to_string(error));
        
        if (password != NULL) {
            CFRelease(password);
        }
        
        CFRelease(ssid);
        return (error);
    }
    
    if (CFArrayGetCount(scan_result) == 0) {
        fprintf(stderr, "network not found\n");
        
        if (password != NULL) {
            CFRelease(password);
        }
        CFRelease(ssid);
        
        return (404);
    }
    
    if (CFArrayGetCount(scan_result) > 0){
        CFDictionaryRef scan_dict;
        scan_dict = CFArrayGetValueAtIndex(scan_result, 0);
        
        
        error = Apple80211Associate(ref, scan_dict, password);
        //CFShow(scan_dict);
        
        
        if(error != kCWNoErr) {
           // fprintf(stderr, "Apple80211Associate failed, %d %s\n", error, error_to_string(error));
            
            if (password != NULL) {
                CFRelease(password);
            }
            
            CFRelease(ssid);
            return (error);
        }
    }
    if (scan_result != NULL){
        CFRelease(scan_result);
    }
    
    if (password != NULL) {
        CFRelease(password);
    }
    
    CFRelease(ssid);
    
    return error;
}

- (int)createIBSSNetworkWithName:(NSString *)name andChannel:(int)channel
{
    Apple80211Disassociate(ref);
    int default_channel = APPLE80211_DEFAULT_CHANNEL;
    const char * network = [name UTF8String];
    if (channel > 0) {
        default_channel = channel;
    }
    int error;
    CFStringRef Keys[10];
    void *Values[10];
    CFStringRef ssid =  CFStringCreateWithCString(kCFAllocatorDefault, network, kCFStringEncodingUTF8);
    
    int
    auth_low = APPLE80211_AUTHTYPE_OPEN,
    auth_up = APPLE80211_AUTHTYPE_NONE,
    chan = default_channel,
    chan_flag = 138,
    ciph = APPLE80211_CIPHER_NONE,
    phy_mode = APPLE80211_MODE_AUTO;
    //char *key = "1234567890";
    
    Keys[0] = CFSTR("AP_MODE_AUTH_LOWER");  Values[0] = (void *)CFNumberCreate(kCFAllocatorDefault, 9, &auth_low);
    Keys[1] = CFSTR("AP_MODE_AUTH_UPPER");  Values[1] = (void *)CFNumberCreate(kCFAllocatorDefault, 9, &auth_up);
    Keys[2] = CFSTR("CHANNEL");             Values[2] = (void *)CFNumberCreate(kCFAllocatorDefault, 9, &chan);
    Keys[3] = CFSTR("CHANNEL_FLAGS");       Values[3] = (void *)CFNumberCreate(kCFAllocatorDefault, 9, &chan_flag);
    Keys[4] = CFSTR("AP_MODE_CYPHER_TYPE"); Values[4] = (void *)CFNumberCreate(kCFAllocatorDefault, 9, &ciph);
    Keys[5] = CFSTR("SSID");                Values[5] = (void *)ssid;
    Keys[6]= CFSTR("AP_MODE_PHY_MODE");     Values[6] = (void *)CFNumberCreate(kCFAllocatorDefault, 9, &phy_mode);
    
    Keys[7] = CFSTR("AP_MODE_SSID_BYTES");  Values[7] = (void *)CFDataCreateWithBytesNoCopy(NULL, (const UInt8 *)network, strlen(network), kCFAllocatorNull);
    Keys[8] = CFSTR("AP_MODE_KEY");         Values[8] = (void *)CFSTR("passkey123"); //Doesn't work
    Keys[9] = CFSTR("AP_MODE_IE_LIST");     Values[9] = (void *)CFDataCreateWithBytesNoCopy(NULL, (const UInt8 *)network, strlen(network), kCFAllocatorNull);
    
    CFDictionaryRef ibssmode_dict = CFDictionaryCreate(kCFAllocatorDefault,
                                                       (void *)&Keys,
                                                       (void *)&Values,
                                                       10,
                                                       &kCFTypeDictionaryKeyCallBacks,
                                                       &kCFTypeDictionaryValueCallBacks);
    
    
    error = Apple80211Set(ref, APPLE80211_IOC_IBSS_MODE, 1, ibssmode_dict);
    
    if (error != kCWNoErr) {
        printf("Failed to create network, Error %i %s\n", error, error_to_string(error));
        
        return (error);
    }
    
    CFRelease(ibssmode_dict);
    return (error);
    
}
-(NSArray *)cachedNetworks
{
    self->_cachedNetworksList = [self scanForNetworks];
    //    NSArray * net = [self scanForNetworks];
    //
    //    if ([net isEqualToArray:_cachedNetworksList]) {
    //        net = [self scanForNetworks];
    //    }
    return self->_cachedNetworksList;
}

- (NSArray *)scanForNetworks
{
    CFArrayRef              scan;
    //    CFDictionaryRef         buffer;
    //    CFMutableArrayRef       result;
    //    CFMutableDictionaryRef  network;
    int           error;
    long                    count = 0;
    
    
    
    
    error = Apple80211Scan(ref, &scan, NULL);
    
    if (error != kCWNoErr) {
        printf("Scan error! %i %s\n", error, error_to_string(error));
        return FALSE;
    }
    
    count = CFArrayGetCount(scan);
    
    
    if (count == 0) {
        printf("no networks found\n");
        return FALSE;
    }
    
    
    
    
    
    
    //NSArray *nsscan = CFBridgingRelease(scan);
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSDictionary *a in (__bridge NSArray *)scan)
    {
        [dict setValue:[a valueForKey:@"SSID_STR"] forKey:@"SSID"];
        [dict setValue:[a valueForKey:@"RSSI"] forKey:@"RSSI"];
        [dict setValue:[a valueForKey:@"NOISE"] forKey:@"NOISE"];
        [dict setValue:[a valueForKey:@"BSSID"] forKey:@"BSSID"];
        [dict setValue:[a valueForKey:@"CHANNEL"] forKey:@"CHANNEL"];
        [dict setValue:[a valueForKey:@"AP_MODE"] forKey:@"AP_MODE"];
        
        if (a[@"WPA_IE"]) {
            [dict setValue:@"WPA" forKey:@"SECURITY"];
        } else if (a[@"RSN_IE"]) {
            [dict setValue:@"WPA2" forKey:@"SECURITY"];
        } else if (a[@"WEP"]) {
            [dict setValue:@"WEP" forKey:@"SECURITY"];
        } else {
            [dict setValue:@"Open" forKey:@"SECURITY"];
        }
        
        [array addObject:[dict copy]];
        
    }
    
    //    CFRelease(scan);
    //    CFRelease(network);
    
    
    return [NSArray arrayWithArray:array];
    //return CFBridgingRelease(result);
    
}

#pragma mark - new methods

-(int)associateWithNetworkName:(NSString *)network andPassword:(nullable NSString *)pass
{
    Apple80211Disassociate(ref);
    
    int           error = 0;

    
    //CFDataRef               ssid;
    CFStringRef             password;
    
    if (pass || [pass length] > 0) {
        
        password = CFBridgingRetain(pass);
    } else {
        password = NULL;
    }
    
//    for (NSDictionary *a in self->_rawScanList) {
//        if ([[a objectForKey:@"SSID_STR"] isEqualToString:network]) {
//             error = Apple80211Associate(ref, CFBridgingRetain(a), password);
//            
//            CFRelease(password);
//            
//            return error;
//        }
//    }
    
   NSArray * result =  [self scanForNetworkWithName:network];
    
    if (result) {
        
        
        if ([result count] > 1) {
            for (NSDictionary *a in result) {
                error = Apple80211Associate(ref, (__bridge CFDictionaryRef)(a), password);
                if (error == kCWNoErr) {
                    
                    if (password) {
                        CFRelease(password);
                    }
                    
                    return error;
                }
            }
       
            if (password) {
                CFRelease(password);
            }
            return error;
        }
        
        if ([result count] == 0) {
            return -3900;
        }
        
        error = Apple80211Associate(ref, (__bridge CFDictionaryRef)([result firstObject]), password);
        if (password) {
            CFRelease(password);
            
        }
        
         return error;
        
        
    }
    
    if (password) {
        CFRelease(password);
    }

    
    return error;

}

-(int)associateWithNetworkData:(NSDictionary *)networkDictionary andPassword:(nullable NSString *)pass

{
    
    if (!networkDictionary) {
        return kCWInvalidParameterErr;
    }
    
    Apple80211Disassociate(ref);
    
    int           error;
    CFDictionaryRef               scan_dict;
    CFStringRef             password = NULL;
    
    scan_dict = CFBridgingRetain(networkDictionary);
    
    if (pass) {
        password = CFBridgingRetain(pass);
    }
    
    error = Apple80211Associate(ref, scan_dict, password);
    
        if (password != NULL) {
            CFRelease(password);
        }
        
        CFRelease(scan_dict);
        return (error);
    
    
    
}

-(NSArray <NSDictionary *> *)scanForNetworkWithName:(nullable NSString *)networkName
{
    int           error;
    CFMutableDictionaryRef  scan_args = NULL;
    CFArrayRef              scan_result = NULL;
    CFStringRef             ssid_str;
    CFDataRef               ssid = NULL;

    

    if (networkName) {
        
        ssid = CFDataCreateWithBytesNoCopy(NULL, (const UInt8 *)[networkName UTF8String],
                                           strlen([networkName UTF8String]), kCFAllocatorNull);
        
        ssid_str = CFStringCreateWithBytes(NULL, CFDataGetBytePtr(ssid), CFDataGetLength(ssid), kCFStringEncodingUTF8, FALSE);
        
        scan_args = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        CFDictionarySetValue(scan_args, CFSTR("SSID_STR"), ssid_str);
        CFRelease(ssid_str);
        error = Apple80211Scan(ref, &scan_result, scan_args);
        CFRelease(scan_args);
        
    } else {
        
        error = Apple80211Scan(ref, &scan_result, NULL);
    }
    

    if (error != kCWNoErr){
        fprintf(stderr, "Apple80211Scan failed, %d %s\n", error, error_to_string(error));
        if (ssid) {
             CFRelease(ssid);
        }
       
        return nil;
      
    }
    
    if (CFArrayGetCount(scan_result) == 0) {
        fprintf(stderr, "network not found\n");
        
        if (ssid) {
            CFRelease(ssid);
        }
        
        return (__bridge NSArray *)(scan_result);
        
    }
    
    
    if (ssid) {
        CFRelease(ssid);
    }
    
    self->_rawScanList = (__bridge NSArray *)(scan_result);
    
    return self->_rawScanList;

    
}

-(nullable NSString *)securityString:(CWSecurity)code
{
    switch (code) {
        case kCWSecurityNone:
            return @"Open";
            break;
        case kCWSecurityWPA2Personal:
            return @"WPA2";
            break;
        case kCWSecurityWPAPersonalMixed:
            return @"WPA / WPA2";
            break;
        case kCWSecurityWPAPersonal:
            return @"WPA";
            break;
        case kCWSecurityWEP:
            return @"WEP";
            break;
            
        default:
            break;
    }
    
    return nil;
}

#pragma mark - errors

- (NSString *)AERWLError:(NSString *)errorText code:(int)error
{
    
    //    alert = [[NSAlert alloc] init];
    //
    //
    //    if (alert) {
    //
    //        [alert setMessageText:errorText];
    //        [alert setInformativeText:[NSString stringWithFormat:@"%i, %s", error, error_to_string(error)]];
    //        [alert setIcon:[NSImage imageNamed:NSImageNameCaution]];
    //
    //
    //    }
    
    return [NSString stringWithFormat:@"%@ : %i %s", errorText, error, error_to_string(error)];
}

-(void)dealloc
{
    Apple80211Close(ref);
}


@end

char *error_to_string(int error)
{
    
    switch (error) {
        case kCWNoErr:
            return "Success";
            break;
            
        case kCWEAPOLErr:
            return "EAPOL-Related error";
            break;
        case kCWInvalidParameterErr:
            return "Parameter error";
            break;
        case kCWNoMemoryErr:
            return "Memory allocation failed";
            
            break;
        case kCWUnknownErr:
            return "Unexpected error condition encountered";
            break;
        case kCWNotSupportedErr:
            return "Operation not supported";
            break;
        case kCWInvalidFormatErr:
            return "Invalid protocol element field detected";
            break;
        case kCWTimeoutErr:
            return "Operation timeout";
            break;
        case kCWUnspecifiedFailureErr:
            return "Access point did not specify a reason for authentication/association";
            break;
        case kCWUnsupportedCapabilitiesErr:
            return "Access point cannot support all requested capabilities";
            break;
        case kCWReassociationDeniedErr:
            return "Reassociation was denied because the access point was unable to determine that an association exists";
            break;
        case kCWAssociationDeniedErr:
            return "Association was denied for an unspecified reason";
            break;
        case kCWAuthenticationAlgorithmUnsupportedErr:
            return "Specified authentication algorithm is not supported";
            break;
        case kCWInvalidAuthenticationSequenceNumberErr:
            return "Authentication frame with an authentication sequence number out of expected sequence";
            break;
        case kCWChallengeFailureErr:
            return "Authentication was rejected because of a challenge failure";
            break;
        case kCWAPFullErr:
            return "Access point is unable to handle another associated station";
            break;
        case kCWUnsupportedRateSetErr:
            return "Interface does not support all of the rates in the basic rate set of the access point";
            break;
        case kCWShortSlotUnsupportedErr:
            return "Association denied because short slot time option is not supported by requesting station";
            break;
        case kCWDSSSOFDMUnsupportedErr:
            return "Association denied because DSSS-OFDM is not supported by requesting station";
            break;
            
        case kCWInvalidInformationElementErr:
            return "Invalid information element included in association request";
            break;
        case kCWInvalidGroupCipherErr:
            return "Invalid group cipher requested";
            break;
        case kCWInvalidPairwiseCipherErr:
            return "Invalid pairwise cipher requested";
            break;
        case kCWInvalidAKMPErr:
            return "Invalid authentication selector requested";
            break;
        case kCWUnsupportedRSNVersionErr:
            return "Invalid WPA/WPA2 version specified";
            break;
        case kCWInvalidRSNCapabilitiesErr:
            return "Invalid RSN capabilities specified in association request";
            break;
        case kCWCipherKeyFlagsMulticast:
            return "Cipher suite rejected due to network security policy";
            break;
        case kCWInvalidPMKErr:
            return "PMK rejected by the access point";
            break;
        case kCWSupplicantTimeoutErr:
            return "WPA/WPA2 hadshake timed out";
            break;
        case kCWHTFeaturesNotSupportedErr:
            return "Association was denied because the requesting station does not support HT features";
            break;
        case kCWPCOTransitionTimeNotSupportedErr:
            return "Association was denied because the requesting station does not support the PCO trasition time required by the AP";
            break;
        case kCWReferenceNotBoundErr:
            return "No interface bound to the network object";
            break;
        case kCWIPCFailureErr:
            return "Error communicating with a separate process";
            break;
        case kCWOperationNotPermittedErr:
            return "Calling process does not have permission to perform this operation";
            break;
        case kCWErr:
            return "Generic Error";
            break;
            
        default:
            //return Apple80211ErrToStr(error);
            break;
    }
    
    return Apple80211ErrToStr(error);
}

