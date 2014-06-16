//
//  HomeViewController.m
//  With_v0
//
//  Created by Vik Denic on 6/15/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "HomeViewController.h"
#import <Parse/Parse.h>
#import "HomeTableViewCell.h"
#import "IndividualEventViewController.h"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property UIRefreshControl *refreshControl;

@property NSMutableArray *eventArray;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    [self.tableView addSubview:refreshControl];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.eventArray = [NSMutableArray array];

    //while everything is loading, we should do what facebook does and simulate that it is a connection problem by outlining out User Inteface. I might not be querying the right way

    [self queryForEvents];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.eventArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    PFObject *object = [self.eventArray objectAtIndex:indexPath.row];

    PFFile *file = [object objectForKey:@"themeImage"];

    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         UIImage *image = [UIImage imageWithData:data];
         cell.themeImageView.image = image;
    }];

//    cell.creatorImageView.image = query through user relation
//    cell.creatorNameLabel.text = query through user relation
    cell.eventNameLabel.text = object[@"title"];
    cell.eventDateLabel.text = @"Saturday. June 25, 5pm";

    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
//                                                         bundle:nil];
//    IndividualEventViewController *individualEventViewController =
//    [storyboard instantiateViewControllerWithIdentifier:@"IndividualEventViewController"];
//
//    [self presentViewController:individualEventViewController
//                       animated:YES
//                     completion:nil];
//
////    [self.view addSubview:individualEventViewController.view];
//}

#pragma mark - Query for Events

- (void)queryForEvents
{
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
        if (!error)
        {
            [self.eventArray addObjectsFromArray:objects];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Pull To Refresh

- (void)refresh:(UIRefreshControl *)refreshControl
{
    [self.eventArray removeAllObjects];
    [self queryForEvents];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
}

- (void)stopRefresh
{
    [self.refreshControl endRefreshing];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}


- (IBAction)unwindSegueToHomeViewController:(UIStoryboardSegue *)sender
{

}

@end
