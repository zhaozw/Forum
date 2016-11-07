//
//  ForumReplyNavigationController.m
//  CCF
//
//  Created by 迪远 王 on 16/4/10.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumReplyNavigationController.h"
#import "TransBundleDelegate.h"
#import "TransBudleUINavigatioController.h"


@implementation TransBudleUINavigatioController


- (void)presentViewController:(UIViewController *)viewControllerToPresent withBundle:(TransBundle *)bundle forRootController:(BOOL)forRootController animated:(BOOL)flag completion:(void (^ __nullable)(void))completion {

    UIViewController *target = forRootController ? viewControllerToPresent.childViewControllers.firstObject : viewControllerToPresent;

    NSAssert([target conformsToProtocol:@protocol(TransBundleDelegate)], @"目标Controller未实现TransBundleDelegate协议");


    NSAssert([target respondsToSelector:@selector(transBundle:)], @"目标Controller未实现transBundle:方法");

    self.delegate = (id <TransBundleDelegate>) target;

    [self.delegate transBundle:bundle];

    [self presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)dismissViewControllerAnimated:(BOOL)flag backToViewController:(UIViewController *)controller withBundle:(TransBundle *)bundle completion:(void (^ __nullable)(void))completion {
    UIViewController *target = controller;

    NSAssert([target conformsToProtocol:@protocol(TransBundleDelegate)], @"目标Controller未实现TransBundleDelegate协议");


    NSAssert([target respondsToSelector:@selector(transBundle:)], @"目标Controller未实现transBundle:方法");

    self.delegate = (id <TransBundleDelegate>) target;

    [self.delegate transBundle:bundle];

    [self dismissViewControllerAnimated:flag completion:completion];
}

- (void)transBundle:(TransBundle *)bundle forController:(UIViewController *)controller {
    UIViewController *target = controller;

    NSAssert([target conformsToProtocol:@protocol(TransBundleDelegate)], @"目标Controller未实现TransBundleDelegate协议");


    NSAssert([target respondsToSelector:@selector(transBundle:)], @"目标Controller未实现transBundle:方法");

    self.delegate = (id <TransBundleDelegate>) target;

    [self.delegate transBundle:bundle];
}

@end
