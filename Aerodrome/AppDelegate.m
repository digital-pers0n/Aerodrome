//
//  AppDelegate.m
//  Aerodrome
//
//  Created by Terminator on 7/22/16.
//
//



#import "AppDelegate.h"
#import "AERMenuItemView.h"
#import "AEROptions.h"
#import "AERStatusMenuItemView.h"
#import "NSMenu+AERMenu.h"
#import "AERController.h"

#import "NSMenuItem+AERNetworkMenuItem.h"

//#import "AERWLInterface+AERWLScanMenu.h"
//#import "AERWLInterface+Icons.h"

#import "NSMenu+UpdateMenu.h"

#import "NSStatusItem+AERStausItem.h"

#import "NSDictionary+AERIcons.h"
#import "AERWLClient.h"

//#import "AERJoinDialog.h"
//#import "AERCreateNetworkDialog.h"
//#import "AERScanWindow.h"
#import "AEROptions.h"
#import <CoreWLAN/CoreWLAN.h>
#import <crt_externs.h>
#import <IOKit/pwr_mgt/IOPMLib.h>


extern CFStringRef SCDynamicStoreCopyComputerName();


@interface AppDelegate ()
{
    IOPMAssertionID assertionID;
}

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate
- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    
    self->execute_queue = dispatch_queue_create("thread", nil);
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {


    
    interface = [[AERController alloc] init];
    
    client = [[AERWLClient alloc] init];

    menuBarIcons = [[NSDictionary alloc] menuBarIcons];
    
    [self  setupMenu];

    coreWlanIterface =[[CWInterface alloc] initWithInterfaceName:[client ifName]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMenu)
                                                 name:CWSSIDDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMenu)
                                                 name:CWPowerDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMenu)
                                                 name:CWModeDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMenu)
                                                 name:CWBSSIDDidChangeNotification
                                               object:nil];
    
    [self updateMenu];
    
    if (self->_isPowered) {
        [self performScan:self];
    }
    
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(receiveSleepNotification:)
                                                               name:NSWorkspaceWillSleepNotification
                                                             object:nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(receiveDisplayWakeNotification:)
                                                               name:NSWorkspaceScreensDidWakeNotification
                                                             object:nil];
    
    
    

    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

// Menu setup

#pragma mark - Menu

-(void) updateMenu
{
    
    if ([client isPowerOn]) {
        self->_isPowered = YES;
        if ([client isActive]) {
            [[menu itemWithTag:AERMenuStatus] setTitle:AERNETWORK_STATUS_ACTIVE];
            self->_isAssociated = YES;
            [[menu itemWithTag:AERMenuDisconnect] setTitle:[NSString stringWithFormat:@"Disconnect from %@", [client ssidName]]];
            [[menu itemWithTag:AERMenuDisconnect] setHidden:NO];
           [menuStatusBarItem setImage:[menuBarIcons objectForKey:[client isIBSS] ? AERICON_STATUS_IBSS : AERICON_STATUS_100]];
            
        } else {
            [[menu itemWithTag:AERMenuDisconnect] setHidden:YES];
            [[menu itemWithTag:AERMenuStatus] setTitle:AERNETWORK_STATUS_DEFAULT];
            [menuStatusBarItem setImage:[menuBarIcons objectForKey:AERICON_STATUS_IDLE]];
            self->_isAssociated = NO;
            [self cancelActivity];
        }
    } else {
        
        [self cleanMenu];
        networks = nil;
        [[menu itemWithTag:AERMenuStatus] setTitle:AERNETWORK_STATUS_OFF];
        [menuStatusBarItem setImage:[menuBarIcons objectForKey:AERICON_STATUS_OFF]];
        self->_isAssociated = NO;
        self->_isPowered = NO;
    }
    
   
}



