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
#import "IndividualEventPhoto.h"
#import "GKImagePicker.h"
#import "StreamProfileViewController.h"
#import "LikeListViewController.h"

@interface StreamEventViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GKImagePickerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSURL *videoUrl;
@property (strong, nonatomic) MPMoviePlayerController *videoController;
@property (strong, nonatomic) GKImagePicker *imagePicker;
@property (strong, nonatomic) UIPopoverController *popoverController;

@property (nonatomic) CGRect originalFrame;
@property UIImagePickerController *cameraController;
@property PFFile *selectedImageFile;
@property UIRefreshControl *refreshControl;
@property NSMutableArray *theLegitArrayOfEverything;

@property int section;

@end

@implementation StreamEventViewController

@synthesize imagePicker;
@synthesize popoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self queryForImages];

//    self.originalFrame = self.tabBarController.tabBar.frame;

    self.theLegitArrayOfEverything = [NSMutableArray array];

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

//#pragma mark - Hide TabBar
//
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    UITabBar *tb = self.tabBarController.tabBar;
//    NSInteger yOffset = scrollView.contentOffset.y;
//    if (yOffset > 0) {
//        tb.frame = CGRectMake(tb.frame.origin.x, self.originalFrame.origin.y + yOffset, tb.frame.size.width, tb.frame.size.height);
//    }
//    if (yOffset < 1) tb.frame = self.originalFrame;
//}

#pragma mark - Getting Pictures and Videos

- (void)queryForImages
{
    [self.theLegitArrayOfEverything removeAllObjects];

    PFRelation *relation = [self.event relationForKey:@"eventPhotos"];
    PFQuery *query = [relation query];
    [query includeKey:@"photographer"];
    [query includeKey:@"createdAt"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
     {
         if (!error)
         {
             for (PFObject *object in results)
             {
                 PFRelation *relation2 = [object relationForKey:@"likeActivity"];
                 PFQuery *query2 = [relation2 query];
                 [query includeKey:@"fromUser"];

                 [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                  {
                      IndividualEventPhoto *individualEventPhoto = [[IndividualEventPhoto alloc]init];

                      individualEventPhoto.likes = [objects mutableCopy];

                      PFFile *file = [object objectForKey:@"photo"];
                      individualEventPhoto.photo = file;
                      individualEventPhoto.object = object;
                      individualEventPhoto.photographerPhoto = [[object objectForKey:@"photographer"] objectForKey:@"userProfilePhoto"];
                      individualEventPhoto.username = [[object objectForKey:@"photographer"] objectForKey:@"username"];

                      PFUser *photographer = [object objectForKey:@"photographer"];
                      individualEventPhoto.photographer = photographer;

                      [self.theLegitArrayOfEverything addObject:individualEventPhoto];
                      ///if statement here to only reload once count equals count

                      if (self.theLegitArrayOfEverything.count == results.count)
                      {
                          [self.tableView reloadData];
                      }
                 }];
            }
        }
    }];
}

#pragma mark - Action Methods

