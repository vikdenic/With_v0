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
@property (strong, nonatomic) NSURL *videoUrl;
@property (strong, nonatomic) MPMoviePlayerController *videoController;

@property NSMutableArray *pictureAndVideoArray;
@property NSMutableArray *imagesArray;

@end

@implementation StreamEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.pictureAndVideoArray = [NSMutableArray array];
    self.imagesArray = [NSMutableArray array];

    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self queryForImages];

    [self.tableView reloadData];

    self.cameraController = [[UIImagePickerController alloc] init];
    self.cameraController.delegate = self;
    self.cameraController.allowsEditing = YES;
    self.cameraController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    self.cameraController.videoMaximumDuration = 11;

    self.cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    //    self.cameraController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}


#pragma mark - Getting Pictures and Videos

//probably do these in the view did load or view will appear?

- (void)queryForImages
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query includeKey:@"photographer"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            [self.pictureAndVideoArray addObjectsFromArray:objects];
        }
        [self createImages];
    }];
}

//this is going to be an issue- videos don't need to be created right? might have to separate the calls or something?

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
}

- (IBAction)onCommentButtonTapped:(UIButton *)sender
{
    PFObject *object = [self.pictureAndVideoArray objectAtIndex:sender.tag];
    self.commentObject = object;
}

#pragma mark - Table View

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    PFObject *object = [self.pictureAndVideoArray objectAtIndex:section];
    //outside the bounds of the array

    PFUser *user = [object objectForKey:@"photographer"];
    //in the future we will want to return the users actual name

    return user.username;
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
    [self presentViewController:self.cameraController animated:NO completion:^{
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
    [picker dismissViewControllerAnimated:NO completion:^{

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

                 // Create a PFObject around a PFFile and associate it with the current user
                 PFObject *photoTaken = [PFObject objectWithClassName:@"Photo"];
                 [photoTaken setObject:imageFile forKey:@"photo"];

                 [photoTaken setObject:[PFUser currentUser] forKey:@"photographer"];
//                 photoTaken[@"caption"] = //

                 [photoTaken saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (!error) {

                          [self dismissViewControllerAnimated:self.cameraController completion:nil];
                      }
                      else {
                          NSLog(@"Error: %@ %@", error, [error userInfo]);
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

@end
