//
//  AppDelegate.mm
//  Aerodrome
//
//  Created by Maxim M. on 11/13/21.
//

#import "AppDelegate.h"
#import "AERWindowController.h"

@interface AppDelegate () {
    AERWindowController *_appController;
}
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _appController = [AERWindowController new];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
