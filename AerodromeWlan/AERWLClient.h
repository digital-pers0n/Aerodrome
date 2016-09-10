//
//  AERWLClient.h
//  Aerodrome
//
//  Created by Terminator on 8/21/16.
//
//

#import <Foundation/Foundation.h>

@interface AERWLClient : NSObject
{
    
    dispatch_source_t _terminateTimer;
    
    
    NSArray       *  _networks;
    NSArray       *  _cachedNetworks;
    NSArray       *  _channels;
    
    NSDictionary  * _statusIcons;
    
    
    
    NSString *_ifName;

    NSXPCConnection *_connection;
}
//+(AERWLInterface *)interface;
+(id)sharedClient;

- (NSXPCConnection *) xpcService;



- (int)joinNetwork:(NSString *)ssid withPassword:(NSString *)pass;
- (int)createIBSS:(NSString *)name withChannel:(int)channel;
- (int) disconnect;

- (NSArray *)scan;

- (NSArray *)channels;
- (NSString *)ssidName;

- (NSString *)opMode;
- (NSString *)state;
- (BOOL)isActive;
- (BOOL)isIBSS;

- (BOOL) powerSwitch;
- (BOOL) isPowerOn;
- (BOOL) setPower:(BOOL)power;

- (NSString *)ifName;

@end
