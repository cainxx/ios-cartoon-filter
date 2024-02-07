//
//  GPUImageBlenderCustomQuanticeLab.m
//  test
//
//  Created by cain on 17/4/11.
//  Copyright © 2017年 dlsd. All rights reserved.
//

#import "GPUImageBlenderCustomQuanticeLab.h"

@implementation GPUImageBlenderCustomQuanticeLab

NSString *const kImageBlenderCustomQuanticeString = SHADER_STRING
(
 precision highp float;
 precision highp int;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform float sigmaR ;
 uniform vec2 size;
 void main (void) {
     vec2 uv = gl_FragCoord.xy / size;
     float twoSigma2=3.0*sigmaR*sigmaR;
     vec2 t = texture2D(inputImageTexture, uv ).yz;
     vec2 vdire = vec2( t.x*2.0-1.0 , t.y*2.0-1.0 ) ;
     vec2 pointer = vec2( vdire.x , vdire.y ) ;
     float acumulo = texture2D( inputImageTexture, uv ).x;
     float norma = 1.0 ;
     float avance = 1.0;
     float limit = 2.0 * sigmaR ;
     while ( avance < limit) {
         float ker = exp( ( -( (avance))) / twoSigma2) ;
         acumulo +=ker * texture2D(inputImageTexture, uv + pointer/size).x;
         norma +=ker ;
         vec2 tt = texture2D(inputImageTexture, uv + pointer/size).yz;
         vdire = vec2(tt.x*2.0-1.0 , tt.y*2.0-1.0 ) ;
         pointer += vdire ; avance ++;
     }
     vdire = vec2( -(t.x*2.0-1.0) , -(t.y*2.0-1.0) ) ;
     pointer = vec2( vdire.x , vdire.y ) ;
     avance = 1.0;
     while ( avance < limit ) {
         float ker = exp( ( -( (avance))) / twoSigma2) ;
         acumulo +=ker * texture2D(inputImageTexture, uv + pointer/size).x;
         norma +=ker;
         vec2 tt = texture2D(inputImageTexture, uv + pointer/size).yz;
         vdire = vec2( -(tt.x*2.0-1.0) , -(tt.y*2.0-1.0 )) ;
         pointer += vdire ; avance ++;
     }
     float finale=smoothstep(0.0, 0.8, acumulo/norma);
     vec3 original = texture2D(inputImageTexture2, uv).xyz;
     highp float overlayeralfa =1.0- finale ;
     original=vec3(original.x* (1.0-overlayeralfa*overlayeralfa*overlayeralfa),original.y* (1.0-overlayeralfa*overlayeralfa),original.z* (1.0-overlayeralfa*overlayeralfa));
     gl_FragColor = vec4(original , 1.0); 
 }

 );

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kImageBlenderCustomQuanticeString]))
    {
        return nil;
    }
    return self;
}

- (void)setSizeInPixels:(CGSize)sizeInPixels;
{
    [self setSize:sizeInPixels forUniformName:@"size"];
}

-(void)setSigma_r:(float)sigma_r{
    [self setFloat:sigma_r forUniformName:@"sigmaR"];
}

-(void)setMode:(int)mode{
    [self setInteger:mode forUniformName:@"mode"];
}


@end
