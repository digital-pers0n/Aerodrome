//
//  AERWLInterface.m
//  Aerodrome
//
//  Created by Terminator on 8/3/16.
//
//

#import "AERController.h"


#define HELPER_PATH @"/AerodromeHelper.app/Contents/MacOS/AerodromeHelper"




@implementation AERController


-(void)showJoinDialogWithNetworkName:(NSString *)name
{
    [self launchHelperWithOption:@[@"-n", name]];
}

-(void)showCreateDialog
{

    [self launchHelperWithOption:@[@"-i"]];
}

-(void)showScanDialog
{
    [self launchHelperWithOption:@[@"-s"]];
}

-(void)showPreferencesDialog
{
    [self launchHelperWithOption:@[@"-p"]];
}

-(void)launchHelperWithOption:(NSArray *)option
{
    //NSString *path = [[NSBundle mainBundle] resourcePath];
    //NSString *helperPath = @"/AerodromeHelper.app/Contents/MacOS/AerodromeHelper";
    //path = [path stringByAppendingString:[NSString stringWithFormat:@"%@  %@ &", HELPER_PATH, option]];
    
    //system([path cStringUsingEncoding:NSUTF8StringEncoding]);
    
    NSString *url = [[NSBundle mainBundle] resourcePath];
    url = [url  stringByAppendingString:@"/AerodromeHelper.app"];
    
    NSURL *path = [NSURL fileURLWithPath:url]; //
    
    
//    if (!path) {
//        path = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", url ]];
//    }
    
    
    
    
    [[NSWorkspace sharedWorkspace] launchApplicationAtURL:path
                                                  options:NSWorkspaceLaunchDefault | NSWorkspaceLaunchWithoutAddingToRecents | NSWorkspaceLaunchWithoutActivation
                                            configuration:@{NSWorkspaceLaunchConfigurationArguments:option}
                                                    error:nil];
}


@end
