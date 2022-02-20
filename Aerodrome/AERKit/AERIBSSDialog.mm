//
//  AERIBSSDialog.mm
//  Aerodrome
//
//  Created by Maxim M. on 2/19/22.
//  Copyright © 2022 digital-person. All rights reserved.
//

#import "AERIBSSDialog.h"

@interface AERIBSSDialog ()
@property (nonatomic, assign) IBOutlet NSTextField *networkNameTextField;
@property (nonatomic, assign) IBOutlet NSPopUpButton *channelNumberPopUp;
@property (nonatomic, assign) IBOutlet NSTextField *statusTextField;

- (IBAction)createNetwork:(id)sender;
- (IBAction)cancel:(id)sender;

@end

[[clang::objc_direct_members]]
@implementation AERIBSSDialog {
    NSArray *_channels;
}


- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)createNetwork:(id)sender {
}

- (IBAction)cancel:(id)sender {
}

@end
