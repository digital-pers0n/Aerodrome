//
//  NSMenuItem+AERNetworkMenuItem.h
//  Aerodrome
//
//  Created by Terminator on 8/4/16.
//
//

#import <Cocoa/Cocoa.h>

@interface NSMenuItem (AERNetworkMenuItem)



-(nullable NSMenuItem *)itemFromNetwork:(nonnull NSDictionary *)network icons:(nullable NSDictionary *)icons action:(nonnull SEL)sel andTag:(NSUInteger)tag;



@end
