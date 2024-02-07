//
//  GPUGaussFilterExpressPassTwo.m
//  test
//
//  Created by cain on 17/4/11.
//  Copyright © 2017年 dlsd. All rights reserved.
//

#import "GPUGaussFilterExpressPassTwo.h"

@implementation GPUGaussFilterExpressPassTwo

NSString *const kImageGaussFilterPassTwoString = SHADER_STRING
(
 precision highp float;
 precision highp int;
 uniform sampler2D inputImageTexture;
 uniform highp vec2 size;
 uniform highp float sigma ;
 void main (void) {
     vec2 uv = gl_FragCoord.xy / size;
     highp float twoSigma2 = 2.0 *sigma*sigma;
     highp float halfWidth = 2.0*sigma;
     highp vec3 acum = texture2D(inputImageTexture, uv ).rgb;
     float norm = 1.0;
     for ( float i = 1.0;i <= halfWidth;i++ ) {
         float kern = exp( -(i*i)/ twoSigma2 );
         vec3 loca = texture2D(inputImageTexture, uv + vec2(0.0,i) / size).rgb+texture2D(inputImageTexture, uv + vec2(0.0,-i) / size).rgb;
         norm += 2.0*kern;
         acum += kern * loca;
     }
     acum= acum/norm;
     float g = (acum.z*2.0-1.0) ;
     float phi=3.1415926+ 0.5 * atan(-2.0 * g, acum.y - acum.x);
     gl_FragColor =vec4( 0.0,phi/(3.1415926*2.0),(cos(phi)+1.0)*0.5 , (sin(phi)+1.0)*0.5) ;
 }
 
 );

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kImageGaussFilterPassTwoString]))
    {
        return nil;
    }
    return self;
}


- (void)setSizeInPixels:(CGSize)sizeInPixels;
{
    [self setSize:sizeInPixels forUniformName:@"size"];
}

-(void)setSigma:(CGFloat)sigma{
    [self setFloat:sigma forUniformName:@"sigma"];
}


@end
