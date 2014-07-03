//
//  ChatEventViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//


#import "ChatEventViewController.h"
#import <Parse/Parse.h>
#import "CustomTableViewCell.h"
#import "ChatEventObject.h"

//-----------------------------------------------

@interface ChatEventViewController () <UITableViewDataSource, UITableViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UITextField *chatTextFieldOutlet;
@property (weak, nonatomic) IBOutlet UITableView *commentTableView;
@property (strong, nonatomic) CustomTableViewCell *customCell;
@property NSString *enteredText;
@property NSArray *chatRoomMessagesArray;
@property NSString *channelPlaceHolder;
@property NSMutableArray *chatObjects;
@property int numberOfRows;

@end

#pragma mark - view life cycle //------------------------------------------------

@implementation ChatEventViewController

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"Test1" object:nil];;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.chatObjects = [NSMutableArray array];

    self.channelPlaceHolder = [NSString stringWithFormat:@"%@", [self.event objectForKey:@"title"]];
    self.navigationController.hidesBottomBarWhenPushed = NO;
    [[self navigationController] setNavigationBarHidden:YES animated:YES];

    //Scroll opposite
//    [self.commentTableView setScrollsToTop:YES];

    //Save tableview frame
//    CGRect frame = self.commentTableView.frame;

    //Apply the transform
//    self.commentTableView.transform=CGAffineTransformMakeRotation(M_PI);
//    self.commentTableView.frame = frame;

    //notification for Ugly keyboard animation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];

    //self.navigationController.hidesBottomBarWhenPushed = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self getChatObject];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

#pragma mark - notifications //------------------------------------------------
- (void)receiveNotification: (NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"Test1"])
    {
        [self reload];
    }
}

#pragma mark - send button  CGAFFINE!!!!! //------------------------------------------------
- (IBAction)sendButtonPressed:(UIButton *)sender
{
    PFObject *chatComment = [PFObject objectWithClassName:@"ChatMessage"];
    chatComment[@"chatText"] = self.chatTextFieldOutlet.text;
    chatComment[@"author"] = [PFUser currentUser];
    chatComment[@"chatEvent"] = self.event;
    [chatComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (!error)
         {
             ChatEventObject *chatEventObject = [[ChatEventObject alloc]init];
             chatEventObject.user = [PFUser currentUser];
             chatEventObject.chatMessage = chatComment[@"chatText"];
             [self.chatObjects addObject:chatEventObject];
             NSIndexPath *path = [NSIndexPath indexPathForRow:self.numberOfRows inSection:0];
             [self.commentTableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];

             [self.commentTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];

             [self.commentTableView reloadData];
         }
    }];
    self.chatTextFieldOutlet.text = @"";


    ///
    // Send a notification to all devices subscribed to the "Giants" channel.

    PFPush *push = [[PFPush alloc] init];
    [push setChannel:self.channelPlaceHolder];
    [push setMessage:@"New Message!"];
    [push sendPushInBackground];

    ///multiple channel prototype
//    NSArray *channels = [NSArray arrayWithObjects:@"Giants", @"Mets", nil];
//    PFPush *push = [[PFPush alloc] init];
//
//    // Be sure to use the plural 'setChannels'.
//    [push setChannels:channels];
//    [push setMessage:@"The Giants won against the Mets 2-3."];
//    [push sendPushInBackground];

    ///send to all prototype
//    // Create our Installation query
//    PFQuery *pushQuery = [PFInstallation query];
//    ///change below for channel push
//    [pushQuery whereKey:@"channels" equalTo:self.channelPlaceHolder];
//    //[pushQuery whereKey:@"channels" equalTo:@"ios"];
//
//
//
//    // Send push notification to query
//    [PFPush sendPushMessageToQueryInBackground:pushQuery
//                                   withMessage:[NSString stringWithFormat:@"new chat message in %@", self.channelPlaceHolder]];


    //Animate the send button
//    sender.transform = CGAffineTransformMakeScale(.5f, .5f);
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDuration:0.8];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//    CGAffineTransform scaleTrans  = CGAffineTransformMakeScale(1.0f, 1.0f);
//    CGAffineTransform lefttorightTrans  = CGAffineTransformMakeTranslation(0.0f,0.0f);
//    sender.transform = CGAffineTransformConcat(scaleTrans, lefttorightTrans);
//    [UIView commitAnimations];
}

- (IBAction)cancelTest:(id)sender
{
    // When users indicate they are no longer Giants fans, we unsubscribe them.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation removeObject:self.channelPlaceHolder forKey:@"channels"];
    [currentInstallation saveInBackground];
}


