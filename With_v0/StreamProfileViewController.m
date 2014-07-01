//
//  StreamProfileViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/29/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StreamProfileViewController.h"
#import <Parse/Parse.h>
#import "StreamProfileFriendListViewController.h"

@interface StreamProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileAvatar;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UILabel *cityStateLabel;

@property (weak, nonatomic) IBOutlet UILabel *pastLabel;
@property (weak, nonatomic) IBOutlet UILabel *UpcomingLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *friendButton;
@property (weak, nonatomic) IBOutlet UIButton *friendStatusButton;

@end

@implementation StreamProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.profileAvatar.layer.cornerRadius = self.profileAvatar.layer.bounds.size.width /2;

    self.profileAvatar.clipsToBounds = YES;

    self.profileAvatar.layer.borderColor = [[UIColor colorWithRed:202/255.0 green:250/255.0 blue:53/255.0 alpha:1] CGColor];

    self.profileAvatar.layer.borderWidth = 2.0;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.nameLabel.numberOfLines = 0;
    self.cityStateLabel.numberOfLines = 0;
    [self.bioTextView sizeToFit];

    [self checkingNumberOfFriends];
    [self setUserInfo];
    [self queryForUserAndProfileUserFriendStatus];
}

-(void)setUserInfo
{
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];

    PFUser *theUser = self.userToPass;
    NSString *theUserObjectId = theUser.objectId;

    [query getObjectInBackgroundWithId:theUserObjectId block:^(PFObject *object, NSError *error) {

        self.nameLabel.text = [object objectForKey:@"username"];
//        self.cityStateLabel.text = [object objectForKey:@"userCityState"];
//        self.bioTextView.text = [object objectForKey:@"userBio"];

        PFFile *imageFile = [object objectForKey:@"userProfilePhoto"];

        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *image = [UIImage imageWithData:data];
            self.profileAvatar.image = image;

        }];
    }];
}

#pragma mark - Actions

- (IBAction)onPastButtonPressed:(id)sender
{
    self.pastLabel.textColor = [UIColor blackColor];
    self.UpcomingLabel.textColor = [UIColor grayColor];
}

- (IBAction)onUpcomingButtonPressed:(id)sender
{
    self.pastLabel.textColor = [UIColor grayColor];
    self.UpcomingLabel.textColor = [UIColor blackColor];
}

- (void)checkingNumberOfFriends;
{
    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"Friendship"];
    [toUserQuery whereKey:@"toUser" equalTo:self.userToPass];
    [toUserQuery whereKey:@"status" equalTo:@"Approved"];

    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"Friendship"];
    [fromUserQuery whereKey:@"fromUser" equalTo:self.userToPass];
    [fromUserQuery whereKey:@"status" equalTo:@"Approved"];

    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[toUserQuery,fromUserQuery]];
    [combinedQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error)
     {
         self.friendButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
         self.friendButton.titleLabel.textAlignment = NSTextAlignmentCenter;
         
         if (number == 0)
         {
             [self.friendButton setTitle:[NSString stringWithFormat:@"%i Friends", number] forState:UIControlStateNormal];

         } else if (number == 1)
         {
             [self.friendButton setTitle:[NSString stringWithFormat:@"%i Friend", number] forState:UIControlStateNormal];

         } else if (number > 1)
         {
             [self.friendButton setTitle:[NSString stringWithFormat:@"%i Friends", number] forState:UIControlStateNormal];
         }
     }];
}


#pragma mark - TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return self.usersArray.count;
    return 0;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
    
    return cell;
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"StreamProfileToStreamFriendList"])
    {
        //pass the to user object
        StreamProfileFriendListViewController *streamProfileFriendListViewController = segue.destinationViewController;
        streamProfileFriendListViewController.userToPass = self.userToPass;
    }
}

- (void)queryForUserAndProfileUserFriendStatus
{
    PFQuery *query = [PFQuery queryWithClassName:@"Friendship"];
    [query whereKey:@"fromUser" equalTo:self.userToPass];
    [query whereKey:@"toUser" equalTo:[PFUser currentUser]];

    PFQuery *query2 = [PFQuery queryWithClassName:@"Friendship"];
    [query2 whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query2 whereKey:@"toUser" equalTo:self.userToPass];

    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[query,query2]];
    [combinedQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
     {
         if ([[object objectForKey:@"status"] isEqualToString:@"Approved"])
         {
             UIImage *btnImage = [UIImage imageNamed:@"added_button_image"];
             [self.friendStatusButton setImage:btnImage forState:UIControlStateNormal];

         } else if ([[object objectForKey:@"status"] isEqualToString:@"Pending"])
         {
             UIImage *btnImage = [UIImage imageNamed:@"pending_image"];
             [self.friendStatusButton setImage:btnImage forState:UIControlStateNormal];

         } else if ([[object objectForKey:@"status"] isEqualToString:@"Denied"])
         {
             UIImage *btnImage = [UIImage imageNamed:@"add_friend_button_image"];
             [self.friendStatusButton setImage:btnImage forState:UIControlStateNormal];

         } else {

             if ([self.userToPass.objectId isEqualToString:[PFUser currentUser].objectId])
             {
                 self.friendStatusButton.hidden = YES;
                 self.friendStatusButton.userInteractionEnabled = NO;
             } else
             {
                 UIImage *btnImage = [UIImage imageNamed:@"add_friend_button_image"];
                 [self.friendStatusButton setImage:btnImage forState:UIControlStateNormal];
             }
         }
    }];
}
///need to add selector to this button


@end