- (IBAction)onLikeButtonTapped:(UIButton *)sender
{
    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"like_unselected"]])
    {

        UIImage *btnImage = [UIImage imageNamed:@"like_selected"];
        [sender setImage:btnImage forState:UIControlStateNormal];

        IndividualEventPhoto *individualEventPhoto = [self.theLegitArrayOfEverything objectAtIndex:sender.tag];
        PFUser *picturePhotographer = [individualEventPhoto.object objectForKey:@"photographer"];

        PFObject *like = [PFObject objectWithClassName:@"LikeActivity"];
        like[@"fromUser"] = [PFUser currentUser];
        like[@"toUser"] = picturePhotographer;
        like[@"photo"] = individualEventPhoto.object;
        [like saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             PFRelation *relation = [individualEventPhoto.object relationforKey:@"likeActivity"];
             [relation addObject:like];
             [individualEventPhoto.object saveInBackground];
         }];

        StreamTableViewCell *cell = (id)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sender.tag]];

        //increment count
        NSString *numberOfLikesString = [cell.numberOfLikesButton titleForState:UIControlStateNormal];
        NSInteger numberOfLikesInt = [numberOfLikesString integerValue];


        if (numberOfLikesInt == 0)
        {
            numberOfLikesInt++;

            [cell.numberOfLikesButton setTitle:[NSString stringWithFormat:@"%li like", (long)numberOfLikesInt] forState:UIControlStateNormal];
        } else
        {
            numberOfLikesInt++;
            [cell.numberOfLikesButton setTitle:[NSString stringWithFormat:@"%li like", (long)numberOfLikesInt] forState:UIControlStateNormal];
        }

    }
    else if ([sender.imageView.image isEqual:[UIImage imageNamed:@"like_selected"]])
    {
        UIImage *btnImage = [UIImage imageNamed:@"like_unselected"];
        [sender setImage:btnImage forState:UIControlStateNormal];

        IndividualEventPhoto *individualEventPhoto = [self.theLegitArrayOfEverything objectAtIndex:sender.tag];

        PFRelation *relation2 = [individualEventPhoto.object relationForKey:@"likeActivity"];
        PFQuery *query2 = [relation2 query];
        [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             for (PFObject *object in objects)
             {
                 [object deleteInBackground];
             }
             
        }];

        StreamTableViewCell *cell = (id)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sender.tag]];

        //decrement count
        NSString *numberOfLikesString = [cell.numberOfLikesButton titleForState:UIControlStateNormal];
        NSInteger numberOfLikesInt = [numberOfLikesString integerValue];

        if (numberOfLikesInt == 1)
        {
            numberOfLikesInt--;
            [cell.numberOfLikesButton setTitle:[NSString stringWithFormat:@"%li like", (long)numberOfLikesInt] forState:UIControlStateNormal];

        }else if (numberOfLikesInt == 2)
        {
            numberOfLikesInt--;
            [cell.numberOfLikesButton setTitle:[NSString stringWithFormat:@"%li like", (long)numberOfLikesInt] forState:UIControlStateNormal];
        }
        else
        {
            numberOfLikesInt--;
            [cell.numberOfLikesButton setTitle:[NSString stringWithFormat:@"%li like", (long)numberOfLikesInt] forState:UIControlStateNormal];
        }

        ///need to remove relation
    }
}

- (IBAction)onCommentButtonTapped:(UIButton *)sender
{
    IndividualEventPhoto *individualEventPhoto = [self.theLegitArrayOfEverything objectAtIndex:sender.tag];
    self.individualEventPhoto = individualEventPhoto;
}

