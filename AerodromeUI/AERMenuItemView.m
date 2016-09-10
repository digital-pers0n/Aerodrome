//
//  AERMenuItemView.m
//  Aerodrome
//
//  Created by Terminator on 7/23/16.
//
//

#import "AERMenuItemView.h"



#define menuitem ([self enclosingMenuItem])
#define AER_VIEW_FRAME NSMakeRect(0, 0, 200, 19)
#define AER_LABEL_FRAME NSMakeRect(20, 0, 175, 19)
#define AER_INDICATOR_FRAME NSMakeRect(180, 0, 19, 19)



@implementation AERMenuItemView



- (void)drawRect:(NSRect)dirtyRect {
    
    
    
    BOOL highlight = [self->_item isHighlighted];
    
    if(highlight)
    {
        [[NSColor selectedMenuItemColor] set];
        //CGContextSetFillColorWithColor([[NSGraphicsContext currentContext] CGContext], [[NSColor selectedMenuItemColor] CGColor]);
        NSRectFill(dirtyRect);
        
        
       
    }
    
    if (self->_images) {
        int wid = self.frame.size.width - 5;
        for (NSImage *i in self->_images) {
            NSCell *iCell = [[NSCell alloc] initImageCell:i];
            [iCell setBackgroundStyle:highlight !=0];
            //wid = wid - 25;
            
            wid = wid - (i.size.width + 7);
            
            [iCell drawWithFrame:NSMakeRect(wid, 0, i.size.width, 19) inView:self];
            
            //wid = wid - i.size.width - 10;

            
        }
        
        
        NSTextFieldCell *textCell = [[NSTextFieldCell alloc] initTextCell:[self->_item title]];
        //[textCell setFont:[NSFont menuFontOfSize:15]];
        [textCell setFont:[NSFont systemFontOfSize:15]];
        
        [textCell setTextColor:highlight ? [NSColor selectedMenuItemTextColor] : [NSColor textColor]];
        [textCell setBackgroundStyle:highlight];
        [textCell setLineBreakMode: NSLineBreakByTruncatingTail];
        
        [textCell drawWithFrame:NSMakeRect(20, 0, wid - 10 , 19) inView:self];
        
        
    } else {
        
        NSTextFieldCell *textCell = [[NSTextFieldCell alloc] initTextCell:[self->_item title]];
        [textCell setFont:[NSFont menuFontOfSize:15]];
        [textCell setLineBreakMode: NSLineBreakByTruncatingTail];
        [textCell setTextColor:highlight ? [NSColor selectedMenuItemTextColor] : [NSColor textColor]];
        [textCell setBackgroundStyle:highlight];
        [textCell drawWithFrame:NSMakeRect(20, 0, self.frame.size.width - 10, 19) inView:self];
        
    }
    

    
}



-(AERMenuItemView *)initWithFrame:(NSRect)frame menuItem:(NSMenuItem *)menuItem andImages:(NSArray *)img
{
    
    @autoreleasepool {
        
        AERMenuItemView *view = [[AERMenuItemView allocWithZone:nil] initWithFrame:frame];
        [view setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable ];
        
        [menuItem setView:view];
        
        view->_item = menuItem;
        view->_images = img;
        
        return view;
        
    }
    
}



- (BOOL)allowsVibrancy
{
    
    return NO;
}
////
- (BOOL)isOpaque
{
    
    return YES;
}



- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

//- (BOOL)becomeFirstResponder
//{
//    [self setNeedsDisplay:YES];
//    return YES;
//}
//
//-(BOOL)acceptsFirstResponder
//{
//    [self setNeedsDisplay:YES];
//    return YES;
//}



//- (void)mouseDown:(NSEvent *)event
//{
//    NSLog(@"mouseDown: %ld", [event clickCount]);
//}
//- (void)mouseDragged:(NSEvent *)event
//{
//    NSPoint p = [event locationInWindow];
//    NSLog(@"mouseDragged:%@", NSStringFromPoint(p));
//}
- (void)mouseUp:(NSEvent *)event
{
    
    
    //NSMenuItem *item = [self enclosingMenuItem];
    NSMenu *m = [self->_item menu];
    
    
   [m cancelTrackingWithoutAnimation];
    [m performActionForItemAtIndex:[m indexOfItem:self->_item]];
    

    
}

@end
