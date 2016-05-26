//
//  UISquareRoundCornerImageView.m
//  CCF
//
//  Created by 迪远 王 on 16/3/19.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "UISquareRoundCornerImageView.h"

@implementation UISquareRoundCornerImageView

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 2.5;
    }
    return self;
}

@end
