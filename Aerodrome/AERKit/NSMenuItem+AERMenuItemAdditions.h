//
//  NSMenuItem+AERMenuItemAdditions.h
//  Aerodrome
//
//  Created by Maxim M. on 12/20/21.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

using AERMenuItemHandler = void(^)(NSMenuItem*);

[[clang::objc_direct_members]]
@interface NSMenuItem (AERMenuItemAdditions)

@property (nonatomic, null_resettable, copy) AERMenuItemHandler onUserAction;

@end

NS_ASSUME_NONNULL_END
