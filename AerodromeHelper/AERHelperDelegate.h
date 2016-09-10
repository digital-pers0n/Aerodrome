//
//  AppDelegate.h
//  AerodromeHelper
//
//  Created by Terminator on 8/21/16.
//
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSXPCConnection *_connection;
    NSWindowController *_currentDialog;
}


@end

