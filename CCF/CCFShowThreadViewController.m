//
//  CCFThreadDetailTableViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/1/1.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFShowThreadViewController.h"
#import "CCFThreadDetailCell.h"
#import "UrlBuilder.h"
#import "CCFParser.h"

#import "MJRefresh.h"
#import "AutoRelayoutUITextView.h"

#import "ShowThreadPage.h"


#import <UITableView+FDTemplateLayoutCell.h>
#import "TransValueDelegate.h"
#import "ForumApi.h"
#import "Thread.h"
#import "TransValueUITableViewCell.h"
#import "CCFProfileTableViewController.h"
#import "CCFNavigationController.h"
#import "UIStoryboard+CCF.h"
#import "CCFSeniorNewPostViewController.h"
#import "TransValueBundle.h"
#import <LCActionSheet.h>
#import <SVProgressHUD.h>
#import "ActionSheetPicker.h"
#import "NSString+Extensions.h"
#import "CCFThreadListTitleCell.h"
#import "PageHeaderView.h"
#import "CCFThreadNotLoadTableViewCell.h"
#import "CCFSimpleReplyNavigationController.h"
#import "CCFSimpleReplyViewController.h"



#import "XibInflater.h"

@interface CCFShowThreadViewController ()< UITextViewDelegate, CCFThreadDetailCellDelegate, TransValueDelegate, CCFThreadListCellDelegate, ReplyCallbackDelegate>{
    
    
    int currentPageNumber;
    int totalPageCount;

    ForumApi *_api;
    
    Thread * transThread;
    
    UIStoryboardSegue * selectSegue;
    
    ShowThreadPage * currentThreadPage;
    
    LCActionSheet * itemActionSheet;
    NSMutableDictionary<NSIndexPath *, NSNumber *> *cellHeightDictionary;
    NSMutableDictionary * postSet;
}

@end

@implementation CCFShowThreadViewController

#pragma mark trans value
-(void)transValue:(Thread *)value{
    transThread = value;
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        postSet = [NSMutableDictionary dictionary];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;


    
    
    
    _api = [[ForumApi alloc] init];
    
    cellHeightDictionary = [NSMutableDictionary<NSIndexPath *, NSNumber *> dictionary];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    currentPageNumber = 1;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [_api showThreadWithId:[transThread.threadID intValue] andPage:1 handler:^(BOOL isSuccess, ShowThreadPage * thread) {
            [self.tableView.mj_header endRefreshing];
            
            if (isSuccess) {
                currentPageNumber = 1;

                totalPageCount = (int)thread.totalPageCount;

                
                NSMutableArray<Post *> * parsedPosts = thread.dataList;

                currentThreadPage = thread;

                [postSet setObject:parsedPosts forKey:[NSNumber numberWithInt:currentPageNumber]];
                
                [self.tableView reloadData];
            }
            
        }];
    }];
    
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        
        [_api showThreadWithId:[transThread.threadID intValue] andPage:currentPageNumber + 1 handler:^(BOOL isSuccess, ShowThreadPage * thread) {
            
            [self.tableView.mj_footer endRefreshing];
            
            if (isSuccess) {
                currentPageNumber ++;
                totalPageCount = (int)thread.totalPageCount;
                

                NSMutableArray<Post *> * parsedPosts = thread.dataList;


                currentThreadPage = thread;
                
                NSMutableArray<Post *> * currentPosts = [postSet objectForKey:[NSNumber numberWithInt:currentPageNumber]];
                if (currentPageNumber >= totalPageCount) {
                    if (currentPosts != nil && currentPosts.count == parsedPosts.count) {
                        [self showNoMoreDataView];
                    }
                    
                }
                [postSet setObject:parsedPosts forKey:[NSNumber numberWithInt:currentPageNumber]];
                
                

                
                [self.tableView reloadData];
            }
            
        }];
        
    }];

    
    
    [self.tableView.mj_header beginRefreshing];

    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    for (int i = totalPageCount; i >= 0; i--) {
        
        
        int count = (int)[[postSet objectForKey:[NSNumber numberWithInteger:i]] count];
        if (count > 0) {
            return 1 + i;
        }
    }
    return 1 + totalPageCount;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    return 22;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString * title = [NSString stringWithFormat:@"%ld/%d", section, totalPageCount];
    self.pageNumber.title = title;
    
    if (section == 0) {
        return nil;
    } else{
        
        PageHeaderView *headerView = [XibInflater inflateViewByXibName:@"PageHeaderView"];
        //[headerView.pageNumber setTitle:title forState:UIControlStateNormal];
        headerView.pageNumber.text = [NSString stringWithFormat:@"PAGE %ld", section];
        return headerView;
    }

    
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSArray * visiblCells = [self.tableView visibleCells];
    if (visiblCells.count > 0) {
        
        NSUInteger sectionNumber = [[self.tableView indexPathForCell:visiblCells.lastObject] section];
        
        if (sectionNumber !=0) {
            
            currentPageNumber = (int)sectionNumber;
            
            NSString * title = [NSString stringWithFormat:@"%ld/%d", sectionNumber, totalPageCount];
            PageHeaderView *headerView = (PageHeaderView*)[self.tableView headerViewForSection:sectionNumber];

            headerView.pageNumber.text = [NSString stringWithFormat:@"PAGE %ld", sectionNumber];
            
            [self.pageNumber setTitle:title];

        }
    }


    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else{
        
        int count = (int)[[postSet objectForKey:[NSNumber numberWithInteger:section]] count];
        if (count == 0) {
            return 1;
        } else{
            return count;
        }
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CCFThreadListTitleCell *cell = (CCFThreadListTitleCell*)[tableView dequeueReusableCellWithIdentifier:@"CCFThreadTitleId"];
        cell.threadTitle.text = transThread.threadTitle;
        return cell;
        
    } else{
        int count = (int)[[postSet objectForKey:[NSNumber numberWithInteger:indexPath.section]] count];
        if (count == 0) {
            
            static NSString *cellId = @"CCFThreadDetailNotLoadId";
            
            CCFThreadNotLoadTableViewCell * cell = (CCFThreadNotLoadTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellId];
            
            return cell;
        } else{
            static NSString *QuoteCellIdentifier = @"CCFThreadDetailCellIdentifier";
            
            CCFThreadDetailCell *cell = (CCFThreadDetailCell*)[tableView dequeueReusableCellWithIdentifier:QuoteCellIdentifier];
            cell.showUserProfileDelegate = self;
            cell.detailDelegate = self;
            NSArray * posts = [postSet objectForKey:[NSNumber numberWithInteger:indexPath.section]];
            
            
            Post *post = posts[indexPath.row];
            [cell setPost:post forIndexPath:indexPath];
            
            return cell;
        }

    }

}

