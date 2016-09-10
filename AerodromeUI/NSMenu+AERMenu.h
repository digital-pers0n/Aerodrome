//
//  NSMenu+AERMenu.h
//  Aerodrome
//
//  Created by Terminator on 8/1/16.
//
//

#import <Cocoa/Cocoa.h>

@interface NSMenu (AERMenu)

- (NSMenuItem *)insertItemWithTitle:(NSString *)aString
                             action:(SEL)aSelector
                            enabled:(BOOL)enable
                          separator:(BOOL)separator
                             hidden:(BOOL)hidden
                      keyEquivalent:(NSString *)charCode
                                tag:(NSUInteger)tag
                            atIndex:(int)index;
// Separator
- (NSMenuItem *)insertSeparatorWithTag:(NSUInteger)tag atIndex:(int)index;

// Disabled Item
- (NSMenuItem *)insertItemDisabledWithTitle:(NSString *)title tag:(NSUInteger)tag atIndex:(int)index;

// Hidden Item
- (NSMenuItem *)insertItemHiddenWithTitle:(NSString *)title action:(SEL)aSelector keyEquivalent:(NSString *)key tag:(NSUInteger)tag atIndex:(int)idx;

- (NSMenuItem *)insertItemWithTitle:(NSString *)title action:(SEL)aSelector keyEquivalent:(NSString *)key tag:(NSUInteger)tag atIndex:(int)idx;
- (NSMenuItem *)insertItemWithTitle:(NSString *)title action:(SEL)aSelector tag:(NSUInteger)tag atIndex:(int)idx;



@end
