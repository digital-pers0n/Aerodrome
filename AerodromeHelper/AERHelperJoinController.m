//
//  AERHelperJoinController.m
//  Aerodrome
//
//  Created by Terminator on 8/21/16.
//
//

#import "AERHelperJoinController.h"
#import "aerwldProtocol.h"
#import "AERHelperPreferences.h"
#import "NSDictionary+AERNetwork.h"

#import "AERWLNetwork.h"
#import <CoreWlan/CoreWLANTypes.h>

@interface AERHelperJoinController ()

@end

@implementation AERHelperJoinController

-(id)initWithXPCService:(NSXPCConnection *)connection;
{
    self = [super initWithWindowNibName:@"AERHelperJoinController"];
    self.connection = connection;
    
    
    
    return self;
}

-(id)initWithNetworkName:(NSString *)name
{
    
    if (self = [super initWithWindowNibName:@"AERHelperJoinController"]) {
        self.network = name;
        self->_scanRecord = [[[AERWLNetwork connection] scanForNetworkWithName:name] firstObject];
        
    }
    
    return  self;
}

+(id)createWithNetworkName:(NSString *)name
{
    return [[AERHelperJoinController alloc] initWithNetworkName:name];
}

+(id)createWithXPCService:(NSXPCConnection *)xpc
{
    return [[AERHelperJoinController alloc] initWithXPCService:xpc];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self->networkNameTextField setStringValue:self.network ? self.network : @""];
    
    if (self->_scanRecord && [[self->_scanRecord ssid] isEqualToString:self.network]) {
        NSString *value = [[AERHelperPreferences sharedPreferences] findInKeychain:self->_scanRecord];
        if (value) {
            [self->passwordTextField setStringValue:value];
        }
        
    } else {
        
        [self->passwordTextField setStringValue:@""];
    }
    
    [self->progressIndicator setHidden:YES];
    [self->statusMessage setHidden:YES];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

//-(void)dealloc
//{
//    self.connection = NULL;
//    self->_network  = NULL;
//
//}

-(void)joinButtonClicked:(id)sender
{
    if ([[self->networkNameTextField stringValue] length] > 32) {
        [self->statusMessage setHidden:NO];
        [self->statusMessage setStringValue:@"Network name is longer than 32 characters."];
        return;
        
    }
    [self->statusMessage setHidden:NO];
    [self->statusMessage setStringValue:@"Attempting to join..."];
    [self->progressIndicator setHidden:NO];
    [self->progressIndicator startAnimation:self];
    
    dispatch_async(dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL), ^{
        
        int rep = 0;
        
        if (self->_scanRecord && [[self->_scanRecord ssid] isEqualToString:[self->networkNameTextField stringValue]]) {
            
            rep = [[AERWLNetwork connection] associateWithNetworkData:self->_scanRecord andPassword:[self->passwordTextField stringValue]];
            
        } else {
            self->_scanRecord = [[[AERWLNetwork connection] scanForNetworkWithName:[self->networkNameTextField stringValue]] firstObject];
            rep = [[AERWLNetwork connection] associateWithNetworkData:self->_scanRecord andPassword:[self->passwordTextField stringValue]];
        }
        
        
        rep = [[AERWLNetwork connection] joinNetworkWithName:[self->networkNameTextField stringValue] andPassword:[self->passwordTextField stringValue]];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (rep != kCWNoErr)
            {
                
                [self->statusMessage setStringValue:[[AERWLNetwork connection] AERWLError:@"Error" code:rep]];
                [self->progressIndicator setHidden:YES];
                [self->progressIndicator stopAnimation:self];
                
            } else {
                [self->progressIndicator setHidden:YES];
                [self->progressIndicator stopAnimation:self];
                
                
                if ([[AERHelperPreferences sharedPreferences] shouldRememberNetworks]) {
                    if ([[self->passwordTextField stringValue] length] > 0) {
                        [[AERHelperPreferences sharedPreferences] addNetowrkToList:self->_scanRecord withPassword:[self->passwordTextField stringValue]];
                        
                        
                        [[self window] performClose:self];
                    }
                }
                
            }
            
        });
        
    });
    
    //
    //
    //    [[self.connection remoteObjectProxy] connectTo:[self->networkNameTextField stringValue] password:[self->passwordTextField stringValue] withReply:^(NSString *rep) {
    //
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //            if (rep)
    //            {
    //                [self->statusMessage setHidden:NO];
    //                [self->statusMessage setStringValue:rep];
    //                [self->progressIndicator setHidden:YES];
    //                [self->progressIndicator stopAnimation:self];
    //
    //            } else {
    //                [self->progressIndicator setHidden:YES];
    //                [self->progressIndicator stopAnimation:self];
    //                [[self window] performClose:self];
    //            }
    //            
    //        });
    //        
    //        
    //    }];
}



@end
