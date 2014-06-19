//
//  StreamEventViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StreamEventViewController.h"
#import "StreamTableViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Parse/Parse.h>
#import "CommentsViewController.h"

@interface StreamEventViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property UIImagePickerController *cameraController;

//@property (strong, nonatomic) NSURL *videoUrl;
//@property (strong, nonatomic) MPMoviePlayerController *videoController;

@property UIRefreshControl *refreshControl;

@property NSMutableArray *pictureAndVideoArray;
@property NSMutableArray *imagesArray;

@property NSMutableArray *numberOfLikes;

@end

@implementation StreamEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.pictureAndVideoArray = [NSMutableArray array];
    self.imagesArray = [NSMutableArray array];
    self.numberOfLikes = [NSMutableArray array];

    [self queryForImages];

    [[self navigationController] setNavigationBarHidden:YES animated:YES];

    //pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    [self.tableView addSubview:refreshControl];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Helper Method

- (void)cameraSetUp
{
    self.cameraController = [[UIImagePickerController alloc] init];
    self.cameraController.delegate = self;
    self.cameraController.allowsEditing = YES;
    self.cameraController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    self.cameraController.videoMaximumDuration = 11;
}


#pragma mark - Getting Pictures and Videos

- (void)queryForImages
{
    [self.pictureAndVideoArray removeAllObjects];
    [self.imagesArray removeAllObjects];

    PFRelation *relation = [self.event relationForKey:@"eventPhotos"];
    PFQuery *query = [relation query];
    [query includeKey:@"photographer"];
    [query includeKey:@"createdAt"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
     {
        if (!error)
        {
            [self.pictureAndVideoArray addObjectsFromArray:results];
        }
        [self createImages];

    }];
}

- (void)createImages
{
    for (PFObject *object in self.pictureAndVideoArray)
    {
        PFFile *file = [object objectForKey:@"photo"];

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

                 [self.imagesArray addObject:resizedImage];
                 [self.tableView reloadData];
             }
             else {
                 NSLog(@"Alert!");
             }
         }];
    }
}

#pragma mark - Action Methods

- (IBAction)onLikeButtonTapped:(UIButton *)sender
{
    PFObject *object = [self.pictureAndVideoArray objectAtIndex:sender.tag];
    PFUser *picturePhotographer = [object objectForKey:@"photographer"];

    PFObject *like = [PFObject objectWithClassName:@"LikeActivity"];
    like[@"fromUser"] = [PFUser currentUser];
    like[@"toUser"] = picturePhotographer;
    like[@"photo"] = object;
    [like saveInBackground];

    //testing like button to see if selected
    if (sender.backgroundColor == [UIColor colorWithPatternImage:[UIImage imageNamed:@"like_selected"]])
    {
        NSLog(@"selected");
        UIImage *btnImage = [UIImage imageNamed:@"like_unselected"];
        [sender setImage:btnImage forState:UIControlStateNormal];

    } else if (sender.backgroundColor == [UIColor colorWithPatternImage:[UIImage imageNamed:@"like_unselected"]])
    {
        NSLog(@"unselected");
        UIImage *btnImage = [UIImage imageNamed:@"like_selected"];
        [sender setImage:btnImage forState:UIControlStateNormal];
    }
}

- (IBAction)onCommentButtonTapped:(UIButton *)sender
{
    PFObject *object = [self.pictureAndVideoArray objectAtIndex:sender.tag];
    self.commentObject = object;
}

#pragma mark - Table View

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = tableView.frame;

    PFObject *object = [self.pictureAndVideoArray objectAtIndex:section];
    PFUser *user = [object objectForKey:@"photographer"];


    //setting time top right
    NSDate *timeOfPicture = [object valueForKey:@"createdAt"];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:timeOfPicture];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger totalTimeForPictures = (hour * 12) + minute;

//    NSTimeInterval secondsElapsed = [ timeIntervalSinceDate:firstDate];

    UILabel *timeInterval = [[UILabel alloc] initWithFrame:CGRectMake(230, 5, 100, 30)];
    timeInterval.text = [NSString stringWithFormat:@"%li min", (long)totalTimeForPictures];

    //setting the username
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 100, 30)];
    title.text = [NSString stringWithFormat:@"%@", user.username];

    PFFile *userProfilePhoto = [user objectForKey:@"userProfilePhoto"];
    UIImageView *customImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
    [userProfilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
             UIImage *image = [UIImage imageWithData:data];
             customImageView.image = image;
             customImageView.layer.cornerRadius = customImageView.bounds.size.width/2;
             customImageView.layer.borderColor = [[UIColor colorWithRed:202/255.0 green:250/255.0 blue:53/255.0 alpha:1] CGColor];
             customImageView.layer.borderWidth = 2.0;
             customImageView.layer.masksToBounds = YES;
         } else {
             customImageView.backgroundColor = [UIColor purpleColor];
         }
     }];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [headerView addSubview:title];
    [headerView addSubview:timeInterval];
    [headerView addSubview:customImageView];
    headerView.backgroundColor = [UIColor blueColor];

    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.pictureAndVideoArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StreamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.theImageView.tag = indexPath.section;
    cell.likeButton.tag = indexPath.section;
    cell.likedImageView.hidden = YES;
    cell.commentButton.tag = indexPath.section;

    cell.theImageView.image = [self.imagesArray objectAtIndex:indexPath.section];


    //getting the number of likes for each photo
    PFQuery *query = [PFQuery queryWithClassName:@"LikeActivity"];
    PFObject *object = [self.pictureAndVideoArray objectAtIndex:indexPath.section];

    [query whereKey:@"photo" equalTo:object];
    [query includeKey:@"fromUser"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         [self.numberOfLikes addObjectsFromArray:objects];

          cell.numberOfLikesLabel.text = [NSString stringWithFormat:@"%lu likes", (unsigned long)objects.count];
     }];

    //double tap to like
    if (cell.theImageView.gestureRecognizers.count == 0)
    {
        UITapGestureRecognizer *tapping = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTap:)];
        tapping.numberOfTapsRequired = 2;
        [cell.theImageView addGestureRecognizer:tapping];
        cell.theImageView.userInteractionEnabled = YES;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

