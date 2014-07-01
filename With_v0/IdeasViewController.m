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

@end

@implementation IdeasViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.ideaStrings = [[NSArray alloc]initWithObjects:@[@"Nine Hole", @"Mock Wedding",@"Jersey Party",
                                                         @"Pub Crawl",@"Tequila Mockingbird",@""]];

}

#pragma mark - Action
- (IBAction)onBackButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -UITableView

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IdeasTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    cell.themeImageView.image = [UIImage imageNamed:@"pacMan"];

    return cell;
}

@end
