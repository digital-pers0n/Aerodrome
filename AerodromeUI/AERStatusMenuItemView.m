//
//  AERStatusMenuItemView.m
//  MenuPlayground
//
//  Created by Terminator on 8/1/16.
//  Copyright © 2016 home. All rights reserved.
//

#import "AERStatusMenuItemView.h"

@implementation AERStatusMenuItemView

- (void)drawRect:(NSRect)dirtyRect {
    @autoreleasepool {
        
    
    
    //[self->_progressIndicator setFrame:NSMakeRect(self.frame.origin.x - 30, 0, 19, 19) ];
    self->_progressIndicator.frame = NSMakeRect(self.frame.size.width - 26, 2, 16, 16);
    NSTextFieldCell *tCell = [[NSTextFieldCell alloc] initTextCell:[self->_menuItem title]];
    [tCell setFont:[NSFont menuBarFontOfSize:14]];
    [tCell setTextColor:[NSColor disabledControlTextColor]];
    [tCell drawWithFrame:NSMakeRect(19, 0, self.frame.size.width - 60, 19) inView:self];
    
    [super drawRect:dirtyRect];
        
    }
    
    // Drawing code here.
}

-(id)initWithFrame:(struct CGRect)arg1 menuItem:(NSMenuItem *)arg2
{
    AERStatusMenuItemView   *view = [[AERStatusMenuItemView alloc] initWithFrame:arg1];
    [view setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable ];
    
    view->_menuItem = arg2;
    NSProgressIndicator *indicator = [[NSProgressIndicator alloc] init];
    view->_progressIndicator = indicator;
    
    [view->_progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
    [view->_progressIndicator setDisplayedWhenStopped:NO];
    [view->_progressIndicator setControlSize:NSSmallControlSize];
    [view->_progressIndicator sizeToFit];
    [view->_progressIndicator setAutoresizingMask:NSViewMaxXMargin];
    [view->_progressIndicator setTranslatesAutoresizingMaskIntoConstraints:YES];
    [view->_progressIndicator setAutoresizesSubviews:YES];
    [view->_progressIndicator setUsesThreadedAnimation:YES];
    [view addSubview:view->_progressIndicator];
    
    
    return view;
}



-(void)startIndicator
{
    [self->_progressIndicator startAnimation:self];
    
}

-(void)stopIndicator
{
    [self->_progressIndicator stopAnimation:self];
}

-(BOOL)isOpaque
{
    return YES;
}

- (BOOL)allowsVibrancy
{
    
    return NO;
}

@end
