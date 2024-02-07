//
//  GPUImageFDOGAA.m
//  test
//
//  Created by cain on 17/4/11.
//  Copyright © 2017年 dlsd. All rights reserved.
//

#import "GPUImageFDOGAA.h"

@implementation GPUImageFDOGAA

NSString *const kImageFDOGAAString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 precision highp float;
 precision highp int;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 precision highp float;
 precision highp int;
 uniform highp float prethreshold;
 uniform highp float threshold;
 uniform int mode;
 float sigma_e=1.0;
 uniform float sigma_r;
 float tau=0.99;
 uniform vec2 size;
 void main() {
     float twoSigmaG1 = 2.0 * sigma_e * sigma_e;
     float twoSigmaG2 = 2.0 * sigma_r * sigma_r;
     float ancho = 2.0 * sigma_r;
     vec2 uv = gl_FragCoord.xy / size;
     vec2 gradient = texture2D(inputImageTexture2, uv).zw;
     vec2 dirPerpen = vec2(gradient.y*2.0-1.0, -(gradient.x*2.0-1.0))/size;
     vec2 acum = texture2D( inputImageTexture, uv ).xx;
     vec2 norm = vec2(1.0, 1.0);
     for( float i = 1.0;i <= ancho;i ++ ) {
         vec2 kernel = vec2( exp( -i*i*i/ twoSigmaG1 ), exp( -i*i*i / twoSigmaG2 ));
         norm += 2.0* kernel;
         float local = texture2D( inputImageTexture, uv - i*dirPerpen ).x+texture2D( inputImageTexture, uv + i*dirPerpen ).x;
         acum += kernel*vec2(local,local);
     }
     acum = acum/norm;
     float total = (300.0*prethreshold) * (acum.x - tau * acum.y);
     if(mode==0){
         gl_FragColor = vec4( (step (0.8, total ) ),gradient, 1.0);
     }else if(mode==2){
         float tt=texture2D(inputImageTexture, textureCoordinate).x*100.0;
         float redbase = floor(tt/16.0)*(0.10+threshold*0.2);
         gl_FragColor = vec4(min(total , redbase),gradient ,1.0);
     }
 }
 
 );

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kImageFDOGAAString]))
    {
        return nil;
    }
    return self;
}

- (void)setSizeInPixels:(CGSize)sizeInPixels;
{
    [self setSize:sizeInPixels forUniformName:@"size"];
}

-(void)setMode:(int)mode{
    [self setInteger:mode forUniformName:@"mode"];
}

-(void)setPrethreshold:(float)prethreshold{
    [self setFloat:prethreshold forUniformName:@"prethreshold"];
}

-(void)setThreshold:(float)threshold{
    [self setFloat:threshold forUniformName:@"threshold"];
}

-(void)setSigma_r:(float)sigma_r{
    [self setFloat:sigma_r forUniformName:@"sigma_r"];
}

@end
