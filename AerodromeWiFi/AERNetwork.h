//
//  AERNetwork.h
//  Aerodrome
//
//  Created by Terminator on 8/2/16.
//
//

#import <Foundation/Foundation.h>
#import "Apple80211.h"
#import "AerodromeWiFi.h"

@interface AERNetwork : NSObject
{
    Apple80211Ref   ref;
    NSString *      interface;
    NSAlert  *      alert;
}


@property(strong)NSString *interface;

+ (AERNetwork *) connection;

- (NSString *)apple80211Interface;
- (int)joinNetworkWithName:(NSString *)ssid andPassword:(NSString *)pass;
- (int)createIBSSNetworkWithName:(NSString *)name andChannel:(int)channel;
- (int)disassociateFromNetwork;
- (BOOL)powerCycle;

- (BOOL)isPowerOn;

- (NSArray *)scanForNetworks;
- (NSArray *)channelsList;
- (NSString *)ssidName;
- (NSString *)opMode;
- (NSString *)state;

- (int)status;
- (int)mode;

- (NSAlert *)aerodromeError:(NSString *)errorText code:(int)error;


- (void) test;

@end
