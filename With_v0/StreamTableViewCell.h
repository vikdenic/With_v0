//
//  StreamTableViewCell.h
//  With_v0
//
//  Created by Blake Mitchell on 6/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreamTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *theImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfLikesLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIImageView *likedImageView;
@property BOOL ifLiked;

@end
