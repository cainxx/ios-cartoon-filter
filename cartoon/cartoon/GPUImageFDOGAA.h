//
//  GPUImageFDOGAA.h
//  test
//
//  Created by cain on 17/4/11.
//  Copyright © 2017年 dlsd. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface GPUImageFDOGAA : GPUImageTwoInputFilter

@property(assign, nonatomic) CGSize sizeInPixels;
@property(assign, nonatomic) int mode;
@property(assign, nonatomic) float prethreshold;
@property(assign, nonatomic) float threshold;
@property(assign, nonatomic) float sigma_r;

@end
