//
//  ProfileViewController.m
//  With_v0
//
//  Created by Vik Denic on 6/15/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "IndividualEventViewController.h"
#import "HomeTableViewCell.h"
#import "HomeViewController.h"
#import "ProfileTableViewCell.h"
#import "IndividualEventViewController.h"

#import "ProfileView1.h"
#import "ProfileView2.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

//Views

@property (weak, nonatomic) IBOutlet UIImageView *profileAvatar;

@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UILabel *cityStateLabel;

@property (weak, nonatomic) IBOutlet UILabel *pastLabel;
@property (weak, nonatomic) IBOutlet UILabel *UpcomingLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *friendButton;

@property (weak, nonatomic) IBOutlet UIButton *friendStatusButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

//Data

@property NSArray *usersArray;
@property NSMutableArray *eventsAttendingArray;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.eventsAttendingArray = [NSMutableArray array];

    [self queryForUsersUpcomingEvents];

    ProfileView1 *prof1 = [[ProfileView1 alloc]init];
    ProfileView2 *prof2 = [[ProfileView2 alloc]init];

    //    self.scrollView.contentSize = CGSizeMake(1000, 160);
    [self.scrollView addSubview:prof1];
    [self.scrollView addSubview:prof2];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"Test1" object:nil];

        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];

        [self setUserInfo];

        self.profileAvatar.layer.cornerRadius = self.profileAvatar.layer.bounds.size.width /2;

        self.profileAvatar.clipsToBounds = YES;

        self.profileAvatar.layer.borderColor = [[UIColor colorWithRed:202/255.0 green:250/255.0 blue:53/255.0 alpha:1] CGColor];

        self.profileAvatar.layer.borderWidth = 2.0;

//        NSLog(@"did show %@",[PFUser currentUser]);

    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Profile"
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];

//    self.title = [PFUser currentUser].username;
//    self.navigationController.navigationBar.topItem.title = [PFUser currentUser].username;

//    self.usersArray = [[NSArray alloc]init];

    [self checkingNumberOfFriends];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.topItem.title = [PFUser currentUser].username;

    self.nameLabel.numberOfLines = 0;
    self.cityStateLabel.numberOfLines = 0;
    [self.bioTextView sizeToFit];

    [self setUserInfo];

//    NSLog(@"will show %@",[PFUser currentUser]);


}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
////    [self setUserInfo];
//
//}

#pragma mark - NSNotificationCenter
-(void)receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"Test1"])
    {
        NSLog(@"Notification Triggered");
        self.profileAvatar.image = nil;
        self.nameLabel.text = nil;
        self.bioTextView.text = nil;
        self.cityStateLabel.text = nil;
//        [self.whatEverArrayFillsTheTableView removeAllObjects];
//        [self.whatEverArrayFillsTheTableView reloadData];
    }
}

-(void)viewDidLayoutSubviews
{
    [self.scrollView setContentSize:CGSizeMake(640, 50)];
}

#pragma mark - Helpers

//-(void)retrieveUsersFromParse
//{
//    PFQuery *retrieveUsers = [PFQuery queryWithClassName:@"User"];
//    [retrieveUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//
//        self.usersArray = objects;
//        [self.tableView reloadData];
//    }];
//}

-(void)setUserInfo
{

    PFQuery *query = [PFQuery queryWithClassName:@"_User"];

    PFUser *currentUser = [PFUser currentUser];
    NSString *currentUserObjectId = currentUser.objectId;

    [query getObjectInBackgroundWithId:currentUserObjectId block:^(PFObject *object, NSError *error) {

            self.nameLabel.text = [object objectForKey:@"name"];
            self.cityStateLabel.text = [object objectForKey:@"userCityState"];
            self.bioTextView.text = [object objectForKey:@"userBio"];
            PFFile *coverImageFile = [object objectForKey:@"coverPhoto"];

            PFFile *imageFile = [object objectForKey:@"userProfilePhoto"];

            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                UIImage *image = [UIImage imageWithData:data];
                self.profileAvatar.image = image;

    }];
        [coverImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *coverImage = [UIImage imageWithData:data];
            self.coverImageView.image = coverImage;
        }];
    }];
}


