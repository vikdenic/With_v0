//
//  CreateEventViewController.m
//  With_v0
//
//  Created by Vik Denic on 6/15/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "CreateEventViewController.h"
#import <Parse/Parse.h>
#import "ChooseEventLocationViewController.h"
#import "DateAndTimeViewController.h"
#import "GKImagePicker.h"
#import "InvitePeopleViewController.h"

@interface CreateEventViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, GKImagePickerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *themeImageView;
//@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextView *detailsTextView;
@property (weak, nonatomic) IBOutlet UILabel *changeThemeButton;
@property (weak, nonatomic) IBOutlet UIButton *dateAndTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *invitePeopleButton;

@property (weak, nonatomic) IBOutlet UIView *dateAndTimeView;

@property UIImagePickerController *cameraController;
@property UIImage *themeImagePicked;

@property PFFile *themeImageFile;
@property PFFile *mapThemeImageFile;

@property (weak, nonatomic) IBOutlet UILabel *detailsPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;


@property (nonatomic, strong) GKImagePicker *imagePicker;
@property (nonatomic, strong) UIPopoverController *popoverController;

@property (weak, nonatomic) IBOutlet UIButton *createButton;

@property BOOL canCreateEvent;

@end

@implementation CreateEventViewController

@synthesize imagePicker;
@synthesize popoverController;


- (void)viewDidLoad
{
    [super viewDidLoad];

    //Vik: Allows this viewController to know when someone log's out
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"Test1" object:nil];

    //Vik
    self.eventName = @"Location";
    self.dateString = nil;

//    self.canCreateEvent = NO;
    [self checkIfFormsComplete];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    [self checkIfFormsComplete];

//    Vik: we will nil these properties on Create button tapped
//    self.themeImageView.image = nil;
//    self.titleTextView.text = nil;
//    self.titleTextField.text = nil;
//    self.detailsTextView.text = nil;

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

    //Vik: sets button text to selected foursquare location
    if(![self.eventName isEqual:@""])
    {
        NSString *locationName = [NSString stringWithFormat:@"           %@",self.eventName];

        [self.locationButton setTitle:locationName forState:UIControlStateNormal];
    }
    else if (!self.eventName)
    {
        [self.locationButton setTitle:@"          Location" forState:UIControlStateNormal];
    }

    //Vik: sets the date & time button text
    if(self.dateString)
    {
    NSString *formattedDateString = [NSString stringWithFormat:@"           %@",self.dateString];

    [self.dateAndTimeButton setTitle:formattedDateString forState:UIControlStateNormal];
    }
    else{
    [self.dateAndTimeButton setTitle:@"           Date and Time" forState:UIControlStateNormal];
    }

//    [self.createButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
////    [self.createButton setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
//    [self.createButton addTarget:self action:@selector(onCreateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    //Vik: Create button disabled until fields filled out
    [self checkIfFormsComplete];
//    NSLog(@"APPEAR: %d", self.canCreateEvent);
}

-(void)receiveNotification:(NSNotification *) notification
{
   if ([[notification name] isEqualToString:@"Test1"])
   {
       NSLog(@"Notification Triggered");
       [self resetCreateFields];
    }
}

#pragma mark - Helpers

-(void)checkIfFormsComplete
{
    if( !self.themeImageView.image || [self.titleTextField.text isEqualToString:@""] || !self.dateString || self.coordinate.latitude == 0.0)
    {
//        self.createButton.titleLabel.textColor = [UIColor grayColor];
        [self.createButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

        self.canCreateEvent = NO;
    }

    if (self.themeImageView.image && ![self.titleTextField.text isEqualToString:@""] && self.dateString && !(self.coordinate.latitude == 0.0) )
    {
//        self.createButton.titleLabel.textColor = [UIColor orangeColor];
    [self.createButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];

        self.canCreateEvent = YES;
    }
}

#pragma mark - Action Methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

//- (IBAction)onDateAndTimeButtonTapped:(id)sender
//{
//    [self animatePopUpShow];
//}

- (IBAction)onLocationButtonTapped:(id)sender
{
    //fourSquare API? what else
}

- (IBAction)onInvitePeopleButtonTapped:(id)sender
{
    //modally brings up all of the users friends and they can tap them to invite
}
- (IBAction)onCreateButtonTapped:(id)sender
{

    if (self.canCreateEvent == YES)
    {
    //if statement here requiring certain fields

    PFObject *event = [PFObject objectWithClassName:@"Event"];
//    event[@"title"] = self.titleTextView.text;
    event[@"title"] = self.titleTextField.text;
    event[@"details"] = self.detailsTextView.text;
    event[@"location"] = self.eventName;
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:self.coordinate.latitude
                                                  longitude:self.coordinate.longitude];
    event[@"locationGeoPoint"] = geoPoint;
    event[@"themeImage"] = self.themeImageFile;
    event[@"mapThemeImage"] = self.mapThemeImageFile;
    event[@"creator"] = [PFUser currentUser];
    event[@"eventDate"] = self.dateString;
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        //send invites to people invited
        for (PFUser *user in self.usersInvitedArray)
        {
            PFObject *eventInvite = [PFObject objectWithClassName:@"EventInvite"];
            eventInvite[@"toUser"] = user;
            eventInvite[@"event"] = event;
            eventInvite[@"statusOfUser"] = @"Invited";
            [eventInvite saveInBackground];

            //creates relations to the event for each user
            PFRelation *relation = [event relationforKey:@"usersInvited"];
            [relation addObject:user];
            [event saveInBackground];
        }
        //puts the event the user created into their events attending and adds them to the going list
//        PFRelation *relation = [event relationForKey:@"usersInvited"];
//        [relation addObject:[PFUser currentUser]];

        PFRelation *eventRelation = [[PFUser currentUser] relationForKey:@"eventsAttending"];
        [eventRelation addObject:event];
        [[PFUser currentUser] saveInBackground];

        PFRelation *goingToRelation = [event relationForKey:@"usersAttending"];
        [goingToRelation addObject:[PFUser currentUser]];
        [event saveInBackground];
    }];




    //takes user back to home page
    [self.tabBarController setSelectedIndex:0];

    [self resetCreateFields];
    }
}