-(void)relayoutContentHeigt:(NSIndexPath *)indexPath with:(CGFloat)height{
    NSNumber * nsheight = [cellHeightDictionary objectForKey:indexPath];
    if (nsheight == nil) {
        [cellHeightDictionary setObject:[NSNumber numberWithFloat:height] forKey:indexPath];
        NSIndexPath *indexPathReload=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPathReload,nil] withRowAnimation:UITableViewRowAnimationNone];
    }

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [tableView fd_heightForCellWithIdentifier:@"CCFThreadTitleId" configuration:^(CCFThreadListTitleCell *cell) {
            
                    cell.threadTitle.text = transThread.threadTitle;
                }];
    } else{
        int count = (int)[[postSet objectForKey:[NSNumber numberWithInteger:indexPath.section]] count];
        if (count == 0) {
            return 44;
        } else{
            NSNumber * nsheight = [cellHeightDictionary objectForKey:indexPath];
            if (nsheight == nil) {
                return  115.0;
            }
            return nsheight.floatValue;
        }

    }

}

#pragma mark LCActionSheetDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    int count = (int)[[postSet objectForKey:[NSNumber numberWithInteger:indexPath.section]] count];
    
    if (count == 0) {
        [SVProgressHUD showWithStatus:@"正在加载" maskType:SVProgressHUDMaskTypeBlack];
        
        
        [_api showThreadWithId:[transThread.threadID intValue] andPage:(int)indexPath.section handler:^(BOOL isSuccess, ShowThreadPage * thread) {
            
            [SVProgressHUD dismiss];
            
            if (isSuccess) {
                currentPageNumber = (int)thread.currentPage;
                
                totalPageCount = (int)thread.totalPageCount;

                
                NSMutableArray<Post *> * parsedPosts = thread.dataList;
                
                
                currentThreadPage = thread;
                
                [postSet setObject:parsedPosts forKey:[NSNumber numberWithInt:currentPageNumber]];
                
                [self.tableView reloadData];
            }
            
        }];
        
    } else{
        NSArray * posts = [postSet objectForKey:[NSNumber numberWithInteger:indexPath.section]];
        
        Post * selectPost = posts[indexPath.row];
        
        itemActionSheet = [LCActionSheet sheetWithTitle:selectPost.postUserInfo.userName buttonTitles:@[@"快速回复", @"高级回复", @"复制链接"] redButtonIndex:-1 clicked:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                UIStoryboard * storyboard = [UIStoryboard mainStoryboard];
                
                CCFSimpleReplyNavigationController* simpleReplyController = [storyboard instantiateViewControllerWithIdentifier:@"CCFSimpleReplyNavigationController"];
                self.replyTransValueDelegate = (id<ReplyTransValueDelegate>)simpleReplyController;
                
                TransValueBundle * bundle = [[TransValueBundle alloc] init];
                
                Post * selectPost = posts[indexPath.row];
                [bundle putIntValue:[transThread.threadID intValue] forKey:@"THREAD_ID"];
                [bundle putIntValue:[selectPost.postID intValue] forKey:@"POST_ID"];
                
                NSString * token = currentThreadPage.securityToken;
                [bundle putStringValue:token forKey:@"SECYRITY_TOKEN"];
                [bundle putStringValue:currentThreadPage.ajaxLastPost forKey:@"AJAX_LAST_POST"];
                [bundle putStringValue:selectPost.postUserInfo.userName forKey:@"POST_USER"];
                
                [self.replyTransValueDelegate transValue:self withBundle:bundle];

                [self.navigationController presentViewController:simpleReplyController animated:YES completion:^{
                    
                }];
                
                
            } else if (buttonIndex == 1){
                
                UIStoryboard * storyBoard = [UIStoryboard mainStoryboard];
                
                CCFSimpleReplyNavigationController * controller = [storyBoard instantiateViewControllerWithIdentifier:@"CCFSeniorNewPostNavigationController"];
                self.replyTransValueDelegate = (id<ReplyTransValueDelegate>)controller;
                
                TransValueBundle * bundle = [[TransValueBundle alloc] init];
                
                [bundle putIntValue:[transThread.threadID intValue] forKey:@"THREAD_ID"];
                
                
                Post * selectPost = posts[indexPath.row];
                
                
                [bundle putIntValue:[selectPost.postID intValue] forKey:@"POST_ID"];
                
                NSString * token = currentThreadPage.securityToken;
                
                
                [bundle putStringValue:token forKey:@"SECYRITY_TOKEN"];
                
                [bundle putStringValue:currentThreadPage.ajaxLastPost forKey:@"AJAX_LAST_POST"];
                
                [bundle putStringValue:selectPost.postUserInfo.userName forKey:@"USER_NAME"];
                
                [self.replyTransValueDelegate transValue:self withBundle:bundle];
                
                [self.navigationController presentViewController:controller animated:YES completion:^{
                    
                }];
                
                
            } else if (buttonIndex == 2){
                NSString * louceng = [selectPost.postLouCeng stringWithRegular:@"\\d+"];
                
                NSString * postUrl = [NSString stringWithFormat: @"https://dream4ever.org//showpost.php?p=%@&postcount=%@", transThread.threadID, louceng];
                
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = postUrl;
                
                [SVProgressHUD showSuccessWithStatus:@"复制成功" maskType:SVProgressHUDMaskTypeBlack];
                
            }
        }];
        
        [itemActionSheet show];
    }
    

}

