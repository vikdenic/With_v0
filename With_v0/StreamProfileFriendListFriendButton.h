//
//  StreamProfileFriendListFriendButton.h
//  With_v0
//
//  Created by Blake Mitchell on 6/30/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface StreamProfileFriendListFriendButton : UIButton

@property PFObject *friendshipObject;
@property PFUser *otherUser;

@end
