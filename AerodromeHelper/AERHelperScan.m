//
//  AERHelperScan.m
//  Aerodrome
//
//  Created by Terminator on 8/22/16.
//
//

#import "AERHelperScan.h"
#import "aerwldProtocol.h"
#import "AERWLClient.h"
#import "AERWLNetwork.h"
#import "AERHelperPreferences.h"

#import "NSDictionary+AERNetwork.h"

#include <sys/types.h>
#include <sys/socket.h>
#include <net/ethernet.h>
#import <CoreWlan/CoreWLANTypes.h>
#import <CoreWLAN/CoreWLANUtil.h>
#import <Security/Security.h>

typedef struct CF_BRIDGED_TYPE(id) OpaqueSecTrustedApplicationGroupRef *SecTrustedApplicationGroupRef;

extern OSStatus SecTrustedApplicationCreateApplicationGroup();

#define tableColumn(x) [self->_scanTable tableColumnWithIdentifier:x]

@interface AERHelperScan ()

@end

@implementation AERHelperScan

-(id)initWithXPCService:(NSXPCConnection *)connection
{
    self = [super initWithWindowNibName:@"AERHelperScan"];
    self.connection = connection;
    
    //[self getScanResult];
    
    //[[NSNotificationCenter defaultCenter] addObserver:[self window] selector:@selector(close:) name:NSWindowWillCloseNotification object:[self window]];
    
    
    
    
    
    return self;
}

+(id)createScanDialog
{
    return [[AERHelperScan alloc] initWithWindowNibName:@"AERHelperScan"];
}

+(id)createWithXPCService:(NSXPCConnection *)service
{
    return [[AERHelperScan alloc] initWithXPCService:service];
}

//-(void)dealloc
//{   self.connection = NULL;
//    self->_scan = NULL;
//    self->_scanTable = NULL;
//   // self.joinDialog = NULL;
//}



- (void)windowDidLoad {
    
    
 
    
    [super windowDidLoad];
    
    
    
    [self->_scanTable setDelegate:self];
    [self->_scanTable setDataSource:self];
    [self->scanIndicator setHidden:YES];
    [self->joinIndicator setHidden:YES];
    [self->scanStatusMessage setHidden:YES];
    
    
    
    NSSortDescriptor *RSSISortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"RSSI"
                                                                         ascending:YES
                                                                          selector:@selector(compare:)];
    [tableColumn(@"RSSI") setSortDescriptorPrototype:RSSISortDescriptor];
    
    NSSortDescriptor *channelSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"CHANNEL"
                                                                            ascending:YES
                                                                             selector:@selector(compare:)];
    [tableColumn(@"CHANNEL") setSortDescriptorPrototype:channelSortDescriptor];
    
    
    //    if (!self->_scan) {
    //
    //        [self getScanResult];
    //    }
    
    [self refreshButtonClicked:nil];
    
    
    
    
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
    //[self->_scanTable reloadData];
    //});
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


-(void)getScanResult
{
    //self->_scan = [[AERWLClient sharedClient] scan];
    
//    [[self.connection remoteObjectProxy] scanForNetwork:^(NSArray *rep) {
//        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self->_scan = rep;
//        //});
//    }];
    
    self->_scan = [[AERWLNetwork connection] scanForNetworkWithName:nil];
    
    sleep(1);
}

#pragma mark - Actions
-(void)refreshButtonClicked:(id)sender
{
    [self->scanIndicator setHidden:NO];
    [self->scanIndicator startAnimation:self];
    [self->scanStatusMessage setHidden:NO];
    [self->scanStatusMessage setStringValue:@"Looking For Networks..."];
    [sender setEnabled:NO];
    dispatch_async(dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT), ^{
    
        [self getScanResult];
        
    });
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        

        

        
        [self->_scanTable reloadData];
        [sender setEnabled:YES];
        [self->scanIndicator setHidden:YES];
        [self->scanIndicator stopAnimation:self];
        
        if (!self->_scan) {
            [self->scanStatusMessage setStringValue:@"Error: Device power is off"];
            
        } else if ([self->_scan count] == 0) {
            [self->scanStatusMessage setStringValue:@"No Networks"];
        } else {
            [self->scanStatusMessage setHidden:YES];
        }
        
    });
    
    
    
    
}

