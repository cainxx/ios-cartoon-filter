//
//  GPUImageFDOGB.m
//  test
//
//  Created by cain on 17/4/11.
//  Copyright © 2017年 dlsd. All rights reserved.
//

#import "GPUImageFDOGB.h"

@implementation GPUImageFDOGB

NSString *const kImageFDOGBString = SHADER_STRING
(
 precision highp float;
 precision highp int;
 uniform int mode;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 float sigmaR=4.0;
 uniform vec2 size;
 void main (void) {
     vec2 uv = gl_FragCoord.xy / size;
     float twoSigma2=3.0*sigmaR*sigmaR;
     vec3 t = texture2D(inputImageTexture2, uv).yzw;
     float oldalfa= 2.0*3.1415926*t.x;
     vec2 vdire = vec2( t.y*2.0-1.0 , t.z*2.0-1.0 ) ;
     vec2 pointer = vec2( vdire.x , vdire.y ) ;
     vec3 acumulo = texture2D( inputImageTexture, uv).xyz;
     vec3 norma = vec3(1.0,1.0,1.0) ;
     vec2 vdireBack = vec2( -(t.y*2.0-1.0) , -(t.z*2.0-1.0) ) ;
     vec2 pointerRBack = vec2( vdireBack.x , vdireBack.y ) ;
     float limit = 2.0 * sigmaR ;
     for (float i=1.0;i < limit;i++) {
         float ker = exp( - i / twoSigma2) ;
         acumulo +=ker * (texture2D(inputImageTexture, uv + pointer/size).xyz + texture2D(inputImageTexture, uv + pointerRBack/size).xyz);
         norma +=2.0*ker ;
         pointer += vdire ;
         pointerRBack += vdireBack ;
     } 
     gl_FragColor = vec4( acumulo/norma, 1.0);
 }
 );

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kImageFDOGBString]))
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



@end
