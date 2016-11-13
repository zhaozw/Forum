//
//  ForumThreadListForChildFormUITableViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/3/27.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumThreadListForChildFormUITableViewController.h"

#import "CCFThreadListCell.h"
#import "ForumNewThreadViewController.h"
#import "ForumUserProfileTableViewController.h"
#import "ForumWebViewController.h"

@interface ForumThreadListForChildFormUITableViewController ()<TransBundleDelegate, MGSwipeTableCellDelegate> {
    NSArray *childForms;
    int forumId;
}

@end

@implementation ForumThreadListForChildFormUITableViewController

- (void)transBundle:(TransBundle *)bundle {
    forumId = [bundle getIntValue:@"ForumId"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    ForumCoreDataManager *manager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
    childForms = [[manager selectChildFormsForId:forumId] mutableCopy];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 180.0;

    if (self.threadTopList == nil) {
        self.threadTopList = [NSMutableArray array];
    }

    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
}

- (void)onPullRefresh {
    [self.ccfApi forumDisplayWithId:forumId andPage:1 handler:^(BOOL isSuccess, ForumDisplayPage *page) {

        [self.tableView.mj_header endRefreshing];

        if (isSuccess) {
            self.totalPage = (int) page.totalPageCount;
            self.currentPage = 1;
            if (self.currentPage >= self.totalPage) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }

            [self.threadTopList removeAllObjects];
            [self.dataList removeAllObjects];

            for (NormalThread *thread in page.dataList) {
                if (thread.isTopThread) {
                    [self.threadTopList addObject:thread];
                } else {
                    [self.dataList addObject:thread];
                }
            }

            [self.tableView reloadData];
        }
    }];
}

- (void)onLoadMore {
    [self.ccfApi forumDisplayWithId:forumId andPage:self.currentPage + 1 handler:^(BOOL isSuccess, ForumDisplayPage *page) {

        [self.tableView.mj_footer endRefreshing];

        if (isSuccess) {
            self.totalPage = (int) page.totalPageCount;
            self.currentPage++;
            if (self.currentPage >= self.totalPage) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }

            for (NormalThread *thread in page.dataList) {
                if (!thread.isTopThread) {
                    [self.dataList addObject:thread];
                }
            }

            [self.tableView reloadData];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return self.threadTopList.count;
    } else {
        return self.dataList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // 帖子内容
    static NSString *reusedIdentifier = @"CCFThreadListCellIdentifier";

    CCFThreadListCell *cell = (CCFThreadListCell *) [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];

    if (indexPath.section == 0) {
        NormalThread *play = self.threadTopList[(NSUInteger) indexPath.row];
        [cell setData:play];
    } else {
        NormalThread *play = self.dataList[(NSUInteger) indexPath.row];
        [cell setData:play];
    }

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
    if (indexPath.section == 0) {
        NormalThread *play = self.threadTopList[(NSUInteger) indexPath.row];

        [self.ccfApi favoriteThreadPostWithId:play.threadID handler:^(BOOL isSuccess, id message) {

        }];
    } else {
        NormalThread *play = self.threadTopList[(NSUInteger) indexPath.row];

        [self.ccfApi favoriteThreadPostWithId:play.threadID handler:^(BOOL isSuccess, id message) {

        }];
    }

    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"CCFThreadListCellIdentifier" configuration:^(CCFThreadListCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}


- (void)configureCell:(CCFThreadListCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"

    [cell setData:self.dataList[(NSUInteger) indexPath.row]];
}

#pragma mark Controller跳转


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([sender isKindOfClass:[UIBarButtonItem class]]) {

        ForumNewThreadViewController *newPostController = segue.destinationViewController;
        TransBundle * bundle = [[TransBundle alloc] init];
        [bundle putIntValue:forumId forKey:@"FORM_ID"];
        [self transBundle:bundle forController:newPostController];
        
    } else if ([sender isKindOfClass:[UITableViewCell class]]) {

        ForumWebViewController *controller = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        NormalThread *thread = nil;
        if (indexPath.section == 0) {
            thread = self.threadTopList[(NSUInteger) indexPath.row];
        } else {
            thread = self.dataList[(NSUInteger) indexPath.row];
        }

        TransBundle *transBundle = [[TransBundle alloc] init];
        [transBundle putIntValue:[thread.threadID intValue] forKey:@"threadID"];
        [transBundle putStringValue:thread.threadAuthorName forKey:@"threadAuthorName"];

        [self transBundle:transBundle forController:controller];


    } else if ([sender isKindOfClass:[UIButton class]]) {
        ForumUserProfileTableViewController *controller = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NormalThread *thread = nil;
        if (indexPath.section == 0) {
            thread = self.threadTopList[(NSUInteger) indexPath.row];
        } else {
            thread = self.dataList[(NSUInteger) indexPath.row];
        }
        TransBundle * bundle = [[TransBundle alloc] init];
        [bundle putIntValue:[thread.threadAuthorID intValue] forKey:@"UserId"];
        [self transBundle:bundle forController:controller];
    }


}

- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)createThread:(id)sender {
}


@end
