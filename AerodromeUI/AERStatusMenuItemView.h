//
//  AERStatusMenuItemView.h
//  MenuPlayground
//
//  Created by Terminator on 8/1/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AERStatusMenuItemView : NSView
{

    NSMenuItem *_menuItem;
    NSProgressIndicator *_progressIndicator;
}


- (void)stopIndicator;
- (void)startIndicator;

- (id)initWithFrame:(struct CGRect)arg1 menuItem:(NSMenuItem *)arg2;

@end
