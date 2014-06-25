//
//  PendingFriendRequestsViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/25/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "PendingFriendRequestsViewController.h"
#import <Parse/Parse.h>

@interface PendingFriendRequestsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PendingFriendRequestsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)queryForPendingFriendships
{
    PFQuery *query = [PFQuery queryWithClassName:@"Friendship"];
    [query whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        //put them in an array and then populate the tableview

    }];
}




#pragma mark- Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    return cell;
}

@end
