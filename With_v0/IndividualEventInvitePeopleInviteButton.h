//
//  IndividualEventInvitePeopleInviteButton.h
//  With_v0
//
//  Created by Blake Mitchell on 7/1/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface IndividualEventInvitePeopleInviteButton : UIButton

@property PFObject *inviteObject;
@property PFUser *otherUser;

@end
