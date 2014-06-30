//
//  StreamProfileFriendListViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/30/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StreamProfileFriendListViewController.h"
#import <Parse/Parse.h>
#import "StreamProfileViewController.h"
#import "StreamProfileFriendsListTableViewCell.h"

@interface StreamProfileFriendListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *approvedFriendships;
@property NSInteger *indexPathRow;
@property NSMutableArray *usersAttendingArray;

@end

@implementation StreamProfileFriendListViewController

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
    StreamProfileFriendsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    PFObject *friendship = [self.approvedFriendships objectAtIndex:indexPath.row];

    cell.friendButton.friendshipObject = friendship;

    NSString *fromUser = [[friendship objectForKey:@"fromUser"] objectId];
    NSString *theUser = self.userToPass.objectId;

    PFUser *userToCompareFriendship;

    if ([fromUser isEqualToString:theUser])
    {
        PFUser *user = [friendship objectForKey:@"toUser"];
        [self.usersAttendingArray addObject:user];

        userToCompareFriendship = user;

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

             ///if nil, set it to something we create
         }];

    } else
    {
        PFUser *user = [friendship objectForKey:@"fromUser"];
        [self.usersAttendingArray addObject:user];

        userToCompareFriendship = user;

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

    //seeing if use is friends with the current user or not
    PFQuery *query = [PFQuery queryWithClassName:@"Friendship"];
    [query whereKey:@"fromUser" equalTo:userToCompareFriendship];
    [query whereKey:@"toUser" equalTo:[PFUser currentUser]];

    PFQuery *query2 = [PFQuery queryWithClassName:@"Friendship"];
    [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"toUser" equalTo:userToCompareFriendship];

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

//    UIImage *btnImage = [UIImage imageNamed:@"added_button_image"];
//    [cell.friendButton setImage:btnImage forState:UIControlStateNormal];
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

//- (void)ontapped:(StreamProfileFriendListFriendButton *)sender
//{
//    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"added_button_image"]])
//    {
//        UIImage *btnImage = [UIImage imageNamed:@"add_friend_button_image"];
//        [sender setImage:btnImage forState:UIControlStateNormal];
//        [sender.friendshipObject deleteInBackground];
//
//    } else if ([sender.imageView.image isEqual:[UIImage imageNamed:@"add_friend_button_image"]])
//    {
//        UIImage *btnImage = [UIImage imageNamed:@"pending_image"];
//        [sender setImage:btnImage forState:UIControlStateNormal];
//
//        [sender.friendshipObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//         {
//             PFObject *friendship = [PFObject objectWithClassName:@"Friendship"];
//             friendship[@"fromUser"] = [PFUser currentUser];
//             friendship[@"toUser"] = sender.otherUser;
//             friendship[@"status"] = @"Pending";
//             [friendship saveInBackground];
//         }];
//    }
//}

- (void)queryForFriends
{

    [self.approvedFriendships removeAllObjects];

    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"Friendship"];
    [toUserQuery whereKey:@"toUser" equalTo:self.userToPass];
    [toUserQuery whereKey:@"status" equalTo:@"Approved"];

    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"Friendship"];
    [fromUserQuery whereKey:@"fromUser" equalTo:self.userToPass];
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

    StreamProfileViewController *stream = [self.storyboard instantiateViewControllerWithIdentifier:@"StreamProfileViewController"];
    PFUser *userToPass = [self.usersAttendingArray objectAtIndex:self.indexPathRow];
    stream.userToPass = userToPass;
    [self.navigationController pushViewController:stream animated:YES];
}

- (void)ontapped:(StreamProfileFriendListFriendButton *)sender
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

@end
