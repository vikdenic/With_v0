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
@property NSArray *messagesArray;

@property NSString *usernamePlaceHolder;

@property CGRect *tempCGRect;

@property CGFloat height;

@property CGFloat tempHeightOfLabel;
@property CGFloat width;


@property (weak, nonatomic) IBOutlet UITextView *hiddenTextView;

@property (weak, nonatomic) IBOutlet UIView *hiddenView;

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
    self.navigationController.hidesBottomBarWhenPushed = NO;

    [[self navigationController] setNavigationBarHidden:YES animated:YES];

    //self.view.backgroundColor = [UIColor blackColor];

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

    self.width = self.hiddenTextView.frame.size.width;
    self.tempHeightOfLabel = self.hiddenTextView.frame.size.height;

    self.hiddenView.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self retrieveAuthorsUsernames];
    [self retrieveCommentsFromParse];
    [self.commentTableView reloadData];
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


    ///
    self.hiddenTextView.text = self.chatTextFieldOutlet.text;
    [self.hiddenTextView sizeToFit];

    self.height = self.hiddenTextView.frame.size.height;

    self.enteredText = self.chatTextFieldOutlet.text;

    self.tempHeightOfLabel = self.hiddenTextView.frame.size.height;

    self.hiddenTextView.frame = CGRectMake(0, 0, self.width, self.height);
    ///



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
            [self.commentTableView reloadData];
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



#pragma mark - Getting from parse //------------------------------------------------
- (void)retrieveCommentsFromParse
{
    PFQuery *commentQuery = [PFQuery queryWithClassName:@"ChatMessage"];
    [commentQuery orderByDescending:@"createdAt"];

    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [objects.lastObject objectForKey:@"chatText"]; //objectForKey:@"chatText"];

            self.chatRoomMessagesArray = objects;

            [self.commentTableView reloadData];
        }
    }];
}

- (void)retrieveAuthorsUsernames
{
    PFQuery *authorQuery = [PFQuery queryWithClassName:@"ChatMessage"];
    [authorQuery orderByDescending:@"createdAt"];

    [authorQuery findObjectsInBackgroundWithBlock:^(NSArray *authors, NSError *error) {
        if (!error)
        {
            [authors.lastObject objectForKey:@"author"];

            self.authorsArray = authors;

            [self.commentTableView reloadData];
        }
    }];
}




#pragma mark - Reload stuff //------------------------------------------------




#pragma mark - (scroll methods) Method to figure out if scrolling up or down //-------------------------
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{

    if (velocity.y > 0)
    {
        [self reload];
        NSLog(@"up");
    }
    if (velocity.y < 0)
    {
        NSLog(@"down");
        [self reload];
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



#pragma mark - TableView del methods //------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = [[CustomTableViewCell alloc] init];

    cell.customTextView.frame = CGRectMake(0, 0, self.hiddenTextView.frame.size.width, self.height);

    [cell.customTextView sizeToFit];

    CGFloat cellSeperation = 10;

    if (self.height < 20) {
        cellSeperation = 80;
    } else {
        cellSeperation = 10;
    }
    return self.height + cellSeperation;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //self.commentTableView.backgroundColor = [UIColor blackColor];
    return self.chatRoomMessagesArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = [[CustomTableViewCell alloc] init];
    PFObject *message = [self.chatRoomMessagesArray objectAtIndex:indexPath.row];
    PFObject *author = [self.authorsArray objectAtIndex:indexPath.row];
    self.usernamePlaceHolder = [author objectForKey:@"author"];

    if ([self.usernamePlaceHolder isEqualToString:[PFUser currentUser].username])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UserCommentCell"];

    }
    else
    {
        // use the Comment Cell (Dequeue here)
        cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    }

    [cell.customTextView setText:[message objectForKey:@"chatText"]];


    ///
    cell.customTextView.text = self.enteredText;
    cell.customTextView.frame = CGRectMake(0, 0, self.hiddenTextView.frame.size.width, self.height);

    [cell.customTextView sizeToFit];
    ///


    cell.usernameLabelInCell.text = self.usernamePlaceHolder;

    cell.usernameLabelInCell.textColor = [UIColor orangeColor];
    //cell.commentTextLabel.textColor = [UIColor blackColor];

    //Avatar pic stuff
    cell.imageInCell.image = [UIImage imageNamed:@"pacMan.jpg"];
    cell.imageInCell.layer.borderWidth = 1.0f;
    cell.imageInCell.layer.cornerRadius = 17.6;
    cell.imageInCell.layer.masksToBounds = YES;
    cell.imageInCell.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    //Rotate the cell too
    cell.transform = CGAffineTransformMakeRotation(M_PI);
    
    return cell;
}


@end

