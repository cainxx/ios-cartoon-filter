//
//  GPUImageDisplacementMapDrawer.h
//  test
//
//  Created by cain on 2017/6/20.
//  Copyright © 2017年 dlsd. All rights reserved.
//

#import "GPUImageFilter.h"

@interface GPUImageDisplacementMapDrawer : GPUImageFilter{
    GLint modelviewUniform;
    GLint projectionUniform;
    GLint textureUniform;
}

@property(assign, nonatomic) int mode;
@property(assign, nonatomic) CGPoint aspectFactor;
@property(assign, nonatomic) CGPoint center;
@property(assign, nonatomic) CGPoint direction;
@property(assign, nonatomic) float scale;
@property(assign, nonatomic) float diameter;
@property(assign, nonatomic) float density;
@property(assign, nonatomic) float pressure;

@property(assign, nonatomic) GPUMatrix4x4 modelview;
@property(assign, nonatomic) GPUMatrix4x4 projection;
@property(assign, nonatomic) GPUMatrix3x3 texture;
@property(assign, nonatomic) GPUVector4 position;
@property(assign, nonatomic) GPUVector3 texcoord;

@end
