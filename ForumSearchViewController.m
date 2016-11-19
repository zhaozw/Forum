//
//  ForumSearchViewController.m
//
//  Created by WDY on 16/1/11.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumSearchViewController.h"

#import "ForumSearchResultCell.h"
#import "ForumUserProfileTableViewController.h"
#import <SVProgressHUD.h>
#import "ForumWebViewController.h"

@interface ForumSearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ThreadListCellDelegate, MGSwipeTableCellDelegate> {
    NSString *_searchid;
    UIStoryboardSegue *selectSegue;
    NSString *searchText;
}

@end

@implementation ForumSearchViewController

- (void)viewDidLoad {
    self.searchBar.delegate = self;

    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self onLoadMore];
    }];

}

- (void)onLoadMore {

    if (_searchid == nil) {
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    [self.ccfApi listSearchResultWithSearchid:_searchid andPage:self.currentPage + 1 handler:^(BOOL isSuccess, SearchForumDisplayPage *message) {
        [self.tableView.mj_footer endRefreshing];

        if (isSuccess) {

            self.currentPage++;
            self.totalPage = (int) message.totalPageCount;

            if (self.currentPage >= self.totalPage) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }

            [self.dataList addObjectsFromArray:message.dataList];
            [self.tableView reloadData];
        } else {
            NSLog(@"searchBarSearchButtonClicked   ERROR %@", message);
        }
    }];

}


#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchText = searchBar.text;

    [searchBar resignFirstResponder];

    [SVProgressHUD showWithStatus:@"搜索中" maskType:SVProgressHUDMaskTypeBlack];

    int select = (int) self.segmentedControl.selectedSegmentIndex;

    [self.ccfApi searchWithKeyWord:searchText forType:select handler:^(BOOL isSuccess, SearchForumDisplayPage *message) {
        [SVProgressHUD dismiss];

        if (isSuccess) {
            _searchid = message.searchid;

            self.currentPage = (int) message.currentPage;
            self.totalPage = (int) message.totalPageCount;

            [self.dataList removeAllObjects];
            [self.dataList addObjectsFromArray:message.dataList];
            [self.tableView reloadData];
        } else {
            NSLog(@"searchBarSearchButtonClicked   ERROR %@", message);
            NSString * msg = (NSString *)message;
            [SVProgressHUD showErrorWithStatus:msg maskType:SVProgressHUDMaskTypeBlack];
        }
    }];

}

- (void)showUserProfile:(NSIndexPath *)indexPath {
    ForumUserProfileTableViewController *controller = selectSegue.destinationViewController;
    ThreadInSearch *thread = self.dataList[(NSUInteger) indexPath.row];
    TransBundle *bundle = [[TransBundle alloc] init];
    [bundle putIntValue:[thread.threadAuthorID intValue] forKey:@"UserId"];

    [self transBundle:bundle forController:controller];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarShouldBeginEditing");
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *QuoteCellIdentifier = @"SearchResultCell";

    ForumSearchResultCell *cell = (ForumSearchResultCell *) [tableView dequeueReusableCellWithIdentifier:QuoteCellIdentifier];
    cell.showUserProfileDelegate = self;

    ThreadInSearch *thread = self.dataList[(NSUInteger) indexPath.row];

    [cell setData:thread forIndexPath:indexPath];

    cell.showUserProfileDelegate = self;

    cell.indexPath = indexPath;

    cell.delegate = self;

    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"收藏此主题" backgroundColor:[UIColor lightGrayColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;

    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];

    return cell;
}


- (BOOL)swipeTableCell:(MGSwipeTableCellWithIndexPath *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    NSIndexPath *indexPath = cell.indexPath;


    ThreadInSearch *play = self.dataList[(NSUInteger) indexPath.row];

    [self.ccfApi favoriteThreadPostWithId:play.threadID handler:^(BOOL isSuccess, id message) {
        BOOL success = isSuccess;
        NSString * result = message;
    }];


    return YES;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"SearchResultCell" configuration:^(ForumSearchResultCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)configureCell:(ForumSearchResultCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"

    [cell setData:self.dataList[(NSUInteger) indexPath.row]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowThreadPosts"]) {

        ForumWebViewController *controller = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        ThreadInSearch *thread = self.dataList[(NSUInteger) indexPath.row];

        TransBundle *transBundle = [[TransBundle alloc] init];
        [transBundle putIntValue:[thread.threadID intValue] forKey:@"threadID"];
        [transBundle putStringValue:thread.threadAuthorName forKey:@"threadAuthorName"];

        [self transBundle:transBundle forController:controller];

    } else if ([segue.identifier isEqualToString:@"ShowUserProfile"]) {
        selectSegue = segue;
    }
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
