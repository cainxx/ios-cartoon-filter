//
//  GPUGaussFilterExpress.m
//  test
//
//  Created by cain on 17/4/11.
//  Copyright © 2017年 dlsd. All rights reserved.
//

#import "GPUGaussFilterExpress.h"

@implementation GPUGaussFilterExpress

NSString *const kImageGaussFilterString = SHADER_STRING
(
 precision highp float;
 precision highp int;
 uniform sampler2D inputImageTexture;
 uniform highp vec2 size;
 uniform highp float sigma ;
 void main (void) {
     vec2 uv = gl_FragCoord.xy / size;
     highp float twoSigma2 = 2.0 * (sigma )*(sigma );
     highp float halfWidth = 2.0* sigma;
     highp vec3 acum = texture2D(inputImageTexture, uv ).rgb;
     float norm = 1.0;
     for ( float i = 1.0;i <= halfWidth;i++ ) {
         float kern = exp( -i*i/ twoSigma2 );
         vec3 loca = texture2D(inputImageTexture, uv + vec2(i,0.0) / size).rgb+texture2D(inputImageTexture, uv + vec2(-i,0.0) / size).rgb;
         norm += 2.0*kern;
         acum += kern * loca;
     }
     acum= acum/norm;
     gl_FragColor = vec4(acum, texture2D(inputImageTexture, uv ).w);
 }

 );

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kImageGaussFilterString]))
    {
        return nil;
    }
    GPUTextureOptions opt;
    opt.internalFormat = GL_RGB;
    opt.format = GL_RGB;
    opt.minFilter = GL_LINEAR;
    opt.magFilter = GL_LINEAR;
    opt.wrapS = GL_CLAMP_TO_EDGE;
    opt.wrapT = GL_CLAMP_TO_EDGE;
    opt.type = GL_HALF_FLOAT_OES;
    
//    _outputTextureOptions.minFilter = GL_LINEAR;
//    _outputTextureOptions.magFilter = GL_LINEAR;
//    _outputTextureOptions.wrapS = GL_CLAMP_TO_EDGE;
//    _outputTextureOptions.wrapT = GL_CLAMP_TO_EDGE;
//    _outputTextureOptions.internalFormat = GL_RGBA;
//    _outputTextureOptions.format = GL_BGRA_EXT;
//    _outputTextureOptions.type = GL_UNSIGNED_BYTE;
//    0x8D61 GL_HALF_FLOAT_OES;
//    [self setOutputTextureOptions:opt];
//    self.outputTextureOptions.internalFormat = GL_RGBA;
//    self.outputTextureOptions.internalFormat = GL_RGBA;
    return self;
}


- (void)setSizeInPixels:(CGSize)sizeInPixels;
{
    [self setSize:sizeInPixels forUniformName:@"size"];
}

-(void)setSigma:(CGFloat)sigma{
    [self setFloat:sigma forUniformName:@"sigma"];
}


//uniform highp vec2 size;
//uniform highp float sigma ;

@end
