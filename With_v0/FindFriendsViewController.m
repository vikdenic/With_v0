//
//  FindFriendsViewController.m
//  With_v0
//
//  Created by Vik Denic on 6/15/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "FindFriendsViewController.h"
#import <Parse/Parse.h>
#import "FindFriendsTableViewCell.h"

@interface FindFriendsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *approvedFriendships;

@end

@implementation FindFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.approvedFriendships = [NSMutableArray array];
    [self queryForFriends];
}

#pragma mark - TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.approvedFriendships.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FindFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    PFObject *friendship = [self.approvedFriendships objectAtIndex:indexPath.row];

    PFUser *user = [friendship objectForKey:@"fromUser"];

    cell.usernameLabel.text = [NSString stringWithFormat:@"%@", user.username];










    cell.friendButton.tag = indexPath.row;
    [cell.friendButton addTarget:self action:@selector(ontapped:) forControlEvents:UIControlEventTouchUpInside];

    UIImage *btnImage = [UIImage imageNamed:@"added_button_image"];
    [cell.friendButton setImage:btnImage forState:UIControlStateNormal];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)ontapped:(FindFriendsFriendButton *)sender
{
    PFUser *user = [self.approvedFriendships objectAtIndex:sender.tag];

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

- (void)queryForFriends
{
    [self.approvedFriendships removeAllObjects];

    PFQuery *query = [PFQuery queryWithClassName:@"Friendship"];
    [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"status" equalTo:@"Approved"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         self.approvedFriendships = [NSMutableArray arrayWithArray:objects];
        [self.tableView reloadData];
    }];

    ///so what I have in this query is the list of friendship objects, I need to get the user from it

    ///I also need to find a way to combine from and to with status approved
    //two separate queries and then compare the objects within it?
}

@end
