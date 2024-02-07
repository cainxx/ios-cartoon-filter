//
//  GPUImageSST.h
//  DBCamera
//
//  Created by cain on 15/9/4.
//  Copyright (c) 2015年 PSSD - Daniele Bogo. All rights reserved.
//

#import "GPUImageFilter.h"

@interface GPUImageSST : GPUImageFilter {
     GLuint sizePixels;
}

@property(assign, nonatomic) CGSize sizeInPixels;

-(id)init;

@end


