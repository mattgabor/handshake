//
//  LandingScreenViewController.m
//  Handshake
//
//  Created by Shai Bruhis on 10/10/15.
//  Copyright © 2015 Prodigies. All rights reserved.
//

#import "LandingScreenViewController.h"
#import "chooseImageSourceViewController.h"


@interface LandingScreenViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *personTextField;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (strong, nonatomic) UIImage *image;

@end

@implementation LandingScreenViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Seed the random number generator
    sranddev();
    
    // Do any additional setup after loading the view.
    self.personTextField.delegate = self;
    self.personTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.personTextField.returnKeyType = UIReturnKeyDone;
    
    [self setupButtonBorder:self.addPhotoButton];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#pragma mark - reenable for real app, disabled for testing
//    PFUser *currentUser = [PFUser currentUser];
//
//    if (currentUser) {
//        [self performSegueWithIdentifier:@"LandingScreenToHome" sender:self];
//    }
}

#pragma mark - Configure UI

- (void)setupButtonBorder:(UIButton *)button
{
    button.layer.cornerRadius = button.bounds.size.height/2;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor grayColor].CGColor;
    button.clipsToBounds = YES;
}

#pragma mark - UITextFieldDelegate

// hides keyboard when clicking "Done" in keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Actions
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"chooseSourceSegue"]) {
        chooseImageSourceViewController *destVC = (chooseImageSourceViewController *)segue.destinationViewController;
        destVC.parent = self;
    }
}

- (IBAction)addPhotoButtonAction:(UIButton *)sender
{
//    self.imagePickerController = [[UIImagePickerController alloc] init];
//    self.imagePickerController.delegate = self;
//    self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
//    self.imagePickerController.allowsEditing = YES;
}

- (IBAction)meetButtonAction:(UIButton *)sender
{
    // Display loading animation
    [KVNProgress show];
    //[SVProgressHUD show];
    
    // Set up new user on Parse
    PFUser *newUser = [PFUser user];
    
    newUser.username = self.personTextField.text;
    
    newUser.password = @"None";
    
    // 65,536 is 2^16 for the max number of the 16 bit number field
    newUser[@"minor"] = [NSNumber numberWithInt: rand() % 65536];
    
    
    // TODO: Check if name is already taken
    // Log in through Parse
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
     {

         if (!self.image) {
             [self alert:@"No Photo Provided"];
             [KVNProgress showError];
             return;
         }
         else if ([self.personTextField.text isEqualToString:@""]) {
             [self alert:@"No Name Provided"];
             [KVNProgress showError];
             return;
         }

         if (succeeded)
         {
             //[SVProgressHUD showSuccessWithStatus:@"Welcome"];
             [KVNProgress showSuccess];
             [self performSegueWithIdentifier:@"LandingScreenToHome" sender:self];
         }
         else
         {
             NSLog(@"ERROR:::: %@",error.description);
         }
     }];
}

- (void)alert:(NSString *)msg
{
#pragma mark - Shai fix this (http://nshipster.com/uialertcontroller/)
    [[[UIAlertView alloc] initWithTitle:@"Sign Up"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

#pragma mark - UIImagePickerControllerDelegate

#define UNWIND_SEGUE_ID @"Unwind From Image Source"
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:UNWIND_SEGUE_ID]) {
        return YES;
    }
    else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}



-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {}

@end
