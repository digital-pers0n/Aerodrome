//
//  aerwld.h
//  aerwld
//
//  Created by Terminator on 8/21/16.
//
//

#import <Foundation/Foundation.h>
#import "aerwldProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface aerwld : NSObject <aerwldProtocol>
{
    dispatch_source_t _terminateTimer;
   
    NSArray *_scanResults;
}

@end
