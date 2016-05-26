//
//  CCFThreadListForChildFormUITableViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/3/27.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFThreadListForChildFormUITableViewController.h"

#import "UrlBuilder.h"
#import "CCFParser.h"
#import "CCFThreadListCell.h"
#import "CCFShowThreadViewController.h"
#import "MJRefresh.h"
#import "CCFNewThreadViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "CCFProfileTableViewController.h"
#import "ForumCoreDataManager.h"


@interface CCFThreadListForChildFormUITableViewController (){
    Forum * transForm;
    
    NSArray * childForms;
}

@end

@implementation CCFThreadListForChildFormUITableViewController

#pragma mark trans value
-(void)transValue:(Forum *)value{
    transForm = value;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    ForumCoreDataManager * manager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
    childForms = [[manager selectChildFormsForId:transForm.formId] mutableCopy];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 180.0;
    
    if (self.threadTopList == nil) {
        self.threadTopList = [NSMutableArray array];
    }
}


-(void)onPullRefresh{
    [self.ccfApi forumDisplayWithId:transForm.formId andPage:1 handler:^(BOOL isSuccess, ForumDisplayPage *page) {
        
        [self.tableView.mj_header endRefreshing];
        
        if (isSuccess) {
            self.totalPage = (int)page.totalPageCount;
            self.currentPage = 1;
            if (self.currentPage >= self.totalPage) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            [self.threadTopList removeAllObjects];
            [self.dataList removeAllObjects];
            
            for (NormalThread * thread in page.dataList) {
                if (thread.isTopThread) {
                    [self.threadTopList addObject:thread];
                }else{
                    [self.dataList addObject:thread];
                }
            }
            
            [self.tableView reloadData];
        }
    }];
}

-(void)onLoadMore{
    [self.ccfApi forumDisplayWithId:transForm.formId andPage:self.currentPage + 1 handler:^(BOOL isSuccess, ForumDisplayPage *page) {
        
        [self.tableView.mj_footer endRefreshing];
        
        if (isSuccess) {
            self.totalPage = (int)page.totalPageCount;
            self.currentPage ++;
            if (self.currentPage >= self.totalPage) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            for (NormalThread * thread in page.dataList) {
                if (!thread.isTopThread) {
                    [self.dataList addObject:thread];
                }
            }
            
            [self.tableView reloadData];
        }
    }];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0){
        return self.threadTopList.count;
    } else{
        return self.dataList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 帖子内容
    static NSString *reusedIdentifier = @"CCFThreadListCellIdentifier";
    
    CCFThreadListCell *cell = (CCFThreadListCell*)[tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
    
    if (indexPath.section == 0) {
        NormalThread *play = self.threadTopList[indexPath.row];
        [cell setData:play];
    } else{
        NormalThread *play = self.dataList[indexPath.row];
        [cell setData:play];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView fd_heightForCellWithIdentifier:@"CCFThreadListCellIdentifier" configuration:^(CCFThreadListCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)configureCell:(CCFThreadListCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    
    [cell setData:self.dataList[indexPath.row]];
}




#pragma mark Controller跳转
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        
        CCFNewThreadViewController * newPostController = segue.destinationViewController;
        self.transValueDelegate = (id<TransValueDelegate>)newPostController;
        [self.transValueDelegate transValue:transForm];
        
        
    } else if([sender isKindOfClass:[UITableViewCell class]]){
        CCFShowThreadViewController * controller = segue.destinationViewController;
        self.transValueDelegate = (id<TransValueDelegate>)controller;
        [self.transValueDelegate transValue:transForm];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NormalThread * thread = nil;
        
        if (indexPath.section == 0) {
            thread = self.threadTopList[indexPath.row];
        } else{
            thread = self.dataList[indexPath.row];
        }
        [self.transValueDelegate transValue:thread];
        
    } else if ([sender isKindOfClass:[UIButton class]]){
        CCFProfileTableViewController * controller = segue.destinationViewController;
        self.transValueDelegate = (id<TransValueDelegate>)controller;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NormalThread * thread = nil;
        
        if (indexPath.section == 0) {
            thread = self.threadTopList[indexPath.row];
        } else{
            thread = self.dataList[indexPath.row];
        }
        
        [self.transValueDelegate transValue:thread];
        
    }
    
    
}


- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)createThread:(id)sender {
}


@end
