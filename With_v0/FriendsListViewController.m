//
//  FriendsListViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/27/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "FriendsListViewController.h"
#import <Parse/Parse.h>
#import "FriendsListTableViewCell.h"
#import "FriendsListFriendButton.h"
#import "StreamProfileViewController.h"

@interface FriendsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *approvedFriendships;
@property NSInteger indexPathRow;
@property NSMutableArray *usersAttendingArray;

@end

@implementation FriendsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.approvedFriendships = [NSMutableArray array];
    self.usersAttendingArray = [NSMutableArray array];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self queryForFriends];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.approvedFriendships.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    PFObject *friendship = [self.approvedFriendships objectAtIndex:indexPath.row];

    cell.friendButton.friendshipObject = friendship;

    NSString *fromUser = [[friendship objectForKey:@"fromUser"] objectId];
    NSString *currentUser = [[PFUser currentUser] objectId];

    if ([fromUser isEqualToString:currentUser])
    {
        PFUser *user = [friendship objectForKey:@"toUser"];
        [self.usersAttendingArray addObject:user];

        cell.friendButton.otherUser = user;

        [cell.usernameButton setTitle:[NSString stringWithFormat:@"%@", user[@"username"]] forState:UIControlStateNormal];
        cell.usernameButton.tag = indexPath.row;
        [cell.usernameButton addTarget:self action:@selector(onButtonTitlePressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.usernameButton setTintColor:[UIColor blackColor]];


        PFFile *userProfilePhoto = [user objectForKey:@"userProfilePhoto"];
        [userProfilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             UIImage *temporaryImage = [UIImage imageWithData:data];
             cell.profilePictureImageView.image = temporaryImage;

             ///if nil, set it to something we create
         }];

    } else
    {
        PFUser *user = [friendship objectForKey:@"fromUser"];
        [self.usersAttendingArray addObject:user];

        cell.friendButton.otherUser = user;

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

    }

    UIImage *btnImage = [UIImage imageNamed:@"added_button_image"];
    [cell.friendButton setImage:btnImage forState:UIControlStateNormal];
    cell.friendButton.tag = indexPath.row;
    [cell.friendButton addTarget:self action:@selector(ontapped:) forControlEvents:UIControlEventTouchUpInside];

    if ([[cell.usernameButton titleForState:UIControlStateNormal] isEqualToString:[PFUser currentUser].username])
    {
        [cell.friendButton setImage:nil forState:UIControlStateNormal];
        cell.friendButton.userInteractionEnabled = NO;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)ontapped:(FriendsListFriendButton *)sender
{
    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"added_button_image"]])
    {
        UIImage *btnImage = [UIImage imageNamed:@"add_friend_button_image"];
        [sender setImage:btnImage forState:UIControlStateNormal];
        [sender.friendshipObject deleteInBackground];

    } else if ([sender.imageView.image isEqual:[UIImage imageNamed:@"add_friend_button_image"]])
    {
        UIImage *btnImage = [UIImage imageNamed:@"pending_image"];
        [sender setImage:btnImage forState:UIControlStateNormal];

        [sender.friendshipObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            PFObject *friendship = [PFObject objectWithClassName:@"Friendship"];
            friendship[@"fromUser"] = [PFUser currentUser];
            friendship[@"toUser"] = sender.otherUser;
            friendship[@"status"] = @"Pending";
            [friendship saveInBackground];
        }];
    }
}

- (void)queryForFriends
{

    [self.approvedFriendships removeAllObjects];

    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"Friendship"];
    [toUserQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [toUserQuery whereKey:@"status" equalTo:@"Approved"];

    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"Friendship"];
    [fromUserQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [fromUserQuery whereKey:@"status" equalTo:@"Approved"];

    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[toUserQuery,fromUserQuery]];
    [combinedQuery includeKey:@"fromUser"];
    [combinedQuery includeKey:@"toUser"];
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         [self.approvedFriendships addObjectsFromArray:objects];

         [self.tableView reloadData];
     }];
}

- (void)onButtonTitlePressed:(UIButton *)sender
{
    self.indexPathRow = sender.tag;
    [self performSegueWithIdentifier:@"FriendsToProfile" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FriendsToProfile"])
    {
        StreamProfileViewController *streamProfileViewController = segue.destinationViewController;
        PFUser *userToPass = [self.usersAttendingArray objectAtIndex:self.indexPathRow];
        streamProfileViewController.userToPass = userToPass;
    }
}

@end
