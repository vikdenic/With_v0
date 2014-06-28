//
//  InvitePeopleViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/28/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "InvitePeopleViewController.h"
#import "InvitePeopleTableViewCell.h"
#import <Parse/Parse.h>

@interface InvitePeopleViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *usersFriends;

@end

@implementation InvitePeopleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.usersFriends = [NSMutableArray array];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self queryForFriends];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.usersFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InvitePeopleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    PFObject *friendship = [self.usersFriends objectAtIndex:indexPath.row];

    NSString *fromUser = [[friendship objectForKey:@"fromUser"] objectId];
    NSString *currentUser = [[PFUser currentUser] objectId];

    if ([fromUser isEqualToString:currentUser])
    {
        PFUser *user = [friendship objectForKey:@"toUser"];

        cell.inviteButton.otherUser = user;

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

        cell.inviteButton.otherUser = user;

        cell.usernameLabel.text = [NSString stringWithFormat:@"%@", user[@"username"]];

        PFFile *userProfilePhoto = [user objectForKey:@"userProfilePhoto"];
        [userProfilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             UIImage *temporaryImage = [UIImage imageWithData:data];
             cell.profilePictureImageView.image = temporaryImage;
         }];

    }

    UIImage *btnImage = [UIImage imageNamed:@"invite_image"];
    [cell.inviteButton setImage:btnImage forState:UIControlStateNormal];
    cell.inviteButton.tag = indexPath.row;
    [cell.inviteButton addTarget:self action:@selector(ontapped:) forControlEvents:UIControlEventTouchUpInside];

    PFUser *currentUserUsername = [PFUser currentUser];
    NSString *usernameString = currentUserUsername.username;

    if ([cell.usernameLabel.text isEqualToString:usernameString])
    {
        [cell.inviteButton setImage:nil forState:UIControlStateNormal];
        cell.inviteButton.userInteractionEnabled = NO;
    }
    
    return cell;
}

- (void)ontapped:(InvitePeopleInviteButton *)sender
{

    ///maybe this is easier to pass an array of PFUser's that the user selects through the segue then on create fast enumerate through them and add create the event invite object? I think that would be easier so if the user modifys it then we won't do it till create it clicked- so just fake the buttons and all that- basically each button that is green needs to be in the array


//    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"invite_image"]])
//    {
//        UIImage *btnImage = [UIImage imageNamed:@"invite_selected_image"];
//        [sender setImage:btnImage forState:UIControlStateNormal];
//
//        PFObject *eventInvite = [PFObject objectWithClassName:@"EventInvite"];
//        eventInvite[@"toUser"] = sender.otherUser;
//        eventInvite[@"event"] = //here I am going to have to have the event object from the previous screen- the one that is supposed to get made on create- tricky....
//        eventInvite[@"statusOfUser"] = @"Invited";
//        [eventInvite saveInBackground];
//        sender.inviteObject = eventInvite;
//
//        ///so as soon as they are in create event - we need to create the event object and then modify it on create button tapped- that way we can pass that event object in the segue to the invite view controller and save it with the users
//
//    } else if ([sender.imageView.image isEqual:[UIImage imageNamed:@"invite_selected_image"]])
//    {
//        UIImage *btnImage = [UIImage imageNamed:@"invite_image"];
//        [sender setImage:btnImage forState:UIControlStateNormal];
//        [sender.inviteObject deleteInBackground];
//    }
}

- (void)queryForFriends
{

    [self.usersFriends removeAllObjects];

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
         [self.usersFriends addObjectsFromArray:objects];

         [self.tableView reloadData];
     }];
}

@end
