//
//  AERHelperScan.h
//  Aerodrome
//
//  Created by Terminator on 8/22/16.
//
//

#import <Cocoa/Cocoa.h>

@interface AERHelperScan : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>
{
    NSXPCConnection *_connection;
    NSArray *_scan;
    NSDictionary *_network;
    //    NSWindowController *_joinDialog;
    
    IBOutlet NSTableView *_scanTable;
    IBOutlet NSProgressIndicator *scanIndicator;
    IBOutlet NSTextField *scanStatusMessage;
    
    IBOutlet NSWindow    *joinDialog;
    IBOutlet NSTextField *joinNetworkNameField;
    IBOutlet NSTextField *joinNetworkPasswordField;
    IBOutlet NSTextField *statusMessage;
    IBOutlet NSProgressIndicator *joinIndicator;
    
    
    //    IBOutlet NSButton *joinButton;
}

//@property(retain) NSWindowController *joinDialog;
@property(retain) NSXPCConnection *connection;
//@property(weak) NSArray *scan;

+(id)createScanDialog;
+(id)createWithXPCService:(NSXPCConnection *)service;

-(IBAction)joinButtonClicked:(id)sender;
-(IBAction)refreshButtonClicked:(id)sender;

-(IBAction)joinDialogCancelButtonClicked:(id)sender;
-(IBAction)joinDialogOkButtonClicked:(id)sender;


@end
