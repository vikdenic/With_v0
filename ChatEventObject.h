//
//  ChatEventObject.h
//  With_v0
//
//  Created by Blake Mitchell on 7/1/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ChatEventObject : NSObject

@property PFUser *user;
@property NSString *chatMessage;

@end
