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
#import "IndividualEventViewController.h"

@interface ExploreViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;
@property CLLocation *location;

@property NSMutableArray *eventObjects;
@property NSMutableArray *comparisonExploreAnnotationArray;

//pop up view
@property (weak, nonatomic) IBOutlet UIView *individualEventView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;

@end

@implementation ExploreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];


    UITapGestureRecognizer *mapTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(theMapTap:)];
        mapTap.numberOfTapsRequired = 1;
        [self.mapView addGestureRecognizer:mapTap];
        self.mapView.userInteractionEnabled = YES;

//    UIPanGestureRecognizer *mapTap2 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(theMapTap2:)];
//    mapTap2.minimumNumberOfTouches = 1;
//    [self.mapView addGestureRecognizer:mapTap2];

    self.eventObjects = [NSMutableArray array];
    self.comparisonExploreAnnotationArray = [NSMutableArray array];

    self.individualEventView.hidden = YES;

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
             exploreAnnotation.date = [object objectForKey:@"eventDate"];

             exploreAnnotation.themeFile = [object objectForKey:@"mapThemeImage"];
             [exploreAnnotation.themeFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {

                 exploreAnnotation.themeImage = [UIImage imageWithData:data];

                 [self.comparisonExploreAnnotationArray addObject:exploreAnnotation];
                 [self.mapView addAnnotation:exploreAnnotation];

             }];

//             [self.mapView addAnnotation:exploreAnnotation];
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

    ExploreEventAnnotationView *annotationView = [[ExploreEventAnnotationView alloc]initWithAnnotation:exploreAnnotation reuseIdentifier:nil];

    //VIK: Circular annotation
    exploreAnnotation.themeImageView = [[UIImageView alloc] initWithImage:exploreAnnotation.themeImage];

    exploreAnnotation.themeImageView.frame = CGRectMake(0,0,70,70);

    exploreAnnotation.themeImageView.contentMode = UIViewContentModeScaleAspectFill;

    exploreAnnotation.themeImageView.layer.cornerRadius = exploreAnnotation.themeImageView.image.size.height/2;

//    exploreAnnotation.themeImageView.layer.masksToBounds = YES;
    exploreAnnotation.themeImageView.clipsToBounds = YES;

    exploreAnnotation.themeImageView.layer.borderColor = [[UIColor colorWithRed:202/255.0 green:250/255.0 blue:53/255.0 alpha:1] CGColor];

    exploreAnnotation.themeImageView.layer.borderWidth = 2.0;

    [annotationView addSubview:exploreAnnotation.themeImageView];

    annotationView.geoPoint = exploreAnnotation.geoPoint;

    ///I think you should just manipulate the actual annotation view itself in ExploreEventAnnotationView.h - add a new property

    //double tap to expand?
    if (annotationView.gestureRecognizers.count == 0)
    {
        UITapGestureRecognizer *tapping = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTap:)];
        tapping.numberOfTapsRequired = 2;
        [annotationView addGestureRecognizer:tapping];
        annotationView.userInteractionEnabled = YES;
    }

    return annotationView;

}

#pragma mark - Tap Gesture Recognizer

- (void)tapTap:(UITapGestureRecognizer *)tapGestureRecognizer
{

    NSLog(@"Tap Tap Tap");

    ExploreEventAnnotationView *annotationView = (ExploreEventAnnotationView *)tapGestureRecognizer.view;

    self.individualEventView.hidden = NO;

    for (ExploreAnnotation *exploreAnnotation in self.comparisonExploreAnnotationArray)
    {
        if ([annotationView.geoPoint isEqual:exploreAnnotation.geoPoint])
    {

        self.titleLabel.text = exploreAnnotation.title;
        self.dateLabel.text = exploreAnnotation.date;
        self.locationLabel.text = exploreAnnotation.location;
        self.detailsTextView.text = exploreAnnotation.details;
        //size to fit this

        self.eventObject = exploreAnnotation.object;
    } else {
    }

    }
}

- (void)theMapTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    self.individualEventView.hidden = YES;
}

//- (void)theMapTap2:(UIPanGestureRecognizer *)panGestureRecognizer
//{
//    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan)
//    {
//        self.individualEventView.hidden = YES;
//    }
//}

- (IBAction)onExitButtonTapped:(id)sender
{
    self.individualEventView.hidden = YES;

}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FromExploreToIndividualSegue"])
    {
        IndividualEventViewController *individualEventViewController = segue.destinationViewController;
//        individualEventViewController.eventObject = self.eventObject;

        //what is the best way to pass this?
    }
}



@end
