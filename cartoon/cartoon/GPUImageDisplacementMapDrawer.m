//
//  GPUImageDisplacementMapDrawer.m
//  test
//
//  Created by cain on 2017/6/20.
//  Copyright © 2017年 dlsd. All rights reserved.
//

#import "GPUImageDisplacementMapDrawer.h"

@implementation GPUImageDisplacementMapDrawer


NSString *const kImageDisplacementMapDrawerString = SHADER_STRING
(
extension GL_EXT_shader_framebuffer_fetch : require
	const int kModeReshape = 0;
	const int kModeResize = 1;
	const int kModeUnwarp = 2;
	uniform int mode;
	uniform mediump sampler2D sourceTexture;
	uniform mediump sampler2D maskTexture;
	uniform highp vec2 aspectFactor;
	uniform highp vec2 center;
	uniform highp vec2 direction;
	uniform highp float scale;
	uniform highp float diameter;
	uniform highp float density;
	uniform highp float pressure;
	varying highp vec2 vTexcoord;
	const highp float kGaussianSigma = 0.3;
	void main() {
        sourceTexture;
        highp vec2 lastFrag = gl_LastFragData[0].rg;
        highp vec2 currentPointWithOffset = (vTexcoord + lastFrag) * aspectFactor;
        highp vec2 diff = currentPointWithOffset - center;
        highp float normalizedSquaredDistance = dot(diff, diff) / (0.25 * diameter * diameter);
        highp float sigma = density * kGaussianSigma;
        highp float intensity = exp(-normalizedSquaredDistance / (2.0 * sigma * sigma)) * pressure;
        highp vec2 delta;
        if (mode == kModeReshape) {
            delta = intensity * direction;
        } else if (mode == kModeResize) {
            intensity *= scale;
            delta = intensity * (currentPointWithOffset - center);
            delta /= aspectFactor;
        } else if (mode == kModeUnwarp) {
            intensity = min(2.0 * intensity, 1.0);
            delta = -intensity * lastFrag;
            gl_FragColor = vec4(lastFrag + delta, 0.0, 0.0);
            return;
        } else {
            delta = vec2(0.0);
        }
        highp float maskTarget = texture2D(maskTexture, vTexcoord + lastFrag + delta).r;
        delta *= 0.5 + 0.5 * maskTarget;
        maskTarget = texture2D(maskTexture, vTexcoord + lastFrag + delta).r;
        delta *= 0.5 + 0.5 * maskTarget;
        maskTarget = texture2D(maskTexture, vTexcoord + lastFrag + delta).r;
        delta *= 0.5 + 0.5 * maskTarget;
        highp float maskSource = texture2D(maskTexture, vTexcoord + lastFrag).r;
        delta *= maskSource;
        gl_FragColor = vec4(lastFrag + delta, 0.0, 0.0);
    }
 );

NSString *const kImageDisplacementMapDrawerVertexString = SHADER_STRING
(
    uniform highp mat4 modelview;
	uniform highp mat4 projection;
	uniform highp mat3 texture;
	attribute highp vec4 position;
	attribute highp vec3 texcoord;
	varying highp vec2 vTexcoord;
	void main() {
        vTexcoord = (texture * vec3(texcoord.xy, 1.0)).xy;
        gl_Position = projection * modelview * position;
    }
 );

- (id)init;
{
    if (!(self = [super initWithVertexShaderFromString:kImageDisplacementMapDrawerVertexString fragmentShaderFromString:kImageDisplacementMapDrawerString]))
    {
        return nil;
    }
    
    modelviewUniform = [filterProgram uniformIndex:@"modelview"];
    projectionUniform = [filterProgram uniformIndex:@"projection"];
    textureUniform = [filterProgram uniformIndex:@"texture"];
    return self;
}


-(void)setMode:(int)mode{
    [self setInteger:mode forUniformName:@"mode"];
}

-(void)setAspectFactor:(CGPoint)aspectFactor{
    [self setPoint:aspectFactor forUniformName:@"aspectFactor"];
}

-(void)setCenter:(CGPoint)center{
    [self setPoint:center forUniformName:@"center"];
}

-(void)setDirection:(CGPoint)direction{
    [self setPoint:direction forUniformName:@"direction"];
}

-(void)setScale:(float)scale{
    [self setFloat:scale forUniformName:@"scale"];
}

-(void)setDiameter:(float)diameter{
    [self setFloat:diameter forUniformName:@"diameter"];
}

-(void)setDensity:(float)density{
    [self setFloat:density forUniformName:@"density"];
}

-(void)setPressure:(float)pressure{
    [self setFloat:pressure forUniformName:@"pressure"];
}

-(void)setModelview:(GPUMatrix4x4)modelview{
    [self setMatrix4f:modelview forUniform:modelviewUniform program:filterProgram];
}

-(void)setTexture:(GPUMatrix3x3)texture{
    [self setMatrix3f:texture forUniform:textureUniform program:filterProgram];
}

-(void)setProjection:(GPUMatrix4x4)projection{
    [self setMatrix4f:projection forUniform:projectionUniform program:filterProgram];
}

- (void)setSizeInPixels:(CGSize)sizeInPixels;
{
    [self setSize:sizeInPixels forUniformName:@"size"];
}

@end


