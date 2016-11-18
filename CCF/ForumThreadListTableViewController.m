//
//  ForumThreadListTableViewController.m
//
//  Created by 迪远 王 on 16/1/1.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumThreadListTableViewController.h"

#import "ForumThreadListCell.h"
#import "ForumNewThreadViewController.h"
#import "ForumUserProfileTableViewController.h"
#import "ForumThreadListForChildFormUITableViewController.h"
#import "NSUserDefaults+Setting.h"
#import "UIStoryboard+Forum.h"
#import "ForumWebViewController.h"
#import "ForumNewThreadNavigationController.h"


@interface ForumThreadListTableViewController () <TransBundleDelegate, CCFThreadListCellDelegate, MGSwipeTableCellDelegate> {
    Forum *transForm;
    NSArray *childForms;
    UIStoryboardSegue *selectSegue;
}

@end

@implementation ForumThreadListTableViewController

#pragma mark trans value

- (void)transBundle:(TransBundle *)bundle {
    transForm = [bundle getObjectValue:@"TransForm"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    ForumCoreDataManager *manager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
    childForms = [[manager selectChildFormsForId:transForm.formId] mutableCopy];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 180.0;

    if (self.threadTopList == nil) {
        self.threadTopList = [NSMutableArray array];
    }

    self.titleNavigationItem.title = transForm.formName;

    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
}

- (void)onPullRefresh {
    [self.ccfApi forumDisplayWithId:transForm.formId andPage:1 handler:^(BOOL isSuccess, ForumDisplayPage *page) {

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
    [self.ccfApi forumDisplayWithId:transForm.formId andPage:self.currentPage + 1 handler:^(BOOL isSuccess, ForumDisplayPage *page) {

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
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        // 子论坛列表
        return childForms.count;
    } else if (section == 1) {
        if ([[NSUserDefaults standardUserDefaults] isTopThreadPostCanShow]) {
            return self.threadTopList.count;
        } else {
            return 0;
        }


    } else {
        return self.dataList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *reusedIdentifier = @"CCFThreadListCellIdentifier";

    if (indexPath.section == 0) {
        // 子论坛
        static NSString *reusedIdentifierForm = @"CCFThreadListCellShowChildForm";
        MGSwipeTableCellWithIndexPath *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifierForm];

        cell.indexPath = indexPath;

        cell.delegate = self;

        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"订阅此论坛" backgroundColor:[UIColor lightGrayColor]]];
        cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;

        Forum *form = childForms[(NSUInteger) indexPath.row];
        cell.textLabel.text = form.formName;

        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0,16,0,16);
        [cell setSeparatorInset:edgeInsets];
        [cell setLayoutMargins:UIEdgeInsetsZero];

        return cell;
    } else if (indexPath.section == 1) {

        // 置顶帖子
        ForumThreadListCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];

        NormalThread *play = self.threadTopList[(NSUInteger) indexPath.row];

        [cell setData:play forIndexPath:indexPath];

        cell.showUserProfileDelegate = self;

        cell.indexPath = indexPath;

        cell.delegate = self;

        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"收藏此主题" backgroundColor:[UIColor lightGrayColor]]];
        cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;


        [cell setSeparatorInset:UIEdgeInsetsZero];
        [cell setLayoutMargins:UIEdgeInsetsZero];

        return cell;
    } else {

        // 普通帖子
        ForumThreadListCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];

        NormalThread *play = self.dataList[(NSUInteger) indexPath.row];

        [cell setData:play forIndexPath:indexPath];

        cell.showUserProfileDelegate = self;


        cell.indexPath = indexPath;

        cell.delegate = self;

        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"收藏此主题" backgroundColor:[UIColor lightGrayColor]]];
        cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;

        [cell setSeparatorInset:UIEdgeInsetsZero];
        [cell setLayoutMargins:UIEdgeInsetsZero];

        return cell;
    }
}


