//
//  CCFShowPrivateMessageViewController.h
//  CCF
//
//  Created by 迪远 王 on 16/3/25.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoRelayoutToolbar.h"
#import "ShowPrivateMessage.h"
#import "TransValueDelegate.h"

@interface CCFShowPrivateMessageViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, strong) NSMutableArray<ShowPrivateMessage *> * dataList;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet AutoRelayoutToolbar *floatToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *back;

@property (weak, nonatomic) id<TransValueDelegate> transValueDelegate;

@end
