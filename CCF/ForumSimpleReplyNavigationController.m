//
//  ForumSimpleReplyNavigationController.m
//  CCF
//
//  Created by 迪远 王 on 16/4/10.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumSimpleReplyNavigationController.h"
#import "ReplyTransValueDelegate.h"

@interface ForumSimpleReplyNavigationController () <ReplyTransValueDelegate>

@end

@implementation ForumSimpleReplyNavigationController


- (void)transValue:(UIViewController *)controller withBundle:(TransValueBundle *)transBundle {
    self.controller = controller;
    self.bundle = transBundle;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
