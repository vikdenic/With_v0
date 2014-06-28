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

@property NSMutableArray *options;
@property NSMutableArray *detailOptions;
@property NSString *createCustomString;
@property NSString *findCustomString;

//API stuff
@property NSArray *venuesArray;
@property NSMutableArray *imagesArray;
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

    self.createCustomString = [NSString stringWithFormat:@"Create \"%@\"",self.searchBar.text];
    self.findCustomString = [NSString stringWithFormat:@"Find \"%@\"",self.searchBar.text];
    self.options = [NSMutableArray arrayWithObjects:self.createCustomString, self.findCustomString, nil];

    NSString *detailCreateString = @"Create this location";
    NSString *detailSearchString = @"Search for this location";
    self.detailOptions = [NSMutableArray arrayWithObjects:detailCreateString, detailSearchString, nil];
    self.imagesArray = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"pin"], [UIImage imageNamed:@"search_image"], nil];
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

    NSLog(@"%d",self.isSearching);

    NSString *currentText = [self.searchBar.text stringByReplacingCharactersInRange:range withString:text];

    self.createCustomString = [NSString stringWithFormat:@"Create \"%@\"",currentText];
    self.findCustomString = [NSString stringWithFormat:@"Find \"%@\"",currentText];
    self.options = [NSMutableArray arrayWithObjects:self.createCustomString, self.findCustomString, nil];

    [self.retrievedVenuesArray removeAllObjects];
    [self.tableView reloadData];

    return YES;
}

-(void)searchForVenue
{
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
    self.isSearching = NO;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
//    NSString *customSearchString = [self.searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
//    NSLog(@"%@", customSearchString);

//    NSLog(@"%d",self.isSearching);
    [self searchForVenue];
}

#pragma mark - TableView Delegates
//NOT SURE WHERE THESE WARNINGS CAME FROM?
-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.isSearching == NO)
    {
    return self.retrievedVenuesArray.count;
    }
    else{
        return 2;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell"];

//    NSLog(@"CELLFORROW: %d",self.isSearching);

    if(self.isSearching == NO)
    {
        FSVenue *venue = [self.retrievedVenuesArray objectAtIndex:indexPath.row];

        if (venue.address && venue.city)
        {
            cell.textLabel.text = venue.name;

            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", venue.address, venue.city];
        }
        else if (!venue.address && venue.city)
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", venue.city];
        }
        else if (!venue.name)
        {
            cell.textLabel.text = @"Unnamed";

            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", venue.address, venue.city];
        }
        cell.imageView.image = nil;
    }

    //Presents option to create custom location or search
    else if(self.isSearching == YES)
    {
        cell.textLabel.text = [self.options objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [self.detailOptions objectAtIndex:indexPath.row];
        cell.imageView.image = [self.imagesArray objectAtIndex:indexPath.row];
    }

    return cell;
}

//CRUCIAL?
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    FSVenue *venue = [self.retrievedVenuesArray objectAtIndex:indexPath.row];
//
//    self.eventName = venue.name;
//    NSLog(@"did select row %@",self.eventName);

//    if(self.isSearching == YES)
//    {
//        if(indexPath.row == 0)
//        {
//            NSLog(@"Create Custom Location");
//            self.isSearching = NO;
//        }
//        else if(indexPath.row == 1)
//        {
//            [self searchBarSearchButtonClicked:self.searchBar];
//            self.isSearching = NO;
//        }
//    }
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isSearching == NO)
    {
    FSVenue *venue = [self.retrievedVenuesArray objectAtIndex:indexPath.row];

    self.eventName = venue.name;

    self.coordinate = CLLocationCoordinate2DMake(venue.lat, venue.lng);
//    NSLog(@"CHOOSE: %f %f", self.coordinate.latitude, self.coordinate.longitude);
    }

    else
    {
        self.isSearching = NO;

        if(indexPath.row == 0)
        {
//            NSLog(@"Create Custom Location");
            self.eventName = self.searchBar.text;
            self.coordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude);
        }

        else if(indexPath.row == 1)
        {
            [self searchForVenue];
//            NSLog(@"Search Custom Location");
        }
    }
    return indexPath;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - Miscellaneous

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
