//
//  AERWLNetwork.h
//  Aerodrome
//
//  Created by Terminator on 8/22/16.
//
//

//Apple80211.framework / Airport.framework

#import <Foundation/Foundation.h>
#import <CoreWLAN/CoreWLANTypes.h>

struct Apple80211;
typedef struct Apple80211 *Apple80211Ref;

int Apple80211Open(Apple80211Ref *handle); //Open Conection
int Apple80211Close(Apple80211Ref handle);
int Apple80211BindToInterface(Apple80211Ref handle, CFStringRef interface);
int Apple80211Scan(Apple80211Ref handle, CFArrayRef *scanResult, CFDictionaryRef parametrs);

int Apple80211SetPower(Apple80211Ref handle, uint32_t power);
int Apple80211GetPower(Apple80211Ref wref, uint32_t *power);
//int Apple80211Set(Apple80211Ref handle, CFStringRef str, uint32_t val);
int ACInterfaceCopyInfo(Apple80211Ref handle);
int ACNetworkCreate(CFStringRef ssid);

int Apple80211Disassociate(Apple80211Ref wref);
int Apple80211Associate(Apple80211Ref handle, CFDictionaryRef SSID, CFStringRef pass);
//int Apple80211Associate2();

int Apple80211Get(Apple80211Ref ref, CFStringRef chr, uint32_t val, CFTypeRef var, uint32_t var2);
int Apple80211Set();

char *Apple80211ErrToStr(uint32_t errCode);
int Apple80211GetIfListCopy(Apple80211Ref handle, CFArrayRef *If_name_array);
int Apple80211GetInfoCopy(Apple80211Ref wref, CFDictionaryRef *dict);
int Apple80211CopyValue();



@interface AERWLNetwork : NSObject
{
    Apple80211Ref   ref;
    NSString *      interface;

    NSArray  *      _cachedNetworksList;
    NSArray  *      _rawScanList;
}

+(id)connection;


- (NSString *)apple80211Interface;

// New Methods
-(int)associateWithNetworkName:(NSString *)network andPassword:(NSString *)pass;
-(int)associateWithNetworkData:(NSDictionary *)networkDictionary andPassword:( NSString *)pass;
-(NSArray <NSDictionary *> *)scanForNetworkWithName:( NSString *)networkName;
-( NSString *)securityString:(CWSecurity)code;

// Old Methods

- (int)joinNetworkWithName:(NSString *)ssid andPassword:(NSString *)pass;
- (int)createIBSSNetworkWithName:(NSString *)name andChannel:(int)channel;

- (NSArray *)scanForNetworks;

- (NSString *)AERWLError:(NSString *)errorText code:(int)error;

@end
