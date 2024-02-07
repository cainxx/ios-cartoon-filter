//
//  GPUImageFlowBilateralFilter.h
//  test
//
//  Created by cain on 17/4/11.
//  Copyright © 2017年 dlsd. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface GPUImageFlowBilateralFilter : GPUImageTwoInputFilter

@property(assign, nonatomic) CGSize sizeInPixels;
@property(assign, nonatomic) CGFloat sigma_d;
@property(assign, nonatomic) CGFloat sigma_r;
@property(assign, nonatomic) int pass;


@end
