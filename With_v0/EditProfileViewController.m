//
//  EditProfileViewController.m
//  With_v0
//
//  Created by Vik Denic on 6/17/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "EditProfileViewController.h"
#import <Parse/Parse.h>

@interface EditProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;

@end

@implementation EditProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setUserInfo];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    [self setUserInfo];

}

#pragma mark - Helpers

-(void)setUserInfo
{
    PFQuery *retrieveUsers = [PFQuery queryWithClassName:@"User"];

    [retrieveUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFUser *user = [PFUser currentUser];
            self.nameTextField.text = [user objectForKey:@"name"];
            self.locationTextField.text = [user objectForKey:@"userCityState"];
            self.bioTextView.text = [user objectForKey:@"userBio"];

            PFFile *imageFile = [user objectForKey:@"userProfilePhoto"];

            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                UIImage *image = [UIImage imageWithData:data];
                self.avatarImageView.image = image;
            }];

//            [self. sizeToFit];
//            [self.cityStateLabel sizeToFit];
//            [self.bioTextView sizeToFit];

            //            self.followersLabel.text = [user objectForKey:@"followersCount"]; ?
            //            self.followingLabel.text = [user objectForKey:@"followingCount"]; ?
        }
    }];
}

#pragma mark - Actions

-(IBAction)onSaveButtonPressed:(id)sender
{

            PFUser *user = [PFUser currentUser];
            [user setValue:self.nameTextField.text forKey:@"name"];
            [user setValue:self.locationTextField.text forKey:@"userCityState"];
            [user setValue:self.bioTextView.text forKey:@"userBio"];
            [user saveInBackground];
}

- (IBAction)onLogOutButtonTapped:(id)sender
{
    [PFUser logOut];
}


@end