-(void)joinButtonClicked:(id)sender
{
//    OSStatus a =   CWKeychainSetPassword((__bridge CFDataRef _Nonnull)([[self->_scan firstObject] ssidData]), CFSTR("abracadabra"));
//    
//    printf("status : %i\n", a);
//    
//    NSString *str = @"abracadabra";
//    SecTrustedApplicationRef app = NULL;
//    SecTrustedApplicationGroupRef v28 = NULL;
//    a = SecTrustedApplicationCreateFromPath(NULL, &app);
//    //SecAccessCreate();
//    a =  SecTrustedApplicationCreateApplicationGroup(CFSTR("AirPort"), 0LL, &v28);
//    
//    NSArray *access = @[CFBridgingRelease(app), CFBridgingRelease(v28)];
//    
//    SecAccessRef acs = NULL;
//    
//    a = SecAccessCreate(CFSTR("AirPort"), CFBridgingRetain(access), &acs);
//    
//   
//    
//    NSDictionary *dc = @{CFBridgingRelease(kSecAttrSynchronizable): @YES,
//                         CFBridgingRelease(kSecAttrAccessible): CFBridgingRelease(kSecAttrAccessibleAfterFirstUnlock),
//                         CFBridgingRelease(kSecClass): CFBridgingRelease(kSecClassGenericPassword),
//                         CFBridgingRelease(kSecAttrLabel): @"Network",
//                         CFBridgingRelease(kSecAttrAccount): @"Network",
//                         CFBridgingRelease(kSecAttrService): @"AirPort",
//                             CFBridgingRelease(kSecAttrDescription): @"AirPort Network Password",
//                             CFBridgingRelease(kSecValueData):[str dataUsingEncoding:NSUTF8StringEncoding],
//                         CFBridgingRelease(kSecAttrAccessGroup): @"Apple",
//                         CFBridgingRelease(kSecAttrAccess): CFBridgingRelease(acs)};
//    
//
//    
//    
//    CFTypeRef dict;
//   a = SecItemAdd((__bridge CFTypeRef)dc, &dict);
//    
//     a = SecItemUpdate((__bridge CFTypeRef)dc, (__bridge CFTypeRef)dc);
//
//    
//    NSError *err = [NSError errorWithDomain:NSCocoaErrorDomain code:a userInfo:nil];
//    dc = [err userInfo];
//    NSLog(@"%@ \n %@\n", [err localizedDescription], [err localizedFailureReason]);
//    
//    err = [NSError errorWithDomain:NSPOSIXErrorDomain   code:a userInfo:nil];
//    NSLog(@"%@ \n  %@\n", [err localizedDescription], [err localizedFailureReason]);
//    
//    err = [NSError errorWithDomain:NSMachErrorDomain   code:a userInfo:nil];
//    NSLog(@"%@ \n %@\n", [err localizedDescription], [err localizedFailureReason]);
//    
//    err = [NSError errorWithDomain:NSOSStatusErrorDomain   code:a userInfo:nil];
//    NSLog(@"%@ \n  %@\n", [err localizedDescription], [err localizedFailureReason]);
////
////    a =  CWKeychainSetWiFiPassword(kCWKeychainDomainUser, [[self->_scan firstObject] ssidData], nil);
////    
//    printf("status : %i\n", a);
////    
////    err = [NSError errorWithDomain:NSPOSIXErrorDomain   code:-3900 userInfo:nil];
////    
////      NSLog(@"%@  %@", [err localizedDescription], [err localizedFailureReason]);

    
    if ([self->_scanTable selectedRow] == -1) {
        
        return;
    }
    self->_network = [self->_scan objectAtIndex:[self->_scanTable selectedRow]];
//    NSDictionary *defaults = [[AERHelperPreferences sharedPreferences] findNetwork:self->_network];
  
    NSString *value = [[AERHelperPreferences sharedPreferences] findInKeychain:self->_network];
    if (value) {
        [self->joinNetworkPasswordField setStringValue:value];
    } else {
        [self->joinNetworkPasswordField setStringValue:@""];

    }

    //    if (defaults) {
//        NSData *value = [defaults objectForKey:@"Value"];
//        
//        [self->joinNetworkPasswordField setStringValue:value ? [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] : @""];
//    } else {
//        [self->joinNetworkPasswordField setStringValue:@""];
//    }
    
    [self->statusMessage setHidden:YES];
    [self->joinNetworkNameField setStringValue:[[self->_scan objectAtIndex:[self->_scanTable selectedRow]] ssid]];
    //[self->joinNetworkPasswordField setStringValue:@""];
    //[[self window] beginSheet:self->joinDialog completionHandler:^(NSModalResponse returnCode) {
    
    //}];
    [NSApp beginSheet:self->joinDialog modalForWindow:[self window] modalDelegate:[self->joinDialog delegate] didEndSelector:nil contextInfo:nil];
    
    
}

