//
//  CCFApiBaseTableViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/3/13.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFApiBaseTableViewController.h"

@interface CCFApiBaseTableViewController (){
    BOOL disablePullrefresh;
    
    BOOL disableLoadMore;
}

@end

@implementation CCFApiBaseTableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    
    if ([self setPullRefresh:YES]) {
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self onPullRefresh];
        }];
        
        if ([self autoPullfresh]) {
            [self.tableView.mj_header beginRefreshing];
        }
    }

    
    if ([self setLoadMore:YES]) {
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [self onLoadMore];
        }];
    }


}

-(void)onPullRefresh{
    
}

-(void)onLoadMore{
    
}

-(BOOL)autoPullfresh{
    return YES;
}

-(BOOL)setPullRefresh:(BOOL)enable{
    return YES;
}

-(BOOL)setLoadMore:(BOOL)enable{
    return YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

#pragma mark initData
- (void)initData {
    self.ccfApi = [[ForumApi alloc]init];
    self.dataList =[[NSMutableArray alloc]init];
}


#pragma mark override-init
-(instancetype)init{
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

#pragma mark overide-initWithCoder
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initData];
    }
    return self;
}

#pragma mark overide-initWithName
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initData];
    }
    return self;
}

#pragma mark overide-initWithStyle
-(instancetype)initWithStyle:(UITableViewStyle)style{
    if (self = [super initWithStyle:style]) {
        [self initData];
    }
    return self;
}

#pragma mark overide-numberOfRowsInSection
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}


@end