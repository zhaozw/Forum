//
//  TransBundleUIViewController.h
//  CCF
//
//  Created by 迪远 王 on 16/4/24.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TransValueBundle.h"

@interface TransBundleUIViewController : UIViewController


- (void)presentViewController:(UIViewController *)viewControllerToPresent withBundle:(TransValueBundle *) bundle animated: (BOOL)flag completion:(void (^ __nullable)(void))completion NS_AVAILABLE_IOS(5_0);

@end
