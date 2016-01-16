//
//  Aerodrome.h
//  Aerodrome
//
//  Created by digital_person on 12/23/15.
//  Copyright © 2015. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface Aerodrome : NSObject
{
    Apple80211Ref   ref;
    NSString *      interface;
    NSAlert  *      alert;
}


@property(strong)NSString *interface;

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

- (NSAlert *)aerodromeError:(NSString *)errorText code:(int)error;




@end
