//
//  CCFWebViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/5/26.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFWebViewController.h"
#import "ShowThreadPage.h"
#import <MJRefresh.h>
#import "SDImageCache+URLCache.h"

#import <NYTPhotosViewController.h>
#import <NYTPhotoViewer/NYTPhoto.h>
#import "NYTExamplePhoto.h"
#import "LCActionSheet.h"
#import "Thread.h"
#import "TransValueDelegate.h"
#import "UrlBuilder.h"
#import "SVProgressHUD.h"
#import "UIStoryboard+CCF.h"
#import "ActionSheetPicker.h"
#import "ReplyCallbackDelegate.h"
#import "CCFSimpleReplyNavigationController.h"
#import "CCFPCH.pch"


@interface CCFWebViewController ()<UIWebViewDelegate, UIScrollViewDelegate,TransValueDelegate,ReplyCallbackDelegate>{
    
    LCActionSheet * itemActionSheet;
    
    Thread * transThread;
    
    ShowThreadPage * currentThreadPage;
    
    int currentPageNumber;
    int totalPageCount;
}

@end

@implementation CCFWebViewController

-(void)transValue:(id)value{
    transThread = value;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.webView setScalesPageToFit:YES];
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    
    for(UIView *view in [[[self.webView subviews] objectAtIndex:0] subviews]) {
        if([view isKindOfClass:[UIImageView class]]) {
            view.hidden = YES; }
    }
    [self.webView setOpaque:NO];
    
    // scrollView
    self.webView.scrollView.delegate = self;
    
    self.webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [self prePage:[transThread.threadID intValue] withAnim:YES];
        
    }];
    
    
    self.webView.scrollView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{

        int toPageNumber = currentPageNumber + 1;
        
        if (toPageNumber >= totalPageCount) {
            toPageNumber = totalPageCount;
        }
        [self showThread:[transThread.threadID intValue] page:toPageNumber withAnim:YES];

    }];
    
    [self.webView.scrollView.mj_header beginRefreshing];
    
}

-(void) prePage:(int)threadId withAnim:(BOOL) anim{
    int page = currentPageNumber--;
    [self.ccfApi showThreadWithId:threadId andPage:page handler:^(BOOL isSuccess, id message) {
        
        ShowThreadPage * threadPage = message;
        
        currentThreadPage = threadPage;
        totalPageCount = (int)currentThreadPage.totalPageCount;
        currentPageNumber = page;
        
        if (currentPageNumber >= totalPageCount) {
            currentPageNumber = totalPageCount;
        }
        
        NSString * title = [NSString stringWithFormat:@"%d/%d", currentPageNumber, totalPageCount];
        self.pageNumber.title = title;
        
        NSMutableArray<Post *> * posts = threadPage.dataList;
        
        
        NSString * lis = @"";
        
        for (Post * post in posts) {
            NSString * avatar = [NSString stringWithFormat:@"https://bbs.et8.net/bbs/customavatars%@", post.postUserInfo.userAvatar];
            NSString * postInfo = [NSString stringWithFormat:POST_MESSAGE,post.postID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];
            
            lis = [lis stringByAppendingString:postInfo];
        }
        
        NSString * html = [NSString stringWithFormat:THREAD_PAGE, threadPage.threadTitle,lis];
        [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:@"https://bbs.et8.net/bbs/"]];
        
        [self.webView.scrollView.mj_header endRefreshing];
        
        
        if (anim) {
            CABasicAnimation *stretchAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
            [stretchAnimation setToValue:[NSNumber numberWithFloat:1.02]];
            [stretchAnimation setRemovedOnCompletion:YES];
            [stretchAnimation setFillMode:kCAFillModeRemoved];
            [stretchAnimation setAutoreverses:YES];
            [stretchAnimation setDuration:0.15];
            [stretchAnimation setDelegate:self];
            
            [stretchAnimation setBeginTime:CACurrentMediaTime() + 0.35];
            
            [stretchAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            //[self.webView setAnchorPoint:CGPointMake(0.0, 1) forView:self.webView];
            [self.view.layer addAnimation:stretchAnimation forKey:@"stretchAnimation"];
            
            CATransition *animation = [CATransition animation];
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromBottom];
            [animation setDuration:0.5f];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [[self.webView layer] addAnimation:animation forKey:nil];
        }
        
    }];
}

