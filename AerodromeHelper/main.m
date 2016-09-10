//
//  main.m
//  AerodromeHelper
//
//  Created by Terminator on 8/21/16.
//
//

#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[]) {
    
    ProcessSerialNumber psn = {0, kCurrentProcess};
    
    TransformProcessType(&psn, kProcessTransformToUIElementApplication);
    return NSApplicationMain(argc, argv);
}
