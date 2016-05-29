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

@interface CCFWebViewController ()<UIWebViewDelegate, UIScrollViewDelegate,TransValueDelegate>{
    
    LCActionSheet * itemActionSheet;
    
    Thread * thread;
}

@end

@implementation CCFWebViewController

-(void)transValue:(id)value{
    thread = value;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    
    

    
    
    
    self.webView.scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        NSMutableString * string = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_view" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] mutableCopy];
        
        [self.ccfApi showThreadWithId:[thread.threadID intValue] andPage:2 handler:^(BOOL isSuccess, id message) {

            
            ShowThreadPage * page = message;
            
            NSMutableArray<Post *> * posts = page.dataList;
            
            
            NSString * lis = @"";
            
            for (Post * post in posts) {
                

                NSString * postInfoPattern = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_message" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
                
                NSString * avatar = [NSString stringWithFormat:@"https://bbs.et8.net/bbs/customavatars%@", post.postUserInfo.userAvatar];
                NSString * postInfo = [NSString stringWithFormat:postInfoPattern,post.postID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];
                
                lis = [lis stringByAppendingString:postInfo];
            }
            
            NSString * html = [NSString stringWithFormat:string, lis];
            [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:@"https://bbs.et8.net/bbs/"]];
            
            [self.webView.scrollView.mj_footer endRefreshing];
            
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
            
            
        }];
        
        
    }];
    
    
    

    
    
    
    [self.ccfApi showThreadWithId:[thread.threadID intValue] andPage:1 handler:^(BOOL isSuccess, id message) {
        
            NSMutableString * string = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_view" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] mutableCopy];
        
        ShowThreadPage * page = message;
        
        NSMutableArray<Post *> * posts = page.dataList;
        
        
        NSString * lis = @"";
        
        for (Post * post in posts) {
            
            NSString * postInfoPattern = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_message" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
            
            NSString * avatar = [NSString stringWithFormat:@"https://bbs.et8.net/bbs/customavatars%@", post.postUserInfo.userAvatar];
            NSString * postInfo = [NSString stringWithFormat:postInfoPattern,post.postID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];
            
            lis = [lis stringByAppendingString:postInfo];
        }
        NSString * html = [NSString stringWithFormat:string, lis];
        [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:@"https://bbs.et8.net/bbs/"]];
    }];
    
}

- (void)showMoreAction{

    itemActionSheet = [LCActionSheet sheetWithTitle:nil buttonTitles:@[@"复制帖子链接", @"在浏览器中查看",@"高级回帖"] redButtonIndex:2 clicked:^(NSInteger buttonIndex) {

        
    }];
    
    [itemActionSheet show];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
