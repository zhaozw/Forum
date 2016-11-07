//
//  ForumApiBaseTableViewController.h
//  CCF
//
//  Created by 迪远 王 on 16/3/13.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCFForumApi.h"
#import "MJRefresh.h"
#import "UITableView+FDTemplateLayoutCell.h"

#import <vBulletinForumEngine/vBulletinForumEngine.h>

@interface ForumApiBaseTableViewController : UITableViewController

@property(nonatomic, strong) CCFForumApi *ccfApi;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, assign) int currentPage;
@property(nonatomic, assign) int totalPage;


- (void)onPullRefresh;


- (void)onLoadMore;

- (BOOL)setPullRefresh:(BOOL)enable;

- (BOOL)setLoadMore:(BOOL)enable;

- (BOOL)autoPullfresh;
@end
