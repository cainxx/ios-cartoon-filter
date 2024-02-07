//
//  GPUImageSST.m
//  DBCamera
//
//  Created by cain on 15/9/4.
//  Copyright (c) 2015年 PSSD - Daniele Bogo. All rights reserved.
//

#import "GPUImageSST.h"

@implementation GPUImageSST


NSString *const kImageSSTShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 uniform highp vec2 size;
 void main (void) {
     highp vec2 uv = gl_FragCoord.xy / size;
     highp vec2 d = 1.0 / size;
     highp vec4 u = ( -1.0 * texture2D(inputImageTexture, uv + vec2(-d.x, -d.y)) + -2.0 * texture2D(inputImageTexture, uv + vec2(-d.x, 0.0)) + -1.0 * texture2D(inputImageTexture, uv + vec2(-d.x, d.y)) + +1.0 * texture2D(inputImageTexture, uv + vec2( d.x, -d.y)) + +2.0 * texture2D(inputImageTexture, uv + vec2( d.x, 0.0)) + +1.0 * texture2D(inputImageTexture, uv + vec2( d.x, d.y)) ) ;
     highp vec4 v = ( -1.0 * texture2D(inputImageTexture, uv + vec2(-d.x, -d.y)) + -2.0 * texture2D(inputImageTexture, uv + vec2( 0.0, -d.y)) + -1.0 * texture2D(inputImageTexture, uv + vec2( d.x, -d.y)) + +1.0 * texture2D(inputImageTexture, uv + vec2(-d.x, d.y)) + +2.0 * texture2D(inputImageTexture, uv + vec2( 0.0, d.y)) + +1.0 * texture2D(inputImageTexture, uv + vec2( d.x, d.y)) ) ;
     gl_FragColor = (1.0*d.y > 1.0)? vec4((dot(u.xyz, u.xyz)), ( dot(v.xyz, v.xyz)), 0.5*(1.0+dot(u.xyz, v.xyz)), 1.0): vec4((dot(u.xyz, u.xyz)), (dot(v.xyz, v.xyz)), 0.5*(1.0+dot(u.xyz, v.xyz)), 1.0);
 }
 );


@synthesize sizeInPixels = _sizeInPixels;

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kImageSSTShaderString]))
    {
        return nil;
    }
    return self;
}


- (void)setSizeInPixels:(CGSize)sizeInPixels;
{
    [self setSize:sizeInPixels forUniformName:@"size"];
}


@end
