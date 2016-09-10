//
//  AERHelperCreateController.m
//  Aerodrome
//
//  Created by Terminator on 8/22/16.
//
//

#import "AERHelperCreateController.h"
#import "AERWLClient.h"
#import "aerwldProtocol.h"
#import "AERWLNetwork.h"
#import <CoreWLAN/CoreWLANTypes.h>

@interface AERHelperCreateController ()

@end

@implementation AERHelperCreateController

-(id)initWithXPCService:(NSXPCConnection *)connection andChannels:(NSArray *)chanList
{
    self = [super initWithWindowNibName:@"AERHelperCreateController"];
    self.connection = connection;
    
    if (chanList) {
        self.channels = chanList;
    } else {
        
         self.channels = [[AERWLClient sharedClient] channels];
        
//        [[self.connection remoteObjectProxy] channels:^(NSArray *rep) {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                self->_channels = rep;
//            });
//        }];
        
    }
    
    
    
    
    return self;
}


-(id)initWithXPCService:(NSXPCConnection *)connection
{
    
    return [self initWithXPCService:connection andChannels:NULL];
}

-(id)initWithChannels:(NSArray *)chan
{
    if (self = [super initWithWindowNibName:@"AERHelperCreateController"]) {
        if (chan)
        {
            self.channels = chan;
        } else {
            self.channels = [[AERWLClient sharedClient] channels];
        }
    }
    
    return self;
}

+(id)createWithChannels:(NSArray *)chan
{
    
    return [[AERHelperCreateController alloc] initWithChannels:chan];
}


+(id)createWithXPCService:(NSXPCConnection *)service andChannels:(NSArray *)channelsArray
{
    return [[AERHelperCreateController alloc] initWithXPCService:service andChannels:channelsArray];
}
+(id)createWithXPCService:(NSXPCConnection *)service
{
    return [[AERHelperCreateController alloc] initWithXPCService:service];
}




//-(void)showWindow:(id)sender
//{
//    //[[self window] makeKeyAndOrderFront:self];
////    [[NSApplication sharedApplication] setDelegate:self->delegate_];
////    [NSApp run];
//
//    [super showWindow:sender];
//}

- (void)windowDidLoad {
    
    [super windowDidLoad];
    
    [self->progressIndicator setHidden:YES];
    [self->statusMessage setHidden:YES];
    
    //[self->networkNameTextField setStringValue:CFBridgingRelease(CSCopyMachineName())]; // deprecated
    NSString *machineName;
    
    char name[32];
    bzero(&name, 32);
    gethostname((char *)&name, 32);
    
    machineName = [[NSString stringWithCString:name encoding:NSUTF8StringEncoding] stringByDeletingPathExtension];
    if (machineName) {
        
        [self->networkNameTextField setStringValue:machineName];
    } else {
        [self->networkNameTextField setStringValue:@"My Network"];
    }
    
    [self populateChannelPopUp];
    
}

-(void)populateChannelPopUp
{
    if(!self.channels)
    {
        self.channels = [[AERWLClient sharedClient] channels];
                    for (NSNumber *i in self.channels) {
                        [self->channelPopupButton addItemWithTitle:[i stringValue]];
                    }
        
//        [[self.connection remoteObjectProxy] channels:^(NSArray *rep) {
//            //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.channels = rep;
//            
//            
//            for (NSNumber *i in self.channels) {
//                [self->channelPopupButton addItemWithTitle:[i stringValue]];
//                
//            }
//            //});
//        }];
    } else {
        for (NSNumber *i in self.channels) {
            [self->channelPopupButton addItemWithTitle:[i stringValue]];
        }
    }
    [self->channelPopupButton selectItemWithTitle:@"11"];
    
}

-(void)createButtonPressed:(id)sender
{
    //    NSXPCConnection *new = [[NSXPCConnection alloc] initWithServiceName:@"void.digital-person.aerd"];
    //    new.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(aerdProtocol)];
    //    [new resume];
    //    [[new remoteObjectProxy] createIBSS:[self->networkNameTextField stringValue] channel:11 withReply:^(int rep){
    //
    //    }];
    if ([[self->networkNameTextField stringValue] length] > 32) {
        [self->statusMessage setHidden:NO];
        [self->statusMessage setStringValue:@"Network name is longer than 32 characters."];
        return;
        
    }
    //[self->_interface createIBSS:[self->networkNameTextField stringValue] withChannel:11];
    
    [self->statusMessage setHidden:NO];
    [self->statusMessage setStringValue:@"Attempting to create..."];
    [self->progressIndicator setHidden:NO];
    [self->progressIndicator startAnimation:self];
    
    dispatch_async(dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL), ^{
        
        int rep = 0;
        
        rep = [[AERWLNetwork connection] createIBSSNetworkWithName:[self->networkNameTextField stringValue]
                                                        andChannel:[channelPopupButton.selectedItem.title intValue]];
    

    
//    [[self.connection remoteObjectProxy] createIBSS:[self->networkNameTextField stringValue] channel:[channelPopupButton.selectedItem.title intValue] withReply:^(NSString *rep) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (rep != kCWNoErr)
            {
                [self->statusMessage setHidden:NO];
                [self->statusMessage setStringValue:[[AERWLNetwork connection] AERWLError:@"Error" code:rep]];
                [self->progressIndicator setHidden:YES];
                [self->progressIndicator stopAnimation:self];
                
            } else {
                [self->progressIndicator setHidden:YES];
                [self->progressIndicator stopAnimation:self];
                [[self window] performClose:self];
            }
            
        });
        
    //}];
        
    });
    
    
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        if ([self statusText])
    //        {
    //            [self->statusMessage setHidden:NO];
    //            [self->statusMessage setStringValue:_statusText];
    //            [self->progressIndicator setHidden:YES];
    //            [self->progressIndicator stopAnimation:self];
    //            [self setStatusText:NULL];
    //        } else {
    //            [self->progressIndicator setHidden:YES];
    //            [self->progressIndicator stopAnimation:self];
    //            [[self window] performClose:self];
    //        }
    //
    //    });
    
}

@end
