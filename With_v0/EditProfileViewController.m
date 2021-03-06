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

@interface EditProfileViewController () <GKImagePickerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;

@property (nonatomic, strong) GKImagePicker *imagePicker;

@property (nonatomic, strong) GKImagePicker *imagePickerCover;

@property (nonatomic, strong) UIPopoverController *popoverController;
@property (weak, nonatomic) IBOutlet UIButton *editCoverButton;

@property PFFile *avatarImageFile;
@property PFFile *miniAvatarImageFile;
@property PFFile *coverImageFile;

@end

@implementation EditProfileViewController

@synthesize imagePicker;
@synthesize popoverController;

@synthesize imagePickerCover;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.nameTextField.delegate = self;
    self.locationTextField.delegate = self;
    self.bioTextView.delegate = self;

//    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;

//    NSLog(@"EDIT %f  %f",self.avatarImageView.frame.size.width, self.avatarImageView.frame.size.height);

    //tap on themImageView to open Image Picker
    UITapGestureRecognizer *tapping = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTap:)];
    tapping.numberOfTapsRequired = 1;

    [self setUserInfo];

    [self.avatarImageView addGestureRecognizer:tapping];
    self.avatarImageView.userInteractionEnabled = YES;

    self.avatarImageView.layer.cornerRadius = self.avatarImageView.layer.bounds.size.width /2;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.borderColor = [[UIColor colorWithRed:202/255.0 green:250/255.0 blue:53/255.0 alpha:1] CGColor];
    self.avatarImageView.layer.borderWidth = 2.0;

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

//    [self setUserInfo];
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

            PFFile *coverImageFile = [user objectForKey:@"coverPhoto"];
            [coverImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                UIImage *coverImage = [UIImage imageWithData:data];
                self.coverImageView.image = coverImage;
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

    if(self.avatarImageFile)
    {
        [user setValue:self.avatarImageFile forKey:@"userProfilePhoto"];
        [user setValue:self.miniAvatarImageFile forKey:@"miniProfilePhoto"];
    }

    [user saveInBackground];
//    NSLog(@"%@", [user objectForKey:@"name"]);
}

- (IBAction)onLogOutButtonTapped:(id)sender
{
    [PFUser logOut];
    [self.tabBarController setSelectedIndex:0];
    self.avatarImageView.image = nil;
    self.nameTextField.text = nil;
    self.locationTextField.text = nil;
    self.bioTextView.text = nil;
    self.coverImageView.image = nil;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"Test1" object:self];
    [self dismissViewControllerAnimated:NO completion:nil];
}



#pragma mark - Tap Gesture Recognizer

- (void)tapTap:(UITapGestureRecognizer *)tapGestureRecognizer
{

//    NSLog(@"TAPTAP");
    //    [self presentViewController:self.cameraController animated:NO completion:nil];
    self.imagePicker = [[GKImagePicker alloc] init];
    self.imagePicker.cropSize = CGSizeMake(320, 320);
    self.imagePicker.delegate = self;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker.imagePickerController];
        [self.popoverController presentPopoverFromRect:tapGestureRecognizer.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    } else {
//        [self presentModalViewController:self.imagePicker.imagePickerController animated:YES];
        [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - Image Picker
- (IBAction)onEditCoverPressed:(id)sender
{
    self.imagePickerCover = [[GKImagePicker alloc] init];
    self.imagePickerCover.cropSize = CGSizeMake(320, 160);
    self.imagePickerCover.delegate = self;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePickerCover.imagePickerController];
        [self.popoverController presentPopoverFromRect:self.editCoverButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    } else {
        //        [self presentModalViewController:self.imagePicker.imagePickerController animated:YES];
        [self presentViewController:self.imagePickerCover.imagePickerController animated:YES completion:nil];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //back to Create Events View Controller
    }];
}

#pragma mark - Profile Pic Tapped
//going to put a tap gesture on this so that when the user taps it, modally a view controller comes up that allows the user to select photos from their library to put in as the theme photo
//might have some sizing issues and stuff here

-(void)imagePicker:(GKImagePicker *)imagePickerd pickedImage:(UIImage *)image
{

    //    self.themeImageView.image = image;
    if(imagePickerd == self.imagePicker)
    {
    //THEME IMAGE FOR HOMEPAGE
    CGSize scaledSize = CGSizeMake(75, 75);
    UIGraphicsBeginImageContextWithOptions(scaledSize, NO, 2.0);

    [image drawInRect:(CGRect){.size = scaledSize}];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.avatarImageView.image = resizedImage;

    NSData *avatarImageData = UIImagePNGRepresentation(resizedImage);
    self.avatarImageFile = [PFFile fileWithData:avatarImageData];
    //


    UIImage *miniTempImage = image;

    //THEME IMAGE FOR MAP
    CGSize tempScaledSize = CGSizeMake(32, 32);
    UIGraphicsBeginImageContextWithOptions(tempScaledSize, NO, 2.0);

    [miniTempImage drawInRect:(CGRect){.size = tempScaledSize}];
    UIImage *resizedMiniImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSData *miniAvatarImageData = UIImagePNGRepresentation(resizedMiniImage);
    self.miniAvatarImageFile = [PFFile fileWithData:miniAvatarImageData];
    //

    // Save PFFile
    [self.avatarImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
        PFUser *user = [PFUser currentUser];

        [user setValue:self.avatarImageFile forKey:@"userProfilePhoto"];
//        [user setValue:self.miniAvatarImageFile forKey:@"miniProfilePhoto"];

        [user saveInBackground];

     }];

    [self.miniAvatarImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         PFUser *user = [PFUser currentUser];

//         [user setValue:self.avatarImageFile forKey:@"userProfilePhoto"];
        [user setValue:self.miniAvatarImageFile forKey:@"miniProfilePhoto"];

         [user saveInBackground];
         
     }];

    }
    else{

        CGSize scaledSize = CGSizeMake(320, 160);
        UIGraphicsBeginImageContextWithOptions(scaledSize, NO, 2.0);

        [image drawInRect:(CGRect){.size = scaledSize}];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        self.coverImageView.image = resizedImage;

        NSData *coverImageData = UIImagePNGRepresentation(resizedImage);
        self.coverImageFile = [PFFile fileWithData:coverImageData];

        // Save PFFile
        [self.coverImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             PFUser *user = [PFUser currentUser];

             [user setValue:self.coverImageFile forKey:@"coverPhoto"];
             //        [user setValue:self.miniAvatarImageFile forKey:@"miniProfilePhoto"];

             [user saveInBackground];

         }];
    }
    [self hideImagePicker];
}

- (void)hideImagePicker{
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {

        [self.popoverController dismissPopoverAnimated:YES];

    } else {

        [self.imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
        [self.imagePickerCover.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL _isAllowed = YES;

    NSString *tempString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if(textField == self.nameTextField)
    {
        if([textField.text isEqualToString:tempString] || [tempString length] > 24)
        {
            _isAllowed = NO;
        }
        else{
            _isAllowed = YES;
        }
    }

    else if (textField == self.locationTextField)
    {
        if([textField.text isEqualToString:tempString] || [tempString length] > 24)
        {
            _isAllowed = NO;
        }
        else{
            _isAllowed = YES;
        }
    }

    else{
        _isAllowed = YES;
    }

    return _isAllowed;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string
{

    NSString *tempString = [textView.text stringByReplacingCharactersInRange:range withString:string];

    if([textView.text isEqualToString:tempString] || [tempString length] > 140)
    {
        return NO;
    }
    else{
        return YES;
    }
}

@end
