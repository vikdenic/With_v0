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

@interface StreamEventViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *tableViewView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property UIImagePickerController *cameraController;
@property (strong, nonatomic) NSURL *videoUrl;
@property (strong, nonatomic) MPMoviePlayerController *videoController;

@end

@implementation StreamEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.collectionViewView.hidden = YES;
//    self.collectionView.userInteractionEnabled = NO;
//    self.collectionViewView.alpha = 0;
//    self.tableViewView.hidden = NO;
//    self.tableViewView.alpha = 1;

    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.cameraController = [[UIImagePickerController alloc] init];
    self.cameraController.delegate = self;
    self.cameraController.allowsEditing = YES;
    self.cameraController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    self.cameraController.videoMaximumDuration = 11;

    self.cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    //    self.cameraController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

}

#pragma mark - Action Methods

//- (IBAction)onTableViewButtonTapped:(id)sender
//{
//    self.tableViewView.hidden = NO;
//    self.tableViewView.alpha = 1;
//    self.tableView.userInteractionEnabled = YES;
//    self.collectionViewView.hidden = YES;
//    self.collectionView.userInteractionEnabled = NO;
//    self.collectionViewView.alpha = 0;
//}
//
//- (IBAction)onCollectionViewButtonTapped:(id)sender
//{
//    self.collectionViewView.hidden = NO;
//    self.collectionViewView.alpha = 1;
//    self.collectionView.userInteractionEnabled = YES;
//    self.tableViewView.hidden = YES;
//    self.tableView.userInteractionEnabled = NO;
//    self.tableViewView.alpha = 0;
//}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 100;
    //this is where we reuturn however many pictures. One picture per section
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StreamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    cell.theImageView.tag = indexPath.section;
    cell.likedImageView.hidden = YES;

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

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Blake";
}


//#pragma mark - Collection View
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return 10;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
//    return cell;
//}



#pragma mark - Tap Gesture Recognizer

- (void)tapTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    UIImageView *sender = (UIImageView *)tapGestureRecognizer.view;

//    PFObject *object = [self.pictureObjectsArray objectAtIndex:sender.tag];
//    PFQuery *query = [PFQuery queryWithClassName:@"Pictures"];
//
//    [query getObjectInBackgroundWithId:object.objectId block:^(PFObject *picture, NSError *error) {
//        NSLog(@"%@", object.objectId);
//        PFUser *current = [PFUser currentUser];
//        PFRelation *relation = [picture relationforKey:@"likers"];
//        [relation addObject:current];
//        [picture saveInBackground];
    
        //we are making a relationship between the picture and likers. Then we add the current user to that relation. Then we save the picture in the background because the picture is what all this is getting called on
//    }];

    StreamTableViewCell *cell = (id)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sender.tag]];

    cell.likedImageView.hidden = NO;

    cell.likedImageView.alpha = 0;

    [UIView animateWithDuration:0.3 animations:^{
        cell.likedImageView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:0.3 delay:1.2 options:0 animations:^{
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
        // Segues to SaveViewController after user picks photo
//        self.imageTaken = [info valueForKey:UIImagePickerControllerOriginalImage];

        //       NSData *imageData = UIImagePNGRepresentation(image);

        //just dismiss it
    }];
}
























@end
