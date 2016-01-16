//
//  AppDelegate.m
//  Aerodrome
//
//  Created by digital_person on 12/22/15.
//  Copyright © 2015 digital_person. All rights reserved.
//

#import "AppDelegate.h"
#import "Aerodrome.h"
#import <CoreWLAN/CoreWLAN.h>
#import <QuartzCore/QuartzCore.h>


#define POWER_OFF           @"Switch Wi-Fi On"
#define POWER_ON            @"Switch Wi-Fi Off"

#define STATUS_ON           @"Wi-Fi: On"
#define STATUS_OFF          @"Wi-Fi: Off"
#define STATUS_SCAN         @"Wi-Fi: Looking For Networks"
#define STATUS_CONNECT      @"Wi-Fi: Running"

#define STATUS_MENU_ICON                [NSImage imageNamed:@"testON"]
#define STATUS_MENU_ICON_CONNECTED		[NSImage imageNamed:@"test"]
#define STATUS_MENU_ICON_OFF            [NSImage imageNamed:@"testOff"]
#define STATUS_MENU_ICON_IBSS           [NSImage imageNamed:@"testIBSS"]

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

@synthesize statusMenu;
@synthesize currentInterface;
//@synthesize connection;



-(void)applicationWillFinishLaunching:(NSNotification *)notification
{
    ProcessSerialNumber psn = {0, kCurrentProcess};
    
    TransformProcessType(&psn, kProcessTransformToUIElementApplication);
    
    self->execute_queue = dispatch_queue_create("thread", nil);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    
    
    connection = [[Aerodrome alloc] init];
    
    self.currentInterface = [CWInterface interfaceWithName:[connection apple80211Interface]];
    

    
    
    [disconnectMenuItem setHidden:YES];
    
    
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    
    statusItem = [bar statusItemWithLength:NSSquareStatusItemLength];
    
    
    imageON = STATUS_MENU_ICON;
    imageOFF = STATUS_MENU_ICON_OFF;
    imageConnected = STATUS_MENU_ICON_CONNECTED;
    imageIBSS = STATUS_MENU_ICON_IBSS;
    
    CGFloat point = 100;
    
    
    
    [imageIBSS setTemplate:YES];
    [imageConnected setTemplate:YES];
    [imageON setTemplate:YES];
    [imageOFF setTemplate:YES];
    
    [statusItem setTarget:self];
    [statusItem setMenu:statusMenu];
    [statusMenu setDelegate:self];
    [statusMenu setMinimumWidth:point];
    [statusItem setImage:imageON];
    
    [scanResultTable setDataSource:self];
    [scanResultTable setDelegate:self];
    
    
    

    
    ssidColumn          = [scanResultTable tableColumnWithIdentifier:@"NETWORK_NAME"];
    bssidColumn         = [scanResultTable tableColumnWithIdentifier:@"BSSID"];
    noiseColumn         = [scanResultTable tableColumnWithIdentifier:@"NOISE"];
    channelColumn       = [scanResultTable tableColumnWithIdentifier:@"CHANNEL"];
    rssiColumn          = [scanResultTable tableColumnWithIdentifier:@"RSSI"];
    securityModeColumn  = [scanResultTable tableColumnWithIdentifier:@"SECURITY"];
    ibssColumn          = [scanResultTable tableColumnWithIdentifier:@"MODE"];
    
    
    
    
    statusMenuItem = [statusMenu insertItemWithTitle:@"title" action:nil keyEquivalent:@"" atIndex:0];
    
//    if([connection isPowerOn] == YES){
//        
//        [statusMenuItem setTitle:STATUS_ON];
//        [statusItem setImage:STATUS_MENU_ICON];
//        [statusMenuItem setHidden:NO];
//        [powerCycleMenuItem setTitle:POWER_ON];
//        
//        if ([[connection ssidName] length] > 0) {
//            
//            if ([[connection opMode]isEqualToString:@"Infrastructure station"]) {
//                
//                [statusItem setImage:STATUS_MENU_ICON_CONNECTED];
//                [statusMenuItem setTitle:STATUS_CONNECT];
//                [disconnectMenuItem setTitle:[NSString stringWithFormat:@"Disconnect from %@", [connection ssidName]]];
//                [disconnectMenuItem setHidden:NO];
//                
//            } else if ([[connection opMode] isEqualToString:@"IBSS (adhoc) station"]){
//                
//                [disconnectMenuItem setTitle:[NSString stringWithFormat:@"Disconnect from %@", [connection ssidName]]];
//                [statusItem setImage:STATUS_MENU_ICON_IBSS];
//                [statusMenuItem setTitle:STATUS_CONNECT];
//                [disconnectMenuItem setHidden:NO];
//            }
//        }
//        
//
//        
//    } else {
//        
//        [statusMenuItem setTitle:STATUS_OFF];
//        [statusItem setImage:STATUS_MENU_ICON_OFF];
//        [powerCycleMenuItem setTitle:POWER_OFF];
//        [statusMenuItem setHidden:NO];
//        
//    }
    
    //[scanDialogWindow setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];

   //Notifications

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMenu)
                                                 name:CWSSIDDidChangeNotification object:nil];
    
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
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    
    scanResult = nil;
    scanResultForTable = nil;
    
}