- (BOOL)swipeTableCell:(MGSwipeTableCellWithIndexPath *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    NSIndexPath *indexPath = cell.indexPath;
    if (indexPath.section == 0) {
        Forum *parent = childForms[(NSUInteger) cell.indexPath.section];

        [self.ccfApi favoriteFormsWithId:[NSString stringWithFormat:@"%d", parent.formId] handler:^(BOOL isSuccess, id message) {
            NSLog(@">>>>>>>>>>>> %@", message);
        }];
    } else if (indexPath.section == 1) {
        NormalThread *play = self.threadTopList[(NSUInteger) indexPath.row];

        [self.ccfApi favoriteThreadPostWithId:play.threadID handler:^(BOOL isSuccess, id message) {

        }];
    } else {
        NormalThread *play = self.dataList[(NSUInteger) indexPath.row];

        [self.ccfApi favoriteThreadPostWithId:play.threadID handler:^(BOOL isSuccess, id message) {

        }];
    }


    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 54;
    } else {
        return [tableView fd_heightForCellWithIdentifier:@"CCFThreadListCellIdentifier" configuration:^(ForumThreadListCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
    }
}


- (void)configureCell:(ForumThreadListCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"

    [cell setData:self.dataList[(NSUInteger) indexPath.row]];
}

- (void)showUserProfile:(NSIndexPath *)indexPath {

    ForumUserProfileTableViewController *controller = selectSegue.destinationViewController;
    NormalThread *thread = nil;

    if (childForms.count == 0) {
        if (indexPath.section == 0) {
            thread = self.threadTopList[(NSUInteger) indexPath.row];
        } else {
            thread = self.dataList[(NSUInteger) indexPath.row];
        }
    } else {
        if (indexPath.section == 1) {
            thread = self.threadTopList[(NSUInteger) indexPath.row];
        } else {
            thread = self.dataList[(NSUInteger) indexPath.row];
        }
    }
    TransBundle * bundle = [[TransBundle alloc] init];
    [bundle putIntValue:[thread.threadAuthorID intValue] forKey:@"UserId"];
    [self transBundle:bundle forController:controller];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark Controller跳转


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([sender isKindOfClass:[UIBarButtonItem class]]) {

        ForumNewThreadViewController *newPostController = segue.destinationViewController;
        TransBundle * bundle = [[TransBundle alloc] init];
        [bundle putIntValue:transForm.formId forKey:@"FORM_ID"];
        [self transBundle:bundle forController:newPostController];



    } else if ([segue.identifier isEqualToString:@"ShowThreadPosts"]) {

        ForumWebViewController *controller = segue.destinationViewController;


        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NormalThread *thread = nil;
        NSInteger section = indexPath.section;
        if (section == 1) {
            thread = self.threadTopList[(NSUInteger) indexPath.row];
        } else if (section == 2) {
            thread = self.dataList[(NSUInteger) indexPath.row];
        }

        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putIntValue:[thread.threadID intValue] forKey:@"threadID"];
        [bundle putStringValue:thread.threadAuthorName forKey:@"threadAuthorName"];

        [self transBundle:bundle forController:controller];

    } else if ([segue.identifier isEqualToString:@"ShowChildForm"]) {
        ForumThreadListForChildFormUITableViewController *controller = segue.destinationViewController;

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        int row = indexPath.row;
        Forum * forum = childForms[(NSUInteger) row];
        TransBundle * bundle = [[TransBundle alloc] init];
        [bundle putIntValue:forum.formId forKey:@"ForumId"];
        [self transBundle:bundle forController:controller];

    } else if ([segue.identifier isEqualToString:@"ShowUserProfile"]) {
        selectSegue = segue;
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
    UIStoryboard *storyboard = [UIStoryboard mainStoryboard];

    ForumNewThreadNavigationController *createController = (id) [storyboard instantiateViewControllerWithIdentifier:@"CreateNewThread"];

    TransBundle *bundle = [[TransBundle alloc] init];
    [bundle putIntValue:transForm.formId forKey:@"FORM_ID"];
    [self presentViewController:(id) createController withBundle:bundle forRootController:YES animated:YES completion:^{

    }];
}

@end
