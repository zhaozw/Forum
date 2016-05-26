//
//  CCFShowNewThreadPostTableViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/3/6.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFShowNewThreadPostTableViewController.h"
#import "CCFNavigationController.h"
#import "ForumDisplayPage.h"
#import "ThreadInSearch.h"
#import "CCFSearchResultCell.h"
#import "ThreadInSearch.h"
#import "CCFProfileTableViewController.h"
#import "DRLTabBarController.h"
#import "CCFShowThreadViewController.h"

@interface CCFShowNewThreadPostTableViewController ()<CCFThreadListCellDelegate>{
    UIStoryboardSegue * selectSegue;
}

@end

@implementation CCFShowNewThreadPostTableViewController

-(void)onPullRefresh{
    [self.ccfApi listNewThreadPostsWithPage:1 handler:^(BOOL isSuccess, ForumDisplayPage *message) {
        [self.tableView.mj_header endRefreshing];
        if (isSuccess) {
            [self.tableView.mj_footer endRefreshing];
            
            self.currentPage = 1;
            self.totalPage = (int)message.totalPageCount;
            
            if (self.currentPage >= self.totalPage) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            [self.dataList removeAllObjects];
            [self.dataList addObjectsFromArray:message.dataList];
            [self.tableView reloadData];
        }
        
    }];
}

-(void)onLoadMore{
    [self.ccfApi listNewThreadPostsWithPage:self.currentPage + 1 handler:^(BOOL isSuccess, ForumDisplayPage *message) {
        [self.tableView.mj_footer endRefreshing];
        if (isSuccess) {
            self.currentPage++;
            self.totalPage = (int)message.totalPageCount;
            if (self.currentPage >= self.totalPage) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.dataList addObjectsFromArray:message.dataList];
            [self.tableView reloadData];
        }
        
    }];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellId = @"CCFSearchResultCell";
    CCFSearchResultCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.showUserProfileDelegate = self;
    
    ThreadInSearch * thread = self.dataList[indexPath.row];
    [cell setData:thread forIndexPath:indexPath];
    return cell;
}

-(void)showUserProfile:(NSIndexPath *)indexPath{
    CCFProfileTableViewController * controller = selectSegue.destinationViewController;
    self.transValueDelegate = (id<TransValueDelegate>)controller;
    
    ThreadInSearch * thread = self.dataList[indexPath.row];
    
    [self.transValueDelegate transValue:thread];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView fd_heightForCellWithIdentifier:@"CCFSearchResultCell" configuration:^(CCFSearchResultCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)configureCell:(CCFSearchResultCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    
    [cell setData:self.dataList[indexPath.row] forIndexPath:indexPath];
}


#pragma mark Controller跳转
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"ShowThreadPosts"]){
        CCFShowThreadViewController * controller = segue.destinationViewController;
        self.transValueDelegate = (id<TransValueDelegate>)controller;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        Thread * thread = self.dataList[indexPath.row];

        [self.transValueDelegate transValue:thread];
        
    } else if ([segue.identifier isEqualToString:@"ShowUserProfile"]){
        selectSegue = segue;
    }
}

- (IBAction)showLeftDrawer:(id)sender {
//    CCFNavigationController * rootController = (CCFNavigationController*)self.navigationController;
//    [rootController showLeftDrawer];
    
    DRLTabBarController * root = (DRLTabBarController *)self.tabBarController;
    [root showLeftDrawer];
}
@end