- (void) setupMenu
{
    

    menu = [NSMenu new];
    
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    

    
    menuStatusBarItem = [bar statusItemWithLength:NSSquareStatusItemLength];

    menuStatusBarItem.target = self;
    menuStatusBarItem.menu = menu;
    
  
    menu.delegate = self;
    
   
    
    
    //[menuStatusBarItem setTitle:@"W"];
//    NSImage *img = [NSImage imageNamed:@"AER"];
//    [img setTemplate:YES];
//    [menuStatusBarItem setImage:img];
    
    [[menu insertItemWithTitle:@"Relaunch"
                        action:@selector(restartMenuItemClicked)
                 keyEquivalent:@"q"
                           tag:AERMenuRestart
                       atIndex:0] setAlternate:YES];
    
    
    [[menu itemAtIndex:0] setKeyEquivalentModifierMask:NSCommandKeyMask | NSAlternateKeyMask];
    [[menu itemAtIndex:0] setTarget:self];
    
/***********************************************************************/
    
    [[menu insertItemWithTitle:@"Quit"
                        action:@selector(terminate:)
                 keyEquivalent:@"q"
                           tag:AERMenuQuit
                       atIndex:0] setKeyEquivalentModifierMask:NSCommandKeyMask];
    
    [menu insertSeparatorWithTag:AERMenuFourthSeparator atIndex:0];
    
/***********************************************************************/
    
    [[menu insertItemWithTitle:@"Open Preferences..."
                        action:@selector(openPreferencesMenuItemClicked:)
                 keyEquivalent:@"p"
                           tag:AERMenuPreferences
                       atIndex:0] setKeyEquivalentModifierMask:NSShiftKeyMask];
    
    [[menu itemAtIndex:0] setTarget:self];
    
/***********************************************************************/
    
    
    
    [[menu insertItemWithTitle:@"Show Scan Dialog"
                        action:@selector(scanWindowMenuItemClicked:)
                 keyEquivalent:@"j"
                           tag:AERMenuShowScanDiagAlt
                       atIndex:0] setAlternate:YES];
    
    [[menu itemAtIndex:0] setKeyEquivalentModifierMask:NSShiftKeyMask | NSAlternateKeyMask];
    [[menu itemAtIndex:0] setTarget:self];
    
/***********************************************************************/

    [[menu insertItemWithTitle:@"Join Other Network..."
                        action:@selector(joinOtherMenuItemClicked:)
                 keyEquivalent:@"j"
                           tag:AERMenuManualJoin
                       atIndex:0] setKeyEquivalentModifierMask:NSShiftKeyMask];
    
    [[menu itemAtIndex:0] setTarget:self];
    
/***********************************************************************/
    
    [[menu insertItemWithTitle:@"Create Network"
                        action:@selector(ibssWithoutPromptMenuItemClicked:)
                 keyEquivalent:@"c"
                           tag:AERMenuCreateIBSSAlt
                       atIndex:0] setAlternate:YES];
    
    [[menu itemAtIndex:0] setKeyEquivalentModifierMask:NSShiftKeyMask | NSAlternateKeyMask];
    [[menu itemAtIndex:0] setTarget:self];
    
/***********************************************************************/

    [[menu insertItemWithTitle:@"Create Network..."
                        action:@selector(ibssCreateButtonClicked:)
                 keyEquivalent:@"c"
                           tag:AERMenuCreateIBSS
                       atIndex:0] setKeyEquivalentModifierMask:NSShiftKeyMask];
    
    [[menu itemAtIndex:0] setTarget:self];
    
/***********************************************************************/
    
    [menu insertItemHiddenWithTitle:@"Devices" action:nil keyEquivalent:@"" tag:AERMenuDevices atIndex:0];
    
/***********************************************************************/
     [menu insertItemHiddenWithTitle:@"No Networks" action:nil keyEquivalent:@"" tag:AERMenuNoNetworks atIndex:0];
    
    [menu insertSeparatorWithTag:AERMenuFirstSeparator atIndex:0];

/***********************************************************************/
    
    [[menu insertItemWithTitle:[client isPowerOn] ? AERPOWER_SWITCH_OFF : AERPOWER_SWITCH_ON
                        action:@selector(switchPowerMenuClicked:)
                 keyEquivalent:@"s"
                           tag:AERMenuPowerSwitch
                       atIndex:0] setKeyEquivalentModifierMask:NSShiftKeyMask];
    
/***********************************************************************/
    
    [[menu insertItemHiddenWithTitle:@"Disconnect"
                              action:@selector(disconnectMenuItemClicked:)
                       keyEquivalent:@"d"
                                 tag:AERMenuDisconnect
                             atIndex:0] setKeyEquivalentModifierMask:NSShiftKeyMask];

/***********************************************************************/
    
    [menu insertItemDisabledWithTitle:@"< Status Item >" tag:AERMenuStatus atIndex:0];
    //    [menu insertMenuItemWithTitle:@"Status" action:nil key:@"" index:0 andTag:AERMenuStatus];
    statusMenuItem = [[AERStatusMenuItemView alloc] initWithFrame:NSMakeRect(0, 0, 260, 19) menuItem:[menu itemAtIndex:0]];
    [[menu itemAtIndex:0] setView:statusMenuItem];
    //
    //
    

}




