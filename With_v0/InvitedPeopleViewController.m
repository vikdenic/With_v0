//
//  InvitedPeopleViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/29/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "InvitedPeopleViewController.h"
#import "InvitedPeopleButton.h"
#import <Parse/Parse.h>
#import "InvitedPeopleTableViewCell.h"
#import "StreamProfileViewController.h"

@interface InvitedPeopleViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *usersAttendingArray;

@property NSInteger indexPathRow;

@property UIRefreshControl *refreshControl;

@end

@implementation InvitedPeopleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.usersAttendingArray = [NSMutableArray array];

    [self usersAttendingQuery];

    //pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.tableView addSubview:refreshControl];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)usersAttendingQuery
{
    [self.usersAttendingArray removeAllObjects];

    PFRelation *relation = [self.event relationForKey:@"usersInvited"];
    PFQuery *query = [relation query];

    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
     {
         self.usersAttendingArray = [NSMutableArray arrayWithArray:results];
         [self.tableView reloadData];
     }];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.usersAttendingArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InvitedPeopleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    PFUser *user = [self.usersAttendingArray objectAtIndex:indexPath.row];

    [cell.usernameButton setTitle:[NSString stringWithFormat:@"%@", user[@"username"]] forState:UIControlStateNormal];
    cell.usernameButton.tag = indexPath.row;
    [cell.usernameButton addTarget:self action:@selector(onButtonTitlePressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.usernameButton setTintColor:[UIColor blackColor]];

    PFFile *userProfilePhoto = [user objectForKey:@"userProfilePhoto"];
    [userProfilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         UIImage *temporaryImage = [UIImage imageWithData:data];
         cell.profilePictureImageView.layer.cornerRadius = cell.profilePictureImageView.bounds.size.width/2;
         cell.profilePictureImageView.layer.borderColor = [[UIColor colorWithRed:202/255.0 green:250/255.0 blue:53/255.0 alpha:1] CGColor];
         cell.profilePictureImageView.layer.borderWidth = 2.0;
         cell.profilePictureImageView.layer.masksToBounds = YES;

         cell.profilePictureImageView.image = temporaryImage;
     }];

    cell.friendButton.tag = indexPath.row;
    [cell.friendButton addTarget:self action:@selector(ontapped:) forControlEvents:UIControlEventTouchUpInside];

    PFQuery *query = [PFQuery queryWithClassName:@"Friendship"];
    [query whereKey:@"fromUser" equalTo:user];
    [query whereKey:@"toUser" equalTo:[PFUser currentUser]];


    PFQuery *query2 = [PFQuery queryWithClassName:@"Friendship"];
    [query2 whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query2 whereKey:@"toUser" equalTo:user];
    

    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[query,query2]];
    [combinedQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
     {

         cell.friendButton.friendshipObject = object;

         if ([[object objectForKey:@"status"] isEqualToString:@"Approved"])
         {
             UIImage *btnImage = [UIImage imageNamed:@"added_button_image"];
             [cell.friendButton setImage:btnImage forState:UIControlStateNormal];

         } else if ([[object objectForKey:@"status"] isEqualToString:@"Pending"])
         {
             UIImage *btnImage = [UIImage imageNamed:@"pending_image"];
             [cell.friendButton setImage:btnImage forState:UIControlStateNormal];

         } else if ([[object objectForKey:@"status"] isEqualToString:@"Denied"])
         {
             UIImage *btnImage = [UIImage imageNamed:@"add_friend_button_image"];
             [cell.friendButton setImage:btnImage forState:UIControlStateNormal];

         } else {
             UIImage *btnImage = [UIImage imageNamed:@"add_friend_button_image"];
             [cell.friendButton setImage:btnImage forState:UIControlStateNormal];
         }

         if ([[cell.usernameButton titleForState:UIControlStateNormal] isEqualToString:[PFUser currentUser].username])
         {
             [cell.friendButton setImage:nil forState:UIControlStateNormal];
             cell.friendButton.userInteractionEnabled = NO;
         }

     }];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)ontapped:(InvitedPeopleButton *)sender
{
    PFUser *user = [self.usersAttendingArray objectAtIndex:sender.tag];

    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"add_friend_button_image"]])
    {
        UIImage *btnImage = [UIImage imageNamed:@"pending_image"];
        [sender setImage:btnImage forState:UIControlStateNormal];

        if (sender.friendshipObject == nil)
        {
            PFObject *friendship = [PFObject objectWithClassName:@"Friendship"];
            friendship[@"fromUser"] = [PFUser currentUser];
            friendship[@"toUser"] = user;
            friendship[@"status"] = @"Pending";
            [friendship saveInBackground];

        } else {
            sender.friendshipObject[@"status"] = @"Pending";
            [sender.friendshipObject saveInBackground];
        }

    } else if ([sender.imageView.image isEqual:[UIImage imageNamed:@"added_button_image"]])
    {
        UIImage *btnImage = [UIImage imageNamed:@"add_friend_button_image"];
        [sender setImage:btnImage forState:UIControlStateNormal];

        sender.friendshipObject[@"status"] = @"Denied";
        [sender.friendshipObject saveInBackground];

    } else if ([sender.imageView.image isEqual:[UIImage imageNamed:@"pending_image"]])
    {
        UIImage *btnImage = [UIImage imageNamed:@"add_friend_button_image"];
        [sender setImage:btnImage forState:UIControlStateNormal];

        sender.friendshipObject[@"status"] = @"Denied";
        [sender.friendshipObject saveInBackground];
    }
}

- (void)onButtonTitlePressed:(UIButton *)sender
{
    self.indexPathRow = sender.tag;
    [self performSegueWithIdentifier:@"InvitedToProfile" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"InvitedToProfile"])
    {
        StreamProfileViewController *streamProfileViewController = segue.destinationViewController;
        PFUser *userToPass = [self.usersAttendingArray objectAtIndex:self.indexPathRow];
        streamProfileViewController.userToPass = userToPass;
    }
}

#pragma mark - Pull To Refresh

- (void)refresh:(UIRefreshControl *)refreshControl
{
    [self usersAttendingQuery];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
}

- (void)stopRefresh
{
    [self.refreshControl endRefreshing];
}


@end
