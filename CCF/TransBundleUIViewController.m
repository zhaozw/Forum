//
//  TransBundleUIViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/4/24.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "TransBundleUIViewController.h"

@interface TransBundleUIViewController ()<TransBundleDelegate>

@end

@implementation TransBundleUIViewController

-(void)transBundle:(TransValueBundle *)bundle{
    self.bundle = bundle;
}

@end
