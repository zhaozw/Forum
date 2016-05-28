//
//  CCFWebViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/5/26.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFWebViewController.h"
#import "ShowThreadPage.h"

@interface CCFWebViewController ()<UIWebViewDelegate, UIScrollViewDelegate>

@end

@implementation CCFWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.webView setScalesPageToFit:YES];
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor clearColor];
    
    for(UIView *view in [[[self.webView subviews] objectAtIndex:0] subviews]) {
        if([view isKindOfClass:[UIImageView class]]) {
            view.hidden = YES; }
    }
    [self.webView setOpaque:NO];
    
    // scrollView
    self.webView.scrollView.delegate = self;
    
    NSMutableString * string = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_view" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] mutableCopy];
    
    
    
    [self.ccfApi showThreadWithId:1314451 andPage:1 handler:^(BOOL isSuccess, id message) {
        ShowThreadPage * page = message;
        
        NSMutableArray<Post *> * posts = page.dataList;
        
        
        NSString * lis = @"";
        
        for (Post * post in posts) {
            
//            <div class="info">
//            
//            <span class="avatar"><a href="large_image"><img src="http://www.hi-pda.com/forum/uc_server/data/avatar/000/45/17/59_avatar_middle.jpg"></a></span>
//            <span class="author">hswglff</span>
//            <span class="floor">1#</span>
//            <span class="time-ago">4 hours ago</span>
//            
//            </div>
            
            
            NSString * postInfoPattern = @"<div class=\"info\">\n<span class=\"avatar\"><a href=\"large_image\"><img src=\"%@\"></a></span>\n<span class=\"author\">%@</span><span class=\"floor\">%@</span>\n<span class=\"time-ago\">%@</span>\n</div>";
            NSString * postInfo = [NSString stringWithFormat:postInfoPattern, post.postUserInfo.userAvatar, post.postUserInfo.userName, post.postLouCeng, post.postTime];
            
            
            NSString * listPattern = @"<li class=\"\" data-id=\"7308071\" onclick=\"location.href='http://example';\">\n%@\n%@\n</li>";
            
            NSString * listString = [NSString stringWithFormat:listPattern,postInfo, post.postContent];
            
            lis = [lis stringByAppendingString:listString];
        }
        
        [string replaceOccurrencesOfString:@"<span style=\"display:none\">##lists##</span>" withString:lis options:0 range:NSMakeRange(0, string.length)];
        
//        [string stringByReplacingOccurrencesOfString:@"##lists##" withString:lis];
        
        [self.webView loadHTMLString:string baseURL:[NSURL URLWithString:@"https://bbs.et8.net/bbs/"]];
        
    }];
    
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
