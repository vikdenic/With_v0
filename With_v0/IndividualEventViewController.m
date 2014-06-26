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

@end

@implementation IndividualEventViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

    [self checkingUsersEventStatus];
    [self checkingUsersAttending];

    self.yesButtonTapped = NO;
    self.noButtonTapped = NO;
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

        self.yesImageView.image = [UIImage imageNamed:@"Yes_Button_Selected"];
        self.noImageView.image = [UIImage imageNamed:@"No_Button"];

        PFRelation *relation = [self.event relationforKey:@"usersAttending"];
        [relation addObject:[PFUser currentUser]];

        PFRelation *relation2 = [self.event relationforKey:@"usersNotAttending"];
        [relation2 removeObject:[PFUser currentUser]];
        [self.event saveInBackground];
        [self performSelector:@selector(checkingUsersAttending) withObject:nil afterDelay:0.8];

    } else {
        self.yesButtonTapped = NO;
        self.yesImageView.image = [UIImage imageNamed:@"Yes_Button"];

        PFRelation *relation = [self.event relationforKey:@"usersAttending"];
        [relation removeObject:[PFUser currentUser]];

        PFRelation *relation2 = [self.event relationforKey:@"usersNotAttending"];
        [relation2 removeObject:[PFUser currentUser]];
        [self.event saveInBackground];
        [self performSelector:@selector(checkingUsersAttending) withObject:nil afterDelay:0.8];
    }
}

- (IBAction)onNoButtonTapped:(id)sender
{

    if (self.noButtonTapped == NO)
    {
        self.noButtonTapped = YES;
        self.noImageView.image = [UIImage imageNamed:@"no_button_selected"];
        self.yesImageView.image = [UIImage imageNamed:@"Yes_Button"];

        PFRelation *relation = [self.event relationForKey:@"usersAttending"];
        [relation removeObject:[PFUser currentUser]];

        PFRelation *relation2 = [self.event relationforKey:@"usersNotAttending"];
        [relation2 addObject:[PFUser currentUser]];
        [self.event saveInBackground];
        [self performSelector:@selector(checkingUsersAttending) withObject:nil afterDelay:1.2];

    } else {

        self.noButtonTapped = NO;
        self.noImageView.image = [UIImage imageNamed:@"No_Button"];

        PFRelation *relation = [self.event relationforKey:@"usersAttending"];
        [relation removeObject:[PFUser currentUser]];

        PFRelation *relation2 = [self.event relationforKey:@"usersNotAttending"];
        [relation2 removeObject:[PFUser currentUser]];
        [self.event saveInBackground];
        [self performSelector:@selector(checkingUsersAttending) withObject:nil afterDelay:1.2];

    }
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
                self.yesImageView.image = [UIImage imageNamed:@"Yes_Button_Selected"];
                self.noImageView.image = [UIImage imageNamed:@"No_Button"];

            } else {

                self.yesImageView.image = [UIImage imageNamed:@"Yes_Button"];
//                self.noImageView.image = [UIImage imageNamed:@"no_button_selected"];
                self.noImageView.image = [UIImage imageNamed:@"No_Button"];
            }
        }
    }];

    PFRelation *relation2 = [self.event relationforKey:@"usersNotAttending"];

    [[relation2 query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        for (PFUser *user in objects)
        {
            NSString *currentUser = [[PFUser currentUser] objectId];

            if ([user.objectId isEqualToString:currentUser])
            {
                self.yesImageView.image = [UIImage imageNamed:@"Yes_Button"];
                self.noImageView.image = [UIImage imageNamed:@"no_button_selected"];

            } else {

                self.yesImageView.image = [UIImage imageNamed:@"Yes_Button"];
//              self.noImageView.image = [UIImage imageNamed:@"no_button_selected"];
                self.noImageView.image = [UIImage imageNamed:@"No)Button"];
            }
        }
    }];
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