-(void)joinDialogOkButtonClicked:(id)sender
{
    if ([[self->joinNetworkNameField stringValue] length] > 32) {
        [self->statusMessage setHidden:NO];
        [self->statusMessage setStringValue:@"Network name is longer than 32 characters."];
        return;
        
    }
    [self->statusMessage setHidden:NO];
    [self->statusMessage setStringValue:@"Attempting to join..."];
    [self->joinIndicator setHidden:NO];
    [self->joinIndicator startAnimation:self];
    
    //[[self.connection remoteObjectProxy] connectTo:[self->joinNetworkNameField stringValue] password:[self->joinNetworkPasswordField stringValue] withReply:^(NSString *rep) {
    
    dispatch_async(dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL), ^{
        
        int rep = 0;
        
        if (self->_network) {
            rep = [[AERWLNetwork connection] associateWithNetworkData:self->_network andPassword:[self->joinNetworkPasswordField stringValue]];
        } else {
            
            rep = [[AERWLNetwork connection] associateWithNetworkName:[self->joinNetworkNameField stringValue] andPassword:[self->joinNetworkPasswordField stringValue]];
        }
        

    
     // rep = [[AERWLNetwork connection] joinNetworkWithName:[self->joinNetworkNameField stringValue] andPassword:[self->joinNetworkPasswordField stringValue]];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (rep != kCWNoErr)
            {
                
                [self->statusMessage setStringValue:[[AERWLNetwork connection] AERWLError:@"Error" code:rep]];
                [self->joinIndicator setHidden:YES];
                [self->joinIndicator stopAnimation:self];
                
            } else {
                
                [self->joinIndicator setHidden:YES];
                [self->joinIndicator stopAnimation:self];
                
                if ([[AERHelperPreferences sharedPreferences] shouldRememberNetworks]) {
                    [[AERHelperPreferences sharedPreferences] addNetowrkToList:self->_network withPassword:[self->joinNetworkPasswordField stringValue]];
                    
                }
                
                [self joinDialogCancelButtonClicked:sender];

                
               
            }
            
        });
        
         });
        

        
        
    //}];
}

-(void)joinDialogCancelButtonClicked:(id)sender
{
    //    [[self window] endSheet:self->joinDialog];
    [NSApp endSheet:self->joinDialog];
    [self->joinDialog orderOut:sender];
    [self showWindow:self];
    
}