#pragma mark - menu delegate

-(void)menuNeedsUpdate:(NSMenu *)aMenu
{
    

}

- (void)menuWillOpen:(NSMenu *)aMenu
{

    if (self->_isPowered) {
        
        [self performScan:self];

        self->_isMenuOpen = YES;
        
        [self startScanUpdateTimerWithInterval:15];

        
        
    }
}


- (void)menuDidClose:(NSMenu *)m
{
    self->_isMenuOpen = NO;
    if (self->_updateTimer) {
        dispatch_source_cancel(self->_updateTimer);
    }
    if (self->_isPowered) {
        //[self cleanMenu];
    }
    
    // Custom item view - ghost highlight fix
    
    if ([[menu highlightedItem] representedObject]) {
        
        
        __weak NSMenuItem *i = [menu highlightedItem];
        int idx = (int)[menu indexOfItem:i];
        [menu removeItem:i];
        [menu insertItem:i atIndex:idx];
        
       
        
    }
    
}

- (void)menu:(NSMenu *)menu willHighlightItem:(NSMenuItem *)item{
    
    if (self->_updateTimer) {
        dispatch_source_cancel(self->_updateTimer);
     
    }
       //[self startScanUpdateTimerWithInterval:25];
}

#pragma mark - activity timer

-(void)cancelActivity
{
    if(self->_activityTimer){
        dispatch_source_cancel(self->_activityTimer);
    }
    
    
    if (self->assertionID) {
        
        IOPMAssertionRelease(assertionID);
        
        
        
        puts("cancel activity");
        
    }
}

-(void)receiveDisplayWakeNotification:(NSNotification *)note{
    
    [self cancelActivity];
    
}

-(void)receiveSleepNotification:(NSNotification *)note
{
    NSLog(@"notification: %@", note.name);
    
 if (self->_isAssociated) {
        
        //[self updateActivity];
      [self startActivityTimerWithInterval:60 * 60];
 }
    
    
}


-(void)updateActivityWithInterval:(int)sec
{
    //if (self->_isAssociated) {
    // kIOPMAssertionTypeNoDisplaySleep prevents display sleep,
    // kIOPMAssertionTypeNoIdleSleep prevents idle sleep
    
    //reasonForActivity is a descriptive string used by the system whenever it needs
    //  to tell the user why the system is not sleeping. For example,
    //  "Mail Compacting Mailboxes" would be a useful string.
    
    //  NOTE: IOPMAssertionCreateWithName limits the string to 128 characters.
    
    //[self cancelActivity];
    
    CFStringRef reasonForActivity= CFSTR("Active Wi-Fi connection");
    
   //static IOPMAssertionID assertionID  = 0;
    IOReturn success;
    
    //if (!self->assertionID) {
//        
//        success = IOPMAssertionCreateWithName(kIOPMAssertPreventUserIdleSystemSleep,
//                                                       kIOPMAssertionLevelOn, reasonForActivity, &assertionID);
    
    success = IOPMAssertionCreateWithDescription(kIOPMAssertNetworkClientActive, reasonForActivity, CFSTR("Wi-Fi is active"), NULL, NULL, sec, kIOPMAssertionTimeoutActionLog, &assertionID);
        puts("assign");
    //}


        
        //success = IOPMAssertionDeclareUserActivity(reasonForActivity, kIOPMUserActiveLocal, &assertionID);
    if (success == kIOReturnSuccess)
    {
        
        //Add the work you need to do without
        //  the system sleeping here.
        
        //UpdateSystemActivity(0);
        
        puts("success");
        
        
        if (!self->_isAssociated && self->assertionID) {
            
            success = IOPMAssertionRelease(assertionID);
            assertionID = 0;
            puts("release");
        }
       
        //The system will be able to sleep again.
    }
    

    
        
        //UpdateSystemActivity(0);
    //}
    //puts("sleep timer");
    
    
    printf("bool: %i, pmid: %i \n", self->_isAssociated, assertionID);
    

   
}

