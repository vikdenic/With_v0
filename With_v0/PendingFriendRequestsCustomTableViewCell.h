//
//  PendingFriendRequestsCustomTableViewCell.h
//  With_v0
//
//  Created by Blake Mitchell on 6/25/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PendingFriendRequestsCustomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *friendButton;

@end