#pragma mark - tableView
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (!self->_scan) {
        [self getScanResult];
    }
    NSDictionary *network;
    //NSString *mode;
    
    NSString *(^fixBSSID)(id) = ^(id bssid) {
        
        @autoreleasepool {
            
            const char *a;
            struct ether_addr *addr;
            bzero(&addr, sizeof(addr));
            
            a  = [bssid UTF8String];
            
            if (a) {
                addr = ether_aton(a);
            }
            
            if (addr) {
                
                bssid = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
                         addr->octet[0],
                         addr->octet[1],
                         addr->octet[2],
                         addr->octet[3],
                         addr->octet[4],
                         addr->octet[5]];
                
            }
            
            
//            bssid = [bssid stringByReplacingOccurrencesOfString:@":0:" withString:@":00:"];
//            bssid = [bssid stringByReplacingOccurrencesOfString:@":1:" withString:@":01:"];
//            bssid = [bssid stringByReplacingOccurrencesOfString:@":2:" withString:@":02:"];
//            bssid = [bssid stringByReplacingOccurrencesOfString:@":3:" withString:@":03:"];
//            bssid = [bssid stringByReplacingOccurrencesOfString:@":4:" withString:@":04:"];
//            bssid = [bssid stringByReplacingOccurrencesOfString:@":5:" withString:@":05:"];
//            bssid = [bssid stringByReplacingOccurrencesOfString:@":6:" withString:@":06:"];
//            bssid = [bssid stringByReplacingOccurrencesOfString:@":7:" withString:@":07:"];
//            bssid = [bssid stringByReplacingOccurrencesOfString:@":8:" withString:@":08:"];
//            bssid = [bssid stringByReplacingOccurrencesOfString:@":9:" withString:@":09:"];
//            bssid = [bssid stringByReplacingOccurrencesOfString:@":a:" withString:@":0a:"];
//            bssid = [bssid stringByReplacingOccurrencesOfString:@":b:" withString:@":0b:"];
//            bssid = [bssid stringByReplacingOccurrencesOfString:@":c:" withString:@":0c:"];
//            bssid = [bssid stringByReplacingOccurrencesOfString:@":d:" withString:@":0d:"];
//            bssid = [bssid stringByReplacingOccurrencesOfString:@":e:" withString:@":0e:"];
//            bssid = [bssid stringByReplacingOccurrencesOfString:@":f:" withString:@":0f:"];
            
            return bssid;
        }
        
        
    };
    
    if (tableView == self->_scanTable) {
        if (row < [self->_scan count]) {
            
            network = [self->_scan objectAtIndex:row];
            
            if (tableColumn == tableColumn(@"SSID")) {
                return [network ssid];
            }
            if (tableColumn == tableColumn(@"BSSID")) {
                return fixBSSID([network bssid]);
            }
            if (tableColumn == tableColumn(@"CHANNEL")) {
                return [[network valueForKey:@"CHANNEL"] stringValue];
            }
            if (tableColumn == tableColumn(@"RSSI")) {
                return [[network valueForKey:@"RSSI"] stringValue];
            }
            
            if (tableColumn == tableColumn(@"SECURITY")) {
                //return [network valueForKey:@"SECURITY"];
                return [[AERWLNetwork connection] securityString:[network securityType]];
            }
            if (tableColumn == tableColumn(@"MODE")) {
                
                
                if([network isIBSS]) {
                    return @"IBSS";
                } else {
                    return @"AP";
                }
                
//                mode = [[network valueForKey:@"AP_MODE"] stringValue];
//                
//                if ([mode isEqualToString:@"1"]) {
//                    return @"IBSS";
//                } else if([mode isEqualToString:@"2"]){
//                    return @"AP";
//                } else {
//                    return [[network valueForKey:@"AP_MODE"] stringValue];
//                }
                
                
                
            }
            
            
            
            
        }
    }
    
    return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return (self->_scan ? [self->_scan count] : 0);
}

-(void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray<NSSortDescriptor *> *)oldDescriptors{
    
    //NSArray *network = [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_NETWORKS_KEY];
    
    
    self->_scan = [self->_scan sortedArrayUsingDescriptors:[tableView sortDescriptors]];
    
    
    
    
    [tableView reloadData];
}

@end