#pragma mark - Menu Delegate

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    if ([connection isPowerOn] == YES) {
        [[NSRunLoop currentRunLoop] performSelector:@selector(scanResultMenu:)
                                             target:self
                                           argument:menu
                                              order:0
                                              modes:[NSArray arrayWithObject:NSEventTrackingRunLoopMode]];
        

        
    }

}

#pragma mark - Actions

#pragma mark - IBSS Dialog actions

 - (void)ibssNetworkMenuItemPressed:(id)sender
{
    CFStringRef machineName = CSCopyMachineName();
    if( machineName )
    {
        [ibssNetworkNameField setStringValue:(id)CFBridgingRelease(machineName)];
        // CFRelease(machineName);
    }
    
    NSArray *set = [connection channelsList];
    
    for (NSNumber *a in set) {
        [ibssChannelPopupButton addItemWithTitle:[NSString stringWithFormat:@"%@", a ]];
        
    }
    
    
    // select channel 11 as default channel
    [ibssChannelPopupButton selectItemWithTitle:@"11"];
    
    [NSApp activateIgnoringOtherApps:YES];
    [ibssDialogWindow makeKeyAndOrderFront:nil];
}

- (void)ibssCreateButtonPressed:(id)sender
{
    __block int error;
    

    [ibssProgressIndicator setHidden:NO];
    [ibssProgressIndicator startAnimation:self];
    
    NSNumber *channel = [NSNumber numberWithInt:[[[ibssChannelPopupButton selectedItem] title] intValue]];
    
    dispatch_async(self->execute_queue, ^{
        
        error = [connection createIBSSNetworkWithName:[ibssNetworkNameField stringValue] andChannel:[channel intValue]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error != kA11NoErr) {
                
                alert = [connection aerodromeError:@"Failed to create network"
                                                       code:error];
                [alert runModal];
                [ibssProgressIndicator setHidden:YES];
                [ibssProgressIndicator stopAnimation:self];
                
            } else {
                
                [ibssDialogWindow performClose:nil];
                
                [statusItem setImage:imageIBSS];
                [statusMenuItem setTitle:STATUS_CONNECT];
                [disconnectMenuItem setTitle:[NSString stringWithFormat:@"Disconnect from %@", [connection ssidName]]];
                [disconnectMenuItem setHidden:NO];
                [ibssProgressIndicator setHidden:YES];
                [ibssProgressIndicator stopAnimation:self];
            }
            
        });
    });
}

#pragma mark - Join Dialog actions

