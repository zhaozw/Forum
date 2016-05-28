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

@interface CCFWebViewController ()<UIWebViewDelegate, UIScrollViewDelegate>

@end

@implementation CCFWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.webView setScalesPageToFit:YES];
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
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
        
        [self.ccfApi showThreadWithId:1314451 andPage:2 handler:^(BOOL isSuccess, id message) {

            
            ShowThreadPage * page = message;
            
            NSMutableArray<Post *> * posts = page.dataList;
            
            
            NSString * lis = @"";
            
            for (Post * post in posts) {
                

                NSString * postInfoPattern = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_message" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
                
                NSString * postInfo = [NSString stringWithFormat:postInfoPattern, post.postUserInfo.userAvatar, post.postUserInfo.userName, post.postLouCeng, post.postTime];
                
                
                NSString * listPattern = @"<li class=\"\" data-id=\"7308071\" onclick=\"location.href='http://example';\">\n%@\n%@\n</li>";
                
                NSString * listString = [NSString stringWithFormat:listPattern,postInfo, post.postContent];
                
                lis = [lis stringByAppendingString:listString];
            }
            
            [string replaceOccurrencesOfString:@"<span style=\"display:none\">##lists##</span>" withString:lis options:0 range:NSMakeRange(0, string.length)];
            [self.webView loadHTMLString:string baseURL:[NSURL URLWithString:@"https://bbs.et8.net/bbs/"]];
            
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
    
    
    

    
    
    
    [self.ccfApi showThreadWithId:1314451 andPage:1 handler:^(BOOL isSuccess, id message) {
        
            NSMutableString * string = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_view" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] mutableCopy];
        
        ShowThreadPage * page = message;
        
        NSMutableArray<Post *> * posts = page.dataList;
        
        
        NSString * lis = @"";
        
        for (Post * post in posts) {
            
            NSString * postInfoPattern = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_message" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
            NSString * postInfo = [NSString stringWithFormat:postInfoPattern, post.postUserInfo.userAvatar, post.postUserInfo.userName, post.postLouCeng, post.postTime];
            
            
            NSString * listPattern = @"<li class=\"\" data-id=\"7308071\" onclick=\"location.href='http://example';\">\n%@\n%@\n</li>";
            
            NSString * listString = [NSString stringWithFormat:listPattern,postInfo, post.postContent];
            
            lis = [lis stringByAppendingString:listString];
        }
        
        [string replaceOccurrencesOfString:@"<span style=\"display:none\">##lists##</span>" withString:lis options:0 range:NSMakeRange(0, string.length)];
        [self.webView loadHTMLString:string baseURL:[NSURL URLWithString:@"https://bbs.et8.net/bbs/"]];
    }];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *urlString = [[request URL] absoluteString];
    NSLog(@"%@ %ld %@",urlString, navigationType, request.URL.scheme);
    
    
    if ([request.URL.scheme isEqualToString:@"floor"]) {
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
