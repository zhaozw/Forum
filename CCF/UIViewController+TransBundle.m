//
// Created by 迪远 王 on 2016/11/6.
// Copyright (c) 2016 andforce. All rights reserved.
//

#import "UIViewController+TransBundle.h"
#import "TransBundleDelegate.h"

@interface UIViewController ()

@property(nonatomic, strong) id <TransBundleDelegate> delegate;

@property(nonatomic, strong) TransBundle *bundle;

@end

@implementation UIViewController (TransBundle)


- (void)presentViewController:(UIViewController *)viewControllerToPresent withBundle:(TransBundle *)bundle forRootController:(BOOL)forRootController animated:(BOOL)flag completion:(void (^ __nullable)(void))completion {

    UIViewController *target = forRootController ? viewControllerToPresent.childViewControllers.firstObject : viewControllerToPresent;

    NSAssert([target conformsToProtocol:@protocol(TransBundleDelegate)], @"目标Controller未实现TransBundleDelegate协议");


    NSAssert([target respondsToSelector:@selector(transBundle:)], @"目标Controller未实现transBundle:方法");

    self.delegate = (id <TransBundleDelegate>) target;

    [self.delegate transBundle:bundle];

    [self presentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end
