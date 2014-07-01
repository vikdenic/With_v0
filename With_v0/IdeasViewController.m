//
//  IdeasViewController.m
//  With_v0
//
//  Created by Vik Denic on 6/30/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "IdeasViewController.h"
#import "IdeasTableViewCell.h"
//#import "ThemeObject.h"
#import <Parse/Parse.h>

@interface IdeasViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *ideaStrings;
@property (strong, nonatomic) NSMutableArray *ideaImages;
@property (strong, nonatomic) NSMutableArray *ideas;


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation IdeasViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.ideaStrings = [[NSMutableArray alloc]init];
    self.ideaImages = [[NSMutableArray alloc]init];

    self.ideas = [[NSMutableArray alloc]init];

    [self getParseData];
}

//make custom object with sort property
#pragma mark - Parse
-(void)getParseData
{
    PFQuery *query = [PFQuery queryWithClassName:@"Idea"];

    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
     {
//         NSLog(@"%@",results);
        for (PFObject *object in results)
        {
            ThemeObject *themeObject = [[ThemeObject alloc]init];
            NSString *themeName = [object objectForKey:@"themeName"];
            NSString *themeDeets = [object objectForKey:@"themeDeets"];

//            [self.ideaStrings addObject:themeName];
//            NSLog(@"%@",themeName);
            themeObject.themeName = themeName;
            themeObject.themeDeets = themeDeets;

            PFFile *imageFile = [object objectForKey:@"themeImage"];
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                UIImage *themeImage = [UIImage imageWithData:data];
//                [self.ideaImages addObject:themeImage];
//                NSLog(@"%d",self.ideaImages.count);
                themeObject.themeImage = themeImage;

                [self.ideas addObject:themeObject];
                [self.tableView reloadData];
            }];
        }
    }];
}

#pragma mark - Action
- (IBAction)onBackButtonPressed:(id)sender
{
    self.ideaStrings = nil;
    self.ideaImages = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -UITableView

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ideas.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IdeasTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    cell.themeLabel.text = [[self.ideas objectAtIndex:indexPath.row] themeName];

    cell.themeImageView.image = [[self.ideas objectAtIndex:indexPath.row] themeImage];

    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.themeObject = [self.ideas objectAtIndex:indexPath.row];

//    NSLog(@"CHCKN SELECTS %@",self.themeObject.themeName);
    return indexPath;
}

@end
