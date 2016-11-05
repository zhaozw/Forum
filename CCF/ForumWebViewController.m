//
//  ForumWebViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/5/26.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumWebViewController.h"
#import <vBulletinForumEngine/vBulletinForumEngine.h>
#import <MJRefresh.h>
#import "SDImageCache+URLCache.h"

#import <NYTPhotosViewController.h>
#import <NYTPhotoViewer/NYTPhoto.h>
#import "NYTExamplePhoto.h"
#import "LCActionSheet.h"

#import "TransValueDelegate.h"
#import "SVProgressHUD.h"
#import "UIStoryboard+CCF.h"
#import "ActionSheetPicker.h"
#import "ReplyCallbackDelegate.h"
#import "ForumSimpleReplyNavigationController.h"
#import "CCFPCH.pch"
#import "NSString+Extensions.h"
#import "ForumTabBarController.h"
#import "TransValueBundle.h"
#import "ForumUserProfileTableViewController.h"
#import "ForumConfig.h"
#import "DTCoreText.h"

@interface ForumWebViewController () <UIWebViewDelegate, UIScrollViewDelegate, TransValueDelegate, ReplyCallbackDelegate, CAAnimationDelegate> {

    LCActionSheet *itemActionSheet;

    TransValueBundle *transBundle;

    ShowThreadPage *currentThreadPage;

    int currentPageNumber;
    int totalPageCount;

    NSMutableDictionary *pageDic;

    NSString *currentHtml;

    int threadID;
    NSString *threadAuthorName;

    int p;
}

@end

@implementation ForumWebViewController

- (void)transValue:(id)value {
    transBundle = value;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    threadID = [transBundle getIntValue:@"threadID"];
    p = [transBundle getIntValue:@"p"];

    threadAuthorName = [transBundle getStringValue:@"threadAuthorName"];


    pageDic = [NSMutableDictionary dictionary];

    currentPageNumber = 1;


    [self.webView setScalesPageToFit:YES];
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];

    for (UIView *view in [[[self.webView subviews] objectAtIndex:0] subviews]) {
        if ([view isKindOfClass:[UIImageView class]]) {
            view.hidden = YES;
        }
    }
    [self.webView setOpaque:NO];

    // scrollView
    self.webView.scrollView.delegate = self;

    self.webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        if (threadID == -1) {
            [self showThreadWithP:[NSString stringWithFormat:@"%d", p]];
        } else {
            if (currentPageNumber > 1) {
                int page = currentPageNumber - 1;
                [self prePage:threadID page:page withAnim:YES];
            } else {
                [self prePage:threadID page:1 withAnim:NO];
            }
        }
    }];


    self.webView.scrollView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{

        int toPageNumber = currentPageNumber + 1;

        if (toPageNumber >= totalPageCount) {
            toPageNumber = totalPageCount;
        }
        [self showThread:threadID page:toPageNumber withAnim:YES];

    }];

    [self.webView.scrollView.mj_header beginRefreshing];
}

