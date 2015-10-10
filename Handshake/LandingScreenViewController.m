//
//  LandingScreenViewController.m
//  Handshake
//
//  Created by Shai Bruhis on 10/10/15.
//  Copyright © 2015 Prodigies. All rights reserved.
//

#import "LandingScreenViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>


@interface LandingScreenViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

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
    PFUser *currentUser = [PFUser currentUser];

    if (currentUser) {
        [self performSegueWithIdentifier:@"landingScreenToHome" sender:self];
    }
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

- (IBAction)addPhotoButtonAction:(UIButton *)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera; /*|UIImagePickerControllerSourceTypePhotoLibrary;*/
    imagePickerController.allowsEditing = YES;
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}

//- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"landingScreenToHome"]) {
//        
//    }
//}

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
             [self performSegueWithIdentifier:@"SignInUser" sender:self];
         }
         else
         {
             NSLog(@"ERROR:::: %@",error.description);
         }
     }];
}

//#define UNWIND_SEGUE_ID @"SignInUser"
//- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
//{
//    if ([identifier isEqualToString:UNWIND_SEGUE_ID]) {
//        if (!self.image) {
//            [self alert:@"No Photo Provided"];
//            return NO;
//        }
//        else if ([self.personTextField.text isEqualToString:@""]) {
//            [self alert:@"No Name Provided"];
//            return NO;
//        }
//        else {
//            return YES;
//        }
//    }
//    else {
//        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
//    }
//}

- (void)alert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Sign Up"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.image = info[UIImagePickerControllerEditedImage];
    if (!self.image)
    {
        self.image = info[UIImagePickerControllerOriginalImage];
    }
    [self.addPhotoButton setTitle:@"" forState:UIControlStateNormal];
    [self.addPhotoButton setBackgroundImage:self.image forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
