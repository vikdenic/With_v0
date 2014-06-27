//
//  IndividualEventViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/15/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "IndividualEventViewController.h"
#import "PeopleAttendingEventViewController.h"

@interface IndividualEventViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *themeImageView;
@property (weak, nonatomic) IBOutlet UIButton *topGoingButton;
@property (weak, nonatomic) IBOutlet UIButton *invitedButton;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UIButton *goingButton;
@property (weak, nonatomic) IBOutlet UIButton *notGoingButton;
@property (weak, nonatomic) IBOutlet UITextView *addressTextView;
@property (weak, nonatomic) IBOutlet UITextView *dateAndTimeTextView;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;
@property (weak, nonatomic) IBOutlet UILabel *creatorLabel;

@property BOOL yesButtonTapped;
@property BOOL noButtonTapped;
@property (weak, nonatomic) IBOutlet UIImageView *yesImageView;
@property (weak, nonatomic) IBOutlet UIImageView *noImageView;

@property (weak, nonatomic) IBOutlet UIButton *editEventButton;

@property UIImage *yesButtonSelected;
@property UIImage *yesButtonUnselected;
@property UIImage *noButtonSelected;
@property UIImage *noButtonUnselected;
@property BOOL isTheUserAttending;


@end

@implementation IndividualEventViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

    [self checkingUsersEventStatus];
    [self checkingUsersAttending];

    self.yesButtonTapped = NO;
    self.noButtonTapped = NO;

    self.yesButtonSelected = [UIImage imageNamed:@"Yes_Button_Selected"];
    self.yesButtonUnselected = [UIImage imageNamed:@"Yes_Button"];
    self.noButtonSelected = [UIImage imageNamed:@"no_button_selected"];
    self.noButtonUnselected = [UIImage imageNamed:@"No_Button"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.detailsTextView.text = self.event[@"details"];
    self.addressTextView.text = self.event[@"location"];
    self.dateAndTimeTextView.text = self.event[@"eventDate"];

    PFUser *user =  [self.event objectForKey:@"creator"];
    self.creatorLabel.text = [NSString stringWithFormat:@"%@", user.username];

    PFFile *file = self.event[@"themeImage"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
             UIImage *temporaryImage = [UIImage imageWithData:data];

             CGSize sacleSize = CGSizeMake(320, 160);
             UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
             [temporaryImage drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
             UIImage * resizedImage = UIGraphicsGetImageFromCurrentImageContext();
             UIGraphicsEndImageContext();

             self.themeImageView.image = resizedImage;
         }
     }];
}

#pragma mark - Action methods

- (IBAction)onYesButtonTapped:(UIButton *)sender
{

    if (self.yesButtonTapped == NO)
    {
        self.yesButtonTapped = YES;

        [self.goingButton setImage:self.yesButtonSelected forState:UIControlStateNormal];
        [self.notGoingButton setImage:self.noButtonUnselected forState:UIControlStateNormal];

        PFRelation *relation = [self.event relationforKey:@"usersAttending"];
        [relation addObject:[PFUser currentUser]];

        PFRelation *relation2 = [self.event relationforKey:@"usersNotAttending"];
        [relation2 removeObject:[PFUser currentUser]];
        [self.event saveInBackground];
        [self performSelector:@selector(checkingUsersAttending) withObject:nil afterDelay:0.8];

    } else {

        self.yesButtonTapped = NO;
        [self.goingButton setImage:self.yesButtonUnselected forState:UIControlStateNormal];


        PFRelation *relation = [self.event relationforKey:@"usersAttending"];
        [relation removeObject:[PFUser currentUser]];

        PFRelation *relation2 = [self.event relationforKey:@"usersNotAttending"];
        [relation2 removeObject:[PFUser currentUser]];
        [self.event saveInBackground];
        [self performSelector:@selector(checkingUsersAttending) withObject:nil afterDelay:0.8];
    }
///
    sender.transform = CGAffineTransformMakeScale(.5f, .5f);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.8];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    CGAffineTransform scaleTrans  = CGAffineTransformMakeScale(1.0f, 1.0f);
    CGAffineTransform lefttorightTrans  = CGAffineTransformMakeTranslation(0.0f,0.0f);
    sender.transform = CGAffineTransformConcat(scaleTrans, lefttorightTrans);
    [UIView commitAnimations];
}

