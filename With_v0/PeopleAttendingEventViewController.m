//
//  PeopleAttendingEventViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/24/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "PeopleAttendingEventViewController.h"
#import "PeopleAttendingTableViewCell.h"
#import "PeopleAttendingFriendButton.h"

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

    UIImage *btnImage = [UIImage imageNamed:@"add_friend_button_image"];
    [cell.friendButton setImage:btnImage forState:UIControlStateNormal];
    cell.friendButton.tag = indexPath.row;
    [cell.friendButton addTarget:self action:@selector(ontapped:) forControlEvents:UIControlEventTouchUpInside];

    ///this selector might not be hooked up to them all?

    ///I need to somehow pass this query object and alter it? Just query again?


    PFQuery *query = [PFQuery queryWithClassName:@"Friendship"];
    [query whereKey:@"fromUser" equalTo:user];
    [query whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"toUser" equalTo:user];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
     {
         if ([[object objectForKey:@"status"] isEqualToString:@"Approved"])
         {
             UIImage *btnImage = [UIImage imageNamed:@"added_button_image"];
             [cell.friendButton setImage:btnImage forState:UIControlStateNormal];
             
             cell.friendButton.friendshipObject = object;

             NSLog(@"%@", cell.friendButton.friendshipObject);

         } else if ([[object objectForKey:@"status"] isEqualToString:@"Pending"])
         {
             UIImage *btnImage = [UIImage imageNamed:@"pending_image"];
             [cell.friendButton setImage:btnImage forState:UIControlStateNormal];
             cell.friendButton.friendshipObject = object;
             NSLog(@"%@", cell.friendButton.friendshipObject);

         } else if ([[object objectForKey:@"status"] isEqualToString:@"Denied"])
         {
             UIImage *btnImage = [UIImage imageNamed:@"add_friend_button_image"];
             [cell.friendButton setImage:btnImage forState:UIControlStateNormal];
             cell.friendButton.friendshipObject = object;
             NSLog(@"%@", cell.friendButton.friendshipObject);
         }
         else {
             cell.friendButton.friendshipObject = nil;
             ///if it's nil this is going to be an issue
         }
    }];

    return cell;
}

- (void)ontapped:(PeopleAttendingFriendButton *)sender
{
    NSLog(@"%@", sender.friendshipObject);


    ///so in all these, we need to see if the friendship object already exists, if it does we alter it, if not, we create it.

    ///We will know if it exists because it will be either pending or approved- those two images - if it is nothing then we will have deleted the object and nothing will be there

    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"add_friend_button_image"]])
    {
        UIImage *btnImage = [UIImage imageNamed:@"added_button_image"];
        [sender setImage:btnImage forState:UIControlStateNormal];

        PFUser *user = [self.usersAttendingArray objectAtIndex:sender.tag];

        ///do this for all of these and do the appropriate action- if it's nil, I will need to create one
        sender.friendshipObject[@"fromUser"] = [PFUser currentUser];
        sender.friendshipObject[@"toUser"] = user;
        sender.friendshipObject[@"status"] = @"Pending";
        [sender.friendshipObject saveInBackground];

        //this is where we need to create the new object?????????

        ///change it to pending- because the current user is asking the other use to be friends

    } else if ([sender.imageView.image isEqual:[UIImage imageNamed:@"added_button_image"]])
    {
        UIImage *btnImage = [UIImage imageNamed:@"add_friend_button_image"];
        [sender setImage:btnImage forState:UIControlStateNormal];

        ///change it to add_friend_button_image and set the status to denied because they were friends and not the user has decided to defriend them- do we delete the relation?
        
    } else if ([sender.imageView.image isEqual:[UIImage imageNamed:@"pending_image"]])
    {
        UIImage *btnImage = [UIImage imageNamed:@"add_friend_button_image"];
        [sender setImage:btnImage forState:UIControlStateNormal];
        ///That's not a real image yet. If it's pending and then they click it, it will go back to add_friend_button_image because they don't want it to be pending

        ///delete the object
    }


//    PFUser *user = [self.usersAttendingArray objectAtIndex:sender.tag];
//
//    PFObject *friendship = [PFObject objectWithClassName:@"Friendship"];
//    friendship[@"fromUser"] = [PFUser currentUser];
//    friendship[@"toUser"] = user;
//    friendship[@"status"] = @"Pending";
//    [friendship saveInBackground];

    ///once a user is accepted or denied from pending friends then they will be moved to friends if the other user accepted it
}


@end
