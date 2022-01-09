//
//  AERNetworkView.m
//  Aerodrome
//
//  Created by Maxim M. on 12/22/21.
//

#import "AERNetworkView.h"

@implementation AERNetworkView {
    __unsafe_unretained NSMenuItem *_item;
    NSArray<NSImageCell*> *_imageCells;
    NSTextFieldCell *_textCell;
    struct Color {
        NSColor *Text, *SelectedText, *SelectedItem;
        Color() noexcept : Text{NSColor.textColor}
        , SelectedText{NSColor.selectedMenuItemTextColor}
        , SelectedItem{NSColor.selectedMenuItemColor} {}
    } _color;
}

- (instancetype)initWithFrame:(NSRect)aRect menuItem:(NSMenuItem*)item
                       images:(NSArray<NSImage*>*)images {
    if (!(self = [super initWithFrame:aRect])) return self;
    self.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
    item.view = self;
    _item = item;
    _imageCells = [&]() -> NSArray<NSImageCell*> * {
        auto result = [NSMutableArray<NSImageCell*> new];
        for (NSImage *image in images) {
            [image setTemplate:YES];
            [result addObject:[[NSImageCell alloc] initImageCell:image]];
        }
        return result;
    }();
    
    _textCell = [&]() -> NSTextFieldCell * {
        auto result = [[NSTextFieldCell alloc] initTextCell:@"Untitled"];
        result.font = [NSFont menuBarFontOfSize:0];
        result.lineBreakMode = NSLineBreakByTruncatingTail;
        return result;
    }();
    
    return self;
}

//MARK: - Overrides

- (BOOL)acceptsFirstMouse:(NSEvent*)theEvent {
    return YES;
}

- (void)mouseUp:(NSEvent*)theEvent {
    auto menu = _item.menu;
    [menu cancelTrackingWithoutAnimation];
    [menu performActionForItemAtIndex:[menu indexOfItem:_item]];
}

- (void)drawRect:(NSRect)dirtyRect {
    auto highlighted = _item.highlighted;
    if (highlighted) {
        [_color.SelectedItem set];
        [NSBezierPath fillRect:dirtyRect];
    }
    
    const auto width = NSWidth(dirtyRect);
    auto pos = width - 5;
    if (_imageCells.count) {
        for (NSImageCell *cell in _imageCells) {
            const auto imageWidth = cell.image.size.width;
            pos -= (imageWidth + 7);
            [cell drawWithFrame:{{pos, 0}, {imageWidth, 19}} inView:self];
        }
    }
    _textCell.stringValue = _item.title;
    _textCell.textColor = highlighted ? _color.SelectedText : _color.Text;
    [_textCell drawWithFrame:{{20, 0}, {pos - 10, 19}} inView:self];
}

@end