#pragma mark - Tap Gesture Recognizer

- (void)tapTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    UIImageView *sender = (UIImageView *)tapGestureRecognizer.view;

    PFObject *object = [self.pictureAndVideoArray objectAtIndex:sender.tag];
    PFUser *picturePhotographer = [object objectForKey:@"photographer"];

    PFObject *like = [PFObject objectWithClassName:@"LikeActivity"];
    like[@"fromUser"] = [PFUser currentUser];
    like[@"toUser"] = picturePhotographer;
    like[@"photo"] = object;
    [like saveInBackground];

    StreamTableViewCell *cell = (id)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sender.tag]];

    UIImage *btnImage = [UIImage imageNamed:@"like_selected"];
    [cell.likeButton setImage:btnImage forState:UIControlStateNormal];

    //increment count
    NSString *numberOfLikesString = cell.numberOfLikesLabel.text;
    NSInteger numberOfLikesInt = [numberOfLikesString integerValue];
    numberOfLikesInt++;
    cell.numberOfLikesLabel.text = [NSString stringWithFormat:@"%li likes", (long)numberOfLikesInt];



    cell.likedImageView.hidden = NO;

    cell.likedImageView.alpha = 0;

    [UIView animateWithDuration:0.3 animations:^{
        cell.likedImageView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:0.3 delay:0.75 options:0 animations:^{
            cell.likedImageView.alpha = 0;
        } completion:^(BOOL finished) {
            cell.likedImageView.hidden = YES;
        }];
    }];
}


- (IBAction)onPickerButtonTapped:(id)sender
{
    [self cameraSetUp];

    self.cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;

    [self presentViewController:self.cameraController animated:NO completion:^{
        //
    }];
}

- (IBAction)onPhotoLibraryButtonTapped:(id)sender
{
    [self cameraSetUp];

    self.cameraController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:self.cameraController animated:YES completion:^{
        //
    }];
}

#pragma mark - Image Picker

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^
     {
         //back to StreamEventViewController
     }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{

        //NEED TO FIGURE OUT HOW TO SAVE VIDEOS DIFFERENTLY- THIS MIGHT BE TRICKY
        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];

        CGSize sacleSize = CGSizeMake(320, 320);
        UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
        UIImage * resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        NSData *imageData = UIImagePNGRepresentation(resizedImage);
        PFFile *imageFile = [PFFile fileWithData:imageData];

        // Save PFFile
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (!error) {

                 PFObject *photoTaken = [PFObject objectWithClassName:@"Photo"];
                 [photoTaken setObject:imageFile forKey:@"photo"];
                 [photoTaken setObject:[PFUser currentUser] forKey:@"photographer"];
//                 photoTaken[@"caption"] = //

                 [photoTaken saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (!error) {

                          PFRelation *relation = [self.event relationforKey:@"eventPhotos"];
                          [relation addObject:photoTaken];
                          [self.event saveInBackground];

                          //[self dismissViewControllerAnimated:NO completion:nil];

                          [self.tableView reloadData];
                      }
                      else {
                      }
                  }];
             }
         }];
    }];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToCommentViewControllerSegue"])
    {
        CommentsViewController *commentsViewController = segue.destinationViewController;
        commentsViewController.commentObject = self.commentObject;
    }
}


- (IBAction)unwindSegueToStreamEventViewController:(UIStoryboardSegue *)sender
{

}

#pragma mark - Pull To Refresh

- (void)refresh:(UIRefreshControl *)refreshControl
{
    [self queryForImages];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
}

- (void)stopRefresh
{
    [self.refreshControl endRefreshing];
}

@end


//probably do these in the view did load or view will appear?

//- (void)queryForImages
//{
//    [self.pictureAndVideoArray removeAllObjects];
//
//    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
//    [query includeKey:@"photographer"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error)
//        {
//            [self.pictureAndVideoArray addObjectsFromArray:objects];
//        }
//        [self createImages];
//    }];
//}


//- (void)queryForImages
//{
//    [self.pictureAndVideoArray removeAllObjects];
//
//    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
//    [query whereKey:@"objectId" equalTo:self.event.objectId];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error)
//        {
//            [self.pictureAndVideoArray addObjectsFromArray:objects];
//
//
//            //then get the photos from it in a new array and create the images from that
//        }
//        [self createImages];
//    }];
//}
