//
//  DateAndTimeViewController.m
//  With_v0
//
//  Created by Vik Denic on 6/21/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "DateAndTimeViewController.h"

@interface DateAndTimeViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation DateAndTimeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


-(void)viewWillDisappear:(BOOL)animated
{
    NSDate *myDate = self.datePicker.date;

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"cccc, MMM d, hh:mm aa"];
    self.dateString = [dateFormat stringFromDate:myDate];
    NSLog(@"Disappear: %@", self.dateString);
}

- (IBAction)onBackPressed:(id)sender
{
    NSDate *myDate = self.datePicker.date;

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"cccc, MMM d, hh:mm aa"];
    self.dateString = [dateFormat stringFromDate:myDate];
    NSLog(@"Disappear: %@", self.dateString);
}


@end
