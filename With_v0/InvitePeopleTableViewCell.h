//
//  InvitePeopleTableViewCell.h
//  With_v0
//
//  Created by Blake Mitchell on 6/28/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InvitePeopleInviteButton.h"

@interface InvitePeopleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet InvitePeopleInviteButton *inviteButton;

@end
