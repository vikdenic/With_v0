//
//  PeopleAttendingEventViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/24/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "PeopleAttendingEventViewController.h"
#import "PeopleAttendingTableViewCell.h"

@interface PeopleAttendingEventViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *usersAttendingArray;

@end

@implementation PeopleAttendingEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.usersAttendingArray = [NSMutableArray array];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self usersAttendingQuery];

}

- (void)usersAttendingQuery
{
    [self.usersAttendingArray removeAllObjects];

    PFRelation *relation = [self.event relationForKey:@"usersAttending"];
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
    PeopleAttendingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    PFUser *user = [self.usersAttendingArray objectAtIndex:indexPath.row];

    cell.usernameLabel.text = [NSString stringWithFormat:@"%@", user[@"username"]];


    PFFile *userProfilePhoto = [user objectForKey:@"userProfilePhoto"];
    [userProfilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
             UIImage *temporaryImage = [UIImage imageWithData:data];
             cell.profilePictureImageView.image = temporaryImage;
     }];

    cell.friendButton.tag = indexPath.row;
    //set it in storyboard and do the for thing like max showed me earlier so set it to no and then if they are friend switch it
    [cell.friendButton addTarget:self action:@selector(ontapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.friendButton setTitle:@"NF" forState:UIControlStateNormal];

    return cell;
}

- (void)ontapped:(UIButton *)sender
{
    [sender setTitle:@"F" forState:UIControlStateNormal];

    PFUser *user = [self.usersAttendingArray objectAtIndex:sender.tag];

    PFObject *friendship = [PFObject objectWithClassName:@"Friendship"];
    friendship[@"fromUser"] = [PFUser currentUser];
    friendship[@"toUser"] = user;
    friendship[@"status"] = @"Pending";
    [friendship saveInBackground];

    ///check this on parse

    ///once a user is accepted or denied from pending friends then they will be moved to friends if the other user accepted it
}


@end
