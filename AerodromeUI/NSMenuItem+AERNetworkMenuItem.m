//
//  NSMenuItem+AERNetworkMenuItem.m
//  Aerodrome
//
//  Created by Terminator on 8/4/16.
//
//

#import "NSMenuItem+AERNetworkMenuItem.h"
#import "AERMenuItemView.h"
#import "AEROptions.h"
#import "NSDictionary+AERNetwork.h"

@implementation NSMenuItem (AERNetworkMenuItem)

-(NSMenuItem *)itemFromNetwork:(NSDictionary *)network icons:(NSDictionary *)icons action:(SEL)sel andTag:(NSUInteger)tag
{
    @autoreleasepool {
        
        
        
        
        NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:network[@"SSID"] action:sel keyEquivalent:@""];
        [newItem setTag:tag];
        __weak NSImage *img, *img2;
        if ([network[@"SECURITY"] isEqualToString:@"Open"]) {
            img = [NSImage imageNamed:NSImageNameLockUnlockedTemplate];
        } else {
            img = [NSImage imageNamed:NSImageNameLockLockedTemplate];
        }
         int rssi = [network rssiValue];
        
        if (icons) {
            
            
            if (rssi > -30) {
                img2 = [icons objectForKey:AERICON_SIGNAL_3];
            } else if(rssi < -30 && rssi > -60) {
                img2 = [icons objectForKey:AERICON_SIGNAL_2];
            } else if (rssi < -60 && rssi > -90) {
                img2 = [icons objectForKey:AERICON_SIGNAL_1];
            } else {
                img2 = [icons objectForKey:AERICON_SIGNAL_0];
            }
        } else {
            
           
            
            if (rssi >= -30) {
                img2 = [NSImage imageNamed:@"AER-signal-3"];
            } else if(rssi < -30 && rssi >= -60) {
                img2 = [NSImage imageNamed:@"AER-signal-2"];
            } else if (rssi < -60 && rssi >= -90) {
                img2 = [NSImage imageNamed:@"AER-signal-1"];
            } else {
                img2 = [NSImage imageNamed:@"AER-signal-0"];
            }
            
            [img2 setTemplate:YES];
            
        }
        
        
        //[img2 setTemplate:YES];
        [newItem setView:[[AERMenuItemView alloc] initWithFrame:NSMakeRect(0, 0, 250, 19) menuItem:newItem andImages:@[img, img2]]];
        [newItem setRepresentedObject:network];
        
        return newItem;
        
    }
}


@end
