//
//  NSMenu+UpdateMenu.h
//  playground-menu-autoupdate
//
//  Created by Terminator on 8/28/16.
//  Copyright © 2016 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSMenu (UpdateMenu)

-(void)updateMenuWithNetworks:(NSArray *)networks andAction:(SEL)action;

@end