- (void)showThreadWithP:(NSString *)pID {
    [self.ccfForumApi showThreadWithP:pID handler:^(BOOL isSuccess, id message) {

        ShowThreadPage *threadPage = message;

        currentThreadPage = threadPage;
        totalPageCount = (int) currentThreadPage.totalPageCount;
        currentPageNumber = (int) threadPage.currentPage;

        threadID = [threadPage.threadID intValue];

        if (currentPageNumber >= totalPageCount) {
            currentPageNumber = totalPageCount;
        }

        NSString *title = [NSString stringWithFormat:@"%d/%d", currentPageNumber, totalPageCount];
        self.pageNumber.title = title;

        NSMutableArray<Post *> *posts = threadPage.dataList;


        NSString *lis = @"";

        for (Post *post in posts) {
            NSString *avatar = BBS_AVATAR(post.postUserInfo.userAvatar);
            NSString *louceng = [post.postLouCeng stringWithRegular:@"\\d+"];
            NSString *postInfo = [NSString stringWithFormat:POST_MESSAGE, post.postID, post.postID, post.postUserInfo.userName, louceng, post.postUserInfo.userID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];
            lis = [lis stringByAppendingString:postInfo];
        }

        NSString *html = nil;

        html = [NSString stringWithFormat:THREAD_PAGE, threadPage.threadTitle, lis];


        pageDic[@(currentPageNumber)] = html;

        [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:BBS_URL]];

        [self.webView.scrollView.mj_header endRefreshing];


        CABasicAnimation *stretchAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
        [stretchAnimation setToValue:@1.02F];
        [stretchAnimation setRemovedOnCompletion:YES];
        [stretchAnimation setFillMode:kCAFillModeRemoved];
        [stretchAnimation setAutoreverses:YES];
        [stretchAnimation setDuration:0.15];
        [stretchAnimation setDelegate:self];
        [stretchAnimation setBeginTime:CACurrentMediaTime() + 0.35];
        [stretchAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.view.layer addAnimation:stretchAnimation forKey:@"stretchAnimation"];
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromBottom];
        [animation setDuration:0.5f];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[self.webView layer] addAnimation:animation forKey:nil];
    }];
}

