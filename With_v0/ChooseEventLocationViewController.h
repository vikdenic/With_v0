//
//  ChooseEventLocationViewController.h
//  With_v0
//
//  Created by Vik Denic on 6/18/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ChooseEventLocationViewController : UIViewController

@property (strong, nonatomic) NSString *eventName;

@property CLLocationCoordinate2D coordinate;

@end
