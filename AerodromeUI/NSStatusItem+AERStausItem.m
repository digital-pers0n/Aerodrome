//
//  NSStatusItem+AERStausItem.m
//  Aerodrome
//
//  Created by Terminator on 8/8/16.
//
//

#import "NSStatusItem+AERStausItem.h"
#import "AEROptions.h"

@implementation NSStatusItem (AERStausItem)

-(void)startAnimation
{
    dispatch_queue_t qu = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), qu, ^{
        [self setTitle:@"Z"];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), qu, ^{
        [self setTitle:@"X"];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), qu, ^{
        [self setTitle:@"W"];
    });
   
    
}

-(void)startAnimationWithIcons:(NSDictionary *)icons
{
    if (icons) {
        NSImage *cache = [self image];
        
        dispatch_queue_t qu = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), qu, ^{
            [self setImage:[icons valueForKey:AERICON_STATUS_30]];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), qu, ^{
            [self setImage:[icons valueForKey:AERICON_STATUS_50]];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), qu, ^{
            [self setImage:[icons valueForKey:AERICON_STATUS_100]];;
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), qu, ^{
            [self setImage:cache];;
        });
        
    }
}

@end