#pragma mark - Table View

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = tableView.frame;

    IndividualEventPhoto *individualEventPhoto = [self.theLegitArrayOfEverything objectAtIndex:section];


    //setting time top right
    NSDate *timeOfPicture = [individualEventPhoto.object valueForKey:@"createdAt"];
    int seconds = -(int)[timeOfPicture timeIntervalSinceNow];
    int minutes = seconds/60;

    UILabel *timeInterval = [[UILabel alloc] initWithFrame:CGRectMake(280, 5, 60, 30)];
    timeInterval.textColor = [UIColor whiteColor];

        if (minutes < 60) {
            timeInterval.text = [NSString stringWithFormat:@"%im", minutes];
        } else if (minutes > 60 && minutes < 1440)
        {
            minutes = minutes/60;
            timeInterval.text = [NSString stringWithFormat:@"%ih", minutes];
        } else {
            minutes = minutes/1440;
            timeInterval.text = [NSString stringWithFormat:@"%id", minutes];
        }

    //setting the username
    UIButton *title = [[UIButton alloc] initWithFrame:CGRectMake(50, 5, 100, 30)];
    [title setTitle:[NSString stringWithFormat:@"%@", individualEventPhoto.username] forState:UIControlStateNormal];
    [title setTintColor:[UIColor whiteColor]];
    title.tag = section;
    [title addTarget:self action:@selector(onButtonTitlePressed:) forControlEvents:UIControlEventTouchUpInside];

    UIImageView *customImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
    customImageView.layer.cornerRadius = customImageView.bounds.size.width/2;
    customImageView.layer.borderColor = [[UIColor colorWithRed:202/255.0 green:250/255.0 blue:53/255.0 alpha:1] CGColor];
    customImageView.layer.borderWidth = 2.0;
    customImageView.layer.masksToBounds = YES;
    [individualEventPhoto.photographerPhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
             UIImage *image = [UIImage imageWithData:data];
             customImageView.image = image;
         } else {
             customImageView.backgroundColor = [UIColor purpleColor];
         }
     }];

    //TRY TO SET THIS HEADERVIEW TO "STREAM_BLUR_IMAGE"
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    headerView.alpha = .7;
    [headerView addSubview:title];
    [headerView addSubview:timeInterval];
    [headerView addSubview:customImageView];
    headerView.backgroundColor = [UIColor blackColor];

    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.theLegitArrayOfEverything.count;
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

    cell.numberOfLikesButton.tag = indexPath.section;
    [cell.numberOfLikesButton addTarget:self action:@selector(onNumberOfLikesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.numberOfLikesButton setTintColor:[UIColor blackColor]];

    IndividualEventPhoto *individualEventPhoto = [self.theLegitArrayOfEverything objectAtIndex:indexPath.section];

    PFRelation *relation2 = [individualEventPhoto.object relationForKey:@"likeActivity"];
    PFQuery *query2 = [relation2 query];
    [query2 countObjectsInBackgroundWithBlock:^(int number, NSError *error)
    {
        if (number == 1)
        {
          [cell.numberOfLikesButton setTitle:[NSString stringWithFormat:@"%i like", number] forState:UIControlStateNormal];

        } else
        {
          [cell.numberOfLikesButton setTitle:[NSString stringWithFormat:@"%i likes", number] forState:UIControlStateNormal];        }
    }];

    [individualEventPhoto.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
             UIImage *temporaryImage = [UIImage imageWithData:data];
             cell.theImageView.image = temporaryImage;
//             cell.theImageView.contentMode = UIViewContentModeScaleAspectFit;
         }
     }];

    //checking to see if current user has liked photo
    UIImage *btnImage = [UIImage imageNamed:@"like_unselected"];
    [cell.likeButton setImage:btnImage forState:UIControlStateNormal];

    for (PFObject *object in individualEventPhoto.likes)
    {
        NSString *fromUserObjectId = [[object objectForKey:@"fromUser"] objectId];
        NSString *currentUser = [[PFUser currentUser] objectId];

        if ([fromUserObjectId isEqualToString:currentUser])
        {
            UIImage *btnImage = [UIImage imageNamed:@"like_selected"];
            [cell.likeButton setImage:btnImage forState:UIControlStateNormal];
            break;
        }
    }

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

    StreamTableViewCell *cell = (id)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sender.tag]];

    if ([cell.likeButton.imageView.image isEqual:[UIImage imageNamed:@"like_selected"]])
    {

    } else {
        UIImageView *sender = (UIImageView *)tapGestureRecognizer.view;

        IndividualEventPhoto *individualEventPhoto = [self.theLegitArrayOfEverything objectAtIndex:sender.tag];
        PFUser *picturePhotographer = [individualEventPhoto.object objectForKey:@"photographer"];

        PFObject *like = [PFObject objectWithClassName:@"LikeActivity"];
        like[@"fromUser"] = [PFUser currentUser];
        like[@"toUser"] = picturePhotographer;
        like[@"photo"] = individualEventPhoto.object;
        [like saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             PFRelation *relation = [individualEventPhoto.object relationforKey:@"likeActivity"];
             [relation addObject:like];
             [individualEventPhoto.object saveInBackground];
         }];

        UIImage *btnImage = [UIImage imageNamed:@"like_selected"];
        [cell.likeButton setImage:btnImage forState:UIControlStateNormal];

        //increment count
        NSString *numberOfLikesString = [cell.numberOfLikesButton titleForState:UIControlStateNormal];
        NSInteger numberOfLikesInt = [numberOfLikesString integerValue];

        if (numberOfLikesInt == 0)
        {
            numberOfLikesInt++;
            [cell.numberOfLikesButton setTitle:[NSString stringWithFormat:@"%li like", (long)numberOfLikesInt] forState:UIControlStateNormal];
        } else
        {
            numberOfLikesInt++;
            [cell.numberOfLikesButton setTitle:[NSString stringWithFormat:@"%li likes", (long)numberOfLikesInt] forState:UIControlStateNormal];
        }

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
}

- (void)onButtonTitlePressed:(UIButton *)sender
{
    self.section = (int)sender.tag;
    [self performSegueWithIdentifier:@"StreamToProfile" sender:self];
}

- (void)onNumberOfLikesButtonPressed: (UIButton *)sender
{
    self.section = (int)sender.tag;
    [self performSegueWithIdentifier:@"LikesLabelToLikeList" sender:self];
}

#pragma mark - Helper Method

- (void)cameraSetUp
{
   self.cameraController = [[UIImagePickerController alloc] init];
   self.cameraController.delegate = self;
   self.cameraController.allowsEditing = YES;
    self.cameraController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];

    ///put this back in for video
//   self.cameraController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
//    self.cameraController.videoMaximumDuration = 11;
}

#pragma mark - Image Picker

