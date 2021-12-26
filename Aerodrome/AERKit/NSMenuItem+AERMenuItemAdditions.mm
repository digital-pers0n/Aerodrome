//
//  NSMenuItem+AERMenuItemAdditions.mm
//  Aerodrome
//
//  Created by Maxim M. on 12/20/21.
//

#import "NSMenuItem+AERMenuItemAdditions.h"
#import "AERAssociatedObject.h"

EXTERNALLY_RETAINED_BEGIN

@implementation NSMenuItem (AERMenuItemAdditions)

- (void)setOnUserAction:(AERMenuItemHandler)action {
    Copy(self, action ?: ^(NSMenuItem*){});
    self.target = self;
    self.action = @selector(aer_onUserAction:);
}

- (AERMenuItemHandler)onUserAction {
    return Get<AERMenuItemHandler>(self);
}

- (void)aer_onUserAction: sender {
    Invoke<AERMenuItemHandler>(self);
}

namespace {
using ObjC::AO;
const void *const kMenuItemHandlerKey = &kMenuItemHandlerKey;
    
template<typename T, typename U>
void Copy(T obj, U value) noexcept {
    AO::Copy(obj, kMenuItemHandlerKey, value);
}

template<typename T, typename U>
__nullable T Get(U obj) noexcept {
    return AO::Get<T>(obj, kMenuItemHandlerKey);
}
    
// force tail-cail optimization
template<typename T, typename U>
void Invoke(const U &obj, const void *key) noexcept {
    auto fn = BRIDGE_CAST(CFTypeRef, AO::Get<T>(obj, key));
    BRIDGE_CAST(T, fn)(obj);
}
    
template<typename T, typename U>
void Invoke(const U &obj) noexcept {
    Invoke<T>(obj, kMenuItemHandlerKey);
}
    
} // anonymous namespace

@end

EXTERNALLY_RETAINED_END
