//
//  chooseImageSourceViewController.h
//  Handshake
//
//  Created by Matthew Gabor on 10/10/15.
//  Copyright © 2015 Prodigies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LandingScreenViewController.h"

@interface chooseImageSourceViewController : UIViewController
// in
@property (nonatomic, strong) LandingScreenViewController *parent;

// out
//@property (nonatomic, strong) UIImagePickerControllerSourceType sourceType;
@property (strong, nonatomic) UIImage *image;

@end
