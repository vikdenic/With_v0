//
//  InvitesViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/27/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "InvitesViewController.h"
#import <Parse/Parse.h>
#import "InvitesTableViewCell.h"

@interface InvitesViewController () <UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *eventArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation InvitesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.eventArray = [NSMutableArray array];

    [self queryForEvents];
}

- (void)queryForEvents
{
    PFQuery *query = [PFQuery queryWithClassName:@"EventInvite"];
    [query whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"statusOfUser" equalTo:@"Invited"];
    [query includeKey:@"event"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         //this is the users events
         for (PFObject *object in objects)
         {
             PFObject *theEvent = [object objectForKey:@"event"];
             NSString *eventId = theEvent.objectId;

             PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
             [eventQuery includeKey:@"creator"];
             [eventQuery whereKey:@"objectId" equalTo:eventId];
             [eventQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
             {
                  [self.eventArray addObject:object];
                  [self.tableView reloadData];
              }];
         }
     }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.eventArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InvitesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    PFObject *object = [self.eventArray objectAtIndex:indexPath.row];

    PFFile *userProfilePhoto = [[object objectForKey:@"creator"] objectForKey:@"userProfilePhoto"];
    [userProfilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (data == nil)
         {
             cell.creatorImageView.image = nil;

         } else {
             UIImage *temporaryImage = [UIImage imageWithData:data];

             cell.creatorImageView.layer.cornerRadius = cell.creatorImageView.bounds.size.width/2;
             cell.creatorImageView.layer.borderColor = [[UIColor colorWithRed:202/255.0 green:250/255.0 blue:53/255.0 alpha:1] CGColor];
             cell.creatorImageView.layer.borderWidth = 2.0;
             cell.creatorImageView.layer.masksToBounds = YES;

             cell.creatorImageView.image = temporaryImage;
         }
     }];

    PFFile *file = [object objectForKey:@"themeImage"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
             UIImage *image = [UIImage imageWithData:data];
            cell.themeImageView.image = image;
     }];

    //creator username
    PFObject *userName = [[object objectForKey:@"creator"] objectForKey:@"username"];
    cell.creatorNameLabel.text = [NSString stringWithFormat:@"%@", userName];

    //event Name and Date;
    cell.eventNameLabel.text = object[@"title"];
    cell.eventDateLabel.text = object[@"eventDate"];
    
    cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
