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

@end

@implementation IndividualEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self navigationController] setNavigationBarHidden:YES animated:YES];

    self.addressTextView.text = @"Address";
    self.dateAndTimeTextView.text = @"Date and Time";
    self.detailsTextView.text = @"Throw on some neon and bring your friends on over to our place for a night of fun and plently of refreshments.";
}

#pragma mark - Action methods

- (IBAction)onYesButtonTapped:(UIButton *)sender
{
    //add the current user to the event, update the count of going

//    if (sender.highlighted)
//    {
//        [self.goingButton setImage:[UIImage imageNamed:@"Yes_Button_Selected"] forState:UIControlStateHighlighted];
//
//    } else {
//        
//        [self.goingButton setImage:[UIImage imageNamed:@"Yes_Button"] forState:UIControlStateHighlighted];
//    }
}

- (IBAction)onNoButtonTapped:(id)sender
{
    //not sure what to do here yet
}

@end
