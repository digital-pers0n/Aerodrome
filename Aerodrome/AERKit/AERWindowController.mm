//
//  AERWindowController.mm
//  Aerodrome
//
//  Created by Maxim M. on 11/17/21.
//

#import "AERWindowController.h"

@interface AERWindowController ()
@property (nonatomic, assign) IBOutlet NSTextField *networkNameTextField;
@property (nonatomic, assign) IBOutlet NSSecureTextField *passwordTextField;

@end

@implementation AERWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

//MARK: - IBActions

- (IBAction)performConnection:(id)sender {
}

- (IBAction)cancel:(id)sender {
}



@end
