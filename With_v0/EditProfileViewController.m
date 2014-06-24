//
//  EditProfileViewController.m
//  With_v0
//
//  Created by Vik Denic on 6/17/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "EditProfileViewController.h"
#import <Parse/Parse.h>
#import "GKImagePicker.h"

@interface EditProfileViewController () <GKImagePickerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;

@property (nonatomic, strong) GKImagePicker *imagePicker;
@property (nonatomic, strong) UIPopoverController *popoverController;

@property PFFile *avatarImageFile;
@property PFFile *miniAvatarImageFile;

@end

@implementation EditProfileViewController

@synthesize imagePicker;
@synthesize popoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setUserInfo];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    //tap on themImageView to open Image Picker
    UITapGestureRecognizer *tapping = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTap:)];
    tapping.numberOfTapsRequired = 1;
    [self.avatarImageView addGestureRecognizer:tapping];
    self.avatarImageView.userInteractionEnabled = YES;

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

    NSLog(@"%@", [user objectForKey:@"name"]);
}

- (IBAction)onLogOutButtonTapped:(id)sender
{
    [PFUser logOut];
    [self.tabBarController setSelectedIndex:0];
    self.avatarImageView.image = nil;
    self.nameTextField.text = nil;
    self.locationTextField.text = nil;
    self.bioTextView.text = nil;
}
#pragma mark - Tap Gesture Recognizer

- (void)tapTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    //    [self presentViewController:self.cameraController animated:NO completion:nil];
    self.imagePicker = [[GKImagePicker alloc] init];
    self.imagePicker.cropSize = CGSizeMake(320, 320);
    self.imagePicker.delegate = self;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker.imagePickerController];
        [self.popoverController presentPopoverFromRect:tapGestureRecognizer.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    } else {

        [self presentModalViewController:self.imagePicker.imagePickerController animated:YES];
    }
}

#pragma mark - Image Picker

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //back to Create Events View Controller
    }];
}

#pragma mark - Theme Image View Tapped
//going to put a tap gesture on this so that when the user taps it, modally a view controller comes up that allows the user to select photos from their library to put in as the theme photo
//might have some sizing issues and stuff here

-(void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image
{
    //    self.themeImageView.image = image;
    UIImage *tempImage = image;

    //THEME IMAGE FOR HOMEPAGE
    CGSize scaledSize = CGSizeMake(70, 70);
    UIGraphicsBeginImageContextWithOptions(scaledSize, NO, 2.0);

    [image drawInRect:(CGRect){.size = scaledSize}];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.avatarImageView.image = resizedImage;

    NSData *avatarImageData = UIImagePNGRepresentation(resizedImage);
    self.avatarImageFile = [PFFile fileWithData:avatarImageData];
    //


    //THEME IMAGE FOR MAP
    CGSize tempScaledSize = CGSizeMake(32, 32);
    UIGraphicsBeginImageContextWithOptions(tempScaledSize, NO, 2.0);

    [tempImage drawInRect:(CGRect){.size = tempScaledSize}];
    UIImage *resizedMiniImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSData *miniAvatarImageData = UIImagePNGRepresentation(resizedMiniImage);
    self.miniAvatarImageFile = [PFFile fileWithData:miniAvatarImageData];
    //

    [self hideImagePicker];
}

- (void)hideImagePicker{
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {

        [self.popoverController dismissPopoverAnimated:YES];

    } else {

        [self.imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
