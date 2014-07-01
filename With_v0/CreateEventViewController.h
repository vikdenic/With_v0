//
//  CreateEventViewController.h
//  With_v0
//
//  Created by Vik Denic on 6/15/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ThemeObject.h"
@interface CreateEventViewController : UIViewController

@property (strong, nonatomic) NSString *eventName;

@property CLLocationCoordinate2D coordinate;

@property (strong, nonatomic) NSString *dateString;

@property NSMutableArray *usersInvitedArray;

@property ThemeObject *themeObject;

@end
