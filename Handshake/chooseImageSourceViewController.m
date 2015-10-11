//
//  chooseImageSourceViewController.m
//  Handshake
//
//  Created by Matthew Gabor on 10/10/15.
//  Copyright © 2015 Prodigies. All rights reserved.
//

#import "chooseImageSourceViewController.h"
#import "LandingScreenViewController.h"

@interface chooseImageSourceViewController ()

//@property (nonatomic, readwrite) UIImagePickerControllerSourceType sourceType;

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
    if ([sender.titleLabel.text isEqualToString:@"Take Photo"]) {
        self.parent.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else if ([sender.titleLabel.text isEqualToString:@"Choose Photo"]) {
        self.parent.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:self.parent.imagePickerController animated:YES completion:NULL];
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
