//
//  AERHelperPreferences.h
//  Aerodrome
//
//  Created by Terminator on 8/23/16.
//
//

#import <Foundation/Foundation.h>

@interface AERHelperPreferences : NSObject

+(id)sharedPreferences;

-(BOOL)shouldRememberNetworks;
-(NSString *)makePSK:(NSString *)ssid andPassword:(NSString *) password;
- (void)addNetowrkToList:(NSDictionary *)network withPassword:(NSString *)pass;
- (void)removeNetworkFromList:(NSDictionary *)network;

- (NSDictionary *)findNetwork:(NSDictionary *)network;

-(NSString *)findInKeychain:(NSDictionary *)network;
-(void)addNetworkToKeychain:(NSDictionary *)network password:(NSString *)password;
-(void)removeNetworkFromKeychain:(NSDictionary *)network;

@end
