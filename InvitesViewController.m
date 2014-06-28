//
//  InvitesViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/27/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "InvitesViewController.h"
#import <Parse/Parse.h>

@interface InvitesViewController () <UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *eventArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation InvitesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.eventArray = [NSMutableArray array];
}

- (void)queryForEvents
{
    PFQuery *query = [PFQuery queryWithClassName:@"EventInvite"];
    [query whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [query includeKey:@"event"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         //this is the users events
         for (PFObject *object in objects)
         {
             PFObject *event = [object objectForKey:@"event"];
             [self.eventArray addObject:event];
         }
         [self.tableView reloadData];
     }];
}


@end