- (void)joinMenuItemPressed:(id)sender
{
    [joinNetworkNameField setStringValue:@""];
    [joinPasswordTextField setStringValue:@""];

    [NSApp activateIgnoringOtherApps:YES];
    [joinDialogWindow makeKeyAndOrderFront:self];
}

- (void)joinJoinButtonPressed:(id)sender
{
    __block Apple80211Err error;
    [joinProgressIndicator setHidden:NO];
    [joinProgressIndicator startAnimation:self];
    
    dispatch_async(self->execute_queue, ^{
        
        
        error = [connection joinNetworkWithName:[joinNetworkNameField stringValue] andPassword:[joinPasswordTextField stringValue]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error != kA11NoErr) {
                
                if (error == 404) {
                    alert = [connection aerodromeError:@"Network Not Found"
                                                           code:error];
                    [alert runModal];
                    [joinProgressIndicator setHidden:YES];
                    [joinProgressIndicator stopAnimation:self];
                    
                } else {
                    
                    alert = [connection aerodromeError:@"Failed to join network"
                                                           code:error];
                    [alert runModal];
                    [joinProgressIndicator setHidden:YES];
                    [joinProgressIndicator stopAnimation:self];
                    
                }
                
            } else {
                
                [joinDialogWindow performClose:nil];
                [disconnectMenuItem setTitle:[NSString stringWithFormat:@"Disconnect from %@", [connection ssidName]]];
                [disconnectMenuItem setHidden:NO];
                [statusMenuItem setTitle:STATUS_CONNECT];
                [statusItem setImage:imageConnected];
                [joinProgressIndicator setHidden:YES];
                [joinProgressIndicator stopAnimation:self];
                
            }
            
        });
        
    });


    
    
}

- (void)joinScanButtonPressed:(id)sender
{
    //scanResultForTable = [connection scanForNetworks];
    [NSApp activateIgnoringOtherApps:YES];
    [scanDialogWindow makeKeyAndOrderFront:self];
    [joinDialogWindow close];
    
    [scanProgressIndicator setHidden:NO];
    [scanProgressIndicator startAnimation:self];
    dispatch_async(self->execute_queue, ^{
        
        scanResultForTable = [connection scanForNetworks];
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [scanProgressIndicator setHidden:YES];
            [scanProgressIndicator stopAnimation:self];
            [scanResultTable reloadData];
        
        });
        
    });
}


#pragma mark - Menu Actions

- (void)scanResultMenuItemPressed:(id)sender
{
    //NSLog(@"Menu pressed %@", sender);
    
    NSInteger tag = [sender tag];
    NSInteger n = tag - 255;
    
    
    NSDictionary *network = [scanResult objectAtIndex:n];
    
    [joinNetworkNameField setStringValue:@""];
    [joinPasswordTextField setStringValue:@""];

    [joinNetworkNameField setStringValue:[network objectForKey:@"SSID"]];
    [NSApp activateIgnoringOtherApps:YES];
    [joinDialogWindow makeKeyAndOrderFront:self];
}

