//
//  CommentsViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/17/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "CommentsViewController.h"
#import "CommentsTableViewCell.h"

@interface CommentsViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property NSMutableArray *commentsArray;

@end

@implementation CommentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.commentsArray = [NSMutableArray array];

    [self.tableView reloadData];

    PFFile *file = [self.commentObject objectForKey:@"photo"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
             UIImage *temporaryImage = [UIImage imageWithData:data];

             CGSize sacleSize = CGSizeMake(320, 320);
             UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
             [temporaryImage drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
             UIImage * resizedImage = UIGraphicsGetImageFromCurrentImageContext();
             UIGraphicsEndImageContext();

             self.imageView.image = resizedImage;
         }
     }];

    [self.textField becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self getComments];
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

    cell.timeLabel.text = [NSString stringWithFormat:@"%@", comment.createdAt];
    //change the date into something cool

    PFObject *userName = [[comment objectForKey:@"fromUser"] objectForKey:@"username"];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@", userName];


    PFFile *userProfilePhoto = [[comment objectForKey:@"fromUser"] objectForKey:@"userProfilePhoto"];

    [userProfilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
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

#pragma mark - Text Field

//input accesorry view- view attached to the top of the keyboard


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    PFObject *object = self.commentObject;
    PFUser *picturePhotographer = [object objectForKey:@"photographer"];

    PFObject *comment = [PFObject objectWithClassName:@"CommentActivity"];
    comment[@"fromUser"] = [PFUser currentUser];
    comment[@"toUser"] = picturePhotographer;
    comment[@"photo"] = object;
    comment[@"commentContent"] = self.textField.text;
    [comment saveInBackground];

    [self.textField resignFirstResponder];
    
    return YES;
}

- (void)getComments
{
    PFQuery *query = [PFQuery queryWithClassName:@"CommentActivity"];
    [query whereKey:@"photo" equalTo:self.commentObject];
    [query includeKey:@"fromUser"];
    [query orderByAscending:@"createdAt"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         [self.commentsArray addObjectsFromArray:objects];
         [self.tableView reloadData];
    }];
}

@end
