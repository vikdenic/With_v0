//
//  CreateEventViewController.m
//  With_v0
//
//  Created by Vik Denic on 6/15/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "CreateEventViewController.h"
#import <Parse/Parse.h>

@interface CreateEventViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *themeImageView;
@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;
@property (weak, nonatomic) IBOutlet UILabel *changeThemeButton;
@property (weak, nonatomic) IBOutlet UIButton *dateAndTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *invitePeopleButton;

@property (weak, nonatomic) IBOutlet UIView *dateAndTimeView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property NSDate *selectedDate;

@property UIImagePickerController *cameraController;
@property UIImage *themeImagePicked;
@property PFFile *themeImagePicker;

@end

@implementation CreateEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.themeImageView.image = nil;
    self.titleTextView.text = nil;
    self.detailsTextView.text = nil;

    self.dateAndTimeView.alpha = 0;
    self.dateAndTimeView.hidden = YES;

    //UIImagePicker Stuff
    self.cameraController = [[UIImagePickerController alloc] init];
    self.cameraController.delegate = self;
    self.cameraController.allowsEditing = YES;
    self.cameraController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    //tap on themImageView to open Image Picker
    UITapGestureRecognizer *tapping = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTap:)];
    tapping.numberOfTapsRequired = 1;
    [self.themeImageView addGestureRecognizer:tapping];
    self.themeImageView.userInteractionEnabled = YES;

}

#pragma mark - Action Methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)onDateAndTimeButtonTapped:(id)sender
{
    [self animatePopUpShow];
}

- (IBAction)onLocationButtonTapped:(id)sender
{
    //fourSquare API? what else
}

- (IBAction)onInvitePeopleButtonTapped:(id)sender
{
    //modally brings up all of the users friends and they can tap them to invite
}

- (IBAction)onCreatButtonTapped:(id)sender
{

    //if statement here requiring certain fields

        PFObject *event = [PFObject objectWithClassName:@"Event"];
        event[@"title"] = self.titleTextView.text;
        event[@"details"] = self.detailsTextView.text;
//        event[@"date"] =
        event [@"location"] = @"Test Location";
        event [@"themeImage"] = self.themeImagePicker;
        event [@"user"] = [PFUser currentUser];
    [event saveInBackground];

    //takes user back to home page
    [self.tabBarController setSelectedIndex:0];

}

#pragma mark - Date and Time View Animation

- (void) animatePopUpShow
{
    self.dateAndTimeView.hidden = NO;

    [UIView animateWithDuration:0.5f
                     animations:^{
                         [self.dateAndTimeView setAlpha:1.0f];
                     }
     ];
}

#pragma mark - Date Picker

-(IBAction)onDoneButtonTappedForDatePicker:(id)sender
{
    self.selectedDate = [self.datePicker date];

//    NSDateFormatter *date = [[NSDateFormatter alloc] init];
//    [date setDateFormat:@"MM-dd-yyyy-HH-mm"];
//    NSString *formattedDate = [date stringFromDate:selectedDate];


    NSString *dateString = [NSDateFormatter localizedStringFromDate:self.selectedDate
                                                          dateStyle:NSDateFormatterFullStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    [self.dateAndTimeButton setTitle:[NSString stringWithFormat:@"           %@", dateString] forState:UIControlStateNormal];
    self.dateAndTimeView.hidden = YES;

    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.dateAndTimeView setAlpha:0.0f];
                     }
     ];
}


#pragma mark - Tap Gesture Recognizer

- (void)tapTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self presentViewController:self.cameraController animated:NO completion:nil];
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:NO completion:^{

        self.themeImagePicked = [info valueForKey:UIImagePickerControllerOriginalImage];
        //here I should resize the image to the size of the imageView so it looks good and normal before saving it?
        //maybe this might make it weird in the other image views it goes in

        self.themeImageView.image = self.themeImagePicked;

        NSData *themeImageData = UIImagePNGRepresentation(self.themeImagePicked);
        self.themeImagePicker = [PFFile fileWithData:themeImageData];

        if (self.themeImageView.image)
        {
            self.changeThemeButton.hidden = YES;
        }
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

#pragma mark - Text View


//this could be an issue
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}

@end