- (void)scanResultMenu:(NSMenu *)menu
{
    
@autoreleasepool {
    
    

    
   __block NSDictionary *network;
    
    [statusMenuItem setTitle:STATUS_SCAN];
    
    
    
    __block NSInteger i;
    
    
    dispatch_async(self->execute_queue, ^{
        
        if ([scanResult count] == 0) {
            
            
            
            
            scanResult = [connection scanForNetworks];
            //NSLog(@"%@", scanResult);
            sleep(1.5);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                i = 3;
                
                
                
                for(NSString *a in scanResult)
                {
                    
                    NSInteger n     = [scanResult indexOfObject:a];
                    network         = [scanResult objectAtIndex:n];
                    NSInteger tag   = n + 255;
                    ++i;
                    
                    
                    //            scanResultMenuItem = [statusMenu insertItemWithTitle:[NSString stringWithFormat:@"%-5ld  %.16s ", [[network objectForKey:@"RSSI"] integerValue], [[network objectForKey:@"SSID"] UTF8String]]
                    //                                                action:@selector(scanResultMenuItemPressed:)
                    //                                         keyEquivalent:@""
                    //                                               atIndex:i];
                    scanResultMenuItem = [statusMenu insertItemWithTitle:[network objectForKey:@"SSID"]
                                                                  action:@selector(scanResultMenuItemPressed:)
                                                           keyEquivalent:@""
                                                                 atIndex:i];
                    
                    
                    
//                    [scanResultMenuItem setView:view];
//                    [view ]
//                    
//                    [viewString setTitle:[network objectForKey:@"SSID"]];
//                    [viewString setAction:@selector(scanResultMenuItemPressed:)];
//                    [viewString setTag:tag];
//                    [viewString setTarget:self];
                    
                    [scanResultMenuItem setTag:tag];
                    [scanResultMenuItem setTarget:self];
                    
                    
                    
                    //[scanResultMenuItem setImage:imageON];
                    
                    
                    
                }
            });
        } else {
            
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                for(id a in scanResult)
                    
                {
                    
                    //NSLog(@" remove %@", [statusMenu itemAtIndex:4]);
                    [statusMenu removeItemAtIndex:4];
                    
                    
                }
                
                
            });
            
            scanResult = [connection scanForNetworks];
            sleep(1.5);
            //NSLog(@"%@", scanResult);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                i = 3;
                
                
                for(NSString *a in scanResult)
                {
                    NSInteger n = [scanResult indexOfObject:a];
                    network = [scanResult objectAtIndex:n];
                    NSInteger tag = n + 255;
                    ++i;
                    
                    
                    scanResultMenuItem = [statusMenu insertItemWithTitle:[network objectForKey:@"SSID"]
                                                                  action:@selector(scanResultMenuItemPressed:)
                                                           keyEquivalent:@""
                                                                 atIndex:i];
                    [scanResultMenuItem setTag:tag];
                    [scanResultMenuItem setTarget:self];
                    
                }
                
            });
        }
        //    if ([[connection opMode]isEqualToString:@"Infrastructure station"]) {
        //        [statusItem setImage:STATUS_MENU_ICON_CONNECTED];
        //        [statusMenuItem setTitle:STATUS_CONNECT];
        //    } else if ([[connection opMode] isEqualToString:@"IBSS (adhoc) station"]){
        //        [statusItem setImage:STATUS_MENU_ICON_IBSS];
        //        [statusMenuItem setTitle:STATUS_CONNECT];
        //    } else {
        //        [statusMenuItem setTitle:STATUS_ON];
        //    }

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self updateMenu];
            
        });
        
    });
    
}
    
        
    
        
    
}


-(void)switchPower:(id)sender
{
//    [disconnectMenuItem setHidden:YES];
//    
//    if ([connection powerCycle] == YES) {
//        [powerCycleMenuItem setTitle:POWER_ON];
//        [statusMenuItem setTitle:STATUS_ON];
//        [statusItem setImage:imageON];
//
//    } else {
//        [powerCycleMenuItem setTitle:POWER_OFF];
//        [statusMenuItem setTitle:STATUS_OFF];
//        [statusItem setImage:imageOFF];
//        if ([scanResult count] > 0) {
//            for(id a in scanResult){
//                [statusMenu removeItemAtIndex:4];
//            }
//            scanResult = nil;
//            scanResultForTable = nil;
//        }
//    }
    
    [connection powerCycle];
    
}

- (void)disassociate:(id)sender
{
    Apple80211Err error;
    error = [connection disassociateFromNetwork];
    if (error != kA11NoErr) {
        
        alert = [connection aerodromeError:@"Failed to disconnect from netwrok"
                                               code:error];
        [alert runModal];
    }
    [disconnectMenuItem setHidden:YES];
    [statusItem setImage:imageON];
}

