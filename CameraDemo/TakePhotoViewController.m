//
//  TakePhotoViewController.m
//  CameraDemo
//
//  Created by xiankelton on 05/11/2016.
//  Copyright © 2016 kelton. All rights reserved.
//

#import "TakePhotoViewController.h"

@interface TakePhotoViewController ()

@end

@implementation TakePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self showTakePhotoView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showTakePhotoView {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = (id)self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.showsCameraControls = NO;
    [self presentViewController:picker animated:YES completion:^(void) {
        
    }];
}


@end
