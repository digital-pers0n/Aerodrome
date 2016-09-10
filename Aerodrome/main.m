//
//  main.m
//  Aerodrome
//
//  Created by Terminator on 7/22/16.
//
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ProcessSerialNumber psn = {0, kCurrentProcess};
        
        TransformProcessType(&psn, kProcessTransformToUIElementApplication);
//        NSApplication *app = [NSApplication sharedApplication];
//        AppDelegate * del = [[AppDelegate alloc] init];
//        [app setDelegate:del];
//        
//        [app run];
//        return 0;
    

     return NSApplicationMain(argc, argv);
    }
}
