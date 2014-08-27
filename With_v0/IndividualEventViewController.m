//
//  IndividualEventViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/15/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "IndividualEventViewController.h"
#import "PeopleAttendingEventViewController.h"
#import "InvitedPeopleViewController.h"
#import "IndividualEventInvitePeopleViewController.h"

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

///
@property NSString *tempTitle;
///

@end

@implementation IndividualEventViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

    ///
    self.tempTitle = self.event[@"title"];
    NSLog(@"\n\ntitle is %@\n\n", self.tempTitle);
    ///

    ///
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:self.tempTitle forKey:@"channels"];
    [currentInstallation saveInBackground];
    ///

    [self checkingUsersEventStatus];
    [self checkingUsersAttending];
    [self checkingUsersInvited];


    self.yesButtonTapped = NO;
    self.noButtonTapped = NO;

    self.yesButtonSelected = [UIImage imageNamed:@"Yes_Button_Selected"];
    self.yesButtonUnselected = [UIImage imageNamed:@"Yes_Button"];
    self.noButtonSelected = [UIImage imageNamed:@"no_button_selected"];
    self.noButtonUnselected = [UIImage imageNamed:@"No_Button"];

    [self.goingButton setImage:self.yesButtonUnselected forState:UIControlStateNormal];
    [self.notGoingButton setImage:self.noButtonUnselected forState:UIControlStateNormal];

    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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

    if (self.event[@"guestCanInviteOthers"])
    {
        self.inviteButton.hidden = NO;
        self.inviteButton.userInteractionEnabled = YES;

    } else {
        self.inviteButton.hidden = YES;
        self.inviteButton.userInteractionEnabled = NO;
    }
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
}

- (IBAction)onNoButtonTapped:(id)sender
{

    if (self.noButtonTapped == NO)
    {
        self.noButtonTapped = YES;

        [self.notGoingButton setImage:self.noButtonSelected forState:UIControlStateNormal];
        [self.goingButton setImage:self.yesButtonUnselected forState:UIControlStateNormal];

        PFRelation *relation = [self.event relationForKey:@"usersAttending"];
        [relation removeObject:[PFUser currentUser]];

        PFRelation *relation2 = [self.event relationforKey:@"usersNotAttending"];
        [relation2 addObject:[PFUser currentUser]];
        [self.event saveInBackground];
        [self performSelector:@selector(checkingUsersAttending) withObject:nil afterDelay:1.2];

//        ///
//        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//        [currentInstallation removeObject:self.tempTitle forKey:@"channels"];
//        [currentInstallation saveInBackground];
//        ///

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

- (void)checkingUsersInvited
{
    PFRelation *relation = [self.event relationForKey:@"usersInvited"];
    PFQuery *query1 = [relation query];
    [query1 countObjectsInBackgroundWithBlock:^(int number, NSError *error)
     {
         self.invitedButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
         self.invitedButton.titleLabel.textAlignment = NSTextAlignmentCenter;
         [self.invitedButton setTitle:[NSString stringWithFormat:@"%i\nInvited", number] forState:UIControlStateNormal];
     }];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"topGoingButtonToPeopleAttendingSegue"])
    {
        PeopleAttendingEventViewController *peopleAttendingEventViewController = segue.destinationViewController;
        peopleAttendingEventViewController.event = self.event;

    } else if ([segue.identifier isEqualToString:@"InvitedButtonToPeopleAttendingSegue"])
    {
        InvitedPeopleViewController *invitedPeopleViewController = segue.destinationViewController;
        invitedPeopleViewController.event = self.event;

    } else if ([segue.identifier isEqualToString:@"IndividualToIndividualInvite"])
    {
        IndividualEventInvitePeopleViewController *individualEventInvitePeopleViewController = segue.destinationViewController;
        individualEventInvitePeopleViewController.event = self.event;
    }
}

- (IBAction)unwindSegueToIndividualViewController:(UIStoryboardSegue *)sender
{
    
}

- (IBAction)unwindFromIndividualInviteTOIndividual:(UIStoryboardSegue *)sender
{
    IndividualEventInvitePeopleViewController *individualEventInvitePeopleViewController = sender.sourceViewController;
    self.usersInvitedArray = individualEventInvitePeopleViewController.usersInvitedArray;
    [self performSelector:@selector(creatingEventInvitesFromSegue) withObject:nil afterDelay:2.0];
}

- (void)creatingEventInvitesFromSegue
{
    for (PFUser *user in self.usersInvitedArray)
    {
        PFObject *eventInvite = [PFObject objectWithClassName:@"EventInvite"];
        eventInvite[@"toUser"] = user;
        eventInvite[@"event"] = self.event;
        eventInvite[@"statusOfUser"] = @"Invited";
        [eventInvite saveInBackground];

        //creates relations to the event for each user
        PFRelation *relation = [self.event relationforKey:@"usersInvited"];
        [relation addObject:user];
        [self.event saveInBackground];
    }
}

@end
