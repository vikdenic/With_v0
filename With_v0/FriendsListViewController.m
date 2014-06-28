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

@interface FriendsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *approvedFriendships;

@end

@implementation FriendsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.approvedFriendships = [NSMutableArray array];

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

    if ([[friendship objectForKey:@"fromUser"] isEqual:[PFUser currentUser]])
    {
        PFUser *user = [friendship objectForKey:@"toUser"];

        cell.friendButton.otherUser = user;

        cell.usernameLabel.text = [NSString stringWithFormat:@"%@", user[@"username"]];

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

        cell.friendButton.otherUser = user;

        cell.usernameLabel.text = [NSString stringWithFormat:@"%@", user[@"username"]];

        PFFile *userProfilePhoto = [user objectForKey:@"userProfilePhoto"];
        [userProfilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             UIImage *temporaryImage = [UIImage imageWithData:data];
             cell.profilePictureImageView.image = temporaryImage;
         }];

    }

    UIImage *btnImage = [UIImage imageNamed:@"added_button_image"];
    [cell.friendButton setImage:btnImage forState:UIControlStateNormal];
    cell.friendButton.tag = indexPath.row;
    [cell.friendButton addTarget:self action:@selector(ontapped:) forControlEvents:UIControlEventTouchUpInside];

    PFUser *currentUserUsername = [PFUser currentUser];
    NSString *usernameString = currentUserUsername.username;

    if ([cell.usernameLabel.text isEqualToString:usernameString])
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

        sender.friendshipObject[@"status"] = @"Denied";
        [sender.friendshipObject saveInBackground];

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

@end