-(void)resetCreateFields
{
    //erases event forms
    self.themeImageView.image = nil;
    self.titleTextField.text = nil;
    self.detailsTextView.text = nil;
    self.eventName = @"Location";
//    [self.locationButton setTitle:@"          Location" forState:UIControlStateNormal];

    self.coordinate = CLLocationCoordinate2DMake(0.0, 0.0);

    self.dateAndTimeButton.titleLabel.text = @"           Date and Time";
//    self.locationButton.titleLabel.text = @"           Location";

    self.canCreateEvent = NO;
}

#pragma mark - Date and Time View Animation


#pragma mark - Tap Gesture Recognizer

- (void)tapTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
//    [self presentViewController:self.cameraController animated:NO completion:nil];
    self.imagePicker = [[GKImagePicker alloc] init];
    self.imagePicker.cropSize = CGSizeMake(320, 160);
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

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //back to Create Events View Controller
    }];

    [self checkIfFormsComplete];
}

#pragma mark - Theme Image View Tapped
//going to put a tap gesture on this so that when the user taps it, modally a view controller comes up that allows the user to select photos from their library to put in as the theme photo
//might have some sizing issues and stuff here

-(void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image
{
//    self.themeImageView.image = image;
    UIImage *tempImage = image;

        //THEME IMAGE FOR HOMEPAGE
        CGSize scaledSize = CGSizeMake(320, 160);
        UIGraphicsBeginImageContextWithOptions(scaledSize, NO, 2.0);

        [image drawInRect:(CGRect){.size = scaledSize}];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        self.themeImageView.image = resizedImage;

        NSData *themeImageData = UIImagePNGRepresentation(resizedImage);
        self.themeImageFile = [PFFile fileWithData:themeImageData];
        //


        //THEME IMAGE FOR MAP
        CGSize tempScaledSize = CGSizeMake(70, 35);
        UIGraphicsBeginImageContextWithOptions(tempScaledSize, NO, 2.0);

        [tempImage drawInRect:(CGRect){.size = tempScaledSize}];
        UIImage *resizedMapImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        NSData *mapThemeImageData = UIImagePNGRepresentation(resizedMapImage);
        self.mapThemeImageFile = [PFFile fileWithData:mapThemeImageData];
        //

        [self hideImagePicker];

    [self checkIfFormsComplete];
}

- (void)hideImagePicker{
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {

        [self.popoverController dismissPopoverAnimated:YES];

    } else {

        [self.imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    }

    [self checkIfFormsComplete];
}

#pragma mark - Text View

// Replicates Placeholder with label
- (IBAction)onTitleTextViewDidBeginEditing:(id)sender
{
    self.placeholderLabel.hidden = YES;
    [self checkIfFormsComplete];
}

- (IBAction)onTitleTextViewDidChange:(id)sender
{
    self.placeholderLabel.hidden = ([self.titleTextField.text length] > 0);
    [self checkIfFormsComplete];
}

- (IBAction)onTitleTextViewDidEnd:(id)sender
{
    self.placeholderLabel.hidden = ([self.titleTextField.text length] > 0);
    [self checkIfFormsComplete];
}

- (IBAction)onTitleEditingChanged:(id)sender
{
    [self checkIfFormsComplete];
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.detailsPlaceholderLabel.hidden = YES;
    [self checkIfFormsComplete];
}

//this could be an issue
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    [self checkIfFormsComplete];
    return YES;
}

#pragma mark - Segues
//NEED TO HOOK UP SEGUE FROM CHOOSELOCATION SELECTED CELL
-(IBAction)unwindChooseLocationToCreateEvent:(UIStoryboardSegue *)sender
{
    ChooseEventLocationViewController *chooseVC = sender.sourceViewController;
    self.eventName = chooseVC.eventName;
    self.coordinate = chooseVC.coordinate;

    [self checkIfFormsComplete];
//    NSLog(@"LOCATION UNWIND: %d", self.canCreateEvent);
//    [self viewWillAppear:YES];
}

-(IBAction)unwindDateToCreate:(UIStoryboardSegue *)sender
{
    DateAndTimeViewController *dateVC = sender.sourceViewController;
    self.dateString = dateVC.dateString;
//    self.dateAndTimeButton.titleLabel.text = [NSString stringWithFormat:@"           %@",self.dateString];

    [self checkIfFormsComplete];
//    NSLog(@"DATE UNWIND: %d", self.canCreateEvent);
//    [self viewWillAppear:YES];
}

- (IBAction)unwindInviteToCreate:(UIStoryboardSegue *)sender
{
    InvitePeopleViewController *invitePeopleViewController = sender.sourceViewController;
    self.usersInvitedArray = invitePeopleViewController.usersInvitedArray;
    ///not sure if this is really going to work
}

-(IBAction)unwindIdeasToCreate:(UIStoryboardSegue *)sender
{
    
}

@end
