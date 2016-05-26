//
//  CCFUtils.m
//  CCF
//
//  Created by WDY on 16/1/7.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "Utils.h"

#import <CommonCrypto/CommonDigest.h>


@implementation Utils

+(NSString *)getTimeSp{
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:datenow];
    NSDate *localeDate = [datenow  dateByAddingTimeInterval: interval];
    //    NSLog(@"时间戳----》 %l", interval);
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[localeDate timeIntervalSince1970]];
    NSLog(@"timeSp:%@",timeSp); //时间戳的值
    
    return timeSp;
}


+(NSString *)getSHA1:(NSString *)src{
    
    const char *cstr = [src cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:src.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++){
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

+(id)scaleUIImage:(UIImage *)sourceImage andMaxSize:(CGSize)maxSize{
    CGSize size = sourceImage.size;
    
    if (size.height > maxSize.height || size.width > maxSize.width) {
        CGFloat heightScale = maxSize.height / size.height;
        CGFloat widthScale = maxSize.width / size.width;
        
        CGFloat scale = heightScale > widthScale ? widthScale : heightScale;
        
        CGFloat width = size.width;
        CGFloat height = size.height;
        
        CGFloat scaledWidth = width * scale;
        CGFloat scaledHeight = height * scale;
        
        CGSize newSize = CGSizeMake(scaledWidth, scaledHeight);
        UIGraphicsBeginImageContext(newSize);//thiswillcrop
        [sourceImage drawInRect:CGRectMake(0,0,scaledWidth,scaledHeight)];
        UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
        
    } else{
        return sourceImage;
    }
    
}


























@end
