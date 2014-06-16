//
//  StreamEventViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StreamEventViewController.h"

@interface StreamEventViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *collectionViewView;
@property (weak, nonatomic) IBOutlet UIView *tableViewView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@end

@implementation StreamEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.collectionView.hidden = YES;
    self.collectionView.userInteractionEnabled = NO;
    self.collectionView.alpha = 0;
    self.tableView.hidden = NO;

    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

#pragma mark - Action Methods

- (IBAction)onTableViewButtonTapped:(id)sender
{
    self.tableView.hidden = NO;
    self.tableView.alpha = 1;
    self.tableView.userInteractionEnabled = YES;
    self.collectionView.hidden = YES;
    self.collectionView.userInteractionEnabled = NO;
    self.collectionView.alpha = 0;
}

- (IBAction)onCollectionViewButtonTapped:(id)sender
{
    self.collectionView.hidden = NO;
    self.collectionView.alpha = 1;
    self.collectionView.userInteractionEnabled = YES;
    self.tableView.hidden = YES;
    self.tableView.userInteractionEnabled = NO;
    self.tableView.alpha = 0;
}

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
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

@end
