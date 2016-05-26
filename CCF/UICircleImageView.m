//
//  UICircleImageView.m
//  CCF
//
//  Created by 迪远 王 on 16/3/13.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "UICircleImageView.h"

@implementation UICircleImageView


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = self.bounds.size.width * 0.5;
//        self.layer.borderWidth = 4;
//        self.layer.borderColor = [UIColor redColor].CGColor;
    }
    return self;
}

@end
