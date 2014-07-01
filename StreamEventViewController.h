//
//  StreamEventViewController.h
//  With_v0
//
//  Created by Blake Mitchell on 6/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "IndividualEventPhoto.h"

@interface StreamEventViewController : UIViewController

@property PFObject *event;
@property PFUser *userToPass;
@property IndividualEventPhoto *individualEventPhoto;

@end
