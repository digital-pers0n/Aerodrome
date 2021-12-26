//
//  AERStatusView.mm
//  Aerodrome
//
//  Created by Maxim M. on 12/15/21.
//

#import "AERStatusView.h"

[[clang::objc_direct_members]]
@implementation AERStatusView {
    NSTextFieldCell *_statusText;
    NSProgressIndicator *_progressIndicator;
}

//MARK: - Initializers

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (!(self = [super initWithFrame:frameRect])) return self;
    self.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
    
    auto tfc = [[NSTextFieldCell alloc] initTextCell:@""];
    tfc.font = [NSFont menuFontOfSize:0];
    tfc.textColor = NSColor.disabledControlTextColor;
    
    auto pi = [NSProgressIndicator new];
    pi.style = NSProgressIndicatorStyleSpinning;
    pi.displayedWhenStopped = NO;
    pi.controlSize = NSControlSizeSmall;
    pi.autoresizingMask = NSViewMaxXMargin;
    pi.translatesAutoresizingMaskIntoConstraints = YES;
    pi.autoresizesSubviews = YES;
    pi.usesThreadedAnimation = YES;
    [self addSubview:pi];
    _progressIndicator = pi;
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    [[NSException exceptionWithName:NSInternalInconsistencyException
                             reason:@"Not implemented" userInfo:nil] raise];
    return nil;
}

//MARK: - Properties

- (void)setStatusText:(NSString *)text {
    _statusText.stringValue = text;
}

- (NSString *)statusText {
    return _statusText.stringValue;
}

//MARK: - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    const auto width = NSWidth(self.frame);
    _progressIndicator.frame = {{width - 26, 2}, {16, 16}};
    [_statusText drawWithFrame:{{19, 0}, {width - 60, 19}} inView:self];
}

@end
