//
//  CCFSimpleReplyNavigationController.h
//  CCF
//
//  Created by 迪远 王 on 16/4/10.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Thread.h"
#import "CCFShowThreadViewController.h"
#import "TransValueBundle.h"

@interface CCFSimpleReplyNavigationController : UINavigationController

@property (nonatomic, strong) TransValueBundle *bundle;
@property (nonatomic, strong) CCFShowThreadViewController * controller;

@end
