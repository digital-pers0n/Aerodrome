//
//  AERHelperJoinController.h
//  Aerodrome
//
//  Created by Terminator on 8/21/16.
//
//

#import <Cocoa/Cocoa.h>

@interface AERHelperJoinController : NSWindowController
{
    
    NSXPCConnection *_connection;
    NSString *_network;
    NSDictionary *_scanRecord;
    
    
    IBOutlet NSTextField         *statusMessage;
    
    IBOutlet NSTextField         *networkNameTextField;
    IBOutlet NSSecureTextField   *passwordTextField;
    IBOutlet NSProgressIndicator *progressIndicator;
    
}

+(id)createWithNetworkName:(NSString *)name;

+(id)createWithXPCService:(NSXPCConnection *)xpc;

@property (retain) NSXPCConnection *connection;
@property (copy) NSString *network;

-(IBAction)joinButtonClicked:(id)sender;

@end
