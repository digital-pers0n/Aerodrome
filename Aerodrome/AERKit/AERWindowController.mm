//
//  AERWindowController.mm
//  Aerodrome
//
//  Created by Maxim M. on 11/17/21.
//

#import "AERDefines.h"
#import "AERNetworkView.h"
#import "AERStatusMenuItem.h"
#import "AERStatusView.h"
#import "AERWiFiClient.h"
#import "AERWindowController.h"
#import "NSMenuItem+AERMenuItemAdditions.h"

EXTERNALLY_RETAINED_BEGIN

namespace AE {
struct WiFiIcon {
    static NSImage *Security(CWSecurity value) noexcept {
        return [NSImage imageNamed:value == kCWSecurityNone
                ? NSImageNameLockUnlockedTemplate
                : NSImageNameLockLockedTemplate];
    }
    
    static NSImage *Signal(NSInteger rssi) noexcept {
        return [&]() -> NSImage * {
            auto create = [](NSString *name) -> NSImage * {
                return [NSImage imageNamed:name];
            };
            if (rssi >= -40) return create(@"AER-signal-3");
            if (rssi >= -60) return create(@"AER-signal-2");
            if (rssi >= -70) return create(@"AER-signal-1");
            return create(@"AER-signal-0");
        }();
    }
    
    static NSImage *Status(WiFiState state) noexcept {
        switch (state) {
        case WiFiState::Off:  return [NSImage imageNamed:@"AER-OFF"];
        case WiFiState::Idle: return [NSImage imageNamed:@"AER-IDLE"];
        case WiFiState::IBSS: return [NSImage imageNamed:@"AER-IBSS"];
        default: return [NSImage imageNamed:@"AER-ACTIVE"];
        }
    }
    
}; // struct WiFiIcon

struct WiFiMenu {
    enum struct Tag {
        Status, Disconnect, Power, Separator, CreateIBSS,
        Join, Preferences, Quit, Relaunch, Network
    }; // enum struct MenuTag
    
    NSMenu *Ref;
    NSStatusItem *StatusItem;
    NSMenuItem *Status, *Disconnect, *Power, *CreateIBSS,
               *Join, *Preferences, *Quit, *Relaunch;
    WiFiMenu() noexcept {
        
        auto create = [&](NSString *string, Tag tag,
                          NSString *key = @"") -> NSMenuItem * {
            return addItem<NSMenuItem>(string, tag, key);
        };
        
        auto separator = [&] {
            auto item = [NSMenuItem separatorItem];
            item.tag = NSInteger(Tag::Separator);
            [Ref addItem:item];
        };
        
        Ref = [NSMenu new];
        StatusItem = [NSStatusBar.systemStatusBar
                      statusItemWithLength:NSSquareStatusItemLength];
        StatusItem.menu = Ref;
        
        Status = addItem<AERStatusMenuItem>(@"Status", Tag::Status);
        
        Disconnect = create(@"Disconnect", Tag::Disconnect);
        Power = create(@"Power State", Tag::Power);
        separator();
        separator();
        CreateIBSS = create(@"Create Network", Tag::CreateIBSS);
        Join = create(@"Join Other Network...", Tag::Join);
        Preferences = create(@"Preferences...", Tag::Preferences);
        separator();
        Quit = create(@"Quit", Tag::Quit);
        Relaunch = create(@"Relaunch", Tag::Relaunch);
        Relaunch.alternate = YES;
    }
    
    template<typename T>
    T *addItem(NSString *title, Tag tag, NSString *key = @"") const noexcept {
        auto item = [[T alloc] initWithTitle:title
                                      action:nil keyEquivalent:key];
        item.tag = NSInteger(tag);
        [Ref addItem:item];
        return item;
    }
    
    void update(NSArray<AERNetwork*>* networks,
                AERMenuItemHandler handler) const noexcept
    {
        for (NSMenuItem *item in Ref.itemArray.copy) {
            if (item.tag == NSInteger(Tag::Network)) {
                [Ref removeItem:item];
            }
        }
        
        const auto &menu = Ref;
        const auto index = NSInteger(Tag::Power) + 2;
        [networks enumerateObjectsWithOptions:0 usingBlock:
         ^(AERNetwork * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull) {
            [menu insertItem:[&]() -> NSMenuItem * {
                auto item = [[NSMenuItem alloc] initWithTitle:obj.ssid
                                                action:nil keyEquivalent:@""];
                
                auto view = [[AERNetworkView alloc] initWithFrame:{{},{260, 19}}
                              menuItem:item images:@[
                                  WiFiIcon::Security(obj.security),
                                  WiFiIcon::Signal(obj.rssiValue)
                              ]];
                item.view = view;
                item.onUserAction = handler;
                item.tag = NSInteger(Tag::Network);
                return item;
            }() atIndex:index + idx];
        }];
        //NSLog(@"%@", Ref);
    }
}; // struct WiFiMenu
} // namespace AE

EXTERNALLY_RETAINED_END

@interface AERWindowController () <NSMenuDelegate>
@property (nonatomic, assign) IBOutlet NSTextField *networkNameTextField;
@property (nonatomic, assign) IBOutlet NSSecureTextField *passwordTextField;

- (IBAction)performConnection:(id)sender;
- (IBAction)cancel:(id)sender;

- (void)didWake:(NSNotification*)n;

@end


[[clang::objc_direct_members]]
@implementation AERWindowController {
    AE::WiFiMenu _menu;
    AERWiFiClient *_client;
}

- (NSNibName)windowNibName {
    return self.className;
}

- (instancetype)init {
    if (!(self = [super init])) return self;
    _client = [[AERWiFiClient alloc] initWithErrorHandler:
    ^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        [NSApp presentError:error];
        [NSApp terminate:nil];
    }];
    
    _menu.Ref.delegate = self;
    auto nc = NSWorkspace.sharedWorkspace.notificationCenter;
    [nc addObserver:self selector:@selector(didWake:)
               name:NSWorkspaceDidWakeNotification object:nil];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

//MARK: - IBActions

- (IBAction)performConnection:(id)sender {
}

- (IBAction)cancel:(id)sender {
}


//MARK: - Notifications

- (void)didWake:(NSNotification *)n {
}

@end
