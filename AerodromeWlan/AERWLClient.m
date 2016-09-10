//
//  AERWLClient.m
//  Aerodrome
//
//  Created by Terminator on 8/21/16.
//
//

#import "AERWLClient.h"
#import "aerwldProtocol.h"
#import "aerwl_ioctl.h"
#import <CoreWLAN/CoreWLAN.h>

@implementation AERWLClient
-(instancetype)init
{
    if(self = [super init]){
        
        if (!self->_connection) {
            self->_connection = [[NSXPCConnection alloc] initWithServiceName:@"void.digital-person.aerwld"];
            self->_connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(aerwldProtocol)];
            [self->_connection resume];
        }
        

        
        char test[16];
        bzero(&test, 16);
        get_if_name((char *)&test);
        
        
        
        
        
        self->_ifName = [NSString stringWithCString:test encoding:NSASCIIStringEncoding];
        
        if (!self->_ifName) {
            self->_ifName =  [[CWInterface interfaceNames] anyObject];
        }
        
    };
    
    return self;
}

-(id)initWithXPC:(NSXPCConnection *)xpc
{
    if (self = [super init]) {
        char test[16];
        bzero(&test, 16);
        get_if_name((char *)&test);
        
        
        
        
        
        self->_ifName = [NSString stringWithCString:test encoding:NSASCIIStringEncoding];
        
        if (!self->_ifName) {
            self->_ifName =  [[CWInterface interfaceNames] anyObject];
            
            
        }
        
        _connection = xpc;
    }
    
    
    
    
    return self;
}

+(id)sharedClient
{
    static AERWLClient *sharedClient;
    static NSXPCConnection *xpc;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xpc = [[NSXPCConnection alloc] initWithServiceName:@"void.digital-person.aerwld"];
        xpc.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(aerwldProtocol)];
        [xpc resume];
        
        sharedClient = [[AERWLClient alloc] initWithXPC:xpc];
    });
    
    return sharedClient;
}

-(NSArray *)scan
{
    
    //self->_cachedNetworks = self->_networks;
    
    [[self->_connection remoteObjectProxy] scanForNetwork:^(NSArray *aArray){
        
        self->_networks = aArray;
        
        
    }];
    
    return self->_networks;
    //   [connection suspend];
    
}



#pragma mark - connections
- (int)createIBSS:(NSString *)name withChannel:(int)channel
{
    //__block int i = 0;
    if (is_associated()) {
        [self disconnect];
    }
    
    
    
    [[self->_connection remoteObjectProxy] createIBSS:name channel:channel withReply:^(NSString *rep) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (rep) {
                //[(AERCreateNetworkDialog *)currentDialog setStatusText:rep];
                //[[self aerodromeError:@"Failed to create network" code:rep] performSelectorOnMainThread:@selector(runModal) withObject:nil waitUntilDone:YES];
            }
        });
    }];
    
    return 0;
}

-(int)joinNetwork:(NSString *)ssid withPassword:(NSString *)pass
{
    if (is_associated()) {
        [self disconnect];
    }
    
    //__block int i = 0;
    [[self->_connection remoteObjectProxy] connectTo:ssid password:pass withReply:^(NSString *rep) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (rep) {
                //[(AERCreateNetworkDialog *)currentDialog setStatusText:rep];
                //[[self aerodromeError:@"Failed to create network" code:rep] performSelectorOnMainThread:@selector(runModal) withObject:nil waitUntilDone:YES];
            }
        });
    }];
    
    return 0;
}

-(int)disconnect
{
    //    __block int i = 0;
    //    [[connection remoteObjectProxy] disconnect:^(int rep) {
    //        i = rep;
    //    }];
    
    return disassociate();
    
}

#pragma mark - info

-(NSArray *)channels
{
    //    [[connection remoteObjectProxy] channels:^(NSArray * rep) {
    //        _channels = rep;
    //    }];
    
    if (!self->_channels) {
        self->_channels = CFBridgingRelease(get_channels_list());
    }
    return self->_channels;
    
}

- (BOOL)isActive
{
    return is_associated();
}

-(NSString *)ssidName
{
    //    __block NSString *name;
    //    [[connection remoteObjectProxy] ssidName:^(NSString * rep){
    //        name = rep;
    //    }];
    
    
    char ssid[32];
    bzero(&ssid, sizeof(ssid));
    get_ssid_name((char *)&ssid);
    
    return [NSString stringWithCString:ssid encoding:NSUTF8StringEncoding];
}
- (NSString *)ifName
{
    //   NSString *name;
    
    //    [[connection remoteObjectProxy] ifName:^(NSString * rep){
    //        name = rep;
    //    }];
    
    return self->_ifName;
}

-(BOOL)isIBSS
{
    return is_ibss();
}

-(NSString *)state
{
    __block NSString *ret;
    
    //    [[connection remoteObjectProxy] status:^(int rep) {
    //        switch (rep) {
    //            case APPLE80211_S_INIT:
    //                ret = AERNETWORK_STATUS_DEFAULT;
    //                break;
    //            case APPLE80211_S_RUN:
    //                ret = AERNETWORK_STATUS_ACTIVE;
    //                break;
    //
    //            default:
    //                ret = AERNETWORK_STATUS_DEFAULT;
    //                break;
    //        }
    //    }];
    
    return ret;
    
}

-(NSString *)opMode
{
    __block NSString *mode;
    
    return mode;
}

#pragma mark - power

- (BOOL)powerSwitch
{
    //    __block BOOL i = 0;
    //    [[connection remoteObjectProxy] powerCycleReply:^(BOOL rep) {
    //        i = rep;
    //    }];
    
    return power_cycle();
}

-(BOOL)isPowerOn
{
    //    __block BOOL i = 0;
    //    [[connection remoteObjectProxy] isPowerON:^(BOOL rep) {
    //        i = rep;
    //    }];
    
    return is_powered();
}

-(BOOL)setPower:(BOOL)power
{
    return set_power_state(power);
}

#pragma mark -XPC

-(NSXPCConnection *)xpcService
{
    return _connection;
}

@end
