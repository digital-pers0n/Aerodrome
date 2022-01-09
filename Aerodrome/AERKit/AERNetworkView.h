//
//  AERNetworkView.h
//  Aerodrome
//
//  Created by Maxim M. on 12/22/21.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface AERNetworkView : NSView
- (instancetype)initWithFrame:(NSRect)aRect menuItem:(NSMenuItem*)item
                       images:(NSArray<NSImage*>*)images;
@end

NS_ASSUME_NONNULL_END
