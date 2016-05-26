
//
//  CCFWritePMViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/4/9.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFWritePMViewController.h"
#import "CCFWritePMNavigationController.h"
#import <SVProgressHUD.h>


@interface CCFWritePMViewController ()

@end



@implementation CCFWritePMViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * profileName = [((CCFWritePMNavigationController*)self.navigationController).bundle getStringValue:@"PROFILE_NAME"];
    
    
    if (profileName != nil) {
        self.toWho.text = profileName;
        [self.privateMessageTitle becomeFirstResponder];
    } else{
        [self.toWho becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)sendPrivateMessage:(id)sender {
    if ([self.toWho.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"无收件人" maskType:SVProgressHUDMaskTypeBlack];
    } else if ([self.privateMessageTitle.text isEqualToString:@""]){
        [SVProgressHUD showErrorWithStatus:@"无标题" maskType:SVProgressHUDMaskTypeBlack];
    } else if ([self.privateMessageContent.text isEqualToString:@""]){
        [SVProgressHUD showErrorWithStatus:@"无内容" maskType:SVProgressHUDMaskTypeBlack];
    } else{
        
        [self.privateMessageContent resignFirstResponder];
        
        [SVProgressHUD showWithStatus:@"正在发送" maskType:SVProgressHUDMaskTypeBlack];
        
        [self.ccfApi sendPrivateMessageToUserName:self.toWho.text andTitle:self.privateMessageTitle.text andMessage:self.privateMessageContent.text handler:^(BOOL isSuccess, id message) {

            [SVProgressHUD dismiss];
            
            if (isSuccess) {
                [self.navigationController popViewControllerAnimated:YES];
            } else{
                [SVProgressHUD showErrorWithStatus:message maskType:SVProgressHUDMaskTypeBlack];
            }
            
        }];
        
    }
}
@end
