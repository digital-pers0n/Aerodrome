//
//  aerwld.m
//  aerwld
//
//  Created by Terminator on 8/21/16.
//
//

#import "aerwld.h"
#import "AERWLService.h"
#import <CoreWLAN/CoreWLANTypes.h>

#define TIMER 30

@implementation aerwld
-(instancetype)init
{
    self = [super init];
    if (self) {
        
        //_scanResults = [[AERWLService connection] scanForNetworks];
        
    }
    
    return self;
}

// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
- (void)upperCaseString:(NSString *)aString withReply:(void (^)(NSString *))reply {
    NSString *response = [aString uppercaseString];
    reply(response);
}

#pragma mark - connections
- (void)connectTo:(NSString *)name password:(NSString *)pass withReply:(void (^)(NSString *))reply
{
    
    
    int i = [[AERWLService connection] joinNetworkWithName:name andPassword:pass];
    if (i != kCWNoErr) {
        reply([[AERWLService connection] AERWLError:@"Error" code:i]);
    }
    [self startTerminateTimerWithInterval:TIMER];
    reply(nil);
    
    
}

-(void)createIBSS:(NSString *)name channel:(int)channel withReply:(void (^)(NSString *))reply
{
    
    
    int  i = [[AERWLService connection] createIBSSNetworkWithName:name andChannel:channel];
    if (i != kCWNoErr) {
        reply([[AERWLService connection] AERWLError:@"Error" code:i]);
    }
    [self startTerminateTimerWithInterval:TIMER];
    reply(nil);
    
    
}

//- (void)disconnect:(void (^)(int))reply
//{
//    int i = [[AERNetwork connection] disassociateFromNetwork];
//
//    reply(i);
//}

#pragma mark - scanning


-(void)scanForNetwork:(void (^)(NSArray *))reply
{
    //_cachedScanResults = _scanResults;
    
    _scanResults = [[AERWLService connection] scanForNetworks];
    [self startTerminateTimerWithInterval:TIMER];
    reply(_scanResults);
    
    
    //    NSArray *response = [wirelessInterface scanForNetworks];
    //    reply(response);
}



//#pragma mark - power
//
//-(void)powerCycleReply:(void (^)(BOOL))reply
//{
//    BOOL i = [[AERNetwork connection] powerCycle];
//    reply(i);
//}
//
//-(void)isPowerON:(void (^)(BOOL))reply
//{
//    BOOL i = [[AERNetwork connection] isPowerOn];
//    reply(i);
//}
//
//#pragma mark - status
//
//- (void)status:(void (^)(int))reply
//{
//    int i = [[AERNetwork connection] status];
//
//    reply(i);
//}
//
//- (void)mode:(void (^)(BOOL))reply
//{
//    int i = [[AERNetwork connection] mode];
//
//    reply(i);
//}
//
- (void)channels:(void (^)(NSArray *))reply
{
    NSArray *i = [[AERWLService connection] channelsList];
    
    [self startTerminateTimerWithInterval:TIMER];
    
    reply(i);
    
    
}
//
//- (void)ifName:(void (^)(NSString *))reply
//{
//    NSString *i = [[AERNetwork connection] interface];
//
//    reply(i);
//}
//
//-(void)ssidName:(void (^)(NSString *))reply
//{
//    NSString *i = [[AERNetwork connection] ssidName];
//
//    reply(i);
//}
-(void)startTerminateTimerWithInterval:(int)sec
{
    
    
    //dispatch_source_t timer = self->_updateTimer;
    if(self->_terminateTimer){
        dispatch_source_cancel(self->_terminateTimer);
    }
    self->_terminateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
    //self->_updateTimer = timer;
    
    dispatch_source_set_timer(self->_terminateTimer, dispatch_time(0, sec * NSEC_PER_SEC), 1.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self->_terminateTimer, ^{
        //      puts("here am I");
        dispatch_source_cancel(self->_terminateTimer);
        //puts("here am I");
        //dispatch_release(timer);
        [self terminate];
        
        //return [self startScanUpdateTimerWithInterval:sec];
        
    });
}

-(void)terminate
{
    NSLog(@"Obliterated");
    puts("terminated");
    exit(0);
}
@end
