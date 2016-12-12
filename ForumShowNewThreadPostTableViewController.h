//
//  ForumShowNewThreadPostTableViewController.h
//
//  Created by 迪远 王 on 16/3/6.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumApiBaseTableViewController.h"

@protocol TransBundleDelegate;
@class TransBundle;

@interface ForumShowNewThreadPostTableViewController : ForumApiBaseTableViewController

- (IBAction)showLeftDrawer:(id)sender;

@property(nonatomic, strong) id <TransBundleDelegate> delegate;

@property(nonatomic, strong) TransBundle *bundle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftMenu;

@end
