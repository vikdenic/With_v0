//
//  ProfileViewController.m
//  With_v0
//
//  Created by Vik Denic on 6/15/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "IndividualEventViewController.h"
#import "HomeTableViewCell.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *profileAvatar;

@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UILabel *cityStateLabel;

@property (weak, nonatomic) IBOutlet UILabel *pastLabel;
@property (weak, nonatomic) IBOutlet UILabel *UpcomingLabel;

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Actions

- (IBAction)onPastButtonPressed:(id)sender
{
    self.pastLabel.textColor = [UIColor blackColor];
    self.UpcomingLabel.textColor = [UIColor grayColor];
}

- (IBAction)onUpcomingButtonPressed:(id)sender
{
    self.pastLabel.textColor = [UIColor grayColor];
    self.UpcomingLabel.textColor = [UIColor blackColor];
}


#pragma mark - TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];

    return cell;
}


#pragma mark - Segues

// When user CANCELS within settings
- (IBAction)unwindSegueCancelSettingsToProfile:(UIStoryboardSegue *)sender
{

}

// When user SAVES settings
- (IBAction)unwindSegueSaveSettingsToProfile:(UIStoryboardSegue *)sender
{

}

- (IBAction)unwindSegueInvitesToProfile:(UIStoryboardSegue *)sender
{
    
}

@end
