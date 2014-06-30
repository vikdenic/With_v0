//
//  CommentsViewController.h
//  With_v0
//
//  Created by Blake Mitchell on 6/17/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "IndividualEventPhoto.h"

@interface CommentsViewController : UIViewController

@property IndividualEventPhoto *individualEventPhoto;
@property PFUser *userToPass;

@end
