//
//  AppDelegate.m
//  AerodromeHelper
//
//  Created by Terminator on 8/21/16.
//
//

#import "AERHelperDelegate.h"
#import "aerwldProtocol.h"
#import "AERHelperJoinController.h"
#import "AERHelperCreateController.h"
#import "AERHelperPreferencesController.h"
#import "AERHelperScan.h"
#import "AERWLClient.h"
#import <crt_externs.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

-(instancetype)init
{
    if (self = [super init]) {
        
        int ch;
        int argc = (*_NSGetArgc());
        char *argv[16];
        for (int b = 0; b <= argc; b++) {
            argv[b] = (*_NSGetArgv())[b];
        }
        while ((ch =  getopt(argc, argv, "pisn:")) != EOF){
            switch (ch) {
                case 'n':
                    [self joinDialogWithNetworkName:@(optarg)];
                    break;
                    
                case 'i':
                    [self ibssDialog];
                    break;
                    
                case 's':
                    [self scanDialog];
                    break;
                case 'p':
                    [self preferencesDialog];
                    break;
                    
                default:
                    break;
            }
            
        }
    }
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    
    
//[NSApp activateIgnoringOtherApps:YES];
    
       // name = (*_NSGetProgname());
        //memcpy(&argv, _NSGetArgv(), 16);
    
    
    //[self.window makeKeyAndOrderFront:self];
//    self->_connection = [[NSXPCConnection alloc] initWithServiceName:@"void.digital-person.aerd"];
//    self->_connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(aerdProtocol)];
//    [self->_connection resume];
//    [[self->_connection description] writeToFile:@"/dev/stderr" atomically:NO encoding:NSUTF8StringEncoding error:nil];
    

    
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}


-(void)joinDialogWithNetworkName:(NSString *)name
{
//    NSString *string = [name substringWithRange:NSMakeRange(0, 1)];
//    
//    NSLog(@"String:  %@, %@", string, [string description]);
    
    
//    if ([[name substringWithRange:NSMakeRange(0, 1)] isEqualToString:@" "]) {
//        name = [name stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
//    }
//    self->_currentDialog = [AERHelperJoinController createWithXPCService:[[AERWLClient sharedClient] xpcService]];
//    [(AERHelperJoinController *)self->_currentDialog setNetwork:name];
    
    self->_currentDialog = [AERHelperJoinController createWithNetworkName:name];
    
    [self showDialog];
}

-(void)ibssDialog
{
//    self->_currentDialog = [AERHelperCreateController createWithXPCService:[[AERWLClient sharedClient] xpcService]
//                                                               andChannels:[[AERWLClient sharedClient] channels]];
    
    self->_currentDialog = [AERHelperCreateController createWithChannels:[[AERWLClient sharedClient] channels]];
    [self showDialog];
    //[(AERHelperJoinController *)self->_currentDialog setNetwork:name];

    
}

-(void)scanDialog
{
    //self->_currentDialog = [AERHelperScan createWithXPCService:[[AERWLClient sharedClient] xpcService]];
    
    self->_currentDialog = [AERHelperScan createScanDialog];
    [self showDialog];
}

-(void)preferencesDialog
{
    self->_currentDialog = [AERHelperPreferencesController createPreferencesWindow];
    
    [self showDialog];
}

-(void)showDialog
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NSApp activateIgnoringOtherApps:YES];
        [self->_currentDialog showWindow:self];
        
        [[self->_currentDialog window] setLevel:NSStatusWindowLevel];
        [[self->_currentDialog window] orderFrontRegardless];
    });

   
    //[[self->_currentDialog window] makeKeyAndOrderFront:self];
}

@end
