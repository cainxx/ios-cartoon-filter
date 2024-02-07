//
//  GPUGaussFilterExpressPassTwo.h
//  test
//
//  Created by cain on 17/4/11.
//  Copyright © 2017年 dlsd. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface GPUGaussFilterExpressPassTwo : GPUImageFilter

@property(assign, nonatomic) CGSize sizeInPixels;
@property(assign, nonatomic) CGFloat sigma;

@end
