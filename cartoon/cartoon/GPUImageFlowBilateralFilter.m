//
//  GPUImageFlowBilateralFilter.m
//  test
//
//  Created by cain on 17/4/11.
//  Copyright © 2017年 dlsd. All rights reserved.
//

#import "GPUImageFlowBilateralFilter.h"

@implementation GPUImageFlowBilateralFilter

NSString *const kImageFlowBilateralString = SHADER_STRING
(
 
 precision highp float;
 precision highp int;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform highp int pass;
 uniform highp float sigma_d;
 uniform highp float sigma_r;
 uniform highp vec2 size;
 void main (void) {
     if(pass==0){
         float twoSigmaD2 = 2.0 * sigma_d * sigma_d;
         float twoSigmaR2 = 2.0 * sigma_r * sigma_r;
         vec2 uv = gl_FragCoord.xy / size;
         vec2 t = texture2D(inputImageTexture2, uv).zw;
         t=vec2( t.x*2.0-1.0,t.y*2.0-1.0 );
         vec2 dir = vec2(t.y, -t.x) ;
         float ds = 1.0 ;
         dir /= size;
         vec3 center = texture2D(inputImageTexture, uv).rgb;
         vec3 sum = center;
         float norm = 1.0;
         float halfWidth = 2.0 * sigma_d;
         for ( float d = ds; d <= halfWidth; d += ds) {
             vec3 c0 = texture2D(inputImageTexture, uv + d * dir).rgb;
             vec3 c1 = texture2D(inputImageTexture, uv - d * dir).rgb;
             float e0 = length(c0 - center);
             float e1 = length(c1 - center);
             float kerneld = exp( - d *d / twoSigmaD2 );
             float kernele0 = exp( - e0 *e0 / twoSigmaR2 );
             float kernele1 = exp( - e1 *e1 / twoSigmaR2 );
             norm += kerneld * kernele0;
             norm += kerneld * kernele1;
             sum += kerneld * kernele0 * c0;
             sum += kerneld * kernele1 * c1;
         }
         sum /= norm;
         gl_FragColor = vec4(sum, 1.0);
     }else{
         float twoSigmaD2 = 2.0 * sigma_d * sigma_d;
         float twoSigmaR2 = 2.0 * sigma_r * sigma_r;
         vec2 uv = gl_FragCoord.xy / size;
         vec2 t = texture2D(inputImageTexture2, uv).zw;
         t=vec2(t.x*2.0-1.0,t.y*2.0-1.0 );
         vec2 dir = t;
         float ds = 1.0 ;
         dir /= size;
         vec3 center = texture2D(inputImageTexture, uv).rgb;
         vec3 sum = center;
         float norm = 1.0;
         float halfWidth = 2.0 * sigma_d;
         for (float d = ds;  d <= halfWidth;  d += ds) {
             vec3 c0 = texture2D(inputImageTexture, uv + d * dir).rgb;
             vec3 c1 = texture2D(inputImageTexture, uv - d * dir).rgb;
             float e0 = length(c0 - center);
             float e1 = length(c1 - center);
             float kerneld = exp( - d *d / twoSigmaD2 ); 
             float kernele0 = exp( - e0 *e0 / twoSigmaR2 ); 
             float kernele1 = exp( - e1 *e1 / twoSigmaR2 ); 
             norm += kerneld * kernele0; 
             norm += kerneld * kernele1; 
             sum += kerneld * kernele0 * c0; 
             sum += kerneld * kernele1 * c1; 
         } 
         sum /= norm;
         gl_FragColor = vec4(sum, 1.0); 
     } 
 }
 
 );

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kImageFlowBilateralString]))
    {
        return nil;
    }
    return self;
}


- (void)setSizeInPixels:(CGSize)sizeInPixels;
{
    [self setSize:sizeInPixels forUniformName:@"size"];
}

//uniform highp int pass;
//uniform highp float sigma_d;
//uniform highp float sigma_r;
//uniform highp vec2 size;

-(void)setPass:(int)pass{
    [self setInteger:pass forUniformName:@"pass"];
}

-(void)setSigma_d:(CGFloat)sigma_d{
    [self setFloat:sigma_d forUniformName:@"sigma_d"];
}

-(void)setSigma_r:(CGFloat)sigma_r{
    [self setFloat:sigma_r forUniformName:@"sigma_r"];
}


@end
