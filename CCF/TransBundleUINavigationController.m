//
//  TransBundleUINavigationController.m
//  CCF
//
//  Created by 迪远 王 on 16/4/24.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "TransBundleUINavigationController.h"

@interface TransBundleUINavigationController ()<TransBundleDelegate>

@end

@implementation TransBundleUINavigationController

-(void)transBundle:(TransValueBundle *)bundle{
    self.bundle = bundle;
}

@end
