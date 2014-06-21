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
//#import "Custom2TableViewCell.h"

@interface ChatEventViewController () <UITableViewDataSource, UITableViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UITextField *chatTextFieldOutlet;
@property (weak, nonatomic) IBOutlet UITableView *commentTableView;
@property NSString *enteredText;
@property NSArray *chatRoomMessagesArray;
@property NSArray *authorsArray;
@property NSArray *messagesArray;

@property NSString *usernamePlaceHolder;

//@property UIPushBehavior *pushBehavior;
//@property UIGravityBehavior *gravityBehavior;
//@property UIDynamicAnimator *dynamicAnimator;
//@property UICollisionBehavior *collisionBehavior;

@end


//------------------------------------------------


#pragma mark - notifications

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

- (void)receiveNotification: (NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"Test1"])
    {
        [self reload];
    }
}



#pragma mark - view life cycle


- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self navigationController] setNavigationBarHidden:YES animated:YES];

    self.view.backgroundColor = [UIColor blackColor];

    //Ugly keyboard animation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];

    //Scroll opposite
    [self.commentTableView setScrollsToTop:YES];

    //Save tableview frame
    CGRect frame = self.commentTableView.frame;

    //Apply the transform
    self.commentTableView.transform=CGAffineTransformMakeRotation(M_PI);
    self.commentTableView.frame = frame;

    self.navigationController.hidesBottomBarWhenPushed = NO;


    //[PFUser logOut];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.usernamePlaceHolder = [[NSString alloc] init];


//    if (![PFUser currentUser])
//    {
//        //Create the log in and sign up view controller
//        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
//        [logInViewController setDelegate:self];
//        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
//        [signUpViewController setDelegate:self];
//
//        //Assign sign up controller to be displayed from the login controller
//        [logInViewController setSignUpController:signUpViewController];
//
//        //Show the log in view controller
//        [self presentViewController:logInViewController animated:NO completion:NULL];
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self retrieveAuthorsUsernames];
    [self retrieveCommentsFromParse];
    [self.commentTableView reloadData];
}


#pragma mark - send button  CGAFFINE!!!!!
///
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



//    sender.transform = CGAffineTransformMakeScale(.3f, .3f);
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDuration:4];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//    CGAffineTransform scaleTrans  = CGAffineTransformMakeScale(2.0f, 2.0f);
//    CGAffineTransform lefttorightTrans  = CGAffineTransformMakeTranslation(-320.0f,-580.0f);
//    sender.transform = CGAffineTransformConcat(scaleTrans, lefttorightTrans);
//    [UIView commitAnimations];

}



#pragma mark - Getting from parse

- (void)retrieveCommentsFromParse
{
    //Create a query
    PFQuery *commentQuery = [PFQuery queryWithClassName:@"ChatMessage"];
    //[commentQuery includeKey:@"message"];
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

    //Kevins help
    //[commentQuery includeKey:@"member"];

    [authorQuery findObjectsInBackgroundWithBlock:^(NSArray *authors, NSError *error) {
        if (!error)
        {
            [authors.lastObject objectForKey:@"author"];

            self.authorsArray = authors;

            [self.commentTableView reloadData];
        }
    }];
}



#pragma mark - TableView del methods

////FInish me
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
//    return 60;
//}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.commentTableView.backgroundColor = [UIColor blackColor];
    return self.chatRoomMessagesArray.count;
}
///
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
    else{
        // use the Comment Cell (Dequeue here)
        cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];

    }

    [cell.commentTextLabel setText:[message objectForKey:@"chatText"]];

//    [cell.usernameLabelInCell setText:[[author objectForKey:@"author"] objectForKey:@"username"]];
    cell.usernameLabelInCell.text = self.usernamePlaceHolder;

    cell.usernameLabelInCell.textColor = [UIColor orangeColor];
    cell.commentTextLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor blackColor];

    //Avatar pic stuff
    cell.imageInCell.image = [UIImage imageNamed:@"pic.jpg"];
    cell.imageInCell.layer.borderWidth = 1.0f;
    cell.imageInCell.layer.cornerRadius = 14.2;
    cell.imageInCell.layer.masksToBounds = YES;
    cell.imageInCell.layer.borderColor = [[UIColor whiteColor] CGColor];

    //Rotate the cell too
    cell.transform = CGAffineTransformMakeRotation(M_PI);

    return cell;
}




#pragma mark - Reload stuff




#pragma mark - Method to figure out if scrolling up or down

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


#pragma mark - Keyboard animation stuff, beware... numbers ahead

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

@end

