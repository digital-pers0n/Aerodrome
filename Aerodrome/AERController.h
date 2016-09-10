//
//  AERWLInterface.h
//  Aerodrome
//
//  Created by Terminator on 8/3/16.
//
//

#import <Cocoa/Cocoa.h>
//#import "AppDelegate.h"
//#import "aerdProtocol.h"



@interface AERController : NSObject

//Dialogs
-(void)showCreateDialog;
-(void)showJoinDialogWithNetworkName:(NSString *)name;
-(void)showScanDialog;
-(void)showPreferencesDialog;





@end
