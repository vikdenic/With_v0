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
#import "InvitesButton.h"

@interface InvitesViewController () <UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *eventArray;
@property NSMutableArray *eventInviteArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation InvitesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.eventArray = [NSMutableArray array];
    self.eventInviteArray = [NSMutableArray array];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

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
             [self.eventInviteArray addObject:object];

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
    PFObject *eventInvite = [self.eventInviteArray objectAtIndex:indexPath.row];

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


    ///must change all these when Vik gets the images that will appear
    UIImage *yesButton = [UIImage imageNamed:@"yes_image_unselected"];
    [cell.yesButton setImage:yesButton forState:UIControlStateNormal];
    cell.yesButton.eventObject = object;
    cell.yesButton.tag = indexPath.row;
    cell.yesButton.eventInviteObject = eventInvite;
    [cell.yesButton addTarget:self action:@selector(onYesTapped:) forControlEvents:UIControlEventTouchUpInside];

    UIImage *noButton = [UIImage imageNamed:@"no_image_unselected"];
    [cell.noButton setImage:noButton forState:UIControlStateNormal];
    cell.noButton.eventObject = object;
    cell.noButton.eventInviteObject = eventInvite;
    cell.noButton.tag = indexPath.row;
    [cell.noButton addTarget:self action:@selector(onNoTapped:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)onYesTapped:(InvitesButton *)sender
{
    InvitesTableViewCell *cell = (id)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];

    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"yes_image_unselected"]])
    {
        UIImage *btnImage = [UIImage imageNamed:@"yes_image_selected"];
        [sender setImage:btnImage forState:UIControlStateNormal];

        PFRelation *eventRelation = [[PFUser currentUser] relationForKey:@"eventsAttending"];
        [eventRelation addObject:sender.eventObject];
        [[PFUser currentUser] saveInBackground];
        ///need to remove this if no is touched, below if yes unselected too
        
        sender.eventInviteObject[@"statusOfUser"] = @"Going";
        [sender.eventInviteObject saveInBackground];

        PFRelation *goingRelation = [sender.eventObject relationForKey:@"usersAttending"];
        [goingRelation addObject:[PFUser currentUser]];
        PFRelation *notGoingRelation = [sender.eventObject relationForKey:@"usersNotAttending"];
        [notGoingRelation removeObject:[PFUser currentUser]];
        [sender.eventObject saveInBackground];

        ///change the status of event invited and maybe just delete it from that class too? think about this

        UIImage *btnImage2 = [UIImage imageNamed:@"no_image_unselected"];
        [cell.noButton setImage:btnImage2 forState:UIControlStateNormal];

    } else if ([sender.imageView.image isEqual:[UIImage imageNamed:@"yes_image_selected"]])
    {
        UIImage *btnImage = [UIImage imageNamed:@"yes_image_unselected"];
        [sender setImage:btnImage forState:UIControlStateNormal];

        sender.eventInviteObject[@"statusOfUser"] = @"Invited";
        [sender.eventInviteObject saveInBackground];

        PFRelation *goingRelation = [sender.eventObject relationForKey:@"usersAttending"];
        [goingRelation removeObject:[PFUser currentUser]];
        [sender.eventObject saveInBackground];
    }
}

- (void)onNoTapped:(InvitesButton *)sender
{
    InvitesTableViewCell *cell = (id)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];

    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"no_image_unselected"]])
    {
        UIImage *btnImage = [UIImage imageNamed:@"no_image_selected"];
        [sender setImage:btnImage forState:UIControlStateNormal];
        //add the relation to the event and put them in the usersNotGoing

        PFRelation *goingRelation = [sender.eventObject relationForKey:@"usersAttending"];
        [goingRelation removeObject:[PFUser currentUser]];
        [sender.eventObject saveInBackground];

        sender.eventInviteObject[@"statusOfUser"] = @"Denied";
        [sender.eventInviteObject saveInBackground];

        PFRelation *notGoingRelation = [sender.eventObject relationForKey:@"usersNotAttending"];
        [notGoingRelation addObject:[PFUser currentUser]];
        [sender.eventObject saveInBackground];

        UIImage *btnImage2 = [UIImage imageNamed:@"yes_image_unselected"];
        [cell.yesButton setImage:btnImage2 forState:UIControlStateNormal];

    } else if ([sender.imageView.image isEqual:[UIImage imageNamed:@"no_image_selected"]])
    {
        UIImage *btnImage = [UIImage imageNamed:@"no_image_unselected"];
        [sender setImage:btnImage forState:UIControlStateNormal];

        sender.eventInviteObject[@"statusOfUser"] = @"Invited";
        [sender.eventInviteObject saveInBackground];

        PFRelation *goingRelation = [sender.eventObject relationForKey:@"usersNotAttending"];
        [goingRelation removeObject:[PFUser currentUser]];
        [sender.eventObject saveInBackground];
    }
}

@end
