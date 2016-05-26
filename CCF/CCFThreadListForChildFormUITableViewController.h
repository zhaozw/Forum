//
//  CCFThreadListForChildFormUITableViewController.h
//  CCF
//
//  Created by 迪远 王 on 16/3/27.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFApiBaseTableViewController.h"
#import "CCFApiBaseTableViewController.h"
#import "TransValueDelegate.h"


@interface CCFThreadListForChildFormUITableViewController : CCFApiBaseTableViewController

// 置顶
@property (nonatomic, strong) NSMutableArray * threadTopList;

- (IBAction)back:(UIBarButtonItem *)sender;
- (IBAction)createThread:(id)sender;



@end