- (IBAction)onNoButtonTapped:(id)sender
{

    if (self.noButtonTapped == NO)
    {
        self.noButtonTapped = YES;
        self.noImageView.image = [UIImage imageNamed:@"no_button_selected"];
        self.yesImageView.image = [UIImage imageNamed:@"Yes_Button"];

        [self.notGoingButton setImage:self.noButtonSelected forState:UIControlStateNormal];
        [self.goingButton setImage:self.yesButtonUnselected forState:UIControlStateNormal];


        PFRelation *relation = [self.event relationForKey:@"usersAttending"];
        [relation removeObject:[PFUser currentUser]];

        PFRelation *relation2 = [self.event relationforKey:@"usersNotAttending"];
        [relation2 addObject:[PFUser currentUser]];
        [self.event saveInBackground];
        [self performSelector:@selector(checkingUsersAttending) withObject:nil afterDelay:1.2];

        

    } else {

        self.noButtonTapped = NO;
        [self.notGoingButton setImage:self.noButtonUnselected forState:UIControlStateNormal];

        PFRelation *relation = [self.event relationforKey:@"usersAttending"];
        [relation removeObject:[PFUser currentUser]];

        PFRelation *relation2 = [self.event relationforKey:@"usersNotAttending"];
        [relation2 removeObject:[PFUser currentUser]];
        [self.event saveInBackground];
        [self performSelector:@selector(checkingUsersAttending) withObject:nil afterDelay:1.2];

    }
///
//    sender.transform = CGAffineTransformMakeScale(.5f, .5f);
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDuration:0.8];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//    CGAffineTransform scaleTrans  = CGAffineTransformMakeScale(1.0f, 1.0f);
//    CGAffineTransform lefttorightTrans  = CGAffineTransformMakeTranslation(0.0f,0.0f);
//    sender.transform = CGAffineTransformConcat(scaleTrans, lefttorightTrans);
//    [UIView commitAnimations];
}

#pragma mark- Checking users status

- (void)checkingUsersEventStatus
{

    PFRelation *relation = [self.event relationforKey:@"usersAttending"];

    [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        for (PFUser *user in objects)
        {
            NSString *currentUser = [[PFUser currentUser] objectId];

            if ([user.objectId isEqualToString:currentUser])
            {
                self.isTheUserAttending = YES;
                [self.goingButton setImage:self.yesButtonSelected forState:UIControlStateNormal];
                [self.notGoingButton setImage:self.noButtonUnselected forState:UIControlStateNormal];
                break;

            } else {

                [self.goingButton setImage:self.yesButtonUnselected forState:UIControlStateNormal];
                [self.goingButton setImage:self.noButtonUnselected forState:UIControlStateNormal];
            }
        }
    }];



    if (!self.isTheUserAttending)
    {

        PFRelation *relation2 = [self.event relationforKey:@"usersNotAttending"];

        [[relation2 query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

            for (PFUser *user in objects)
            {
                NSString *currentUser = [[PFUser currentUser] objectId];

                if ([user.objectId isEqualToString:currentUser])
                {
                    self.yesImageView.image = [UIImage imageNamed:@"Yes_Button"];
                    self.noImageView.image = [UIImage imageNamed:@"no_button_selected"];

                    [self.goingButton setImage:self.yesButtonUnselected forState:UIControlStateNormal];
                    [self.notGoingButton setImage:self.noButtonSelected forState:UIControlStateNormal];
                    break;

                } else {

                    [self.goingButton setImage:self.yesButtonUnselected forState:UIControlStateNormal];
                    [self.goingButton setImage:self.noButtonUnselected forState:UIControlStateNormal];
                }
            }
        }];
    }
}

- (void)checkingUsersAttending
{
    PFRelation *relation = [self.event relationForKey:@"usersAttending"];
    PFQuery *query1 = [relation query];
    [query1 countObjectsInBackgroundWithBlock:^(int number, NSError *error)
     {
         self.topGoingButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
         self.topGoingButton.titleLabel.textAlignment = NSTextAlignmentCenter;
         [self.topGoingButton setTitle:[NSString stringWithFormat:@"%i\nGoing", number] forState:UIControlStateNormal];
     }];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"topGoingButtonToPeopleAttendingSegue"])
    {
        PeopleAttendingEventViewController *peopleAttendingEventViewController = segue.destinationViewController;
        peopleAttendingEventViewController.event = self.event;
    }
}

- (IBAction)unwindSegueToIndividualViewController:(UIStoryboardSegue *)sender
{
    
}

@end
