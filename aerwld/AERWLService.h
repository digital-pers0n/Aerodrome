//
//  AERWLService.h
//  Aerodrome
//
//  Created by Terminator on 8/21/16.
//
//

#import <Foundation/Foundation.h>

struct Apple80211;
typedef struct Apple80211 *Apple80211Ref;

int Apple80211Open(Apple80211Ref *handle); //Open Conection
int Apple80211Close(Apple80211Ref handle);
int Apple80211BindToInterface(Apple80211Ref handle, CFStringRef interface);
int Apple80211Scan(Apple80211Ref handle, CFArrayRef *scanResult, CFDictionaryRef parametrs);
int Apple80211Get(Apple80211Ref ref, CFStringRef chr, uint32_t val, CFTypeRef var, uint32_t var2);
int Apple80211Set();
int Apple80211GetIfListCopy(Apple80211Ref handle, CFArrayRef *If_name_array);
int Apple80211GetInfoCopy(Apple80211Ref wref, CFDictionaryRef *dict);
int Apple80211Associate();
char *Apple80211ErrToStr(uint32_t errCode);

@interface AERWLService : NSObject
{
    Apple80211Ref   ref;
    NSString *      interface;

}

+(id)connection;


- (NSString *)apple80211Interface;
- (int)joinNetworkWithName:(NSString *)ssid andPassword:(NSString *)pass;
- (int)createIBSSNetworkWithName:(NSString *)name andChannel:(int)channel;

- (NSArray *)scanForNetworks;


-(NSArray *)channelsList;

- (NSString *)AERWLError:(NSString *)errorText code:(int)error;

@end
