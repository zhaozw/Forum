//
//  CCFUtils.h
//  CCF
//
//  Created by WDY on 16/1/7.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject

+(NSString *) getTimeSp;

+(NSString *) getSHA1:(NSString *) src;

+(UIImage *) scaleUIImage:(UIImage *) sourceImage andMaxSize:(CGSize)maxSize;

@end
