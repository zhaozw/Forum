//
//  TransBundleUIViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/4/24.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "TransBundleUIViewController.h"
#import "TransBundleDelegate.h"


@interface TransBundleUIViewController ()

@property(nonatomic, strong) id <TransBundleDelegate> delegate;

@property(nonatomic, strong) TransValueBundle *bundle;

@end

@implementation TransBundleUIViewController


- (void)presentViewController:(UIViewController *)viewControllerToPresent withBundle:(TransValueBundle *)bundle animated:(BOOL)flag completion:(void (^ __nullable)(void))completion {

    assert(![viewControllerToPresent conformsToProtocol:@protocol (TransBundleDelegate)]);

    self.delegate = (id <TransBundleDelegate>) viewControllerToPresent;

    [self.delegate transBundle:bundle];
    [self presentViewController:viewControllerToPresent animated:flag completion:completion];

}
@end