#pragma mark - (scroll methods) Method to figure out if scrolling up or down //-------------------------
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{

    if (velocity.y > 0)
    {
        //[self reload];
        NSLog(@"up");
    }
    if (velocity.y < 0)
    {
        NSLog(@"down");
        //[self reload];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.chatTextFieldOutlet resignFirstResponder];
}


#pragma mark - Keyboard animation stuff //------------------------------------------------

//new style keyboard animation
- (void) keyboardDidShow:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] intValue]];


    if ([[UIScreen mainScreen] bounds].size.height == 1136)
    {
        [self.view setFrame:CGRectMake(0, -220, 640, 1120)];
    } else {
        [self.view setFrame:CGRectMake(0, -220, 640, 920)];
    }

    [UIView commitAnimations];
}


//Old style
- (void) keyboardDidHide:(NSNotification *)notification
{
    if ([[UIScreen mainScreen] bounds].size.height == 1136)
    {
        [UIView animateWithDuration:0.25 animations:^{
            [self.view setFrame:CGRectMake(0, 0, 640, 1120)];
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            [self.view setFrame:CGRectMake(0, 0, 640, 920)];
        }];
    }
}

- (void)reload
{
    [self getChatObject];
}


//////////CHANNELS
- (IBAction)testChannelSubscribeButt:(id)sender {
    // When users indicate they are Giants fans, we subscribe them to that channel.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:self.channelPlaceHolder forKey:@"channels"];
    [currentInstallation saveInBackground];
    NSLog(@"some punk is goin to the party");

}


#pragma mark - Getting from parse //------------------------------------------------

- (void)getChatObject
{
    [self.chatObjects removeAllObjects];

    PFQuery *commentQuery = [PFQuery queryWithClassName:@"ChatMessage"];
    [commentQuery whereKey:@"chatEvent" equalTo:self.event];
    [commentQuery orderByDescending:@"createdAt"];
    [commentQuery includeKey:@"author"];
    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {

            for (PFObject *object in objects)
            {
                ChatEventObject *chatEventObject = [[ChatEventObject alloc]init];
                chatEventObject.user = [object objectForKey:@"author"];
                chatEventObject.chatMessage = [object objectForKey:@"chatText"];
                [self.chatObjects addObject:chatEventObject];
                [self.commentTableView reloadData];
            }
            self.chatObjects = self.chatObjects.reverseObjectEnumerator.allObjects.mutableCopy;
        }
    }];
}

#pragma mark - TableView del methods //------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.customCell) {
        self.customCell = [tableView dequeueReusableCellWithIdentifier:@"ChatroomCell"];
    }

    ///configure the cell pain in thee ass
    ChatEventObject *chatEventObject = [self.chatObjects objectAtIndex:indexPath.row];

    [self.customCell.chatMessageCellLabel setText:chatEventObject.chatMessage];

    ///layout cell
    [self.customCell layoutIfNeeded];

    //get height
    CGFloat height = [self.customCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    return height;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.numberOfRows = (int)self.chatObjects.count;
    return self.chatObjects.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == 0)
    {
        int row = (int)self.chatObjects.count -1;

        NSIndexPath *path = [NSIndexPath indexPathForRow:row-- inSection:0];

        [self.commentTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom  animated:NO];

        [self.commentTableView reloadData];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = [[CustomTableViewCell alloc] init];

    ChatEventObject *chatEventObject = [self.chatObjects objectAtIndex:indexPath.row];

    if ([chatEventObject.user.objectId isEqualToString:[PFUser currentUser].objectId])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UserChatCell"];
        cell.usernameChatCellLabel.textColor = [UIColor orangeColor];

    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ChatroomCell"];
        cell.usernameChatCellLabel.textColor = [UIColor colorWithRed:202/255.0 green:250/255.0 blue:53/255.0 alpha:1];
    }

    cell.chatMessageCellLabel.text = [NSString stringWithFormat:@"%@", chatEventObject.chatMessage];

    cell.usernameChatCellLabel.text = chatEventObject.user.username;

    //setting the user profile picture
    PFFile *userProfilePhoto = [chatEventObject.user objectForKey:@"miniProfilePhoto"];
    [userProfilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
             UIImage *image = [UIImage imageWithData:data];
             cell.chatAvatarImage.image = image;

         } else {
             cell.chatAvatarImage.image = [UIImage imageNamed:@"clock"];
         }
     }];
    cell.chatAvatarImage.layer.borderWidth = 1.0f;
    cell.chatAvatarImage.layer.cornerRadius = 11.7;
    cell.chatAvatarImage.layer.masksToBounds = YES;
    cell.chatAvatarImage.layer.borderColor = [[UIColor blackColor] CGColor];

    //Rotate the cell too
//    cell.transform = CGAffineTransformMakeRotation(M_PI);

    return cell;
}

@end
