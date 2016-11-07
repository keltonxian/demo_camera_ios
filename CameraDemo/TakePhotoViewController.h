//
//  TakePhotoViewController.h
//  CameraDemo
//
//  Created by xiankelton on 05/11/2016.
//  Copyright © 2016 kelton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TakePhotoViewController : UIViewController {
    UIImagePickerController *_picker;
    UIImageView *_imageView;
    int _sizeIndex;
    float _previewAspectRatio;
}


@end

