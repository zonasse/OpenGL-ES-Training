//
//  ViewController.m
//  GPUImage
//
//  Created by 钟奇龙 on 2019/12/5.
//  Copyright © 2019 zonasse.bupt. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) GPUImageSaturationFilter *filter;
@end

@implementation ViewController
- (IBAction)changeSaturation:(UISlider *)sender {
    if (!_filter) {
        _filter = [[GPUImageSaturationFilter alloc] init];
    }
    _filter.saturation = 1.0;
    [_filter forceProcessingAtSize:_image.size];
    
    [_filter useNextFrameForImageCapture];
    _filter.saturation = sender.value;
    
    // 数据源
    GPUImagePicture *stillImageSourcer = [[GPUImagePicture alloc] initWithImage:_image];
    
    [stillImageSourcer addTarget:_filter];
    
    [stillImageSourcer processImage];
    
    UIImage *newImage = [_filter imageFromCurrentFramebuffer];
    
    _imageView.image = newImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"star" ofType:@"jpg"]];
    // Do any additional setup after loading the view.
}



@end
