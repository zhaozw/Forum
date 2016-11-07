//
//  ForumFavThreadPostTableViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/3/12.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumFavThreadPostTableViewController.h"
#import "CCFSimpleThreadTableViewCell.h"
#import "ForumTabBarController.h"
#import "ForumWebViewController.h"
#import "ForumUserProfileTableViewController.h"
#import "UIStoryboard+CCF.h"
#import "UIViewController+TransBundle.h"

@interface ForumFavThreadPostTableViewController () <MGSwipeTableCellDelegate, CCFThreadListCellDelegate> {
    UIStoryboardSegue *selectSegue;
}

@end

@implementation ForumFavThreadPostTableViewController

- (void)onPullRefresh {
    [self.ccfApi listFavoriteThreadPostsWithPage:1 handler:^(BOOL isSuccess, ForumDisplayPage *resultPage) {

        [self.tableView.mj_header endRefreshing];
        if (isSuccess) {

            [self.tableView.mj_header endRefreshing];

            self.currentPage = 1;
            self.totalPage = (int) resultPage.totalPageCount;
            [self.dataList removeAllObjects];
            [self.dataList addObjectsFromArray:resultPage.dataList];
            [self.tableView reloadData];
        }
    }];
}

- (void)onLoadMore {
    [self.ccfApi listFavoriteThreadPostsWithPage:self.currentPage handler:^(BOOL isSuccess, ForumDisplayPage *resultPage) {

        [self.tableView.mj_footer endRefreshing];

        if (isSuccess) {
            self.totalPage = (int) resultPage.totalPageCount;
            self.currentPage++;
            if (self.currentPage >= self.totalPage) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.dataList addObjectsFromArray:resultPage.dataList];

            [self.tableView reloadData];
        }
    }];
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CCFSimpleThreadTableViewCell";
    CCFSimpleThreadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.showUserProfileDelegate = self;
    //configure right buttons
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"取消收藏" backgroundColor:[UIColor lightGrayColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;

    SimpleThread *list = self.dataList[(NSUInteger) indexPath.row];
    [cell setData:list forIndexPath:indexPath];

    return cell;
}


- (BOOL)swipeTableCell:(MGSwipeTableCellWithIndexPath *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {

    SimpleThread *list = self.dataList[(NSUInteger) cell.indexPath.row];

    [self.ccfApi unfavoriteThreadPostWithId:list.threadID handler:^(BOOL isSuccess, id message) {
        NSLog(@">>>>>>>>>>>> %@", message);
    }];

    [self.dataList removeObjectAtIndex:(NSUInteger) cell.indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationLeft];

    return YES;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"CCFSimpleThreadTableViewCell" configuration:^(CCFSimpleThreadTableViewCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)configureCell:(CCFSimpleThreadTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"

    [cell setData:self.dataList[(NSUInteger) indexPath.row]];
}

#pragma mark Controller跳转

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowThreadPosts"]) {
        ForumWebViewController *controller = segue.destinationViewController;

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        Thread *thread = self.dataList[(NSUInteger) indexPath.row];

        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putIntValue:[thread.threadID intValue] forKey:@"threadID"];
        [bundle putStringValue:thread.threadAuthorName forKey:@"threadAuthorName"];

        [self transBundle:bundle forController:controller];

    } else if ([segue.identifier isEqualToString:@"ShowUserProfile"]) {
        selectSegue = segue;
    }
}

- (void)showUserProfile:(NSIndexPath *)indexPath {

    ForumUserProfileTableViewController *controller = selectSegue.destinationViewController;

    TransBundle *bundle = [[TransBundle alloc] init];
    SimpleThread *thread = self.dataList[(NSUInteger) indexPath.row];
    [bundle putIntValue:[thread.threadAuthorID intValue] forKey:@"UserId"];
    [self transBundle:bundle forController:controller];

}

- (IBAction)showLeftDrawer:(id)sender {
    ForumTabBarController *controller = (ForumTabBarController *) self.tabBarController;


    UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
    UINavigationController *myProfileControllder = [storyboard instantiateViewControllerWithIdentifier:@"CCFMyProfileNavigationController"];
    [controller presentViewController:myProfileControllder animated:YES completion:^{

    }];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
