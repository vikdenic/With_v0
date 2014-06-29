//
//  LoginViewController.m
//  Ribbit
//
//  Created by Ben Jakuben on 7/30/13.
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.hidesBackButton = YES;

    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Log In"
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];

    [self.usernameField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];

    [self.passwordField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];

    self.navigationController.navigationBarHidden = YES;
}

// Dismisses billTextField's keyboard upon tap-away

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (IBAction)login:(id)sender {
    NSString *username = [[self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]lowercaseString];
    NSString *password = [[self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]lowercaseString];
    
    if ([username length] == 0 || [password length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Make sure you enter a username and password!"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                                    message:[error.userInfo objectForKey:@"error"]
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
            else {

                //DISMISS LOG-IN SO TABBAR ISNT HIDDEN ANYMORE
                [self dismissViewControllerAnimated:YES completion:^{
                }];

                //TRYING TO GET TO HOME FEED
                [self.navigationController popToRootViewControllerAnimated:YES];
                [self.tabBarController setSelectedIndex:0];
                self.navigationController.navigationBarHidden = NO;
            }
        }];
    }
}

-(IBAction)unwindFromRegisterToLogIn:(UIStoryboardSegue *)sender
{
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];

}

@end
