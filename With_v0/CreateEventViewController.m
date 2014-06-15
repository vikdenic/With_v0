//
//  CreateEventViewController.m
//  With_v0
//
//  Created by Vik Denic on 6/15/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "CreateEventViewController.h"
#import <Parse/Parse.h>

@interface CreateEventViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *themeImageView;
@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;
@property (weak, nonatomic) IBOutlet UILabel *changeThemeButton;
@property (weak, nonatomic) IBOutlet UIButton *dateAndTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *invitePeopleButton;

@property (weak, nonatomic) IBOutlet UIView *dateAndTimeView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation CreateEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.dateAndTimeView.alpha = 0;
    self.dateAndTimeView.hidden = YES;
}

#pragma mark - Action Methods

- (IBAction)onDateAndTimeButtonTapped:(id)sender
{
    [self animatePopUpShow];
}

- (IBAction)onLocationButtonTapped:(id)sender
{

}

- (IBAction)onInvitePeopleButtonTapped:(id)sender
{
    
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
    NSDate *selectedDate = [self.datePicker date];

//    NSDateFormatter *date = [[NSDateFormatter alloc] init];
//    [date setDateFormat:@"MM-dd-yyyy-HH-mm"];
//    NSString *formattedDate = [date stringFromDate:selectedDate];


    NSString *dateString = [NSDateFormatter localizedStringFromDate:selectedDate
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



@end
