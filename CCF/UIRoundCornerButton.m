//
//  UIRoundCornerButton.m
//  CCF
//
//  Created by 迪远 王 on 16/4/10.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "UIRoundCornerButton.h"

@implementation UIRoundCornerButton

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        UIColor * borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        self.layer.borderColor = borderColor.CGColor;
        self.layer.borderWidth = 0.5;
        self.layer.cornerRadius = 5.0;
    }
    return self;
}

@end