- (void)updateMenu
{
    

    
    
    
    
    if ([connection isPowerOn] == YES) {
        [powerCycleMenuItem setTitle:POWER_ON];
        [statusMenuItem setTitle:STATUS_ON];
        
        [statusItem setImage:imageON];
        

        if ([[connection ssidName] length] > 0) {
            [disconnectMenuItem setTitle:[NSString stringWithFormat:@"Disconnect from %@", [connection ssidName]]];
            [disconnectMenuItem setHidden:NO];
            
            
            if ([[connection opMode]isEqualToString:@"Infrastructure station"]) {
                [statusItem setImage:STATUS_MENU_ICON_CONNECTED];
                [statusMenuItem setTitle:STATUS_CONNECT];
            } else if ([[connection opMode] isEqualToString:@"IBSS (adhoc) station"]){
                [statusItem setImage:STATUS_MENU_ICON_IBSS];
                [statusMenuItem setTitle:STATUS_CONNECT];
            }
            
        } else {
            [disconnectMenuItem setHidden:YES];
            
        }

        
    } else {
        [powerCycleMenuItem setTitle:POWER_OFF];
        [statusMenuItem setTitle:STATUS_OFF];
        [statusItem setImage:imageOFF];
        [disconnectMenuItem setHidden:YES];
        
        if ([scanResult count] > 0) {
            for(id a in scanResult){
                [statusMenu removeItemAtIndex:4];
            }
            scanResult = nil;
            scanResultForTable = nil;
        }
    }
    
    
    
    


}

#pragma mark - Scan Dialog Actions

- (void)scanDialogWindowScanButton:(id)sender
{
    [scanProgressIndicator setHidden:NO];
    [scanProgressIndicator startAnimation:self];
    
    dispatch_async(self->execute_queue, ^{
    
        scanResultForTable = [connection scanForNetworks];
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [scanResultTable reloadData];
            [scanProgressIndicator setHidden:YES];
            [scanProgressIndicator stopAnimation:self];
        
        });
        
    });
    
    
    
}

- (void)scanDialogWindowJoinButton:(id)sender
{
    NSInteger index = [scanResultTable selectedRow];
    NSDictionary *network;
    
    if (index >= 0) {
        [joinNetworkNameField setStringValue:@""];
        [joinPasswordTextField setStringValue:@""];
        network = [scanResultForTable objectAtIndex:index];
        [joinNetworkNameField setStringValue:[network valueForKey:@"SSID"]];
        [NSApp activateIgnoringOtherApps:YES];
        [joinDialogWindow makeKeyAndOrderFront:self];
        
    }

}

#pragma mark -
#pragma mark NSTableDataSource Protocol


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSDictionary *network;
    NSString *mode;
    
    if (tableView == scanResultTable) {
        
        
        
        if (row < [scanResultForTable count]) {
            
            network = [scanResultForTable objectAtIndex:row];
            
            if (tableColumn == ssidColumn) {
                return [network valueForKey:@"SSID"];
            }
            if (tableColumn == bssidColumn) {
                return [network valueForKey:@"BSSID"];
            }
            if (tableColumn == channelColumn) {
                return [[network valueForKey:@"CHANNEL"] stringValue];
            }
            if (tableColumn == rssiColumn) {
                return [[network valueForKey:@"RSSI"] stringValue];
            }
            if (tableColumn == noiseColumn) {
                return [[network valueForKey:@"NOISE"] stringValue];
                
            }
            if (tableColumn == securityModeColumn) {
                return [network valueForKey:@"SECURITY"];
            }
            if (tableColumn == ibssColumn) {
                
                mode = [[network valueForKey:@"AP_MODE"] stringValue];
                
                if ([mode isEqualToString:@"1"]) {
                    return @"IBSS";
                } else if([mode isEqualToString:@"2"]){
                    return @"AP";
                } else {
                    return [[network valueForKey:@"AP_MODE"] stringValue];
                }
                
                
                
            }
            
            
            
            
        }
    }
    
    
    return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return (scanResultForTable ? [scanResultForTable count] : 0);
}


@end
