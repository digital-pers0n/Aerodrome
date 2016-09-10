//
//  AppDelegate.h
//  Aerodrome
//
//  Created by Terminator on 7/22/16.
//
//

#import <Cocoa/Cocoa.h>



@class CWInterface, AERHelper, AERController, AERStatusMenuItemView, AERWLClient;
//@class AERMenu, AERProgressIndicator;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>
{
    
   // AERHelper *helper;
    dispatch_queue_t execute_queue;
    dispatch_source_t _updateTimer;
    dispatch_source_t _activityTimer;
    //BOOL    _shouldStartScanUpdateTimer;
    BOOL    _isMenuOpen;
    BOOL    _isAssociated;
    BOOL    _isPowered;
    
    //Menu
    NSStatusItem *menuStatusBarItem;
    
    NSMenu  *menu;
    
    AERStatusMenuItemView  *statusMenuItem;
    
    //Daemon
//    NSXPCConnection *connection;
    //AERWLInterface  *interface;
    AERController *interface;
    
    AERWLClient *client;
    
    NSArray *networks;
    
    NSDictionary *menuBarIcons;
    
    //CoreWlan
    CWInterface *coreWlanIterface;
    
    //Dialogs
    //NSWindowController *currentDialog;
    
}

-(void)networkItemClicked:(id)sender;


@end

