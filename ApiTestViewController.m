//
//  ApiTestViewController.m
//
//  Created by WDY on 16/3/1.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ApiTestViewController.h"
#import "ForumApi.h"

@interface ApiTestViewController ()

@end

@implementation ApiTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    ForumApi *api = [[ForumApi alloc] init];

    [api formList:^(BOOL isSuccess, id message) {

    }];

}


@end