-(void)startActivityTimerWithInterval:(int)sec
{
    if(self->_activityTimer){
        dispatch_source_cancel(self->_activityTimer);
    }
    
    //[self cancelActivity];
    
    if (!self->_isAssociated) {
        
        
        return;
    }
    
    [self updateActivityWithInterval:sec];
    
    self->_activityTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
    dispatch_source_set_timer(self->_activityTimer, dispatch_time(0, sec * NSEC_PER_SEC), 1.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self->_activityTimer, ^{
        dispatch_source_cancel(self->_activityTimer);
        
        [self updateActivityWithInterval:sec];
        
        return [self startActivityTimerWithInterval:sec];
    });
    
     dispatch_resume(self->_activityTimer);
}

#pragma mark - scan

-(void)startScanUpdateTimerWithInterval:(int)sec
{
    if (!self->_isMenuOpen) {
        return;
    }
    
    //dispatch_source_t timer = self->_updateTimer;
    if(self->_updateTimer){
        dispatch_source_cancel(self->_updateTimer);
    }
    self->_updateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
    //self->_updateTimer = timer;
    
    dispatch_source_set_timer(self->_updateTimer, dispatch_time(0, sec * NSEC_PER_SEC), 1.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self->_updateTimer, ^{

        dispatch_source_cancel(self->_updateTimer);

        [self performScan:self];
        
        return [self startScanUpdateTimerWithInterval:sec];
        
    });
    
    
    
    dispatch_resume(self->_updateTimer);
    
}



-(void)cleanMenu
{
    

    
    for (NSMenuItem *i in [menu itemArray])
    {
        @autoreleasepool {
            
                
            
            if ([i tag] < 1000)
            {
               
                [menu removeItem:i];
                
                //puts("item removed");
            }
        
            
            
        }
        
    }
    networks = nil;
    //    NSArray *a = [menu itemArray];
    //    sleep(0);
    
    
}

-(void)networkItemClicked:(id)sender
{
    
//    NSInteger tag = [sender tag];
//    NSInteger n = tag - 100;
    
//    interface.currentDialog = [AERJoinDialog createWithXPCService:interface->connection];
//    
//     [(AERJoinDialog *)interface.currentDialog setNetwork:[sender title]];
//    
//    [NSApp activateIgnoringOtherApps:YES];
//    [interface.currentDialog showWindow:self];
//    
//    [[interface.currentDialog window] makeKeyAndOrderFront:self];
    
    //[interface joinNetwork:[sender title] withPassword:nil];
    

    
    [interface showJoinDialogWithNetworkName:[[sender representedObject] objectForKey:@"SSID"]];
   
    
   // [[NSString stringWithFormat:@"Sender: %@, network: %@", [sender title], [networks objectAtIndex:n]] writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
}



-(void)performScan:(id)sender
{
    
        [[menu itemWithTag:AERMenuStatus] setTitle:AERNETWORK_STATUS_SCAN];
        
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [statusMenuItem startIndicator];
        //[menuStatusBarItem startAnimation];
        //[menuStatusBarItem startAnimationWithIcons:menuBarIcons];
    });
    

    
