//
//  AERNetwork.m
//  Aerodrome
//
//  Created by Terminator on 8/2/16.
//
//

#import "AERNetwork.h"
#import <sys/ioctl.h>

#define APPLE80211_DEFAULT_CHANNEL 11


@implementation AERNetwork




@synthesize interface;

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//       interface  = [self apple80211Interface];
//    }
//    return self;
//}

#pragma mark - Airport.framework/Apple80211.framework functions

+ (AERNetwork *)connection
{
    static dispatch_once_t onceToken;
    static AERNetwork *obj;
dispatch_once(&onceToken, ^{
    
    obj = [AERNetwork new];
    
    [obj apple80211Interface];
    
});
    
    return obj;
}

- (NSString *)apple80211Interface
{
    long			count;
    Apple80211Err	error;
    CFArrayRef		if_name_list;
    CFStringRef     if_name = NULL;
    Apple80211Ref	wref;
    
    
    error = Apple80211Open(&wref);
    if (error != kA11NoErr) {
        fprintf(stderr, "Apple80211Open failed, %x %s\n", error, Apple80211ErrToStr(error));
        
        return (NULL);
    }
    error = Apple80211GetIfListCopy(wref, &if_name_list);
    if (error != kA11NoErr) {
        fprintf(stderr, "Apple80211GetIfListCopy failed, %x %s\n", error, Apple80211ErrToStr(error));
        
        goto done;
    }
    count = CFArrayGetCount(if_name_list);
    if (count > 0) {
        
        
        if_name = CFArrayGetValueAtIndex(if_name_list, 0);
        //CFShow(if_name);
        error = Apple80211BindToInterface(wref, if_name);
        if (error != kA11NoErr) {
            fprintf(stderr, "Apple80211BindToInterface failed, %x %s\n",
                    error, Apple80211ErrToStr(error));
            
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

- (int)disassociateFromNetwork
{
    Apple80211Err error;
    error = Apple80211Disassociate(ref);
    if (error != kA11NoErr){
        fprintf(stderr, "Disassociate failed %x %s\n", error , Apple80211ErrToStr(error));
        
        return error;
    }
    //printf("Disassociated\n");
    return error;
}

- (int)joinNetworkWithName:(NSString *)network andPassword:(NSString *)pass
{
    Apple80211Err           error;
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
    if (error != kA11NoErr){
        fprintf(stderr, "Apple80211Scan failed, %d %s\n", error, Apple80211ErrToStr(error));
        
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
        
        
        if(error != kA11NoErr) {
            fprintf(stderr, "Apple80211Associate failed, %d %s\n", error, Apple80211ErrToStr(error));
            
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
    int default_channel = APPLE80211_DEFAULT_CHANNEL;
    const char * network = [name UTF8String];
    if (channel > 0) {
        default_channel = channel;
    }
    Apple80211Err error;
    CFStringRef Keys[10];
    void *Values[10];
    CFStringRef ssid =  CFStringCreateWithCString(kCFAllocatorDefault, network, kCFStringEncodingUTF8);
    
    int
    auth_low = APPLE80211_AUTHTYPE_SHARED,
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
    
    if (error != kA11NoErr) {
        printf("Failed to create network, Error %i %s\n", error, Apple80211ErrToStr(error));
        
        return (error);
    }
    
    CFRelease(ibssmode_dict);
    return (error);
    
}

- (NSString *)fixBSSID:(NSString *)bssid{
    
    bssid = [bssid stringByReplacingOccurrencesOfString:@":0:" withString:@":00:"];
    bssid = [bssid stringByReplacingOccurrencesOfString:@":1:" withString:@":01:"];
    bssid = [bssid stringByReplacingOccurrencesOfString:@":2:" withString:@":02:"];
    bssid = [bssid stringByReplacingOccurrencesOfString:@":3:" withString:@":03:"];
    bssid = [bssid stringByReplacingOccurrencesOfString:@":4:" withString:@":04:"];
    bssid = [bssid stringByReplacingOccurrencesOfString:@":5:" withString:@":05:"];
    bssid = [bssid stringByReplacingOccurrencesOfString:@":6:" withString:@":06:"];
    bssid = [bssid stringByReplacingOccurrencesOfString:@":7:" withString:@":07:"];
    bssid = [bssid stringByReplacingOccurrencesOfString:@":8:" withString:@":08:"];
    bssid = [bssid stringByReplacingOccurrencesOfString:@":9:" withString:@":09:"];
    bssid = [bssid stringByReplacingOccurrencesOfString:@":a:" withString:@":0a:"];
    bssid = [bssid stringByReplacingOccurrencesOfString:@":b:" withString:@":0b:"];
    bssid = [bssid stringByReplacingOccurrencesOfString:@":c:" withString:@":0c:"];
    bssid = [bssid stringByReplacingOccurrencesOfString:@":d:" withString:@":0d:"];
    bssid = [bssid stringByReplacingOccurrencesOfString:@":e:" withString:@":0e:"];
    bssid = [bssid stringByReplacingOccurrencesOfString:@":f:" withString:@":0f:"];
    
    return bssid;
    
}

- (NSArray *)scanForNetworks
{
    CFArrayRef              scan;
    //    CFDictionaryRef         buffer;
    //    CFMutableArrayRef       result;
    //    CFMutableDictionaryRef  network;
    Apple80211Err           error;
    long                    count = 0;
    
    
    
    
    error = Apple80211Scan(ref, &scan, NULL);
    
    if (error != kA11NoErr) {
        printf("Scan error! %i %s\n", error, Apple80211ErrToStr(error));
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

- (BOOL)powerCycle
{
    uint32_t power = 0;
    Apple80211Err error;
    
    error = Apple80211GetPower(ref, &power);
    if (error != kA11NoErr) {
        printf("error to get power: %i %s\n", error, Apple80211ErrToStr(error));
        
        return (error);
    }
    if (power > 0) {
        //printf("AirPort: power Off\n");
        
        Apple80211SetPower(ref, 0);
        return (NO);
    }
    //printf("AirPort: power On\n");
    Apple80211SetPower(ref, 1);
    return (YES);
}

- (BOOL)isPowerOn
{
    uint32_t power = 0;
    Apple80211Err error;
    
    error = Apple80211GetPower(ref, &power);
    if (power > 0) {
        //printf("AirPort: On\n");
        return (YES);
    } else if(power == 0){
        //printf("AirPort: Off\n");
        return (NO);
    }
    
    return (error);
}

- (NSAlert *)aerodromeError:(NSString *)errorText code:(int)error
{
    
    alert = [[NSAlert alloc] init];
    
    
    if (alert) {
        
        [alert setMessageText:errorText];
        [alert setInformativeText:[NSString stringWithFormat:@"%i, %s", error, Apple80211ErrToStr(error)]];
        [alert setIcon:[NSImage imageNamed:NSImageNameCaution]];
        
        
    }
    
    return alert;
}

- (NSString *)ssidName
{
    
    
    if([[self opMode] isEqualToString:@"none"]){
        
        return NULL;
        
    }
    
    CFDataRef ssid;
    
    Apple80211Err error;
    error = Apple80211CopyValue(ref, APPLE80211_IOC_SSID, 0, &ssid);
    
    
    
    if (error != kA11NoErr) {
        
        
        printf("ssidName - error: %i %s\n", error, Apple80211ErrToStr(error));
        return NULL;
    }
    
    CFStringRef ssid_name = CFStringCreateWithBytes(NULL, CFDataGetBytePtr(ssid), CFDataGetLength(ssid), kCFStringEncodingUTF8, FALSE);
    
    if (ssid_name == NULL)
    {
        return NULL;
    }
    
    return CFBridgingRelease(ssid_name);
    
    //
    //    char *ssid[32];
    //
    //    [self a80211GetSet:SIOCGA80211 Type:APPLE80211_IOC_SSID Value:0 Data:&ssid Size:32];
    //
    //    if ([[NSString stringWithCString:(const char *)ssid encoding:NSUTF8StringEncoding] length] > 0) {
    //        return [NSString stringWithCString:(const char *)ssid encoding:NSUTF8StringEncoding];
    //    }
    //
    //    return NULL;
    
}

#pragma mark - ioctl functions

-(int)a80211GetSet:(uint32_t)ioc
              Type:(uint32_t)type
             Value:(uint32_t *)valuep
              Data:(void *)data
              Size:(size_t)length
{
    struct apple80211req cmd;
    
    int a80211_sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (a80211_sock == -1) {
        return -1;
    }
    
    bzero(&cmd, sizeof(cmd));
    
    // memcpy(cmd.req_if_name, g_if_name, 16);
    strlcpy(cmd.req_if_name, [interface UTF8String], sizeof(cmd.req_if_name));
    cmd.req_type = type;
    cmd.req_val = valuep ? *valuep : 0;
    cmd.req_len = (uint32_t) length;
    cmd.req_data = data;
    errno = 0;
    int ret = ioctl(a80211_sock, ioc, &cmd, sizeof(cmd));
    if (ret < 0) {
        perror("SIOCGA80211");
        
    }
    
    if (valuep)
        *valuep = cmd.req_val;
    
    close(a80211_sock);
    return ret;
}

-(NSArray *)channelsList
{
    CFMutableArrayRef channels = NULL;
    CFNumberRef string = NULL;
    NSArray *returnArray;
    
    //CFMutableSetRef set = CFSetCreateMutable(kCFAllocatorDefault, 14, &kCFTypeSetCallBacks);
    
    
    struct apple80211_sup_channel_data data;
    memset(&data, 0, sizeof(data));
    
    //a80211_getset(SIOCGA80211, APPLE80211_IOC_SUPPORTED_CHANNELS, 0, &data, sizeof(data));
    [self a80211GetSet:SIOCGA80211 Type:APPLE80211_IOC_SUPPORTED_CHANNELS Value:0 Data:&data Size:sizeof(data)];
    
    channels = CFArrayCreateMutable(kCFAllocatorDefault, data.num_channels, &kCFTypeArrayCallBacks);
    
    //printf("Supported channels: ");
    for (int i = 0; i < APPLE80211_MAX_CHANNELS ; i++) {
        if (data.supported_channels[i].channel == 0) {
            ;
        } else {
            string = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &data.supported_channels[i].channel);
            // CFSetAddValue(set, string);
            CFArrayAppendValue(channels, string);
            // printf("%i ",  data.supported_channels[i].channel);
        }
    }
    
    
    returnArray = CFBridgingRelease(channels);
    return returnArray;
}

- (NSString *)opMode
{
    char *ret = "none";
    char *modes[6] =
    {
        "none",
        "Infrastructure station",
        "IBSS (adhoc) station",
        "Old lucent compatible adhoc demo",
        "Software Access Point",
        "Monitor mode"
    };
    
    uint32_t op = 0;
    //a80211_getset(SIOCGA80211, APPLE80211_IOC_OP_MODE, &op, NULL, 0);
    [self a80211GetSet:SIOCGA80211 Type:APPLE80211_IOC_OP_MODE Value:&op Data:NULL Size:0];
    
    if (op == APPLE80211_M_NONE) {
        ret = modes[0];
    } else if (op == APPLE80211_M_STA) {
        ret = modes[1];
    } else if (op == APPLE80211_M_IBSS) {
        ret = modes[2];
    } else if (op == APPLE80211_M_AHDEMO) {
        ret = modes[3];
    } else if (op == APPLE80211_M_HOSTAP) {
        ret = modes[4];
    } else if (op == APPLE80211_M_MONITOR) {
        ret = modes[5];
    }
    
    
    
    return ([NSString stringWithCString:ret encoding:NSUTF8StringEncoding]);
    
}

- (int)mode
{
    uint32_t op = 0;
    //a80211_getset(SIOCGA80211, APPLE80211_IOC_OP_MODE, &op, NULL, 0);
    [self a80211GetSet:SIOCGA80211 Type:APPLE80211_IOC_OP_MODE Value:&op Data:NULL Size:0];

    
    return op;
}

- (NSString *)state
{
    char *ret = "unknown";
    char *states[5] =
    {
        "Wi-Fi: default state",
        "Wi-Fi: scanning",
        "Wi-Fi: authenticating",
        "Wi-Fi: associating",
        "Wi-Fi: running"
    };
    
    uint32_t st = 0;
    //a80211_getset(SIOCGA80211, APPLE80211_IOC_STATE, &st, NULL, 0);
    [self a80211GetSet:SIOCGA80211 Type:APPLE80211_IOC_STATE Value:&st Data:NULL Size:0];
    
    if (st == APPLE80211_S_INIT) {
        ret = states[0];
    } else if (st == APPLE80211_S_SCAN){
        ret = states[1];
    } else if (st == APPLE80211_S_AUTH){
        ret = states[2];
    } else if (st == APPLE80211_S_ASSOC){
        ret = states[3];
    } else if (st == APPLE80211_S_RUN){
        ret = states[4];
    }
    
    
    return ([NSString stringWithCString:ret encoding:NSUTF8StringEncoding]);
}

-(int)status
{
    
    uint32_t st = 0;
    //a80211_getset(SIOCGA80211, APPLE80211_IOC_STATE, &st, NULL, 0);
    [self a80211GetSet:SIOCGA80211 Type:APPLE80211_IOC_STATE Value:&st Data:NULL Size:0];
    
    return st;
}

-(void)test
{

    
}

@end
