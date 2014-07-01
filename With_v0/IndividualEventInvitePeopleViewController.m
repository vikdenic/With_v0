//
//  IndividualEventInvitePeopleViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 7/1/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "IndividualEventInvitePeopleViewController.h"
#import "IndividualEventInvitePeopleTableViewCell.h"

@interface IndividualEventInvitePeopleViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *usersFriends;
@property NSMutableArray *usersAlreadyAttendingArray;

@end

@implementation IndividualEventInvitePeopleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.usersFriends = [NSMutableArray array];
    self.usersInvitedArray = [NSMutableArray array];

    [self queryForFriends];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.usersFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IndividualEventInvitePeopleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    PFObject *friendship = [self.usersFriends objectAtIndex:indexPath.row];

    NSString *fromUser = [[friendship objectForKey:@"fromUser"] objectId];
    NSString *currentUser = [[PFUser currentUser] objectId];

    PFUser *userNameLabelUser;

    if ([fromUser isEqualToString:currentUser])
    {
        PFUser *user = [friendship objectForKey:@"toUser"];

        cell.inviteButton.otherUser = user;

        userNameLabelUser = user;

        cell.usernameLabel.text = [NSString stringWithFormat:@"%@", user[@"username"]];

        PFFile *userProfilePhoto = [user objectForKey:@"miniProfilePhoto"];
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

        cell.inviteButton.otherUser = user;

        userNameLabelUser = user;

        cell.usernameLabel.text = [NSString stringWithFormat:@"%@", user[@"username"]];

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

    for (PFUser *alreadyInvitedUser in self.usersAlreadyAttendingArray)
    {
        NSLog(@"for loop");
        NSString *alreadyInvitedUserId = alreadyInvitedUser.objectId;
        NSString *userNameLabelUserId = userNameLabelUser.objectId;

        if ([alreadyInvitedUserId isEqualToString:userNameLabelUserId])
        {
            //means the user is already invited
            UIImage *btnImage = [UIImage imageNamed:@"invite_selected_image"];
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [cell.inviteButton setImage:btnImage forState:UIControlStateNormal];
            cell.inviteButton.userInteractionEnabled = NO;
            break;

            ///if this is so, disable this button so the user can't change it or invite them
        } else {

            //means the user has the option to invite them
            UIImage *btnImage = [UIImage imageNamed:@"invite_image"];
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [cell.inviteButton setImage:btnImage forState:UIControlStateNormal];

        }
    }
//    UIImage *btnImage = [UIImage imageNamed:@"invite_image"];
//    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [cell.inviteButton setImage:btnImage forState:UIControlStateNormal];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)ontapped:(IndividualEventInvitePeopleInviteButton *)sender
{

    ///maybe this is easier to pass an array of PFUser's that the user selects through the segue then on create fast enumerate through them and add create the event invite object? I think that would be easier so if the user modifys it then we won't do it till create it clicked- so just fake the buttons and all that- basically each button that is green needs to be in the array


    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"invite_image"]])
    {
        UIImage *btnImage = [UIImage imageNamed:@"invite_selected_image"];
        [sender setImage:btnImage forState:UIControlStateNormal];

        [self.usersInvitedArray addObject:sender.otherUser];

    } else if ([sender.imageView.image isEqual:[UIImage imageNamed:@"invite_selected_image"]])
    {
        UIImage *btnImage = [UIImage imageNamed:@"invite_image"];
        [sender setImage:btnImage forState:UIControlStateNormal];

        [self.usersInvitedArray removeObject:sender.otherUser];

        ///what if they go back and fourth and stuff?
    }
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

    PFRelation *relation = [self.event relationForKey:@"usersInvited"];
    PFQuery *query = [relation query];

    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
     {
         self.usersAlreadyAttendingArray = [NSMutableArray arrayWithArray:results];
         [self.tableView reloadData];
     }];
}

@end