-(void) showThread:(int) threadId page:(int)page withAnim:(BOOL) anim{
    
    [self.ccfApi showThreadWithId:threadId andPage:page handler:^(BOOL isSuccess, id message) {

        ShowThreadPage * threadPage = message;
        
        currentThreadPage = threadPage;
        totalPageCount = (int)currentThreadPage.totalPageCount;
        currentPageNumber = page;
        
        if (currentPageNumber >= totalPageCount) {
            currentPageNumber = totalPageCount;
        }
        
        NSString * title = [NSString stringWithFormat:@"%d/%d", currentPageNumber, totalPageCount];
        self.pageNumber.title = title;
        
        NSMutableArray<Post *> * posts = threadPage.dataList;
        
        
        NSString * lis = @"";
        
        for (Post * post in posts) {
 
            NSString * avatar = [NSString stringWithFormat:@"https://bbs.et8.net/bbs/customavatars%@", post.postUserInfo.userAvatar];
            NSString * postInfo = [NSString stringWithFormat:POST_MESSAGE,post.postID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];
            
            lis = [lis stringByAppendingString:postInfo];
        }
        
        NSString * html = [NSString stringWithFormat:THREAD_PAGE_NOTITLE ,lis];
        [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:@"https://bbs.et8.net/bbs/"]];
        
        [self.webView.scrollView.mj_footer endRefreshing];
        
        
        if (anim) {
            CABasicAnimation *stretchAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
            [stretchAnimation setToValue:[NSNumber numberWithFloat:1.02]];
            [stretchAnimation setRemovedOnCompletion:YES];
            [stretchAnimation setFillMode:kCAFillModeRemoved];
            [stretchAnimation setAutoreverses:YES];
            [stretchAnimation setDuration:0.15];
            [stretchAnimation setDelegate:self];
            
            [stretchAnimation setBeginTime:CACurrentMediaTime() + 0.35];
            
            [stretchAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            //[self.webView setAnchorPoint:CGPointMake(0.0, 1) forView:self.webView];
            [self.view.layer addAnimation:stretchAnimation forKey:@"stretchAnimation"];
            
            CATransition *animation = [CATransition animation];
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromTop];
            [animation setDuration:0.5f];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [[self.webView layer] addAnimation:animation forKey:nil];
        }
        
    }];
}

- (void)showMoreAction{

    itemActionSheet = [LCActionSheet sheetWithTitle:nil buttonTitles:@[@"复制帖子链接", @"在浏览器中查看",@"高级回帖"] redButtonIndex:2 clicked:^(NSInteger buttonIndex) {

        
    }];
    
    [itemActionSheet show];
}

-(void)transReplyValue:(ShowThreadPage *)value{
    
    currentThreadPage = value;
    
    currentPageNumber = (int)value.currentPage;
    totalPageCount = (int)value.totalPageCount;
    
    NSMutableArray<Post *> * parsedPosts = value.dataList;
    
    
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *urlString = [[request URL] absoluteString];
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> %@ %ld %@",urlString, navigationType, request.URL.scheme);
    
    
    if ([request.URL.scheme isEqualToString:@"postid"]) {
        
        [self showMoreAction];
        return NO;
        
    }
    
    if ([request.URL.scheme isEqualToString:@"image"]) {
        
        NSString * absUrl = request.URL.absoluteString;
        
        
        NSString *src = [absUrl stringByReplacingOccurrencesOfString:@"image://https//" withString:@"https://"];
        if ([absUrl hasPrefix:@"image://http//"]) {
            src = [absUrl stringByReplacingOccurrencesOfString:@"image://http//" withString:@"http://"];
        }

        UIImage *memCachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:src];
        NSData *data = nil;
        if (memCachedImage) {
            if (!memCachedImage.images) {
                data = UIImageJPEGRepresentation(memCachedImage, 1.f);
            }
        } else {
            data = [[SDImageCache sharedImageCache] hp_imageDataFromDiskCacheForKey:src];
            memCachedImage = [UIImage imageWithData: data];
        }

        NSMutableArray * array = [NSMutableArray array];

        NYTExamplePhoto  * photo1 = [[NYTExamplePhoto alloc] init];

        photo1.attributedCaptionTitle = [[NSAttributedString alloc] initWithString:@"1" attributes:nil];
        photo1.image = memCachedImage;
        [array addObject:photo1];
        NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:array];
        [self presentViewController:photosViewController animated:YES completion:nil];
        
        return NO;
    }

    return YES;
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
            [self showThread:[transThread.threadID intValue] page:selectPage withAnim:YES];
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


- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeNumber:(id)sender {
    [self showChangePageActionSheet:sender];
    
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
//            UIStoryboard * storyBoard = [UIStoryboard mainStoryboard];
//            
//            CCFSimpleReplyNavigationController * controller = [storyBoard instantiateViewControllerWithIdentifier:@"CCFSeniorNewPostNavigationController"];
//            
//            self.replyTransValueDelegate = (id<ReplyTransValueDelegate>)controller;
//            
//            TransValueBundle * bundle = [[TransValueBundle alloc] init];
//            
//            [bundle putIntValue:[transThread.threadID intValue] forKey:@"THREAD_ID"];
//            NSString * token = currentThreadPage.securityToken;
//            [bundle putStringValue:token forKey:@"SECYRITY_TOKEN"];
//            [bundle putStringValue:transThread.threadAuthorName forKey:@"POST_USER"];
//            [bundle putStringValue:currentThreadPage.formId forKey:@"FORM_ID"];
//            
//            [self.replyTransValueDelegate transValue:self withBundle:bundle];
//            
//            [self.navigationController presentViewController:controller animated:YES completion:^{
//                
//            }];
            
        }
    }];
    
    [itemActionSheet show];
}

- (IBAction)reply:(id)sender {
    
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
@end
