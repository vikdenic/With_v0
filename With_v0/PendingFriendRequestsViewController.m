//
//  PendingFriendRequestsViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/25/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "PendingFriendRequestsViewController.h"
#import <Parse/Parse.h>
#import "PendingFriendRequestsCustomTableViewCell.h"

@interface PendingFriendRequestsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *pendingFriendships;

@end

@implementation PendingFriendRequestsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.pendingFriendships = [NSMutableArray array];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self queryForPendingFriendships];
}

- (void)queryForPendingFriendships
{
    [self.pendingFriendships removeAllObjects];

    PFQuery *query = [PFQuery queryWithClassName:@"Friendship"];
    [query whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"status" equalTo:@"Pending"];
    [query includeKey:@"fromUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        [self.pendingFriendships addObjectsFromArray:objects];
        [self.tableView reloadData];
    }];
}

#pragma mark- Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pendingFriendships.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PendingFriendRequestsCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    PFObject *friendship = [self.pendingFriendships objectAtIndex:indexPath.row];

    PFUser *user = [friendship objectForKey:@"fromUser"];

    cell.usernameLabel.text = [NSString stringWithFormat:@"%@", user.username];

    PFFile *userProfilePhoto = [user objectForKey:@"userProfilePhoto"];
    [userProfilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         UIImage *temporaryImage = [UIImage imageWithData:data];
         cell.profilePictureImageView.image = temporaryImage;

         ///if nil, set it to something we create
     }];

    //No Friend Button
    cell.friendButtonNo.tag = indexPath.row;
    [cell.friendButtonNo addTarget:self action:@selector(ontappedNo:) forControlEvents:UIControlEventTouchUpInside];
    [cell.friendButtonNo setTitle:@"NF" forState:UIControlStateNormal];

    //Yes Friend Button
    cell.friendButtonYes.tag = indexPath.row;
    [cell.friendButtonYes addTarget:self action:@selector(ontappedYes:) forControlEvents:UIControlEventTouchUpInside];
    [cell.friendButtonYes setTitle:@"NF" forState:UIControlStateNormal];

    return cell;
}

- (void)ontappedNo:(UIButton *)sender
{
    [sender setTitle:@"D" forState:UIControlStateNormal];

    PFObject *friendship = [self.pendingFriendships objectAtIndex:sender.tag];
    friendship[@"status"] = @"Denied";
    [friendship saveInBackground];
}

- (void)ontappedYes:(UIButton *)sender
{
    [sender setTitle:@"A" forState:UIControlStateNormal];

    PFObject *friendship = [self.pendingFriendships objectAtIndex:sender.tag];
    friendship[@"status"] = @"Approved";
    [friendship saveInBackground];
}

@end
