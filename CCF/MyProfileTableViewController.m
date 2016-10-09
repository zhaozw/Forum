//
//  MyProfileTableViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/10/9.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "MyProfileTableViewController.h"

@interface MyProfileTableViewController (){
    UserProfile * userProfile;
    
}

@end

@implementation MyProfileTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(BOOL)setLoadMore:(BOOL)enable{
    return NO;
}


-(void)onPullRefresh{
    
    NSString * currentUserId = self.ccfApi.getLoginUser.userID;
    
    [self.ccfApi showProfileWithUserId:currentUserId handler:^(BOOL isSuccess, UserProfile* message) {
        userProfile = message;
        
        [self.tableView.mj_header endRefreshing];
        
        [self.tableView reloadData];
    }];
}

@end
