//
//  UICircleButton.m
//  CCF
//
//  Created by 迪远 王 on 16/4/10.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "UICircleButton.h"

@implementation UICircleButton

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
