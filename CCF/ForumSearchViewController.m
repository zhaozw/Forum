//
//  ForumSearchViewController.m
//  CCF
//
//  Created by WDY on 16/1/11.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumSearchViewController.h"

#import "CCFSearchResultCell.h"
#import "ForumUserProfileTableViewController.h"
#import <SVProgressHUD.h>
#import "ForumWebViewController.h"
#import "TransBundle.h"
#import "UIViewController+TransBundle.h"

@interface ForumSearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CCFThreadListCellDelegate> {
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
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


- (void)keyboardDidHide:(id)sender {
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
        }
    }];
}

#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchText = searchBar.text;

    [searchBar resignFirstResponder];

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

    static NSString *QuoteCellIdentifier = @"CCFSearchResultCell";

    CCFSearchResultCell *cell = (CCFSearchResultCell *) [tableView dequeueReusableCellWithIdentifier:QuoteCellIdentifier];
    cell.showUserProfileDelegate = self;
    [cell setData:self.dataList[(NSUInteger) indexPath.row]];


    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"CCFSearchResultCell" configuration:^(CCFSearchResultCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)configureCell:(CCFSearchResultCell *)cell atIndexPath:(NSIndexPath *)indexPath {
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
