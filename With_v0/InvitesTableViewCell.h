//
//  InvitesTableViewCell.h
//  With_v0
//
//  Created by Blake Mitchell on 6/28/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InvitesButton.h"

@interface InvitesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *themeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *creatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *creatorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDateLabel;

@property (weak, nonatomic) IBOutlet InvitesButton *yesButton;
@property (weak, nonatomic) IBOutlet InvitesButton *noButton;

@property (weak, nonatomic) IBOutlet UIView *blurContainerView;
@property (weak, nonatomic) IBOutlet UIView *transparentView;

@end
