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
#import "PageViewController.h"
#import "LoginViewController.h"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property UIRefreshControl *refreshControl;

@property NSMutableArray *eventArray;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    PFUser *currentUser = [PFUser currentUser];
//
//    //there is a bug here where the user can go to the home screen here//disable and hide the tab bar;
//
//    if (currentUser)
//    {
//        
//    } else{
//        [self performSegueWithIdentifier:@"showLogin" sender:self];
//    }
//
//    //pull to refresh
//    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
//    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
//    self.refreshControl = refreshControl;
//
//    [self.tableView addSubview:refreshControl];
//
//    [[self navigationController] setNavigationBarHidden:YES animated:YES];
//
//    [self queryForEvents];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    PFUser *currentUser = [PFUser currentUser];

    //there is a bug here where the user can go to the home screen here//disable and hide the tab bar;

    if (currentUser)
    {

    } else{
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }

    //pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    [self.tableView addSubview:refreshControl];

    [[self navigationController] setNavigationBarHidden:YES animated:YES];

    [self queryForEvents];

//    self.event = nil;

    //while everything is loading, we should do what facebook does and simulate that it is a connection problem by outlining out User Inteface. I might not be querying the right way

//    [self queryForEvents];
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

    //profile picture for creator
    PFFile *userProfilePhoto = [[object objectForKey:@"user"] objectForKey:@"userProfilePhoto"];
    [userProfilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
             UIImage *temporaryImage = [UIImage imageWithData:data];

             cell.creatorImageView.layer.cornerRadius = cell.creatorImageView.bounds.size.width/2;
             cell.creatorImageView.layer.borderColor = [[UIColor colorWithRed:202/255.0 green:250/255.0 blue:53/255.0 alpha:1] CGColor];
             cell.creatorImageView.layer.borderWidth = 2.0;
             cell.creatorImageView.layer.masksToBounds = YES;
             cell.creatorImageView.backgroundColor = [UIColor redColor];

             cell.creatorImageView.image = temporaryImage;
         } else {
             
             cell.creatorImageView.image = nil;
         }
     }];


    //theme image
    PFFile *file = [object objectForKey:@"themeImage"];

    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         UIImage *image = [UIImage imageWithData:data];
         cell.themeImageView.image = image;
    }];


    //creator username
    PFObject *userName = [[object objectForKey:@"user"] objectForKey:@"username"];
    cell.creatorNameLabel.text = [NSString stringWithFormat:@"%@", userName];

    //event Name and Date;
    cell.eventNameLabel.text = object[@"title"];
    cell.eventDateLabel.text = @"Saturday. June 25, 5pm";

    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Query for Events

- (void)queryForEvents
{
    [self.eventArray removeAllObjects];

    self.eventArray = [NSMutableArray array];

    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query includeKey:@"user"];
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
    if ([segue.identifier isEqualToString:@"ToPageViewControllerSegue"])
    {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        self.event = [self.eventArray objectAtIndex:selectedIndexPath.row];
        PageViewController *pageViewController = segue.destinationViewController;
        pageViewController.event = self.event;
    }
    else if([segue.identifier isEqualToString:@"showLogin"])
    {
        {
            LoginViewController *loginVC = segue.destinationViewController;
            loginVC.hidesBottomBarWhenPushed = YES;
        }
    }
}

- (IBAction)unwindSegueToHomeViewController:(UIStoryboardSegue *)sender
{

}

-(IBAction)unwindLogOutToHome:(UIStoryboardSegue *)sender
{
    
}

@end
