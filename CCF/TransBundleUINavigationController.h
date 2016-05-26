//
//  TransBundleUINavigationController.h
//  CCF
//
//  Created by 迪远 王 on 16/4/24.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransValueBundle.h"
#import "TransBundleDelegate.h"


@interface TransBundleUINavigationController : UINavigationController

@property (nonatomic, strong) id<TransBundleDelegate> transBundleDelegate;

@property (nonatomic, strong) TransValueBundle * bundle;

@end
