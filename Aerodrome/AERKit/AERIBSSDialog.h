//
//  AERIBSSDialog.h
//  Aerodrome
//
//  Created by Maxim M. on 2/19/22.
//  Copyright © 2022 digital-person. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface AERIBSSDialog : NSWindowController
- (instancetype)initWithChannels:(NSArray<NSNumber*>*)channels
       ok:(void(^)(NSString *name, NSInteger ch))okHandler
   cancel:(void(^)(void))cancelHandler;

@property (nonatomic, nullable) NSString *statusText;

@end

NS_ASSUME_NONNULL_END
