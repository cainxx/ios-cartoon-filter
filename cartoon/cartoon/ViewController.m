//
//  ViewController.m
//  test
//
//  Created by cain on 17/4/11.
//  Copyright © 2017年 dlsd. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"
#import "GPUImageSST.h"
#import "GPUGaussFilterExpress.h"
#import "GPUGaussFilterExpressPassTwo.h"
#import "GPUImageFlowBilateralFilter.h"
#import "GPUImageColorQuantization.h"
#import "GPUImageFDOGB.h"
#import "GPUImageFDOGAA.h"
#import "GPUImageBlenderCustomQuanticeLab.h"

@import MobileCoreServices;

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property CGSize imgSize;
@property GPUImagePicture *lookImg;
@property (weak, nonatomic) IBOutlet UIView *gpuContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    return;
}

-(void)viewDidAppear:(BOOL)animated{
    [self process: [UIImage imageNamed:@"test.jpeg"] ];
}
    
-(void)process:(UIImage *)soureImg{

    CGSize size = CGSizeMake(1280, 1280 * (soureImg.size.height/soureImg.size.width));
    UIGraphicsBeginImageContext(size);
    [soureImg drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.imageView.image = img;
    self.imgSize = img.size;
    float arguScale = img.size.width / 559.0;
    
    NSArray *viewsToRemove =  self.gpuContainer.subviews;
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
   
    GPUImageView *gpuImgView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, 375, 375 * (img.size.height/img.size.width) )];
    [self.gpuContainer addSubview:gpuImgView];
    
    GPUImagePicture *gpuPic = [[GPUImagePicture alloc] initWithImage:img];
    GPUImageSST *sstFilter = [[GPUImageSST alloc] init];
    sstFilter.sizeInPixels = self.imgSize;
    [gpuPic addTarget:sstFilter];
    
    GPUGaussFilterExpress *gaussFilter = [[GPUGaussFilterExpress alloc] init];
    gaussFilter.sizeInPixels = self.imgSize;
    gaussFilter.sigma = 2.7 * arguScale;
    [sstFilter addTarget:gaussFilter];
    
    GPUGaussFilterExpressPassTwo *gaussFilterPassTwo = [[GPUGaussFilterExpressPassTwo alloc] init];
    gaussFilterPassTwo.sizeInPixels = self.imgSize;
    gaussFilterPassTwo.sigma = 2.7 * arguScale;
    [gaussFilter addTarget:gaussFilterPassTwo];
    
//    return;
    GPUImageFlowBilateralFilter *flowBilateralFilter = [[GPUImageFlowBilateralFilter alloc] init];
    flowBilateralFilter.sizeInPixels = self.imgSize;
    flowBilateralFilter.sigma_d = 8.64;
    flowBilateralFilter.sigma_r = 0.08 ;
    flowBilateralFilter.pass = 0;
    [gpuPic addTarget:flowBilateralFilter atTextureLocation:0 ];
    [gaussFilterPassTwo addTarget:flowBilateralFilter atTextureLocation:1];
    
    GPUImageFDOGAA *fdogAA = [[GPUImageFDOGAA alloc] init];
    fdogAA.sizeInPixels = self.imgSize;
    fdogAA.mode = 0;
    fdogAA.prethreshold = 1.0 * arguScale;
    fdogAA.threshold = 0.5 * arguScale;
    fdogAA.sigma_r = 3.5035 * arguScale;
    [gaussFilterPassTwo addTarget:fdogAA atTextureLocation:1];
    
    GPUImageColorQuantization *colorQuantization = [[GPUImageColorQuantization alloc] init];
    colorQuantization.mode = 0;
    colorQuantization.sizeInPixels = self.imgSize;
    [flowBilateralFilter addTarget:colorQuantization];
    [flowBilateralFilter addTarget:fdogAA atTextureLocation:0];

    GPUImageSST *sstFilter2 = [[GPUImageSST alloc] init];
    sstFilter2.sizeInPixels = self.imgSize;
    [colorQuantization addTarget:sstFilter2];
    
    GPUImageFDOGB *fdogB = [[GPUImageFDOGB alloc] init];
    fdogB.sizeInPixels = self.imgSize;
    [colorQuantization addTarget:fdogB atTextureLocation:0];
    
    GPUGaussFilterExpress *gaussFilter2 = [[GPUGaussFilterExpress alloc] init];
    gaussFilter2.sizeInPixels = self.imgSize;
    gaussFilter2.sigma = 2.1875 * arguScale;
    [sstFilter2 addTarget:gaussFilter2];
    
    GPUGaussFilterExpressPassTwo *gaussFilterPassTwo2 = [[GPUGaussFilterExpressPassTwo alloc] init];
    gaussFilterPassTwo2.sizeInPixels = self.imgSize;
    gaussFilterPassTwo2.sigma = 2.1875 * arguScale;
    [gaussFilter2 addTarget:gaussFilterPassTwo2];
    [gaussFilterPassTwo2 addTarget:fdogB atTextureLocation:1];

    [colorQuantization addTarget:gpuImgView];
    [gpuPic processImage];

    GPUImageBlenderCustomQuanticeLab *blender = [[GPUImageBlenderCustomQuanticeLab alloc] init];
    blender.sizeInPixels = self.imgSize;
    blender.sigma_r = 3.5 * arguScale;
    [fdogB addTarget:blender atTextureLocation:1];
    [fdogAA addTarget:blender atTextureLocation:0];
    
    GPUImageLookupFilter *lookFilter  = [[GPUImageLookupFilter alloc] init];
    self.lookImg = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"lookup_miss_etikate.png"]];
    [self.lookImg addTarget:lookFilter atTextureLocation:1];
    [self.lookImg processImage];
    [blender addTarget:lookFilter];
    [lookFilter addTarget:gpuImgView];
    [gpuPic processImage];
}


- (IBAction)button:(id)sender {
    //初始化UIImagePickerController类
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = @[(NSString*)kUTTypeImage];
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //获取图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
        [self process:image];
    }];
   
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
