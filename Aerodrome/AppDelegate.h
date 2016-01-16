//
//  AppDelegate.h
//  Aerodrome
//
//  Created by digital_person on 12/22/15.
//  Copyright © 2015 digital_person. All rights reserved.
// 

#import <Cocoa/Cocoa.h>
#import "Apple80211.h"
#import "apple80211_ioctl.h"
#import "apple80211_var.h"
#import "Apple80211Err.h"




@class CWInterface;
@class Aerodrome;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate, NSTableViewDelegate, NSTableViewDataSource>

{
    
    dispatch_queue_t execute_queue;
    
    //Notification handling
    
    CWInterface *currentInterface;
    Aerodrome   *connection;
    
    NSAlert     *alert;
    IBOutlet NSView      *view;
    IBOutlet NSButton   *viewString;
    
    //Data
    NSArray     *scanResult;
    NSArray     *scanResultForTable;
    
    
    
    
    //Menu
    
    NSStatusItem        *statusItem;
    
    IBOutlet NSMenuItem          *scanResultMenuItem;
    NSMenuItem                   *statusMenuItem;
    
    IBOutlet NSMenuItem *powerCycleMenuItem;
    IBOutlet NSMenuItem *disconnectMenuItem;
    
    
    //Join Dialog
    
    IBOutlet NSTextField            *joinNetworkNameField;
    IBOutlet NSSecureTextField      *joinPasswordTextField;
    IBOutlet NSWindow               *joinDialogWindow;
    IBOutlet NSButton               *joinJoinButton;
    IBOutlet NSButton               *joinScanButton;
    IBOutlet NSProgressIndicator    *joinProgressIndicator;
    
    //Scan Window
    
    IBOutlet NSWindow               *scanDialogWindow;
    IBOutlet NSButton               *scanScanButton;
    IBOutlet NSButton               *scanJoinButton;
    IBOutlet NSTableView            *scanResultTable;
    IBOutlet NSProgressIndicator    *scanProgressIndicator;
    NSTableColumn                   *ssidColumn;
    NSTableColumn                   *bssidColumn;
    NSTableColumn                   *channelColumn;
    NSTableColumn                   *securityModeColumn;
    NSTableColumn                   *ibssColumn;
    NSTableColumn                   *rssiColumn;
    NSTableColumn                   *noiseColumn;
    
    //IBSS Dialog
    IBOutlet NSWindow               *ibssDialogWindow;
    IBOutlet NSTextField            *ibssNetworkNameField;
    IBOutlet NSButton               *ibssCreateButton;
    IBOutlet NSPopUpButton          *ibssChannelPopupButton;
    IBOutlet NSProgressIndicator    *ibssProgressIndicator;
    
    //Icons
    NSImage *imageON;
    NSImage *imageOFF;
    NSImage *imageIBSS;
    NSImage *imageConnected;
    
}

@property (assign) IBOutlet     NSMenu      *statusMenu;
@property (readwrite, retain)   CWInterface *currentInterface;
//@property (assign)              Aerodrome   *connection;



- (IBAction)disassociate:(id)sender;
- (IBAction)switchPower:(id)sender;

// Scan Menu
- (void)scanResultMenu:(NSMenu *)menu;
- (void)scanResultMenuItemPressed:(id)sender;

// Join Dialog
- (IBAction)joinMenuItemPressed:(id)sender;
- (IBAction)joinJoinButtonPressed:(id)sender;
- (IBAction)joinScanButtonPressed:(id)sender;

// IBSS Dialog
- (IBAction)ibssNetworkMenuItemPressed:(id)sender;
- (IBAction)ibssCreateButtonPressed:(id)sender;

// Scan Dialog Window
- (IBAction)scanDialogWindowJoinButton:(id)sender;
- (IBAction)scanDialogWindowScanButton:(id)sender;



@end

