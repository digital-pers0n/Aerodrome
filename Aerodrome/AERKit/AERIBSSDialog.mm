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
    NSArray<NSString*> *_channels;
    void (^_okHandler)(NSString* _Nonnull, NSInteger);
    void (^_cancelHandler)(void);
}

- (NSNibName)windowNibName {
    return self.className;
}

- (instancetype)initWithChannels:(NSArray<NSNumber *> *)channels
                ok:(void (^)(NSString*, NSInteger))okHandler
            cancel:(void (^)(void))cancelHandler
{
    if (!(self = [super init])) return nil;
    _channels = [&]() -> NSArray<NSString*>* {
        auto result = [NSMutableArray new];
        for (NSNumber *object in channels) {
            [result addObject:object.stringValue];
        }
        return result;
    }();
    _okHandler = [okHandler copy];
    _cancelHandler = [cancelHandler copy];
    return self;
}

- (void)setStatusText:(NSString *)text {
    if (!text) {
        _statusTextField.hidden = YES;
    } else {
        _statusTextField.hidden = NO;
        _statusTextField.stringValue = text;
    }
}

- (NSString*)statusText {
    return _statusTextField.stringValue;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [_channelNumberPopUp addItemsWithTitles:_channels];
}

- (IBAction)createNetwork:(id)sender {
    _okHandler(_networkNameTextField.stringValue,
               _channelNumberPopUp.selectedItem.title.integerValue);
}

- (IBAction)cancel:(id)sender {
    _cancelHandler();
}

@end