-(void)showUserProfile:(NSIndexPath *)indexPath{
    CCFProfileTableViewController * controller = selectSegue.destinationViewController;
    self.transValueDelegate = (id<TransValueDelegate>)controller;
    NSArray * posts = [postSet objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    Post * post = posts[indexPath.row];
    
    [self.transValueDelegate transValue:post];
}
#pragma mark Controller跳转
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"ShowUserProfile"]){
        selectSegue = segue;
    } else if ([segue.identifier isEqualToString:@"ShowSimpleReply"]){
        
        CCFSimpleReplyNavigationController * simpleReplyController = segue.destinationViewController;

        self.replyTransValueDelegate = (id<ReplyTransValueDelegate>)simpleReplyController;
        
        TransValueBundle * bundle = [[TransValueBundle alloc] init];
        [bundle putIntValue:[transThread.threadID intValue] forKey:@"THREAD_ID"];

        
        [self.replyTransValueDelegate transValue:self withBundle:bundle];
    }
}

- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void) showChangePageActionSheet:(UIBarButtonItem *)sender{
    NSMutableArray<NSString*> * pages = [NSMutableArray array];
    for (int i = 0 ; i < currentThreadPage.totalPageCount; i++) {
        NSString * page = [NSString stringWithFormat:@"第 %d 页", i + 1];
        [pages addObject:page];
    }
    
    
    
    ActionSheetStringPicker * picker = [[ActionSheetStringPicker alloc] initWithTitle:@"选择页面" rows:pages initialSelection:currentPageNumber - 1 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        
        int selectPage = (int)selectedIndex + 1;
        
        if (selectPage != currentPageNumber) {

            [SVProgressHUD showWithStatus:@"正在切换" maskType:SVProgressHUDMaskTypeBlack];
            
            
            [_api showThreadWithId:[transThread.threadID intValue] andPage:selectPage handler:^(BOOL isSuccess, ShowThreadPage * thread) {
                
                [SVProgressHUD dismiss];
                
                if (isSuccess) {
                    currentPageNumber = (int)thread.currentPage;
                    
                    totalPageCount = (int)thread.totalPageCount;
                    
                    
                    NSMutableArray<Post *> * parsedPosts = thread.dataList;
                    
                    
                    currentThreadPage = thread;
                    
                    [postSet setObject:parsedPosts forKey:[NSNumber numberWithInt:currentPageNumber]];
                    
                    [self.tableView reloadData];
                    
                    [self scrollToNewSection];
                }
                
            }];
        }
        
        
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
        
    } origin:sender];
    
    UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc] init];
    cancelItem.title = @"取消";
    [picker setCancelButton:cancelItem];
    
    UIBarButtonItem * queding = [[UIBarButtonItem alloc] init];
    queding.title = @"确定";
    [picker setDoneButton:queding];
    
    
    [picker showActionSheetPicker];
}


