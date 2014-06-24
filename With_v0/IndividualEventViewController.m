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

    self.yesButtonTapped = NO;
    self.noButtonTapped = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //pass title of event to nav bar title

    self.detailsTextView.text = self.event[@"details"];
    self.addressTextView.text = self.event[@"address"];
    self.dateAndTimeTextView.text = self.event[@"eventDate"];

    //need to have a place holder if stuff is empty so it doesn't crash

    //I could just pass the image since it's the same one they click on

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

    PFRelation *relation = [self.event relationForKey:@"usersAttending"];
    PFQuery *query1 = [relation query];
    [query1 countObjectsInBackgroundWithBlock:^(int number, NSError *error)
     {
         self.topGoingButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
         self.topGoingButton.titleLabel.textAlignment = NSTextAlignmentCenter; 
         [self.topGoingButton setTitle:[NSString stringWithFormat:@"%i\nGoing", number] forState:UIControlStateNormal];
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

    } else {
        self.yesButtonTapped = NO;
        self.yesImageView.image = [UIImage imageNamed:@"Yes_Button"];

        PFRelation *relation = [self.event relationforKey:@"usersAttending"];
        [relation removeObject:[PFUser currentUser]];

        PFRelation *relation2 = [self.event relationforKey:@"usersNotAttending"];
        [relation2 removeObject:[PFUser currentUser]];
        [self.event saveInBackground];
    }
}

- (IBAction)onNoButtonTapped:(id)sender
{

    if (self.noButtonTapped == NO)
    {
        self.noButtonTapped = YES;
        self.noImageView.image = [UIImage imageNamed:@"no_button_selected"];
        self.yesImageView.image = [UIImage imageNamed:@"Yes_Button"];

        //removes current user from going
        PFRelation *relation = [self.event relationForKey:@"usersAttending"];
        [relation removeObject:[PFUser currentUser]];

        //adds current user to not going relation
        PFRelation *relation2 = [self.event relationforKey:@"usersNotAttending"];
        [relation2 addObject:[PFUser currentUser]];
        [self.event saveInBackground];

    } else {

        self.noButtonTapped = NO;
        self.noImageView.image = [UIImage imageNamed:@"No_Button"];

        PFRelation *relation = [self.event relationforKey:@"usersAttending"];
        [relation removeObject:[PFUser currentUser]];

        PFRelation *relation2 = [self.event relationforKey:@"usersNotAttending"];
        [relation2 removeObject:[PFUser currentUser]];
        [self.event saveInBackground];
    }
}

#pragma mark- Checking users status

- (void)checkingUsersEventStatus
{
    //check to see if user is going to the event
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
                self.noImageView.image = [UIImage imageNamed:@"no_button_selected"];
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
                //should query both going and not going because the user might not have decided Yet

                self.yesImageView.image = [UIImage imageNamed:@"Yes_Button_Selected"];
                self.noImageView.image = [UIImage imageNamed:@"No_Button"];
            }
        }
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
