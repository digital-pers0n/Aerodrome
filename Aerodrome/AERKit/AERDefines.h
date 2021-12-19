//
//  AERDefines.h
//  Aerodrome
//
//  Created by Maxim M. on 12/17/21.
//

#ifndef AERDefines_h
#define AERDefines_h

/**
 A very simple compile-time checker for key value paths.
 It doesn't cover all possible cases e.g "self.@avg", CoreData attributes etc.
*/
#define KVP(object, keyPath) sizeof((object).keyPath) ? @#keyPath : @""

/**
 Similar to KVP() macro, but operates on class names instead of objects.
 */
#define KEYPATH(className, keyPath) KVP((className*)@"", keyPath)

/**
 Prevent ARC from aggressively retaining temporary objects.
 */
#define EXTERNALLY_RETAINED [[clang::objc_externally_retained]]

#define EXTERNALLY_RETAINED_BEGIN \
_Pragma("clang attribute push ([[clang::objc_externally_retained]], \
apply_to=any(function, objc_method, block))")

#define EXTERNALLY_RETAINED_END _Pragma("clang attribute pop")

#define UNSAFE __unsafe_unretained

#endif /* AERDefines_h */
