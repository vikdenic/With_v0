//
//  FindFriendsViewController.m
//  With_v0
//
//  Created by Vik Denic on 6/15/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "FindFriendsViewController.h"
#import <Parse/Parse.h>
#import "FindFriendsTableViewCell.h"

@interface FindFriendsViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation FindFriendsViewController

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
- (IBAction)onPeopleYouMayKnowButtonPressed:(id)sender
{

}

#pragma mark - TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FindFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FindCell"];


    return cell;
}

@end
