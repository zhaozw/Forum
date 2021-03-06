//
//  ForumReportViewController.m
//
//  Created by 迪远 王 on 2016/11/15.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumReportViewController.h"
#import "SVProgressHUD.h"

#import "UIStoryboard+Forum.h"
#import "vBulletinForumEngine.h"
#import "TransBundle.h"
#import "TransBundleDelegate.h"

@interface ForumReportViewController ()<TransBundleDelegate>{
    NSString * userName;
    int postId;
}

@end

@implementation ForumReportViewController

- (void)transBundle:(TransBundle *)bundle {
    userName = [bundle getStringValue:@"POST_USER"];
    postId = [bundle getIntValue:@"POST_ID"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.reportMessage becomeFirstResponder];
}


- (IBAction)back:(id)sender {
}

- (IBAction)reportThreadPost:(id)sender {
    [self.reportMessage resignFirstResponder];
    [SVProgressHUD showWithStatus:@"请等待..." maskType:SVProgressHUDMaskTypeBlack];
    
    [self.forumBrowser reportThreadPost:postId andMessage:self.reportMessage.text handler:^(BOOL isSuccess, id message) {
       [SVProgressHUD showSuccessWithStatus:@"已经举报给管理员" maskType:SVProgressHUDMaskTypeBlack];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}
@end
