//
//  LikesListTableViewCell.h
//  With_v0
//
//  Created by Blake Mitchell on 6/30/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LikesListFriendButton.h"

@interface LikesListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UIButton *usernameButton;
@property (weak, nonatomic) IBOutlet LikesListFriendButton *friendButton;

@end