-(void) scrollToNewSection{
    NSIndexPath * scrolltoIndex = [NSIndexPath indexPathForRow: 0 inSection: currentPageNumber];
    
    [self.tableView scrollToRowAtIndexPath:scrolltoIndex atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(void)transReplyValue:(ShowThreadPage *)value{
    
    currentThreadPage = value;
    
    currentPageNumber = (int)value.currentPage;
    totalPageCount = (int)value.totalPageCount;
    
    NSMutableArray<Post *> * parsedPosts = value.dataList;
    
    [postSet setObject:parsedPosts forKey:[NSNumber numberWithInt:currentPageNumber]];
    
    [self.tableView reloadData];
    
    [self scrollToNewSection];
    
}

- (IBAction)showMoreAction:(UIBarButtonItem *)sender {
    


    itemActionSheet = [LCActionSheet sheetWithTitle:nil buttonTitles:@[@"复制帖子链接", @"在浏览器中查看",@"高级回帖"] redButtonIndex:2 clicked:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            // 复制贴链接
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = [[UrlBuilder buildThreadURL:[transThread.threadID intValue] withPage:0] absoluteString];
            
            [SVProgressHUD showSuccessWithStatus:@"复制成功" maskType:SVProgressHUDMaskTypeBlack];

        } else if (buttonIndex == 1){
            // 在浏览器种查看
            [[UIApplication sharedApplication] openURL:[UrlBuilder buildThreadURL:[transThread.threadID intValue] withPage:1]];
        } else if (buttonIndex == 2){
            // 进入高级回帖
            UIStoryboard * storyBoard = [UIStoryboard mainStoryboard];
            
            CCFSimpleReplyNavigationController * controller = [storyBoard instantiateViewControllerWithIdentifier:@"CCFSeniorNewPostNavigationController"];
            
            self.replyTransValueDelegate = (id<ReplyTransValueDelegate>)controller;
            
            TransValueBundle * bundle = [[TransValueBundle alloc] init];
            
            [bundle putIntValue:[transThread.threadID intValue] forKey:@"THREAD_ID"];
            NSString * token = currentThreadPage.securityToken;
            [bundle putStringValue:token forKey:@"SECYRITY_TOKEN"];
            [bundle putStringValue:transThread.threadAuthorName forKey:@"POST_USER"];
            [bundle putStringValue:currentThreadPage.formId forKey:@"FORM_ID"];
            
            [self.replyTransValueDelegate transValue:self withBundle:bundle];
            
            [self.navigationController presentViewController:controller animated:YES completion:^{
                
            }];
            
        }
    }];
    
    [itemActionSheet show];
}

-(void) showNoMoreDataView{
    [SVProgressHUD showInfoWithStatus:@"暂无新帖" maskType:SVProgressHUDMaskTypeBlack];
}
- (IBAction)floatReplyClick:(id)sender {
    
//    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height -self.tableView.bounds.size.height) animated:YES];
    
    int count = (int)[[postSet objectForKey:[NSNumber numberWithInteger:currentPageNumber]] count];
    if (count > 1) {
        count = count -1;
    }
    NSIndexPath * scrolltoIndex = [NSIndexPath indexPathForRow: count inSection: currentPageNumber];

    [self.tableView scrollToRowAtIndexPath:scrolltoIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];

}
- (IBAction)changeNumber:(id)sender {
    [self showChangePageActionSheet:sender];
    
}
- (IBAction)showSimpleReply:(id)sender {
}
@end
