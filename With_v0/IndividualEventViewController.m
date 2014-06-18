//
//  IndividualEventViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/15/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "IndividualEventViewController.h"

@interface IndividualEventViewController ()

@property (weak ,nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *themeImageView;
@property (weak, nonatomic) IBOutlet UILabel *goingLabel;
@property (weak, nonatomic) IBOutlet UILabel *invitedLabel;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UIButton *goingButton;
@property (weak, nonatomic) IBOutlet UIButton *notGoingButton;
@property (weak, nonatomic) IBOutlet UITextView *addressTextView;
@property (weak, nonatomic) IBOutlet UITextView *dateAndTimeTextView;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;

@property BOOL yesButtonTapped;
@property BOOL noButtonTapped;
@property (weak, nonatomic) IBOutlet UIImageView *yesImageView;
@property (weak, nonatomic) IBOutlet UIImageView *noImageView;

@end

@implementation IndividualEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self navigationController] setNavigationBarHidden:YES animated:YES];

    self.addressTextView.text = @"Address";
    self.dateAndTimeTextView.text = @"Date and Time";
    self.detailsTextView.text = @"Throw on some neon and bring your friends on over to our place for a night of fun and plently of refreshments.";

    self.yesButtonTapped = NO;
    self.noButtonTapped = NO;
    self.yesImageView.image = [UIImage imageNamed:@"Yes_Button"];
    self.noImageView.image = [UIImage imageNamed:@"No_Button"];
}

#pragma mark - Action methods

- (IBAction)onYesButtonTapped:(UIButton *)sender
{

    if (self.yesButtonTapped == NO)
    {
        self.yesButtonTapped = YES;

        self.yesImageView.image = [UIImage imageNamed:@"Yes_Button_Selected"];
        self.noImageView.image = [UIImage imageNamed:@"No_Button"];

    } else {

        self.yesButtonTapped = NO;
        
        self.yesImageView.image = [UIImage imageNamed:@"Yes_Button"];
        self.noImageView.image = [UIImage imageNamed:@"no_button_selected"];

    }
}

- (IBAction)onNoButtonTapped:(id)sender
{

    if (self.noButtonTapped == NO)
    {
        self.noButtonTapped = YES;
        self.noImageView.image = [UIImage imageNamed:@"no_button_selected"];
        self.yesImageView.image = [UIImage imageNamed:@"Yes_Button"];

    } else {

        self.noButtonTapped = NO;
        self.noImageView.image = [UIImage imageNamed:@"No_Button"];
        self.yesImageView.image = [UIImage imageNamed:@"Yes_Button_Selected"];
    }
}

#pragma mark - Segue

- (IBAction)unwindSegueToIndividualViewController:(UIStoryboardSegue *)sender
{
    
}











@end