- (IBAction)onPickerButtonTapped:(id)sender
{
    [self cameraSetUp];

   self.cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
   [self presentViewController:self.cameraController animated:NO completion:^{

  }];
}

- (IBAction)onPhotoLibraryButtonTapped:(id)sender
{
    //    [self presentViewController:self.cameraController animated:NO completion:nil];
    self.imagePicker = [[GKImagePicker alloc] init];
    self.imagePicker.cropSize = CGSizeMake(320, 320);
    self.imagePicker.delegate = self;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker.imagePickerController];
//        [self.popoverController presentPopoverFromRect:tapGestureRecognizer.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    } else {

//        [self presentModalViewController:self.imagePicker.imagePickerController animated:YES];
        [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
    }
}

-(void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image
{
    //THEME IMAGE FOR HOMEPAGE
    CGSize scaledSize = CGSizeMake(320, 320);
    UIGraphicsBeginImageContextWithOptions(scaledSize, NO, 0.0);

    [image drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.05f);
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
                      NSLog(@"Error");
                  }
              }];
         }
     }];
    [self hideImagePicker];
}

- (void)hideImagePicker{
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {

        [self.popoverController dismissPopoverAnimated:YES];

    } else {

        [self.imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    }
}

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

    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
//
//    CGSize sacleSize = CGSizeMake(320, 320);
//    UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
//    [image drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
//    UIImage * resizedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();

        CGSize size = image.size;

        // Crop the crop rect that the user selected
        CGRect cropRect = [[info objectForKey:UIImagePickerControllerCropRect]
                           CGRectValue];

        // Create a graphics context of the correct size
        UIGraphicsBeginImageContext(cropRect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();

        // Correct for image orientation
        UIImageOrientation orientation = [image imageOrientation];
        if(orientation == UIImageOrientationUp) {
            CGContextTranslateCTM(context, 0, size.height);
            CGContextScaleCTM(context, 1, -1);
            cropRect = CGRectMake(cropRect.origin.x,
                                  -cropRect.origin.y,
                                  cropRect.size.width,
                                  cropRect.size.height);
        } else if(orientation == UIImageOrientationRight) {
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextRotateCTM(context, -M_PI/2);
            size = CGSizeMake(size.height, size.width);
            cropRect = CGRectMake(cropRect.origin.y,
                                  cropRect.origin.x,
                                  cropRect.size.height,
                                  cropRect.size.width);
        } else if(orientation == UIImageOrientationDown) {
            CGContextTranslateCTM(context, size.width, 0);
            CGContextScaleCTM(context, -1, 1);
            cropRect = CGRectMake(-cropRect.origin.x,
                                  cropRect.origin.y,
                                  cropRect.size.width,
                                  cropRect.size.height);
        }

        // Draw the image in the correct place
        CGContextTranslateCTM(context, -cropRect.origin.x, -cropRect.origin.y);
        CGContextDrawImage(context,
                           CGRectMake(0,0, size.width, size.height),
                           image.CGImage);

        // Pull out the cropped image
        UIImage *imageTaken = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();


    NSData *imageData = UIImageJPEGRepresentation(imageTaken, 0.05f);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (!error) {

                 PFObject *photoTaken = [PFObject objectWithClassName:@"Photo"];
                 [photoTaken setObject:imageFile forKey:@"photo"];
                 [photoTaken setObject:[PFUser currentUser] forKey:@"photographer"];
                 [photoTaken saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (!error) {

                          PFRelation *relation = [self.event relationforKey:@"eventPhotos"];
                          [relation addObject:photoTaken];
                          [self.event saveInBackground];
                          [self.tableView reloadData];
                      }
                      else
                      {
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
        commentsViewController.individualEventPhoto = self.individualEventPhoto;

    } else if ([segue.identifier isEqualToString:@"StreamToProfile"])
    {
        StreamProfileViewController *streamProfileViewController = segue.destinationViewController;
        IndividualEventPhoto *individualEventPhoto = [self.theLegitArrayOfEverything objectAtIndex:self.section];
        PFUser *userToPass = individualEventPhoto.photographer;
        streamProfileViewController.userToPass = userToPass;

    } else if ([segue.identifier isEqualToString:@"LikesLabelToLikeList"])
    {
        IndividualEventPhoto *individualEventPhoto = [self.theLegitArrayOfEverything objectAtIndex:self.section];

        LikeListViewController *likesListViewController = segue.destinationViewController;
        likesListViewController.individualEventPhoto = individualEventPhoto;

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

