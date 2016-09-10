//
//  AERHelperCreateController.h
//  Aerodrome
//
//  Created by Terminator on 8/22/16.
//
//

#import <Cocoa/Cocoa.h>

@interface AERHelperCreateController : NSWindowController
{
    
    //IBOutlet NSWindow *window_;
    
    NSXPCConnection *_connection;
    
    
    NSArray *_channels;
    
    IBOutlet NSTextField *statusMessage;
    //    IBOutlet NSButton *createButton;
    //    IBOutlet NSButton *cancelButton;
    
    IBOutlet NSTextField *networkNameTextField;
    IBOutlet NSPopUpButton *channelPopupButton;
    
    IBOutlet NSProgressIndicator    *progressIndicator;
}

@property(retain)   NSXPCConnection *connection;
@property(copy)     NSArray *channels;

+(id)createWithChannels:(NSArray *)channels;

+(id)createWithXPCService:(NSXPCConnection *)service;
+(id)createWithXPCService:(NSXPCConnection *)service andChannels:(NSArray *)channelsArray;

-(IBAction)createButtonPressed:(id)sender;

@end
