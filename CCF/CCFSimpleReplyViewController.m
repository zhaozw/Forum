//
//  CCFSimpleReplyViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/4/10.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFSimpleReplyViewController.h"
#import "CCFSimpleReplyNavigationController.h"
#import "SVProgressHUD.h"
#import "ShowThreadPage.h"
#import "UIStoryboard+CCF.h"
#import "CCFShowThreadViewController.h"
#import "Post.h"
#import "TransValueBundle.h"

@interface CCFSimpleReplyViewController (){
    TransValueBundle * bundle;
}

@end

@implementation CCFSimpleReplyViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    CCFSimpleReplyNavigationController * navigationController = (CCFSimpleReplyNavigationController *)self.navigationController;
    
    bundle = navigationController.bundle;
    
    
    
    NSString * userName = [bundle getStringValue:@"POST_USER"];
    if (userName != nil) {
            self.replyContent.text = [NSString stringWithFormat:@"@%@\n", userName];
    }

    
    [self.replyContent becomeFirstResponder];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}

- (IBAction)sendSimpleReply:(id)sender {
    
    [self.replyContent resignFirstResponder];
    
    [SVProgressHUD showWithStatus:@"正在回复" maskType:SVProgressHUDMaskTypeBlack];
    

    int threadId = [bundle getIntValue:@"THREAD_ID"];
    int postId = [bundle getIntValue:@"POST_ID"];
    
    if (postId != -1) {
        NSString * securityToken = [bundle getStringValue:@"SECYRITY_TOKEN"];
        NSString * ajaxLastPost = [bundle getStringValue:@"AJAX_LAST_POST"];
        
        [self.ccfApi quickReplyPostWithThreadId:threadId forPostId:postId andMessage:self.replyContent.text securitytoken:securityToken ajaxLastPost:ajaxLastPost handler:^(BOOL isSuccess, ShowThreadPage* message) {
            if (isSuccess && message != nil) {
                [SVProgressHUD showSuccessWithStatus:@"回复成功" maskType: SVProgressHUDMaskTypeBlack];
                
//                CCFShowThreadPage * thread = message;
//
//                CCFSimpleReplyNavigationController * navigationController = (CCFSimpleReplyNavigationController *)self.navigationController;
//                
//                
//                self.delegate = (id<SimpleReplyDelegate>)navigationController.controller;
                
                [self dismissViewControllerAnimated:YES completion:^{
                    //[self.delegate transReplyValue:thread];
                }];
                
            } else{
                [SVProgressHUD showErrorWithStatus:@"回复失败" maskType: SVProgressHUDMaskTypeBlack];
            }
        }];
    } else{
        [self.ccfApi replyThreadWithId:threadId andMessage:self.replyContent.text handler:^(BOOL isSuccess, id message) {
            
            if (isSuccess) {
                
                [SVProgressHUD showSuccessWithStatus:@"回复成功" maskType: SVProgressHUDMaskTypeBlack];
                
                self.replyContent.text = @"";
                
                ShowThreadPage * thread = message;
                
                
                CCFSimpleReplyNavigationController * navigationController = (CCFSimpleReplyNavigationController *)self.navigationController;
                
                
                self.delegate = (id<ReplyCallbackDelegate>)navigationController.controller;
                
                [self dismissViewControllerAnimated:YES completion:^{
                    [self.delegate transReplyValue:thread];
                }];
                
                
            } else{
                [SVProgressHUD showErrorWithStatus:@"回复失败" maskType: SVProgressHUDMaskTypeBlack];
            }
        }];

    }
  
}


- (IBAction)back:(id)sender {
    [self.replyContent resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
