//
//  GPUImageColorQuantization.m
//  test
//
//  Created by cain on 17/4/11.
//  Copyright © 2017年 dlsd. All rights reserved.
//

#import "GPUImageColorQuantization.h"

@implementation GPUImageColorQuantization

NSString *const kImageColorQuantizationString = SHADER_STRING
(
 precision highp float;
 uniform sampler2D inputImageTexture;
 uniform vec2 size;
 uniform int mode;
 uniform vec3 firstColor;
 varying vec2 textureCoordinate;
 uniform lowp vec2 vignetteCenter;
 uniform lowp vec3 vignetteColor;
 uniform highp float vignetteStart;
 uniform highp float vignetteEnd;
 
 vec3 rgb2xyz( vec3 rgbcolor ) {
     highp vec3 xyzcolor=vec3((( rgbcolor.r > 0.04045 ) ? pow( ( rgbcolor.r + 0.055 ) / 1.055, 2.4 ) : rgbcolor.r / 12.92), ( ( rgbcolor.g > 0.04045 ) ? pow( ( rgbcolor.g + 0.055 ) / 1.055, 2.4 ) : rgbcolor.g / 12.92), (( rgbcolor.b > 0.04045 ) ? pow( ( rgbcolor.b + 0.055 ) / 1.055, 2.4 ) : rgbcolor.b / 12.92)); return 100.0 * xyzcolor * mat3( 0.4124, 0.3576, 0.1805, 0.2126, 0.7152, 0.0722,0.0193, 0.1192, 0.9505 );
 }
 vec3 xyz2Lab( vec3 xyzcolor ) {
     vec3 tem = xyzcolor / vec3( 95.047, 100, 108.883 );
     vec3 v=vec3(( tem.x > 0.008856 ) ? pow( tem.x, 1.0 / 3.0 ) : ( 7.787 * tem.x ) + ( 16.0 / 116.0 ), ( tem.y > 0.008856 ) ? pow( tem.y, 1.0 / 3.0 ) : ( 7.787 * tem.y ) + ( 16.0 / 116.0 ), ( tem.z > 0.008856 ) ? pow( tem.z, 1.0 / 3.0 ) : ( 7.787 * tem.z ) + ( 16.0 / 116.0 )); return vec3(( 116.0 * v.y ) - 16.0, 500.0 * ( v.x - v.y ), 200.0 * ( v.y - v.z ));
 }
 
 vec3 rgb2Lab(vec3 rgbcolor) {
     vec3 lab = xyz2Lab( rgb2xyz( rgbcolor ) );
     return vec3( lab.x / 100.0, 0.5 + 0.5 * ( lab.y / 127.0 ), 0.5 + 0.5 * ( lab.z / 127.0 ));
 }
 
 vec3 lab2xyz( vec3 c ) {
     float fy = ( c.x + 16.0 ) / 116.0;
     float fx = c.y / 500.0 + fy;
     float fz = fy - c.z / 200.0;
     return vec3( 95.047 * (( fx > 0.206897 ) ? fx * fx * fx : ( fx - 16.0 / 116.0 ) / 7.787), 100.000 * (( fy > 0.206897 ) ? fy * fy * fy : ( fy - 16.0 / 116.0 ) / 7.787), 108.883 * (( fz > 0.206897 ) ? fz * fz * fz : ( fz - 16.0 / 116.0 ) / 7.787) );
 }
 
 vec3 xyz2rgb( vec3 c ) {
     vec3 v = c / 100.0 * mat3(3.2406, -1.5372, -0.4986, -0.9689, 1.8758, 0.0415, 0.0557, -0.2040, 1.0570 );
     vec3 r;
     r.x = ( v.r > 0.0031308 ) ? (( 1.055 * pow( v.r, ( 1.0 / 2.4 ))) - 0.055 ) : 12.92 * v.r;
     r.y = ( v.g > 0.0031308 ) ? (( 1.055 * pow( v.g, ( 1.0 / 2.4 ))) - 0.055 ) : 12.92 * v.g;
     r.z = ( v.b > 0.0031308 ) ? (( 1.055 * pow( v.b, ( 1.0 / 2.4 ))) - 0.055 ) : 12.92 * v.b;
     return r;
 }
 
 vec3 lab2rgb(vec3 c) {
     return xyz2rgb( lab2xyz( vec3(100.0 * c.x, 2.0 * 127.0 * (c.y - 0.5), 2.0 * 127.0 * (c.z - 0.5)) ) );
 }
 
 void main(void) {
     vec2 uv = gl_FragCoord.xy / size;
     vec2 d = 1.0 / size;
     vec3 c = texture2D(inputImageTexture, uv).xyz;
     c= clamp(rgb2Lab( c), 0.0, 1.0);
     if(mode==0){
         float cuantized = floor(c.x*6.0+0.5) /6.0;
         vec3 cb = vec3(cuantized, c.yz);
         gl_FragColor = vec4( clamp(lab2rgb(clamp(cb, 0.0, 1.0)), 0.0, 1.0), 1.0 );
     }else if(mode==1){
         lowp float d = distance(textureCoordinate, vec2(vignetteCenter.x, vignetteCenter.y));
         lowp float percent = smoothstep(vignetteStart, vignetteEnd, d);
         c=mix(c.rgb, vignetteColor, percent) ;
         float cuantized = floor(c.x*6.0+0.5) /6.0;
         vec3 cb = vec3(cuantized, c.yz);
         gl_FragColor = vec4( clamp(lab2rgb(clamp(cb, 0.0, 1.0)), 0.0, 1.0), 1.0 );
     }else { 
         float cuantized = floor(c.x*6.0+0.5) /6.0; 
         gl_FragColor = vec4( cuantized,cuantized,cuantized, 1.0 ); 
     } 
 } 
 );

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kImageColorQuantizationString]))
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
