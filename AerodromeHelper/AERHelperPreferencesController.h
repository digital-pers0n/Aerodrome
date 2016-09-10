//
//  AERHelperPreferencesController.h
//  Aerodrome
//
//  Created by Terminator on 8/23/16.
//
//

#import <Cocoa/Cocoa.h>



@interface AERHelperPreferencesController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>
{
    // Previous Networks
    
    BOOL rememberNetworks;
    IBOutlet NSButton *checkButton;

    
    // Table
    
    IBOutlet NSTableView *networksTable;
    NSTableColumn                   *ssidColumn;
    NSTableColumn                   *securityModeColumn;
    
    
    
    NSMutableArray  *networksList;
}

+(id)createPreferencesWindow;

-(IBAction)checkButtonPressed:(id)sender;
-(IBAction)deleteNetworkButtonPressed:(id)sender;

@end
