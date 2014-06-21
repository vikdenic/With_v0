//
//  ChooseEventLocationViewController.m
//  With_v0
//
//  Created by Vik Denic on 6/18/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "ChooseEventLocationViewController.h"
#import <MapKit/MapKit.h>
#import "FSVenue.h"
#import "CreateEventViewController.h"

@interface ChooseEventLocationViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//API stuff
@property NSArray *venuesArray;
@property NSMutableArray *retrievedVenuesArray;

//Location stuff
@property CLLocationManager *locationManager;
@property double latitude;
@property double longitude;

@property BOOL isSearching;

@end

@implementation ChooseEventLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.searchBar.delegate = self;
    self.isSearching = NO;

    [self locationStuff];

    self.venuesArray = [[NSArray alloc]init];
    self.retrievedVenuesArray = [[NSMutableArray alloc]init];

    [self retrieveInitialData];
}

-(void)locationStuff
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

#pragma mark - Core Location

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Privacy Setting" message:@"Please change your privacy settings to allow SeeNote to update your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{

    self.latitude = self.locationManager.location.coordinate.latitude;
    self.longitude = self.locationManager.location.coordinate.longitude;

    [self.locationManager stopUpdatingLocation];
    [self retrieveInitialData];
}

#pragma mark - FourSquare Data

-(void)retrieveInitialData
{
    NSString *locationString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%f,%f&oauth_token=3JZTWOWUCT0SQDKB1MAQ54ILOYNKJXDERR5CLKFSN20GRZIT&v=20140618", self.latitude, self.longitude];

//    NSLog(@"%@",locationString);

    NSURL *url = [NSURL URLWithString:locationString];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response,
                                                                                                            NSData *data,
                                                                                                            NSError *connectionError) {

        NSDictionary *fsDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];

        self.venuesArray = [[fsDictionary objectForKey:@"response"]objectForKey:@"venues"];

        for(NSDictionary *venueDictionary in self.venuesArray)
        {
            FSVenue *venue = [[FSVenue alloc]init];

            venue.name = [venueDictionary objectForKey:@"name"];

            venue.address = [[venueDictionary objectForKey:@"location"] objectForKey:@"address"];
            venue.city = [[venueDictionary objectForKey:@"location"] objectForKey:@"city"];


            venue.lat = [[[venueDictionary objectForKey:@"location"] objectForKey:@"lat"] floatValue];
            venue.lng = [[[venueDictionary objectForKey:@"location"] objectForKey:@"lng"] floatValue];

//            NSLog(@"%@ %f %f", venue.name, venue.lat, venue.lng);

            [self.retrievedVenuesArray addObject:venue];
        }
        [self.tableView reloadData];
    }];
}



#pragma mark - Search Bar

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    self.isSearching = YES;
    [self.retrievedVenuesArray removeAllObjects];
    [self.tableView reloadData];

    return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
//    NSString *customSearchString = [self.searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
//    NSLog(@"%@", customSearchString);
    self.isSearching = NO;

    NSString *customSearchString = [self.searchBar.text stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];

    NSString *locationString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?query=%@&ll=%f,%f&oauth_token=3JZTWOWUCT0SQDKB1MAQ54ILOYNKJXDERR5CLKFSN20GRZIT&v=20140618", customSearchString, self.latitude, self.longitude];

    //    NSLog(@"%@",locationString);

    NSURL *url = [NSURL URLWithString:locationString];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response,
                                                                                                            NSData *data,
                                                                                                            NSError *connectionError) {

        NSDictionary *fsDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];

        self.venuesArray = [[fsDictionary objectForKey:@"response"]objectForKey:@"venues"];

        for(NSDictionary *venueDictionary in self.venuesArray)
        {
            FSVenue *venue = [[FSVenue alloc]init];

            venue.name = [venueDictionary objectForKey:@"name"];

            venue.address = [[venueDictionary objectForKey:@"location"] objectForKey:@"address"];
            venue.city = [[venueDictionary objectForKey:@"location"] objectForKey:@"city"];


            venue.lat = [[[venueDictionary objectForKey:@"location"] objectForKey:@"lat"] floatValue];
            venue.lng = [[[venueDictionary objectForKey:@"location"] objectForKey:@"lng"] floatValue];

            //            NSLog(@"%@ %f %f", venue.name, venue.lat, venue.lng);
            
            [self.retrievedVenuesArray addObject:venue];
        }
        [self.tableView reloadData];
    }];
    [self.searchBar resignFirstResponder];
}

#pragma mark - TableView Delegates
//NOT SURE WHERE THESE WARNINGS CAME FROM?
-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.retrievedVenuesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    FSVenue *venue = [self.retrievedVenuesArray objectAtIndex:indexPath.row];


    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell"];

    cell.textLabel.text = venue.name;

    if(venue.address)
    {
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", venue.address, venue.city];
    }
    else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", venue.city];
    }

    return cell;
}

//CRUCIAL
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    FSVenue *venue = [self.retrievedVenuesArray objectAtIndex:indexPath.row];
//
//    self.eventName = venue.name;
//    NSLog(@"did select row %@",self.eventName);
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSVenue *venue = [self.retrievedVenuesArray objectAtIndex:indexPath.row];

    self.eventName = venue.name;

    self.coordinate = CLLocationCoordinate2DMake(venue.lat, venue.lng);
    NSLog(@"CHOOSE: %f %f", self.coordinate.latitude, self.coordinate.longitude);

    return indexPath;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - Miscellaneous

// Dismisses billTextField's keyboard upon tap-away

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
