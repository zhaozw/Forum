//
//  UIPageLabel.m
//  CCF
//
//  Created by 迪远 王 on 16/4/17.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "UIPageLabel.h"
#import "NSString+Extensions.h"

@implementation UIPageLabel{
UIColor * bgcolor;
UIImage * bgImage;
}



-(void)drawRect:(CGRect)rect{
    
    if (bgcolor == nil) {
        bgcolor = [self colorWithR:71 G:169 B:186];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (bgImage == nil) {
        bgImage = [self createImageWithColor:bgcolor];
    }
    
    UIRectCorner corner = UIRectCornerAllCorners;
    
    corner = UIRectCornerTopRight;
    
    
    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRoundedRect: self.bounds byRoundingCorners: corner cornerRadii: CGSizeMake(3, 3)];
    
    [rectanglePath closePath];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    
    [bgImage drawInRect: self.bounds];
    CGContextRestoreGState(context);
    
    [super drawRect:rect];
    
}

-(void)setText:(NSString *)text{
    NSString * paddingText = [NSString stringWithFormat:@"  %@ ", [text trim]];
    [super setText:paddingText];
}

-(UIColor*)colorWithR:(float)r G:(float)g B:(float)b{
    return [UIColor colorWithRed:r / 255.0 green:g /255.0 blue:b /255.0 alpha:1];
}

- (UIImage *)createImageWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}
@end
