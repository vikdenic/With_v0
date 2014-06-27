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

#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property UIRefreshControl *refreshControl;

@property NSMutableArray *eventArray;
@property NSMutableArray *indexPathArray;

@property BOOL doingTheQuery;

@property (nonatomic) CGRect originalFrame;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.originalFrame = self.tabBarController.tabBar.frame;

    self.eventArray = [NSMutableArray array];
    self.indexPathArray = [NSMutableArray array];

    self.tabBarController.tabBar.tintColor = [UIColor orangeColor];

    PFUser *currentUser = [PFUser currentUser];

        if (currentUser)
        {

        } else {
            
            [self performSegueWithIdentifier:@"showLogin" sender:self];
        }

    //pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.tableView addSubview:refreshControl];

    [[self navigationController] setNavigationBarHidden:NO animated:YES];

    [self queryForEvents];

    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Home"
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
}

#pragma mark - Hide TabBar
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    UITabBar *tb = self.tabBarController.tabBar;
    NSInteger yOffset = scrollView.contentOffset.y;
    if (yOffset > 0) {
        tb.frame = CGRectMake(tb.frame.origin.x, self.originalFrame.origin.y + yOffset, tb.frame.size.width, tb.frame.size.height);
    }
    if (yOffset < 1) tb.frame = self.originalFrame;
}

#pragma mark - Blur

//- (void) captureBlur {
//    HomeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
//
//    //Get a UIImage from the UIView
//    NSLog(@"blur capture");
//    UIGraphicsBeginImageContext(cell.themeImageView.bounds.size);
//    [cell.themeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    //Blur the UIImage
//    CIImage *imageToBlur = [CIImage imageWithCGImage:viewImage.CGImage];
//    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
//    [gaussianBlurFilter setValue:imageToBlur forKey: @"inputImage"];
//    [gaussianBlurFilter setValue:[NSNumber numberWithFloat: 10] forKey: @"inputRadius"]; //change number to increase/decrease blur
//    CIImage *resultImage = [gaussianBlurFilter valueForKey: @"outputImage"];
//
//    //create UIImage from filtered image
//    UIImage *blurrredImage = [[UIImage alloc] initWithCIImage:resultImage];
//
//    //Place the UIImage in a UIImageView
//    UIImageView *newView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    newView.image = blurrredImage;
//
//    //insert blur UIImageView below transparent view inside the blur image container
//    [cell.blurContainerView insertSubview:newView belowSubview:cell.transparentView];
//}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.eventArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    if (cell == nil) {
        cell = [[HomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }

    PFObject *object = [self.eventArray objectAtIndex:indexPath.row];

    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);

    PFFile *userProfilePhoto = [[object objectForKey:@"creator"] objectForKey:@"userProfilePhoto"];
    [userProfilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         dispatch_async(queue2, ^{
             UIImage *temporaryImage = [UIImage imageWithData:data];

         cell.creatorImageView.layer.cornerRadius = cell.creatorImageView.bounds.size.width/2;
         cell.creatorImageView.layer.borderColor = [[UIColor colorWithRed:202/255.0 green:250/255.0 blue:53/255.0 alpha:1] CGColor];
         cell.creatorImageView.layer.borderWidth = 2.0;
         cell.creatorImageView.layer.masksToBounds = YES;
//         cell.creatorImageView.backgroundColor = [UIColor redColor];

         dispatch_sync(dispatch_get_main_queue(), ^{
             cell.creatorImageView.image = temporaryImage;
            });
        });
     }];

    //this gets the image not on the main thread
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    PFFile *file = [object objectForKey:@"themeImage"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         dispatch_async(queue, ^{
             UIImage *image = [UIImage imageWithData:data];

             dispatch_sync(dispatch_get_main_queue(), ^{
                cell.themeImageView.image = image;
             });
         });
     }];

    //creator username
    PFObject *userName = [[object objectForKey:@"creator"] objectForKey:@"username"];
    cell.creatorNameLabel.text = [NSString stringWithFormat:@"%@", userName];

    //event Name and Date;
    cell.eventNameLabel.text = object[@"title"];
    cell.eventDateLabel.text = object[@"eventDate"];

    cell.accessoryType = UITableViewCellAccessoryNone;

    NSInteger sectionsAmount = [tableView numberOfSections];
    NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
    if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1)
    {
        if (!self.doingTheQuery)
        {
            [self queryForEvents];
        }

        ///so what if it's the bottom and there is no more, how to stop it from continually doing this- only do it once
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Query for Events

- (void)queryForEvents
{
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query includeKey:@"creator"];
    query.limit = 4;

    if (self.eventArray.count == 0)
    {
        query.skip = 0;

    } else
    {
        query.skip = self.eventArray.count;
    }
//  query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         self.doingTheQuery = YES;

         if (self.eventArray.count < 3)
         {
            [self.eventArray addObjectsFromArray:objects];
            [self.tableView reloadData];

         } else if (self.eventArray.count >= 3)
         {
             int theCount = (int)self.eventArray.count;
             [self.eventArray addObjectsFromArray:objects];

             for (int i = theCount; i <= self.eventArray.count-1; i++)
             {
                 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                 [self.indexPathArray addObject:indexPath];
             }

             [self.tableView insertRowsAtIndexPaths:self.indexPathArray withRowAnimation:UITableViewRowAnimationFade];
             [self.indexPathArray removeAllObjects];
         }
         self.doingTheQuery = NO;
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

- (IBAction)showActionSheet:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Report", nil];

    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    NSString *theButtonIndex = [actionSheet buttonTitleAtIndex:buttonIndex];

    if ([theButtonIndex isEqualToString:@"Cancel"])
    {
        //dismiss

    } else if ([theButtonIndex isEqualToString:@"Report"])
    {
        ///if it is reported- this button is clicked- we need to notify ourselves somehow?
        ///send them a uialert to tell them it has been reported
    }
}

- (IBAction)unwindSegueToHomeViewController:(UIStoryboardSegue *)sender
{

}

@end


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



