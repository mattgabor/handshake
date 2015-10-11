//
//  chooseImageSourceViewController.m
//  Handshake
//
//  Created by Matthew Gabor on 10/10/15.
//  Copyright © 2015 Prodigies. All rights reserved.
//

#import "chooseImageSourceViewController.h"
#import "LandingScreenViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>


@interface chooseImageSourceViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

//@property (nonatomic, readwrite) UIImagePickerControllerSourceType sourceType;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;


@end

@implementation chooseImageSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)chooseSourceAction:(UIButton *)sender {
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    self.imagePickerController.allowsEditing = YES;
    if ([sender.titleLabel.text isEqualToString:@"Take Photo"]) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else if ([sender.titleLabel.text isEqualToString:@"Choose Photo"]) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:self.imagePickerController animated:YES completion:NULL];
}

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
//    [self.addPhotoButton setTitle:@"" forState:UIControlStateNormal];
//    [self.addPhotoButton setBackgroundImage:self.image forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

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




@end
