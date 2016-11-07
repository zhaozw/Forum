//
// Created by 迪远 王 on 2016/11/6.
// Copyright (c) 2016 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransBundle.h"

//@protocol TransBundleDelegate <NSObject>
//
//
//@required
//- (void)transBundle:(TransBundle *)value;
//
//@end

@interface UIViewController (TransBundle)

- (void)presentViewController:(UIViewController *)viewControllerToPresent withBundle:(TransBundle *)bundle forRootController:(BOOL)forRootController animated:(BOOL)flag completion:(void (^ __nullable)(void))completion NS_AVAILABLE_IOS(5_0);

- (void)dismissViewControllerAnimated:(BOOL)flag backToViewController:(UIViewController *)controller withBundle:(TransBundle *)bundle completion:(void (^ __nullable)(void))completion NS_AVAILABLE_IOS(5_0);

- (void)transBundle:(TransBundle *)bundle forController:(UIViewController *)controller;
@end
