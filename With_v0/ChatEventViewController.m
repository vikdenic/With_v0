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

//-----------------------------------------------

@interface ChatEventViewController () <UITableViewDataSource, UITableViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UITextField *chatTextFieldOutlet;
@property (weak, nonatomic) IBOutlet UITableView *commentTableView;
@property NSString *enteredText;
@property NSArray *chatRoomMessagesArray;
@property NSArray *authorsArray;
@property NSArray *messagesArray5000;
@property NSArray *imageFilesArray;
@property NSMutableArray *imagesArray;

@property (strong, nonatomic) CustomTableViewCell *customCell;

@property NSString *usernamePlaceHolder;


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

    self.imagesArray = [[NSMutableArray alloc] init];

    self.navigationController.hidesBottomBarWhenPushed = NO;

    [[self navigationController] setNavigationBarHidden:YES animated:YES];

    //Scroll opposite
    [self.commentTableView setScrollsToTop:YES];

    //Save tableview frame
    CGRect frame = self.commentTableView.frame;

    //Apply the transform
    self.commentTableView.transform=CGAffineTransformMakeRotation(M_PI);
    self.commentTableView.frame = frame;

    //notification for Ugly keyboard animation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];

    self.navigationController.hidesBottomBarWhenPushed = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self retrieveAuthorsUsernames];
    [self retrieveCommentsFromParse];
    //[self retrieveAuthorsAvatarImages];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.usernamePlaceHolder = [[NSString alloc] init];
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
    [self.view endEditing:YES];

    self.enteredText = self.chatTextFieldOutlet.text;

    //Create Comment Object
    PFObject *chatComment = [PFObject objectWithClassName:@"ChatMessage"];

    //this adds the text into parse key textContent
    [chatComment setObject:self.enteredText forKey:@"chatText"];

    //This Creates relationship to the user!

    [chatComment setObject:[PFUser currentUser].username forKey:@"author"];

    //Save comment
    [chatComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {

            [self retrieveAuthorsUsernames];
            [self retrieveCommentsFromParse];
            //[self retrieveAuthorsAvatarImages];
            //[self.commentTableView reloadData];
        }
    }];

    self.chatTextFieldOutlet.text = @"";

    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];

    // Send push notification to query
    [PFPush sendPushMessageToQueryInBackground:pushQuery
                                   withMessage:@"new chat message in \"event name\""];


    //Animate the send button
    sender.transform = CGAffineTransformMakeScale(.5f, .5f);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.8];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    CGAffineTransform scaleTrans  = CGAffineTransformMakeScale(1.0f, 1.0f);
    CGAffineTransform lefttorightTrans  = CGAffineTransformMakeTranslation(0.0f,0.0f);
    sender.transform = CGAffineTransformConcat(scaleTrans, lefttorightTrans);
    [UIView commitAnimations];
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
    [self retrieveCommentsFromParse];
    [self retrieveAuthorsUsernames];
    //[self retrieveAuthorsAvatarImages];
    [self.commentTableView reloadData];
}


///
//- (IBAction)testChannelSubscribeButt:(id)sender {
//    // When users indicate they are Giants fans, we subscribe them to that channel.
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//    [currentInstallation addUniqueObject:@"Giants" forKey:@"channels"];
//    [currentInstallation saveInBackground];
//    NSLog(@"some punk likes the giants");
//
//}



#pragma mark - Getting from parse //------------------------------------------------
- (void)retrieveCommentsFromParse
{
    PFQuery *commentQuery = [PFQuery queryWithClassName:@"ChatMessage"];
    [commentQuery orderByDescending:@"createdAt"];

    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            [objects.lastObject objectForKey:@"chatText"]; //objectForKey:@"chatText"];

            self.messagesArray5000 = objects;

            [self.commentTableView reloadData];
        }
    }];
}

- (void)retrieveAuthorsUsernames
{
    PFQuery *authorQuery = [PFQuery queryWithClassName:@"ChatMessage"];
    [authorQuery orderByDescending:@"createdAt"];
    [authorQuery includeKey:@"author2"];

    [authorQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (!error)
        {
            [[users.lastObject objectForKey:@"author2"] objectForKey:@"username"];

            self.authorsArray = users;

            NSLog(@"%@", self.authorsArray);

            [self.commentTableView reloadData];
        }
    }];
}

//- (void)retrieveAuthorsAvatarImages
//{
//    PFQuery *avatarQuery = [PFQuery queryWithClassName:@"ChatMessage"];
//    [avatarQuery orderByDescending:@"createdAt"];
//    [avatarQuery includeKey:@"author2"];
//
//    [avatarQuery findObjectsInBackgroundWithBlock:^(NSArray *imageFiles, NSError *error) {
//        if (!error)
//        {
//            [[imageFiles.lastObject objectForKey:@"author2"] objectForKey:@"miniProfilePhoto"];
//
//            self.imageFilesArray = imageFiles;
//
//            for (PFFile *file in self.imageFilesArray) {
//                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//                    UIImage *finalImage = [UIImage imageWithData:data];
//                    [self.imagesArray addObject:finalImage];
//
//                    NSLog(@"FINAL IMAGE: %@",finalImage);
//                }];
//
//            }
//
//            [self.commentTableView reloadData];
//        }
//    }];
//}



#pragma mark - TableView del methods //------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.customCell) {
        self.customCell = [tableView dequeueReusableCellWithIdentifier:@"ChatroomCell"];
    }

    ///configure the cell pain in thee ass
    PFObject *message = [self.messagesArray5000 objectAtIndex:indexPath.row];

    [self.customCell.chatMessageCellLabel setText:[message objectForKey:@"chatText"]];

    ///layout cell
    [self.customCell layoutIfNeeded];

    //get height
    CGFloat height = [self.customCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    return height;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messagesArray5000.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = [[CustomTableViewCell alloc] init];
    PFObject *message = [self.messagesArray5000 objectAtIndex:indexPath.row];
    PFObject *author = [self.authorsArray objectAtIndex:indexPath.row];

    self.usernamePlaceHolder = [author objectForKey:@"author"];

    cell.chatMessageCellLabel.text = self.enteredText;


    if ([self.usernamePlaceHolder isEqualToString:[PFUser currentUser].username])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UserChatCell"];
        cell.usernameChatCellLabel.textColor = [UIColor orangeColor];


    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ChatroomCell"];///change later
    }

    [cell.chatMessageCellLabel setText:[message objectForKey:@"chatText"]];

    cell.usernameChatCellLabel.text = self.usernamePlaceHolder;

    //Avatar pic stuff
    cell.chatAvatarImage.image = [UIImage imageNamed:@"pacMan.jpg"];
    cell.chatAvatarImage.image = [self.imagesArray objectAtIndex:indexPath.row];
    cell.chatAvatarImage.layer.borderWidth = 1.0f;
    cell.chatAvatarImage.layer.cornerRadius = 11.7;
    cell.chatAvatarImage.layer.masksToBounds = YES;
    cell.chatAvatarImage.layer.borderColor = [[UIColor blackColor] CGColor];
    
    //Rotate the cell too
    cell.transform = CGAffineTransformMakeRotation(M_PI);
    
    return cell;
}

@end
