//
//  IndividualEventInvitePeopleTableViewCell.h
//  With_v0
//
//  Created by Blake Mitchell on 7/1/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndividualEventInvitePeopleInviteButton.h"

@interface IndividualEventInvitePeopleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet IndividualEventInvitePeopleInviteButton *inviteButton;

@end
