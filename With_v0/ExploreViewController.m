//
//  ExploreViewController.m
//  With_v0
//
//  Created by Vik Denic on 6/15/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "ExploreViewController.h"
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "ExploreEventAnnotationView.h"
#import "ExploreAnnotation.h"

@interface ExploreViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, weak)IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;
@property CLLocation *location;

@property NSMutableArray *eventObjects;

@end

@implementation ExploreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.eventObjects = [NSMutableArray array];

    self.navigationController.navigationBarHidden = YES;

    //user double clicks and event and a uiview pops up and bounces like on ifunny that shows the user all the info about the event and they can click buttons like going or no and see the address and all that and can click a button that will take them to the actual event page

    //in the view - title, details, number of people and pic for now?

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

- (void)queryForEvents: (PFGeoPoint *)userGeoPoint
{


    //need to make this so user can search around and also see events not around their current location?

    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query whereKey:@"locationGeoPoint" nearGeoPoint:userGeoPoint withinMiles:20];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         [self.eventObjects addObjectsFromArray:objects];

         for (PFObject *object in self.eventObjects)
         {
             ExploreAnnotation *exploreAnnotation = [[ExploreAnnotation alloc] init];

             exploreAnnotation.geoPoint = [object objectForKey:@"locationGeoPoint"];
             exploreAnnotation.coordinate = CLLocationCoordinate2DMake(exploreAnnotation.geoPoint.latitude, exploreAnnotation.geoPoint.longitude);
             exploreAnnotation.title = [object objectForKey:@"title"];
             exploreAnnotation.details = [object objectForKey:@"details"];
             exploreAnnotation.object = object;
             exploreAnnotation.creator = [object objectForKey:@"creator"];
             exploreAnnotation.location = [object objectForKey:@"location"];

             exploreAnnotation.themeFile = [object objectForKey:@"themeImage"];
             [exploreAnnotation.themeFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {

                 exploreAnnotation.themeImage = [UIImage imageWithData:data];
             }];

             [self.mapView addAnnotation:exploreAnnotation];
         }
     }];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Change your location in the simulator!!!!");
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    [self.mapView setShowsUserLocation:YES];

    self.location = [self.locationManager location];

    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:self.location.coordinate.latitude longitude:self.location.coordinate.longitude];

    [self queryForEvents:userGeoPoint];

    [self performSelector:@selector(delayForZoom)
               withObject:nil
               afterDelay:2.0];
}

- (void)delayForZoom
{
    MKCoordinateRegion mapRegion;
    mapRegion.center = self.location.coordinate;
    mapRegion.span.latitudeDelta = 0.10;
    mapRegion.span.longitudeDelta = 0.10;
    [self.mapView setRegion:mapRegion animated: YES];
}


#pragma mark - Map

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;

    ExploreAnnotation *exploreAnnotation = (ExploreAnnotation *)annotation;

    MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:exploreAnnotation reuseIdentifier:nil];

    CGSize sacleSize = CGSizeMake(50, 50);
    UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
    [exploreAnnotation.themeImage drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
    UIImage * resizedImage = UIGraphicsGetImageFromCurrentImageContext();

    annotationView.image = resizedImage;
    annotationView.layer.cornerRadius = resizedImage.size.width/2;
    annotationView.layer.borderColor = [[UIColor colorWithRed:202/255.0 green:250/255.0 blue:53/255.0 alpha:1] CGColor];
    annotationView.layer.borderWidth = 2.0;
    annotationView.clipsToBounds = YES;

//    //double tap to expand?
//    if (annotationView.gestureRecognizers.count == 0)
//    {
//        UITapGestureRecognizer *tapping = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTap:)];
//        tapping.numberOfTapsRequired = 2;
//        [annotationView addGestureRecognizer:tapping];
//        annotationView.userInteractionEnabled = YES;
//    }

    return annotationView;

}

#pragma mark - Tap Gesture Recognizer

//- (void)tapTap:(UITapGestureRecognizer *)tapGestureRecognizer
//{
//    PicNoteAnnotationView *annotationView = (PicNoteAnnotationView *)tapGestureRecognizer.view;
//
//    for (Picnote *picNote in self.mapItems)
//    {
//
//        if ([annotationView.path isEqualToString:[NSString stringWithFormat:@"%@", picNote.path]])
//        {
//            self.thePassedPicNote = picNote;
//            [self performSegueWithIdentifier:@"MapAllPicsToIndividualSegue" sender:self];
//        }
//    }
//}


@end
