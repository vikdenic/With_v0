//
//  PeopleAttendingEventViewController.h
//  With_v0
//
//  Created by Blake Mitchell on 6/24/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PeopleAttendingEventViewController : UIViewController

@property PFObject *event;
@property PFUser *userToPass;

@end
