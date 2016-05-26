//
//  CCFThreadTableViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/1/1.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFThreadListTableViewController.h"

#import "UrlBuilder.h"
#import "CCFParser.h"
#import "CCFThreadListCell.h"
#import "CCFShowThreadViewController.h"
#import "MJRefresh.h"
#import "CCFNewThreadViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "CCFProfileTableViewController.h"
#import "CCFThreadListForChildFormUITableViewController.h"
#import "NSUserDefaults+Setting.h"
#import "CCFNewThreadNavigationController.h"
#import "UIStoryboard+CCF.h"
#import <SVProgressHUD.h>
#import "ForumCoreDataManager.h"
#import "MGSwipeTableCellWithIndexPath.h"



#define TypePullRefresh 0
#define TypeLoadMore 1

@interface CCFThreadListTableViewController ()<TransValueDelegate, CCFThreadListCellDelegate, TransBundleDelegate, MGSwipeTableCellDelegate>{
    Forum * transForm;
    
    NSArray * childForms;
    
    UIStoryboardSegue * selectSegue;
}

@end

@implementation CCFThreadListTableViewController

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
    
    self.titleNavigationItem.title = transForm.formName;

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
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
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
    } else if (section == 1){
        if ([[NSUserDefaults standardUserDefaults] isTopThreadPostCanShow]) {
            return self.threadTopList.count;
        } else{
            return 0;
        }
        
        
    } else{
        return self.dataList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 帖子内容
    static NSString *reusedIdentifier = @"CCFThreadListCellIdentifier";
    
    if (indexPath.section == 0) {
        // 子论坛
        static NSString *reusedIdentifierForm = @"CCFThreadListCellShowChildForm";
        MGSwipeTableCellWithIndexPath *cell = (MGSwipeTableCellWithIndexPath*)[tableView dequeueReusableCellWithIdentifier:reusedIdentifierForm];
        
        cell.indexPath = indexPath;
        
        cell.delegate = self;
        
        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"订阅此论坛" backgroundColor:[UIColor lightGrayColor]]];
        cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
        
        Forum * form = childForms[indexPath.row];
        cell.textLabel.text = form.formName;
        return cell;
    } else if(indexPath.section == 1){
        
        CCFThreadListCell *cell = (CCFThreadListCell*)[tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
        
        NormalThread *play = self.threadTopList[indexPath.row];
        
        [cell setData:play forIndexPath:indexPath];
        
        cell.showUserProfileDelegate = self;
        
        cell.indexPath = indexPath;
        
        cell.delegate = self;
        
        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"收藏此主题" backgroundColor:[UIColor lightGrayColor]]];
        cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
        
        
        
        return cell;
    } else{
        
        CCFThreadListCell *cell = (CCFThreadListCell*)[tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
        
        NormalThread *play = self.dataList[indexPath.row];
        
        [cell setData:play forIndexPath:indexPath];
        
        cell.showUserProfileDelegate = self;
        
        
        cell.indexPath = indexPath;
        
        cell.delegate = self;
        
        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"收藏此主题" backgroundColor:[UIColor lightGrayColor]]];
        cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
        
        return cell;
    }
}

-(BOOL)swipeTableCell:(MGSwipeTableCellWithIndexPath *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion{
    NSIndexPath * indexPath = cell.indexPath;
    if (indexPath.section == 0) {
        Forum * parent = childForms[cell.indexPath.section];
        
        [self.ccfApi favoriteFormsWithId:[NSString stringWithFormat:@"%d",parent.formId] handler:^(BOOL isSuccess, id message) {
            NSLog(@">>>>>>>>>>>> %@", message);
        }];
    } else{
         NormalThread *play = self.threadTopList[indexPath.row];
        
        [self.ccfApi favoriteThreadPostWithId:play.threadID handler:^(BOOL isSuccess, id message) {
            
        }];
    }

    
    return YES;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 44;
    } else{
        return [tableView fd_heightForCellWithIdentifier:@"CCFThreadListCellIdentifier" configuration:^(CCFThreadListCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
    }
}

- (void)configureCell:(CCFThreadListCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    
    [cell setData:self.dataList[indexPath.row]];
}


-(void)showUserProfile:(NSIndexPath *)indexPath{
    
    CCFProfileTableViewController * controller = (CCFProfileTableViewController *)selectSegue.destinationViewController;
    self.transValueDelegate = (id<TransValueDelegate>)controller;
    
    NormalThread * thread = nil;
    
    if (childForms.count == 0) {
        if (indexPath.section == 0) {
            thread = self.threadTopList[indexPath.row];
        } else{
            thread = self.dataList[indexPath.row];
        }
    } else{
        if (indexPath.section == 1) {
            thread = self.threadTopList[indexPath.row];
        } else{
            thread = self.dataList[indexPath.row];
        }
    }

    
    [self.transValueDelegate transValue:thread];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
#pragma mark Controller跳转
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        
        CCFNewThreadViewController * newPostController = segue.destinationViewController;

        self.transValueDelegate = (id<TransValueDelegate>)newPostController;
        [self.transValueDelegate transValue:transForm];
        
        
    } else if([segue.identifier isEqualToString:@"ShowThreadPosts"]){
        CCFShowThreadViewController * controller = segue.destinationViewController;
        self.transValueDelegate = (id<TransValueDelegate>)controller;

        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NormalThread * thread = nil;
        
        NSInteger section = indexPath.section;
        
        if ( section == 1) {
            thread = self.threadTopList[indexPath.row];
        } else if(section == 2){
            thread = self.dataList[indexPath.row];
        }
        
        
        [self.transValueDelegate transValue:thread];
        
    } else if ([segue.identifier isEqualToString:@"ShowChildForm"]){
        CCFThreadListForChildFormUITableViewController * controller = segue.destinationViewController;
        self.transValueDelegate = (id<TransValueDelegate>)controller;
        [self.transValueDelegate transValue:transForm];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.transValueDelegate transValue:childForms[indexPath.row]];
        
    } else if ([segue.identifier isEqualToString:@"ShowUserProfile"]){
        selectSegue = segue;
    }
    
    else if ([sender isKindOfClass:[UIButton class]]){
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

-(void)transBundle:(TransValueBundle *)bundle{
    
}
- (IBAction)createThread:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
    
    CCFNewThreadNavigationController * createController = [storyboard instantiateViewControllerWithIdentifier:@"CCFNewThreadNavigationController"];
    self.transBundleDelegate = (id<TransBundleDelegate>)createController;
    
    TransValueBundle * bundle = [[TransValueBundle alloc] init];
    [bundle putIntValue:transForm.formId forKey:@"FORM_ID"];
    [self.transBundleDelegate transBundle:bundle];
    
    [self.navigationController presentViewController:createController animated:YES completion:^{
        
    }];
}
@end
