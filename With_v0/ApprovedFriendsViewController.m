//
//  ApprovedFriendsViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/25/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "ApprovedFriendsViewController.h"
#import "ApprovedFriendsTableViewCell.h"

@interface ApprovedFriendsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ApprovedFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ApprovedFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    return cell;
}

@end