- (void)prePage:(int)threadId page:(int)page withAnim:(BOOL)anim {


    [self.ccfForumApi showThreadWithId:threadId andPage:page handler:^(BOOL isSuccess, id message) {

        ShowThreadPage *threadPage = message;

        currentThreadPage = threadPage;
        totalPageCount = (int) currentThreadPage.totalPageCount;
        currentPageNumber = page;

        if (currentPageNumber >= totalPageCount) {
            currentPageNumber = totalPageCount;
        }

        NSString *title = [NSString stringWithFormat:@"%d/%d", currentPageNumber, totalPageCount];
        self.pageNumber.title = title;

        NSMutableArray<Post *> *posts = threadPage.dataList;


        NSString *lis = @"";

        for (Post *post in posts) {
            NSString *avatar = BBS_AVATAR(post.postUserInfo.userAvatar);
            NSString *louceng = [post.postLouCeng stringWithRegular:@"\\d+"];
            NSString *postInfo = [NSString stringWithFormat:POST_MESSAGE, post.postID, post.postID, post.postUserInfo.userName, louceng, post.postUserInfo.userID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];
            lis = [lis stringByAppendingString:postInfo];
        }

        NSString *html = nil;

        if (page <= 1) {
            html = [NSString stringWithFormat:THREAD_PAGE, threadPage.threadTitle, lis];
        } else {
            html = [NSString stringWithFormat:THREAD_PAGE_NOTITLE, lis];
        }


        pageDic[@(currentPageNumber)] = html;

        [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:BBS_URL]];

        [self.webView.scrollView.mj_header endRefreshing];


        if (anim) {
            CABasicAnimation *stretchAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
            [stretchAnimation setToValue:@1.02F];
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

- (void)showThread:(int)threadId page:(int)page withAnim:(BOOL)anim {


    NSString *cacheHtml = pageDic[@(page)];

    [self.ccfForumApi showThreadWithId:threadId andPage:page handler:^(BOOL isSuccess, id message) {

        [SVProgressHUD dismiss];

        ShowThreadPage *threadPage = message;

        currentThreadPage = threadPage;
        totalPageCount = (int) currentThreadPage.totalPageCount;
        currentPageNumber = page;

        if (currentPageNumber >= totalPageCount) {
            currentPageNumber = totalPageCount;
        }

        NSString *title = [NSString stringWithFormat:@"%d/%d", currentPageNumber, totalPageCount];
        self.pageNumber.title = title;

        NSMutableArray<Post *> *posts = threadPage.dataList;

        NSString *lis = @"";

        for (Post *post in posts) {

            NSString *avatar = BBS_AVATAR(post.postUserInfo.userAvatar);
            NSString *louceng = [post.postLouCeng stringWithRegular:@"\\d+"];
            NSString *postInfo = [NSString stringWithFormat:POST_MESSAGE, post.postID, post.postID, post.postUserInfo.userName, louceng, post.postUserInfo.userID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];

            lis = [lis stringByAppendingString:postInfo];

            //[self addPostByJSElement:post avatar:avatar louceng:louceng];


        }

        NSString *html = nil;

        if (page <= 1) {
            html = [NSString stringWithFormat:THREAD_PAGE, threadPage.threadTitle, lis];
        } else {
            html = [NSString stringWithFormat:THREAD_PAGE_NOTITLE, lis];
        }

        [self.webView.scrollView.mj_footer endRefreshing];





        if (![cacheHtml isEqualToString:currentHtml]) {
            [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:BBS_URL]];
            currentHtml = html;
            pageDic[@(page)] = html;
        }


        if (anim && ![cacheHtml isEqualToString:currentHtml]) {
            CABasicAnimation *stretchAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
            [stretchAnimation setToValue:@1.02F];
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

- (void)addPostByJSElement:(Post *)post avatar:(NSString *)avatar louceng:(NSString *)louceng {
    NSString *pattern = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"append_post" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    NSString *contentPattern = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"append_post_content" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    NSString *content = [NSString stringWithFormat:contentPattern, post.postUserInfo.userID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];
    NSString *deleteEnter = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *deleteT = [deleteEnter stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    NSString *deleteR = [deleteT stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSString *deleteLine = [deleteR stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];


    NSString *js = [NSString stringWithFormat:pattern, post.postID, post.postID, post.postUserInfo.userName, louceng, deleteLine];

    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)showMoreAction {

//    itemActionSheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:nil clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
//
//    } otherButtonTitles:@"复制帖子链接", @"在浏览器中查看",@"高级回帖" , nil];

    itemActionSheet = [LCActionSheet sheetWithTitle:nil buttonTitles:@[@"复制帖子链接", @"在浏览器中查看", @"高级回帖"] redButtonIndex:2 clicked:^(NSInteger buttonIndex) {


    }];

    [itemActionSheet show];
}

- (void)transReplyValue:(ShowThreadPage *)value {

    currentThreadPage = value;

    currentPageNumber = (int) value.currentPage;
    totalPageCount = (int) value.totalPageCount;

    NSMutableArray<Post *> *parsedPosts = value.dataList;


}


- (NSDictionary *)dictionaryFromQuery:(NSString *)query usingEncoding:(NSStringEncoding)encoding {
    NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
    NSScanner *scanner = [[NSScanner alloc] initWithString:query];
    while (![scanner isAtEnd]) {
        NSString *pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray *kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString *key = [[kvPair objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:encoding];
            NSString *value = [[kvPair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:encoding];
            [pairs setObject:value forKey:key];
        }
    }

    return [NSDictionary dictionaryWithDictionary:pairs];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    NSString *urlString = [[request URL] absoluteString];
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> %@ %d %@", urlString, navigationType, request.URL.scheme);


    if ([request.URL.scheme isEqualToString:@"postid"]) {
        NSDictionary *query = [self dictionaryFromQuery:request.URL.query usingEncoding:NSUTF8StringEncoding];

        NSString *userName = [[query valueForKey:@"postuser"] replaceUnicode];
        int postId = [[query valueForKey:@"postid"] intValue];
        NSString *louCeng = [query valueForKey:@"postlouceng"];

        itemActionSheet = [LCActionSheet sheetWithTitle:userName buttonTitles:@[@"快速回复", @"高级回复", @"复制链接"] redButtonIndex:-1 clicked:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                UIStoryboard *storyboard = [UIStoryboard mainStoryboard];

                ForumSimpleReplyNavigationController *simpleReplyController = [storyboard instantiateViewControllerWithIdentifier:@"ForumSimpleReplyNavigationController"];
                self.replyTransValueDelegate = (id <ReplyTransValueDelegate>) simpleReplyController;

                TransValueBundle *bundle = [[TransValueBundle alloc] init];

                [bundle putIntValue:threadID forKey:@"THREAD_ID"];
                [bundle putIntValue:postId forKey:@"POST_ID"];

                NSString *token = currentThreadPage.securityToken;
                [bundle putStringValue:token forKey:@"SECYRITY_TOKEN"];
                [bundle putStringValue:currentThreadPage.ajaxLastPost forKey:@"AJAX_LAST_POST"];
                [bundle putStringValue:userName forKey:@"POST_USER"];

                [self.replyTransValueDelegate transValue:self withBundle:bundle];

                [self.navigationController presentViewController:simpleReplyController animated:YES completion:^{

                }];


            } else if (buttonIndex == 1) {

                UIStoryboard *storyBoard = [UIStoryboard mainStoryboard];

                ForumSimpleReplyNavigationController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"CCFSeniorNewPostNavigationController"];
                self.replyTransValueDelegate = (id <ReplyTransValueDelegate>) controller;

                TransValueBundle *bundle = [[TransValueBundle alloc] init];

                [bundle putIntValue:threadID forKey:@"THREAD_ID"];


                [bundle putIntValue:postId forKey:@"POST_ID"];

                NSString *token = currentThreadPage.securityToken;


                [bundle putStringValue:token forKey:@"SECYRITY_TOKEN"];

                [bundle putStringValue:currentThreadPage.ajaxLastPost forKey:@"AJAX_LAST_POST"];

                [bundle putStringValue:userName forKey:@"USER_NAME"];

                [self.replyTransValueDelegate transValue:self withBundle:bundle];

                [self.navigationController presentViewController:controller animated:YES completion:^{

                }];


            } else if (buttonIndex == 2) {
                NSString *louceng = louCeng;

                NSString *postUrl = BBS_SHOWTHREAD_POSTCOUNT(postId, louCeng);

                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = postUrl;

                [SVProgressHUD showSuccessWithStatus:@"复制成功" maskType:SVProgressHUDMaskTypeBlack];

            }
        }];

        [itemActionSheet show];
        return NO;

    }

    if ([request.URL.scheme isEqualToString:@"image"]) {

        NSString *absUrl = request.URL.absoluteString;


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
            memCachedImage = [UIImage imageWithData:data];
        }

        NSMutableArray *array = [NSMutableArray array];

        NYTExamplePhoto *photo1 = [[NYTExamplePhoto alloc] init];

        photo1.attributedCaptionTitle = [[NSAttributedString alloc] initWithString:@"1" attributes:nil];
        photo1.image = memCachedImage;
        [array addObject:photo1];
        NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:array];
        [self presentViewController:photosViewController animated:YES completion:nil];

        return NO;
    }

    if ([request.URL.scheme isEqualToString:@"avatar"]) {
        NSDictionary *query = [self dictionaryFromQuery:request.URL.query usingEncoding:NSUTF8StringEncoding];

        NSString *userid = [query valueForKey:@"userid"];


        UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
        ForumUserProfileTableViewController *showThreadController = [storyboard instantiateViewControllerWithIdentifier:@"ForumUserProfileTableViewController"];
        self.transValueDelegate = (id <TransValueDelegate>) showThreadController;
        TransValueBundle *showTransBundle = [[TransValueBundle alloc] init];
        [showTransBundle putIntValue:[userid intValue] forKey:@"userid"];
        [self.transValueDelegate transValue:showTransBundle];

        [self.navigationController pushViewController:showThreadController animated:YES];

        return NO;
    }

    if (navigationType == UIWebViewNavigationTypeLinkClicked && ([request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"])) {


        NSString *path = request.URL.path;
        if ([path rangeOfString:@"showthread.php"].location != NSNotFound) {
            // 显示帖子
            NSDictionary *query = [self dictionaryFromQuery:request.URL.query usingEncoding:NSUTF8StringEncoding];

            NSString *threadIdStr = [query valueForKey:@"t"];


            UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
            ForumWebViewController *showThreadController = [storyboard instantiateViewControllerWithIdentifier:@"ForumWebViewController"];
            self.transValueDelegate = (id <TransValueDelegate>) showThreadController;
            TransValueBundle *showTransBundle = [[TransValueBundle alloc] init];
            [showTransBundle putIntValue:[threadIdStr intValue] forKey:@"threadID"];
            [self.transValueDelegate transValue:showTransBundle];

            [self.navigationController pushViewController:showThreadController animated:YES];

            return NO;
        } else {
            [[UIApplication sharedApplication] openURL:request.URL];

            return NO;
        }
    }
    return YES;
}

- (void)showChangePageActionSheet:(UIBarButtonItem *)sender {
    NSMutableArray<NSString *> *pages = [NSMutableArray array];
    for (int i = 0; i < currentThreadPage.totalPageCount; i++) {
        NSString *page = [NSString stringWithFormat:@"第 %d 页", i + 1];
        [pages addObject:page];
    }


    ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"选择页面" rows:pages initialSelection:currentPageNumber - 1 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {

        int selectPage = (int) selectedIndex + 1;

        if (selectPage != currentPageNumber) {

            [SVProgressHUD showWithStatus:@"正在切换" maskType:SVProgressHUDMaskTypeBlack];
            [self showThread:threadID page:selectPage withAnim:YES];
        }


    }                                                                    cancelBlock:^(ActionSheetStringPicker *picker) {


    }                                                                         origin:sender];

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] init];
    cancelItem.title = @"取消";
    [picker setCancelButton:cancelItem];

    UIBarButtonItem *queding = [[UIBarButtonItem alloc] init];
    queding.title = @"确定";
    [picker setDoneButton:queding];


    [picker showActionSheetPicker];
}


- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];



//    NSString * currentHtml = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('list').innerHTML;"];
//
//    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('list').innerHTML +='%@';", @"<li class=\"post-title\">\n            <div class=\"title\">\n\t 9999999 \n</div>\n        </li>"]];



//    NSString *injectSrc = @"var i = document.createElement('div'); i.innerHTML = '%@';document.documentElement.appendChild(i);";
//    NSString *runToInject = [NSString stringWithFormat:injectSrc, @"Hello World"];
//    [self.webView stringByEvaluatingJavaScriptFromString:runToInject];
}

- (IBAction)changeNumber:(id)sender {
    [self showChangePageActionSheet:sender];

}

- (IBAction)showMoreAction:(UIBarButtonItem *)sender {

    itemActionSheet = [LCActionSheet sheetWithTitle:nil buttonTitles:@[@"复制帖子链接", @"在浏览器中查看", @"高级回帖"] redButtonIndex:4 clicked:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            // 复制贴链接
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = BBS_SHOWTHREAD_PAGE(threadID, 0);

            [SVProgressHUD showSuccessWithStatus:@"复制成功" maskType:SVProgressHUDMaskTypeBlack];

        } else if (buttonIndex == 1) {
            // 在浏览器种查看
            NSURL *url = [NSURL URLWithString:BBS_SHOWTHREAD_PAGE(threadID, 1)];
            [[UIApplication sharedApplication] openURL:url];
        } else if (buttonIndex == 2) {
            [self reply:self];

        }
    }];

    [itemActionSheet show];
}

- (IBAction)reply:(id)sender {

    UIStoryboard *storyBoard = [UIStoryboard mainStoryboard];
    ForumSimpleReplyNavigationController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"CCFSeniorNewPostNavigationController"];
    self.replyTransValueDelegate = (id <ReplyTransValueDelegate>) controller;
    TransValueBundle *bundle = [[TransValueBundle alloc] init];
    [bundle putIntValue:threadID forKey:@"THREAD_ID"];
    NSString *token = currentThreadPage.securityToken;
    [bundle putStringValue:token forKey:@"SECYRITY_TOKEN"];
    [bundle putStringValue:threadAuthorName forKey:@"POST_USER"];
    [bundle putStringValue:currentThreadPage.formId forKey:@"FORM_ID"];
    [self.replyTransValueDelegate transValue:self withBundle:bundle];
    [self.navigationController presentViewController:controller animated:YES completion:^{

    }];
}
@end
