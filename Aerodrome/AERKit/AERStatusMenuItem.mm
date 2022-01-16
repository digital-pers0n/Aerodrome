//
//  AERStatusMenuItem.mm
//  Aerodrome
//
//  Created by Maxim M. on 1/9/22.
//  Copyright © 2022 digital-person. All rights reserved.
//

#import "AERStatusMenuItem.h"
#import "AERStatusView.h"

@implementation AERStatusMenuItem {
    __unsafe_unretained AERStatusView *_view;
}

- (instancetype)initWithTitle:(NSString *)string
                       action:(SEL)selector keyEquivalent:(NSString *)charCode {
    if (!(self = [super initWithTitle:string action:selector
                        keyEquivalent:charCode])) return self;
    auto view = [[AERStatusView alloc] initWithFrame:{{}, {260, 19}}];
    self.view = view;
    _view = view;
    return self;
}

// MARK: - Overrides

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    _view.statusText = title;
}

@end
