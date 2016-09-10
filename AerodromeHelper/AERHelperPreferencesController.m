//
//  AERHelperPreferencesController.m
//  Aerodrome
//
//  Created by Terminator on 8/23/16.
//
//

#import "AERHelperPreferencesController.h"
#import "AEROptions.h"
#import "AERHelperPreferences.h"
#import "NSDictionary+AERNetwork.h"

@interface AERHelperPreferencesController ()

@end

@implementation AERHelperPreferencesController

-(instancetype)init
{
    if (self = [super initWithWindowNibName:@"AERHelperPreferencesController"]) {
        
        networksList = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:PREFS_NETWORKS_KEY] copyItems:YES];
    }
    
//    [[AERHelperPreferences alloc] addNetowrkToList:@{@"SSID_STR": @"Testing Item",
//                                                     @"BSSID": @"aa:bb:cc:dd:ee:ff",
//                                                     @"SSID": [@"dfsk" dataUsingEncoding:NSUTF8StringEncoding],
//                                                     @"WPA_IE": [NSNumber numberWithInt:32]} withPassword:@"abracadabra"];
    
    return self;
}

+(id)createPreferencesWindow
{
    return [[AERHelperPreferencesController alloc] init];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    rememberNetworks = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:PREFS_REMEMBER_PREVIOUS_NETWORKS_KEY];
    NSLog(@" state before %li", (long)checkButton.state);
    
    checkButton.state = rememberNetworks;
    
    NSLog(@" state after %li", (long)checkButton.state);
    
    
    [networksTable setDataSource:self];
    [networksTable setDelegate:self];
    
    //    NSDictionary *network = @{@"SSID": @"Catanella", @"BSSID": @"78:e4:00:4a:01:29", @"SECURITY": @"WEP", @"PASS": @"LizzyNanaRaina"};
    //    [tools addNetowrkToList:network];
    
    
    
    
    ssidColumn          = [networksTable tableColumnWithIdentifier:@"SSID"];
    
    securityModeColumn  = [networksTable tableColumnWithIdentifier:@"SECURITY"];
    
    
    [[self window] center];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (void)checkButtonPressed:(id)sender


{
    // NSLog(@"check button state before %li", (long)checkButton.state);
    
    if ([checkButton state] == NSOnState) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PREFS_REMEMBER_PREVIOUS_NETWORKS_KEY];
    } else {
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREFS_REMEMBER_PREVIOUS_NETWORKS_KEY];
    }
    
    
}

-(void)deleteNetworkButtonPressed:(id)sender{
    
    
    [[AERHelperPreferences sharedPreferences] removeNetworkFromKeychain:[networksList objectAtIndex:[networksTable selectedRow]]];
    
    [networksList removeObjectAtIndex:[networksTable selectedRow]];
    [networksTable reloadData];
    [[NSUserDefaults standardUserDefaults] setObject:networksList forKey:PREFS_NETWORKS_KEY];
  
}

#pragma mark - Previous Networks TableView

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSDictionary *network;
    //    NSString *mode;
    //NSArray *list = [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_NETWORKS_KEY];
    
    if (tableView == networksTable) {
        
        
        
        if (row < [networksList count]) {
            
            network = [networksList objectAtIndex:row];
            
            if (tableColumn == ssidColumn) {
                return [network valueForKey:@"SSID_STR"];
            }
            
            if (tableColumn == securityModeColumn) {
                return [network valueForKey:@"SECURITY"];
            }
            
            
            
            
        }
    }
    
    
    return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    //NSArray *network = [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_NETWORKS_KEY];
    
    return (networksList ? [networksList count] : 0);
}

@end
