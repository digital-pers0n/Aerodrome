//
//  NSMenu+AERMenu.m
//  Aerodrome
//
//  Created by Terminator on 8/1/16.
//
//

#import "NSMenu+AERMenu.h"
#import "NSMenuItem+AERNetworkMenuItem.h"
#import "AEROptions.h"

@implementation NSMenu (AERMenu)

- (NSMenuItem *)insertItemWithTitle:(NSString *)aString
                             action:(SEL)aSelector
                            enabled:(BOOL)enable
                          separator:(BOOL)separator
                             hidden:(BOOL)hidden
                      keyEquivalent:(NSString *)charCode
                                tag:(NSUInteger)tag
                            atIndex:(int)index
{
    if (separator) {
        
        NSMenuItem *sep = [NSMenuItem separatorItem];
        [sep setTag:tag];
        [self insertItem:sep atIndex:index];
        return sep;
    }
    
    NSMenuItem *newItem =[[NSMenuItem alloc] initWithTitle:aString action:aSelector keyEquivalent:charCode];
    [newItem setEnabled:enable];
    [newItem setTag:tag];
   // [newItem setTarget:self];
    [newItem setHidden:hidden];
    
    [self insertItem:newItem atIndex:index];
    
    return newItem;
    
}

-(NSMenuItem *)insertItemWithTitle:(NSString *)title action:(SEL)aSelector tag:(NSUInteger)tag atIndex:(int)idx
{
    return [self insertItemWithTitle:title action:aSelector enabled:YES separator:NO hidden:NO keyEquivalent:@"" tag:tag atIndex:idx];
}

- (NSMenuItem *)insertItemWithTitle:(NSString *)title action:(SEL)aSelector keyEquivalent:(NSString *)key tag:(NSUInteger)tag atIndex:(int)idx
{
    return [self insertItemWithTitle:title action:aSelector enabled:YES separator:NO hidden:NO keyEquivalent:key tag:tag atIndex:idx];
}

- (NSMenuItem *)insertItemDisabledWithTitle:(NSString *)title tag:(NSUInteger)tag atIndex:(int)index
{
   return [self insertItemWithTitle:title action:nil enabled:NO separator:NO hidden:NO keyEquivalent:@"" tag:tag atIndex:index];
}

- (NSMenuItem *)insertSeparatorWithTag:(NSUInteger)tag atIndex:(int)index
{
    return [self insertItemWithTitle:nil action:nil enabled:YES separator:YES hidden:NO keyEquivalent:@"" tag:tag atIndex:index];
}

- (NSMenuItem *)insertItemHiddenWithTitle:(NSString *)title action:(SEL)aSelector keyEquivalent:(NSString *)charCode tag:(NSUInteger)tag atIndex:(int)idx
{
    return [self insertItemWithTitle:title action:aSelector enabled:YES separator:NO hidden:YES keyEquivalent:charCode tag:tag atIndex:idx];
}

#pragma mark - populate menu

-(void)populateMenu:(NSMenu *)menu withNetworks:(NSDictionary *)networks
{
    
}



@end
