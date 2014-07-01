//
//  IdeasViewController.m
//  With_v0
//
//  Created by Vik Denic on 6/30/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "IdeasViewController.h"
#import "IdeasTableViewCell.h"

@interface IdeasViewController () <UITableViewDelegate, UITableViewDataSource>

@property NSArray *ideaStrings;
@property NSArray *ideaImages;


@end

@implementation IdeasViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.ideaStrings = @[@"Glow Party", @"Pub Crawl", @"Nine Hole",
                         @"Mock Wedding", @"Tequila Mockingbird"];

    self.ideaImages = @[[UIImage imageNamed:@"glow_image"],[UIImage imageNamed:@"pub_image"],[UIImage imageNamed:@"golf_image"],[UIImage imageNamed:@"wedding_image"], [UIImage imageNamed:@"tequilla_image"]];
}

#pragma mark - Action
- (IBAction)onBackButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -UITableView

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ideaStrings.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IdeasTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    cell.themeImageView.image = [self.ideaImages objectAtIndex:indexPath.row];

    cell.themeLabel.text = [self.ideaStrings objectAtIndex:indexPath.row];

    return cell;
}

@end
