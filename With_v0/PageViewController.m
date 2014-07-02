//
//  PageViewController.m
//  With_v0
//
//  Created by Blake Mitchell on 6/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "PageViewController.h"
#import "IndividualEventViewController.h"
#import "StreamEventViewController.h"
#import "ChatEventViewController.h"

@interface PageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property IndividualEventViewController *individualViewController;
@property StreamEventViewController *streamEventViewController;

@property NSArray *viewControllerArray;

@end

@implementation PageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    [self setupScene];
    [self setupPageControl];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)setupScene
{
    self.individualViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IndividualEventViewController"];

    self.individualViewController.event = self.event;

    self.streamEventViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StreamEventViewController"];

    self.streamEventViewController.event = self.event;

    self.viewControllerArray = [NSArray arrayWithObjects:self.individualViewController,self.streamEventViewController, nil];

    [self setViewControllers:@[self.viewControllerArray.firstObject]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
}

- (void)setupPageControl
{

    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor purpleColor];
    pageControl.backgroundColor = [UIColor clearColor];

}

#pragma mark - Page View Controller Data Source

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.viewControllerArray.count;
}


-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
     viewControllerBeforeViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[IndividualEventViewController class]])
    {
        return nil;

    } else if ([viewController isKindOfClass:[StreamEventViewController class]])
    {
        return self.viewControllerArray[0];
    } else
    {
        return nil;
    }
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerAfterViewController:(UIViewController *)viewController
{

    if ([viewController isKindOfClass:[IndividualEventViewController class]])
    {
        return self.viewControllerArray[1];

    } else if ([viewController isKindOfClass:[StreamEventViewController class]])
    {
        return nil;

    } else {
        return nil;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToChatSegue"])
    {
        ChatEventViewController *chatEventViewController = segue.destinationViewController;
        chatEventViewController.event = self.event;
    }
}


//- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
//{
//    if ([previousViewControllers[0] isKindOfClass:[IndividualEventViewController class]])
//    {
//        self.title = @"Individual";
//
//    } else if ([previousViewControllers[0] isKindOfClass:[ChatEventViewController class]])
//    {
//        self.title = @"Chat";
//
//    } else
//    {
//        self.title = @"Favorites";
//    }
//}


@end
