//
//  ProfileViewController.m
//  With_v0
//
//  Created by Vik Denic on 6/15/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "IndividualEventViewController.h"
#import "HomeTableViewCell.h"
#import "HomeViewController.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource>

//Views

@property (weak, nonatomic) IBOutlet UIImageView *profileAvatar;

@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UILabel *cityStateLabel;

@property (weak, nonatomic) IBOutlet UILabel *pastLabel;
@property (weak, nonatomic) IBOutlet UILabel *UpcomingLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

//Data

@property NSArray *usersArray;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];

        [self setUserInfo];

        self.profileAvatar.layer.cornerRadius = self.profileAvatar.layer.bounds.size.width /2;

        self.profileAvatar.clipsToBounds = YES;

        self.profileAvatar.layer.borderColor = [[UIColor colorWithRed:202/255.0 green:250/255.0 blue:53/255.0 alpha:1] CGColor];

        self.profileAvatar.layer.borderWidth = 2.0;

        NSLog(@"did show %@",[PFUser currentUser]);

//    self.usersArray = [[NSArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setUserInfo];

    NSLog(@"will show %@",[PFUser currentUser]);


}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
////    [self setUserInfo];
//
//}

#pragma mark - Helpers

//-(void)retrieveUsersFromParse
//{
//    PFQuery *retrieveUsers = [PFQuery queryWithClassName:@"User"];
//    [retrieveUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//
//        self.usersArray = objects;
//        [self.tableView reloadData];
//    }];
//}

-(void)setUserInfo
{
    PFQuery *retrieveUsers = [PFQuery queryWithClassName:@"User"];

    [retrieveUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFUser *user = [PFUser currentUser];
            self.nameLabel.text = [user objectForKey:@"name"];
            self.cityStateLabel.text = [user objectForKey:@"userCityState"];
            self.bioTextView.text = [user objectForKey:@"userBio"];
            
            PFFile *imageFile = [user objectForKey:@"userProfilePhoto"];

            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                UIImage *image = [UIImage imageWithData:data];
                self.profileAvatar.image = image;
            }];

            [self.nameLabel sizeToFit];
            [self.cityStateLabel sizeToFit];
            [self.bioTextView sizeToFit];

//            self.followersLabel.text = [user objectForKey:@"followersCount"]; ?
//            self.followingLabel.text = [user objectForKey:@"followingCount"]; ?
        }
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


#pragma mark - TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.usersArray.count;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];

    return cell;
}


#pragma mark - Segues

// When user CANCELS within settings
- (IBAction)unwindSegueCancelSettingsToProfile:(UIStoryboardSegue *)sender
{

}

// When user SAVES settings
- (IBAction)unwindSegueSaveSettingsToProfile:(UIStoryboardSegue *)sender
{
    [self setUserInfo];
}

- (IBAction)unwindSegueInvitesToProfile:(UIStoryboardSegue *)sender
{
    
}

//-(IBAction)unwindLogOutToProfile:(UIStoryboardSegue *)sender
//{
//    [PFUser logOut];
//
//    [self performSegueWithIdentifier:@"LogOutToSignIn" sender:self];
//}

@end
