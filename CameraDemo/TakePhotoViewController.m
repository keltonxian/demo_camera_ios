//
//  TakePhotoViewController.m
//  CameraDemo
//
//  Created by xiankelton on 05/11/2016.
//  Copyright © 2016 kelton. All rights reserved.
//

#import "TakePhotoViewController.h"

#define SAVE_IMAGE_FILE_NAME       @"demo_camera_ios.png"
#define SAVE_IMAGE_ORIENTATION_KEY @"key_image_orientation.png"

@interface TakePhotoViewController ()

@end

@implementation TakePhotoViewController

- (IBAction)actionReturn:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"Main"];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)actionChangeCamera:(UIButton *)sender {
    UIImagePickerControllerCameraDevice nori = UIImagePickerControllerCameraDeviceFront;
    UIImagePickerControllerCameraDevice ori = [_picker cameraDevice];
    if (ori == UIImagePickerControllerCameraDeviceFront) {
        nori = UIImagePickerControllerCameraDeviceRear;
    }
    [_picker setCameraDevice:nori];
}

- (IBAction)actionChangeSize:(UIButton *)sender {
    _sizeIndex += 1;
    if (_sizeIndex > 3) {
        _sizeIndex = 1;
    }
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat width = screenSize.width;
    CGFloat height = screenSize.height;
    width = floorf(width / _sizeIndex);
    height = floorf(height / _sizeIndex);
    [self changePreviewSize:CGSizeMake(width, height)];
}

- (IBAction)actionCapture:(UIButton *)sender {
    [_picker takePicture];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _sizeIndex = 1;
    
    // iOS is going to calculate a size which constrains the 4:3 aspect ratio
    // to the screen size. We're basically mimicking that here to determine
    // what size the system will likely display the image at on screen.
    _previewAspectRatio = 4.0 / 3.0;
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        _previewAspectRatio = 1.0;
//    }
    
    // add image view for show captured image
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    [self.view addSubview:imageView];
    [imageView release];
    [self.view sendSubviewToBack:imageView];
    [self updateImage];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self takePhoto];
}

- (void)updateImage {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:SAVE_IMAGE_FILE_NAME];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    if (nil == image) {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    UIImageOrientation imageOrientation = [userDefaults integerForKey:SAVE_IMAGE_ORIENTATION_KEY];
    image = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:imageOrientation];
    //    NSLog(@"image size[%f][%f]", image.size.width, image.size.height);
    _imageView.image = image;
    _imageView.alpha = 1;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGSize imageSize = image.size;
    float scale = screenSize.width / 3 / imageSize.width;
    CGFloat width = imageSize.width * scale;
    CGFloat height = imageSize.height * scale;
    //    NSLog(@"image pos[%f][%f][%f][%f]", screenSize.width - width, screenSize.height - height, width, height);
    [_imageView setFrame:CGRectMake(screenSize.width - width, screenSize.height - height, width, height)];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    NSArray *features = [detector featuresInImage:ciImage];
    //    NSLog(@"features count[%lu]", (unsigned long)[features count]);
    [[_imageView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (CIFaceFeature *faceFeature in features) {
        //将image沿y轴对称
        CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, -1);
        //将image往上移动
        CGFloat imageH = ciImage.extent.size.height;
        transform = CGAffineTransformTranslate(transform, 0, -imageH);
        //在image上画出方框
        CGRect feaRect = faceFeature.bounds;
        //调整后的坐标
        CGRect newFeaRect = CGRectApplyAffineTransform(feaRect, transform);
        //调整imageView的frame
        CGFloat imageViewW = _imageView.bounds.size.width;
        CGFloat imageViewH = _imageView.bounds.size.height;
        CGFloat imageW = ciImage.extent.size.width;
        //显示
        CGFloat scale = MIN(imageViewH / imageH, imageViewW / imageW);
        //缩放
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
        
        //修正
        newFeaRect = CGRectApplyAffineTransform(newFeaRect, scaleTransform);
        newFeaRect.origin.x += (imageViewW - imageW * scale ) / 2;
        newFeaRect.origin.y += (imageViewH - imageH * scale ) / 2;
        
        //绘画
        UIView *breageView = [[UIView alloc] initWithFrame:newFeaRect];
        breageView.layer.borderColor = [UIColor redColor].CGColor;
        breageView.layer.borderWidth = 2;
        [_imageView addSubview:breageView];

        //左眼
        if (faceFeature.hasLeftEyePosition) {
            
        }
        
        //右眼
        if (faceFeature.hasRightEyePosition) {
            
        }
        
        //嘴巴
        if (faceFeature.hasMouthPosition) {
            
        }
    }
}

- (void)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = (id)self;
    _picker = picker;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.showsCameraControls = NO;
    //    [self presentViewController:picker animated:YES completion:^(void) {}];
    [self.view addSubview:picker.view];
    [self.view sendSubviewToBack:picker.view];
    
    [_picker.view setTransform:CGAffineTransformScale(_picker.view.transform, _previewAspectRatio, _previewAspectRatio)];
    CGSize size = [[UIScreen mainScreen] bounds].size;
    [self changePreviewSize:size];
    
}

- (void)changePreviewSize:(CGSize)size {
    CGRect pickerViewBounds = _picker.view.bounds;
    pickerViewBounds.size.width = size.width;
    pickerViewBounds.size.height = pickerViewBounds.size.width*_previewAspectRatio;
    _picker.view.bounds = pickerViewBounds;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    while (width > 1000) {
        width /= 2;
        height /= 2;
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [image drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    image = newImage;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:[image imageOrientation] forKey:SAVE_IMAGE_ORIENTATION_KEY];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:SAVE_IMAGE_FILE_NAME];
    
    // Save image.
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    
    [self updateImage];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
}


@end
