//
//  CCFNSAttributedStringBuilder.h
//  CCF
//
//  Created by WDY on 16/4/21.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <DTCoreText.h>

@interface CCFNSAttributedStringBuilder : NSObject

-(NSAttributedString*) buildNSAttributedString:(NSString *)html withImageSize:(CGSize)imageSize;

@end
