//
//  AERAssociatedObject.h
//  Aerodrome
//
//  Created by Maxim M. on 12/19/21.
//

#ifndef AERAssociatedObject_h
#define AERAssociatedObject_h

#import <objc/runtime.h>
#import "AERDefines.h"

NS_ASSUME_NONNULL_BEGIN
EXTERNALLY_RETAINED_BEGIN

namespace ObjC {
struct AO {
    enum struct Type { Weak, Strong, Copy, StrongUnsafe, CopyUnsafe };
    
    template<Type Policy = Type::Strong> static void
    Set(id obj, const void *key, id value = nil) noexcept {
        constexpr auto policy = [] {
        switch (Policy) {
            case Type::Weak:         return OBJC_ASSOCIATION_ASSIGN;
            case Type::Strong:       return OBJC_ASSOCIATION_RETAIN;
            case Type::Copy:         return OBJC_ASSOCIATION_COPY;
            case Type::StrongUnsafe: return OBJC_ASSOCIATION_RETAIN_NONATOMIC;
            case Type::CopyUnsafe:   return OBJC_ASSOCIATION_COPY_NONATOMIC;
        }}();
        objc_setAssociatedObject(obj, key, value, policy);
    }
    
    template<typename T = id> static
    __nullable T Get(id obj, const void *key) noexcept {
        return static_cast<T>(objc_getAssociatedObject(obj, key));
    }
    
    static void Copy(id obj, const void *key, id value = nil) noexcept {
        Set<Type::Copy>(obj, key, value);
    }
    
    static void SetStrong(id obj, const void *key, id value = nil) noexcept {
        Set<Type::Strong>(obj, key, value);
    }
    
    static void SetWeak(id obj, const void *key, id value = nil) noexcept {
        Set<Type::Weak>(obj, key, value);
    }
    
    static void SetStrongUnsafe(id obj, const void *key,
                                id value = nil) noexcept {
        Set<Type::StrongUnsafe>(obj, key, value);
    }
    
    static void CopyUnsafe(id obj, const void *key, id value = nil) noexcept {
        Set<Type::CopyUnsafe>(obj, key, value);
    }
}; // struct AO
} // namespace ObjC

EXTERNALLY_RETAINED_END
NS_ASSUME_NONNULL_END

#endif /* AERAssociatedObject_h */
