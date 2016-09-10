//
//  AERMenuItemView.h
//  Aerodrome
//
//  Created by Terminator on 7/23/16.
//
//

#import <Cocoa/Cocoa.h>

@interface AERMenuItemView : NSView {
    
    
    NSArray * _images;
    NSMenuItem *_item;
    
    
}


- (AERMenuItemView *)initWithFrame:(NSRect)frame menuItem:(NSMenuItem *) menuItem andImages:(NSArray *)img;


@end
