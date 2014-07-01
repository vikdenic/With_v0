//
//  CommentsViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/17/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//


#import "CommentsViewController.h"
#import "CommentsTableViewCell.h"
#import "StreamProfileViewController.h"

@interface CommentsViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property NSMutableArray *commentsArray;
@property NSInteger indexPathRow;
@property NSMutableArray *usersAttendingArray;

@end

@implementation CommentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.commentsArray = [NSMutableArray array];
    self.usersAttendingArray = [NSMutableArray array];
    [self gettingComments];

    [self.textField becomeFirstResponder];
}

- (void)gettingComments
{
    [self.commentsArray removeAllObjects];

    PFRelation *relation = [self.individualEventPhoto.object relationForKey:@"commentActivity"];
    PFQuery *query = [relation query];
    [query includeKey:@"fromUser"];
    [query includeKey:@"createdAt"];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
     {
         [self.commentsArray addObjectsFromArray:results];
         [self.tableView reloadData];
     }];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *comment = [self.commentsArray objectAtIndex:indexPath.row];

    CommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.commentLabel.text = [comment objectForKey:@"commentContent"];

    //setting the time since comment was uploaded
    NSDate *timeOfPicture = [comment valueForKey:@"createdAt"];
    int seconds = -(int)[timeOfPicture timeIntervalSinceNow];
    int minutes = seconds/60;

    if (minutes < 60) {
        cell.timeLabel.text = [NSString stringWithFormat:@"%im", minutes];
    } else if (minutes > 60 && minutes < 1440)
    {
        minutes = minutes/60;
        cell.timeLabel.text = [NSString stringWithFormat:@"%ih", minutes];
    } else {
        minutes = minutes/1440;
        cell.timeLabel.text = [NSString stringWithFormat:@"%id", minutes];
    }

    PFObject *userName = [[comment objectForKey:@"fromUser"] objectForKey:@"username"];

    PFUser *user = [comment objectForKey:@"fromUser"];
    if (user == nil)
    {

    } else
    {
        [self.usersAttendingArray addObject:user];
    }

    [cell.usernameButton setTitle:[NSString stringWithFormat:@"%@", userName] forState:UIControlStateNormal];
    cell.usernameButton.tag = indexPath.row;
    [cell.usernameButton addTarget:self action:@selector(onButtonTitlePressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.usernameButton setTintColor:[UIColor blackColor]];

    PFFile *userProfilePhoto = [[comment objectForKey:@"fromUser"] objectForKey:@"userProfilePhoto"];

    [userProfilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
             //this will already be set to the right image size- can we round it too?
             UIImage *image = [UIImage imageWithData:data];
             cell.theImageView.image = image;
             cell.theImageView.layer.cornerRadius = cell.theImageView.bounds.size.width/2;
             cell.theImageView.layer.borderColor = [[UIColor colorWithRed:202/255.0 green:250/255.0 blue:53/255.0 alpha:1] CGColor];
             cell.theImageView.layer.borderWidth = 2.0;
             cell.theImageView.layer.masksToBounds = YES;
             cell.theImageView.backgroundColor = [UIColor redColor];

         } else {
             cell.theImageView.image = [UIImage imageNamed:@"clock"];
         }
     }];

    return cell;
}

- (void)onButtonTitlePressed:(UIButton *)sender
{
    self.indexPathRow = sender.tag;
    [self performSegueWithIdentifier:@"CommentsToProfile" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CommentsToProfile"])
    {
        StreamProfileViewController *streamProfileViewController = segue.destinationViewController;
        PFUser *userToPass = [self.usersAttendingArray objectAtIndex:self.indexPathRow];
        streamProfileViewController.userToPass = userToPass;
    }
}

- (IBAction)sendButtPushed:(UIButton *)sender
{
    PFUser *picturePhotographer = [self.individualEventPhoto.object objectForKey:@"photographer"];

    PFObject *comment = [PFObject objectWithClassName:@"CommentActivity"];
    comment[@"fromUser"] = [PFUser currentUser];
    comment[@"toUser"] = picturePhotographer;
    comment[@"photo"] = self.individualEventPhoto.object;
    comment[@"commentContent"] = self.textField.text;
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         PFRelation *relation = [self.individualEventPhoto.object relationForKey:@"commentActivity"];
         [relation addObject:comment];
         [self.individualEventPhoto.object saveInBackground];
     }];

    self.textField.text = @"";
    [self.textField resignFirstResponder];
    [self gettingComments];
}

@end


//input accesorry view- view attached to the top of the keyboard


//-(BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    //    PFObject *object = self.commentObject;
//    PFUser *picturePhotographer = [self.individualEventPhoto.object objectForKey:@"photographer"];
//
//    PFObject *comment = [PFObject objectWithClassName:@"CommentActivity"];
//    comment[@"fromUser"] = [PFUser currentUser];
//    comment[@"toUser"] = picturePhotographer;
//    comment[@"photo"] = self.individualEventPhoto.object;
//    comment[@"commentContent"] = self.textField.text;
//    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//     {
//         PFRelation *relation = [self.individualEventPhoto.object relationForKey:@"commentActivity"];
//         [relation addObject:comment];
//         [self.individualEventPhoto.object saveInBackground];
//     }];
//
//    [self.textField resignFirstResponder];
//
//    return YES;
//}

//#pragma mark - Keyboard animation stuff //------------------------------------------------
//
////new style keyboard animation
//- (void) keyboardDidShow:(NSNotification *)notification
//{
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]];
//    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] intValue]];
//
//
//    if ([[UIScreen mainScreen] bounds].size.height == 1136)
//    {
//        [self.view setFrame:CGRectMake(0, -220, 640, 1120)];
//    } else {
//        [self.view setFrame:CGRectMake(0, -220, 640, 920)];
//    }
//
//    [UIView commitAnimations];
//}
//
//
////Old style
//- (void) keyboardDidHide:(NSNotification *)notification
//{
//    if ([[UIScreen mainScreen] bounds].size.height == 1136)
//    {
//        [UIView animateWithDuration:0.25 animations:^{
//            [self.view setFrame:CGRectMake(0, 0, 640, 1120)];
//        }];
//    } else {
//        [UIView animateWithDuration:0.25 animations:^{
//            [self.view setFrame:CGRectMake(0, 0, 640, 920)];
//        }];
//    }
//}
//
//
//#pragma mark - (scroll methods) Method to figure out if scrolling up or down //-------------------------
//-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
//{
//    NSLog(@"scrollViewShouldScrollToTop");
//    return YES;
//}
//
//
//-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
//
//    NSLog(@"scrollViewWillEndDragging");
//
//    if (velocity.y > 0)
//    {
//        //[self reloadTable];
//    }
//    if (velocity.y < 0)
//    {
//        //[self reloadTable];
//    }
//}
//
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    NSLog(@"scrollViewDidEndDecelerating");
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    NSLog(@"self = %@", self);
//    NSLog(@"scrollView = %@", scrollView);
//    NSLog(@"textField = %@", self.textField);
//    [self.textField resignFirstResponder];
//}

//- (void)getComments
//{
//    PFQuery *query = [PFQuery queryWithClassName:@"CommentActivity"];
//    [query whereKey:@"photo" equalTo:self.commentObject];
//    [query includeKey:@"fromUser"];
//    [query orderByAscending:@"createdAt"];
//
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//     {
//         [self.commentsArray addObjectsFromArray:objects];
//         [self.tableView reloadData];
//    }];
//}
