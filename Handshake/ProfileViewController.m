//
//  ProfileViewController.m
//  Handshake
//
//  Created by Shai Bruhis on 10/10/15.
//  Copyright © 2015 Prodigies. All rights reserved.
//

#import "ProfileViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>


@interface ProfileViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *personTextField;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (strong, nonatomic) UIImage *image;

@end

@implementation ProfileViewController

- (void)setupButtonBorder:(UIButton *)button
{
    button.layer.cornerRadius = button.bounds.size.height/2;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor grayColor].CGColor;
    button.clipsToBounds = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.personTextField.delegate = self;
    self.personTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.personTextField.returnKeyType = UIReturnKeyDone;
    
    [self setupButtonBorder:self.addPhotoButton];
    
}

// hides keyboard when clicking "Done" in keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)addPhotoButtonAction:(UIButton *)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePickerController.sourceType = /*UIImagePickerControllerSourceTypeCamera |*/ UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.allowsEditing = YES;
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.image = info[UIImagePickerControllerEditedImage];
    if (!self.image) {
        self.image = info[UIImagePickerControllerOriginalImage];
    }
    
    [self.addPhotoButton setTitle:@"" forState:UIControlStateNormal];
    [self.addPhotoButton setBackgroundImage:self.image forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)meetButtonAction:(UIButton *)sender
{
    
}
@end
