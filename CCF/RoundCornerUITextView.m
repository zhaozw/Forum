//
//  RoundCornerUITextView.m
//  CCF
//
//  Created by 迪远 王 on 16/1/16.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "RoundCornerUITextView.h"

@implementation RoundCornerUITextView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setCorner];
    }
    return self;
}



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setCorner];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setCorner];
    }
    return self;
}

-(void) setCorner{
    UIColor * borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = 0.5;
    self.layer.cornerRadius = 5.0;

}

@end