//    if (networks) {
//        
//        [self cleanMenu];
//        
//    }
    
    // dispatch_async(self->execute_queue, ^{
        networks = [client scan];

        
        //});
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (self->_isMenuOpen) {
             //[interface populateMenu:menu withNetworks:networks andAction:@selector(networkItemClicked:)];
            //[interface smartUpdate:menu withNetowrks:networks andAction:@selector(networkItemClicked:)];
            
            [menu updateMenuWithNetworks:networks andAction:@selector(networkItemClicked:)];
        }
    


     
        [[menu itemWithTag:AERMenuStatus] setTitle: self->_isAssociated ? AERNETWORK_STATUS_ACTIVE : AERNETWORK_STATUS_DEFAULT];
    [statusMenuItem stopIndicator];
    
});
    
}


#pragma mark - Menu Actions

#pragma mark - Switch Power

-(void)switchPowerMenuClicked:(id)sender
{
    if([client powerSwitch])
    {
        [[menu itemWithTag:AERMenuPowerSwitch] setTitle:@"Switch Wi-Fi Off"];
        
    } else {
        
        [[menu itemWithTag:AERMenuPowerSwitch] setTitle:@"Switch Wi-Fi On"];
    }
    
    
   
}

#pragma mark - Create IBSS

-(void)ibssWithoutPromptMenuItemClicked:(id)sender
{
    // CFStringRef machineName = CSCopyMachineName(); //Deprecated
    //[interface createIBSS:CFBridgingRelease(machineName) withChannel:11];

    
    NSString *machineName;
    
    char name[32];
    bzero(&name, 32);
    gethostname((char *)&name, 32);
    
    machineName = [[NSString stringWithCString:name encoding:NSUTF8StringEncoding] stringByDeletingPathExtension];
    if (machineName) {

        [client createIBSS:machineName withChannel:11];
    } else {
       [client createIBSS:@"My Network" withChannel:11];
    }
  
    
    //NSNumber *channel = [NSNumber numberWithInt:11];
    
    
    


    
}

-(void)ibssCreateButtonClicked:(id)sender
{

    [interface showCreateDialog];

//    interface.currentDialog = [AERCreateNetworkDialog createWithXPCService:interface->connection andChannels:[interface channels]];
//    //interface.currentDialog = [AERCreateNetworkDialog createWithXPCService:interface->connection]; //[AERCreateNetworkDialog createWithInterface:interface];
//    
//    [NSApp activateIgnoringOtherApps:YES];
//    [interface.currentDialog showWindow:self];
//    
//    [[interface.currentDialog window] makeKeyAndOrderFront:self];
   
    

    
    
}


#pragma mark - Join Network

-(void)joinOtherMenuItemClicked:(id)sender
{
    [interface showJoinDialogWithNetworkName:@""];
    
//    interface.currentDialog = [AERJoinDialog createWithXPCService:interface->connection];
//    
//    [(AERJoinDialog *)interface.currentDialog setNetwork:@""];
//    
//    [NSApp activateIgnoringOtherApps:YES];
//    [interface.currentDialog showWindow:self];
//    
//    [[interface.currentDialog window] makeKeyAndOrderFront:self];

}

-(void)scanWindowMenuItemClicked:(id)sender
{
    [interface showScanDialog];
//    
//    interface.currentDialog = [AERScanWindow createWithXPCService:interface->connection];
//    
//
//    
//    [NSApp activateIgnoringOtherApps:YES];
//    [interface.currentDialog showWindow:self];
//    
//    [[interface.currentDialog window] makeKeyAndOrderFront:self];
}

#pragma mark - Open Preferences
-(void)openPreferencesMenuItemClicked:(id)sender
{
    [interface showPreferencesDialog];
}

#pragma mark - Disconnect
-(void)disconnectMenuItemClicked:(id)sender
{
    [client disconnect];
    
}

#pragma mark - Restart application

-(void)restartMenuItemClicked
{
    
    
    [[NSWorkspace sharedWorkspace] launchApplicationAtURL:[[NSBundle mainBundle] bundleURL]
                                                  options:NSWorkspaceLaunchWithoutActivation | NSWorkspaceLaunchNewInstance
                                            configuration:@{}
                                                    error:nil];
    [NSApp terminate:self];
    
}

@end
