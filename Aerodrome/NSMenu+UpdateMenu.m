//
//  NSMenu+UpdateMenu.m
//  playground-menu-autoupdate
//
//  Created by Terminator on 8/28/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "NSMenu+UpdateMenu.h"

#import "NSDictionary+AERNetwork.h"
#import "NSMenu+AERMenu.h"
#import "NSMenuItem+AERNetworkMenuItem.h"

#import "AEROptions.h"

@implementation NSMenu (UpdateMenu)


-(void)updateMenuWithNetworks:(NSArray *)networks andAction:(SEL)action


{
    
    @autoreleasepool {
        
        
        BOOL containsIbss = NO;
        
        int idx = 0;
        
        NSMutableArray *itemsToUpdate = [NSMutableArray new];
  //      NSMutableArray *itemsToRemove = [NSMutableArray new];
        
        
        
        if ([self itemWithTag:AERMenuSecondSeparator]) {
            [self removeItem:[self itemWithTag:AERMenuSecondSeparator]];
        }
        
        for (NSMenuItem *a in [self itemArray]) {
            if ( a.tag < 500 && ![networks containsObject:[a representedObject]]) {
                // [itemsToRemove addObject:a];
                
                [self removeItem:a];
            }
        }
        
        
        
        for (NSDictionary *a in networks) {
            
            if ([self indexOfItemWithRepresentedObject:a] == -1) {
                [itemsToUpdate addObject:a];
            }
            
            if ([a isIBSS]) {
                containsIbss = YES;
            }
        }
        

        
//        if (itemsToRemove) {
//            for (NSMenuItem *a in itemsToRemove) {
//                [self removeItem:a];
//            }
//        }
        
        if (itemsToUpdate) {
            for (NSDictionary *a in itemsToUpdate) {
                
                if ([a isIBSS]) {
                    //                [[self insertItemWithTitle:[a ssid] action:action tag:idx + 100 atIndex:[self indexOfItemWithTag:AERMenuDevices] + 1] setRepresentedObject:a];
                    
                    [self insertItem:[[NSMenuItem alloc] itemFromNetwork:a
                                                                   icons:nil
                                                                  action:action
                                                                  andTag:idx + 100]
                     
                             atIndex:[self indexOfItemWithTag:AERMenuDevices] + 1];
                    
                    
                    
                    
                } else {
                    
                    //                [[self insertItemWithTitle:[a ssid] action:action tag:idx + 200 atIndex:[self indexOfItemWithTag:AERMenuNoNetworks] + 1] setRepresentedObject:a];
                    
                    [self insertItem:[[NSMenuItem alloc] itemFromNetwork:a
                                                                   icons:nil
                                                                  action:action
                                                                  andTag:idx + 200]
                     
                             atIndex:[self indexOfItemWithTag:AERMenuDevices] - 1];
                    
                }
                
                
                idx++;
            }
            
            if (containsIbss) {
                
                if ([[self itemWithTag:AERMenuDevices] isHidden]) {
                    [[self itemWithTag:AERMenuDevices] setHidden:NO];
                }
                
                if (![self itemWithTag:AERMenuThirdSeparator]) {
                    [self insertSeparatorWithTag:AERMenuThirdSeparator atIndex:(int)[self indexOfItemWithTag:AERMenuCreateIBSS]];
                }
                
            } else {
                
                if (![[self itemWithTag:AERMenuDevices] isHidden]) {
                    [[self itemWithTag:AERMenuDevices] setHidden:YES];
                    
                }
                
                if ([self itemWithTag:AERMenuThirdSeparator]) {
                    [self removeItem:[self itemWithTag:AERMenuThirdSeparator]];
                }
            }
            
            
            if (![self itemWithTag:AERMenuSecondSeparator]) {
                [self insertSeparatorWithTag:AERMenuSecondSeparator atIndex:(int)[self indexOfItemWithTag:AERMenuDevices]];
            }
            
        }
        
    }
    
}

@end
