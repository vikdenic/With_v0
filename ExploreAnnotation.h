//
//  ExploreAnnotation.h
//  With_v0
//
//  Created by Blake Mitchell on 6/22/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface ExploreAnnotation : MKPointAnnotation

@property PFGeoPoint *geoPoint;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property NSString *title;
@property NSString *details;
@property PFObject *object;
@property PFUser *creator;
@property NSString *location;
@property PFFile *themeFile;
@property UIImage *themeImage;
@property NSString *date;

@end
