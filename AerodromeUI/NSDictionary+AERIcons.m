//
//  NSImage+AERIcons.m
//  Aerodrome
//
//  Created by Terminator on 8/29/16.
//
//

#import "NSDictionary+AERIcons.h"

#import "AEROptions.h"

@implementation NSDictionary (AERIcons)

-(NSDictionary *)menuBarIcons
{
    
    NSDictionary *result;
    NSImage *aer0 = [NSImage imageNamed:@"AER-OFF"];
    
    
    NSImage *aer30 = [NSImage imageNamed:@"AER-30"];
    
    NSImage *aer50 = [NSImage imageNamed:@"AER-50"];
    
    NSImage *aer100 = [NSImage imageNamed:@"AER-ACTIVE"];
    
    NSImage *aerIbss = [NSImage imageNamed:@"AER-IBSS"];
    
    NSImage *aerIdle = [NSImage imageNamed:@"AER-IDLE"];

    
    result = @{
                           AERICON_STATUS_OFF : aer0,
                           AERICON_STATUS_30 : aer30,
                           AERICON_STATUS_50 : aer50,
                           AERICON_STATUS_100 : aer100,
                           AERICON_STATUS_IBSS : aerIbss,
                           AERICON_STATUS_IDLE : aerIdle,
                           
                           };
    
    for (NSImage *a in [result allValues]) {
        
        [a setTemplate:YES];
    }
    
    return result;
}


-(NSDictionary *)signalIcons
{
     NSDictionary *result;
    
    
    NSImage *aerSignal0 = [NSImage imageNamed:@"AER-signal-0"];
    
    NSImage *aerSignal1 = [NSImage imageNamed:@"AER-signal-1"];
    
    NSImage *aerSignal2 = [NSImage imageNamed:@"AER-signal-2"];
    
    NSImage *aerSignal3 = [NSImage imageNamed:@"AER-signal-3"];
    
    result = @{

                           AERICON_SIGNAL_0 : aerSignal0,
                           AERICON_SIGNAL_1 : aerSignal1,
                           AERICON_SIGNAL_2 : aerSignal2,
                           AERICON_SIGNAL_3 : aerSignal3,
                           
                           };
    
    for (NSImage *a in [result allValues]) {
        
        [a setTemplate:YES];
    }
    
    return result;
}


@end