//    PFQuery *retrieveUsers = [PFQuery queryWithClassName:@"User"];
//
//    [retrieveUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            PFUser *user = [PFUser currentUser];
//            self.nameLabel.text = [user objectForKey:@"name"];
//            self.cityStateLabel.text = [user objectForKey:@"userCityState"];
//            self.bioTextView.text = [user objectForKey:@"userBio"];
//            
//            PFFile *imageFile = [user objectForKey:@"userProfilePhoto"];
//
//            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//                UIImage *image = [UIImage imageWithData:data];
//                self.profileAvatar.image = image;
//            }];

//            self.followersLabel.text = [user objectForKey:@"followersCount"]; ?
//            self.followingLabel.text = [user objectForKey:@"followingCount"]; ?
//        }
//    }];


#pragma mark - Actions

- (IBAction)onPastButtonPressed:(id)sender
{
    self.pastLabel.textColor = [UIColor blackColor];
    self.UpcomingLabel.textColor = [UIColor grayColor];
}

- (IBAction)onUpcomingButtonPressed:(id)sender
{
    self.pastLabel.textColor = [UIColor grayColor];
    self.UpcomingLabel.textColor = [UIColor blackColor];
}


#pragma mark - TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.eventsAttendingArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    PFObject *object = [self.eventsAttendingArray objectAtIndex:indexPath.row];

    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);

    PFFile *userProfilePhoto = [[object objectForKey:@"creator"] objectForKey:@"userProfilePhoto"];
    [userProfilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (data == nil)
         {
             cell.creatorImageView.image = nil;

         } else
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
         }
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

    return cell;

}

- (void)queryForUsersUpcomingEvents
{
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"eventsAttending"];
    PFQuery *query = [relation query];
    [query includeKey:@"creator"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
     {
         self.eventsAttendingArray = [NSMutableArray arrayWithArray:results];
         [self.tableView reloadData];
     }];
}

- (void)checkingNumberOfFriends;
{
    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"Friendship"];
    [toUserQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [toUserQuery whereKey:@"status" equalTo:@"Approved"];

    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"Friendship"];
    [fromUserQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [fromUserQuery whereKey:@"status" equalTo:@"Approved"];

    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[toUserQuery,fromUserQuery]];
    [combinedQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error)
     {
         self.friendButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
         self.friendButton.titleLabel.textAlignment = NSTextAlignmentCenter;

         if (number == 0)
         {
          [self.friendButton setTitle:[NSString stringWithFormat:@"%i Friends", number] forState:UIControlStateNormal];

         } else if (number == 1)
         {
             [self.friendButton setTitle:[NSString stringWithFormat:@"%i Friend", number] forState:UIControlStateNormal];

         } else if (number > 1)
         {
             [self.friendButton setTitle:[NSString stringWithFormat:@"%i Friends", number] forState:UIControlStateNormal];
         }
    }];
}


#pragma mark - Segues

// When user CANCELS within settings
- (IBAction)unwindSegueCancelSettingsToProfile:(UIStoryboardSegue *)sender
{

}

// When user SAVES settings
- (IBAction)unwindSegueSaveSettingsToProfile:(UIStoryboardSegue *)sender
{
    [self setUserInfo];
}

- (IBAction)unwindSegueInvitesToProfile:(UIStoryboardSegue *)sender
{
    
}

//-(IBAction)unwindLogOutToProfile:(UIStoryboardSegue *)sender
//{
//    [PFUser logOut];
//
//    [self performSegueWithIdentifier:@"LogOutToSignIn" sender:self];
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ProfileToIndividualSegue"])
    {
        IndividualEventViewController *individualEventViewController = segue.destinationViewController;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        self.event = [self.eventsAttendingArray objectAtIndex:selectedIndexPath.row];
        individualEventViewController.event = self.event;
    }
}

@end
