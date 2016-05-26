//
//  ApiTestViewController.m
//  CCF
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
    
    
    ForumApi * api = [[ForumApi alloc] init];
//     [api loginWithName:@"马小甲" andPassWord:@"CCF!@#456" handler:^(BOOL isSuccess, id message) {
//         
//     }];
    
//    [api sendPrivateMessageToUserName:@"马小甲" andTitle:@"2222222" andMessage:@"ppppp" handler:^(BOOL isSuccess, id message) {
//        if (isSuccess) {
//            NSLog(@"发送成功 %@", message);
//        } else{
//            NSLog(@"发送失败 %@", message);
//        }
//    }];

    
//    [api replyPrivateMessageWithId:@"2022896" andMessage:@"ttttttttt" handler:^(BOOL isSuccess, id handler) {
//        
//    }];
    
//    [api listMyAllThreads:^(BOOL isSuccess, id message) {
//        NSLog(@"我的Thread %@", message);
//    }];
    
    
//    [api listMyAllThreadPost:^(BOOL isSuccess, id message) {
//        NSLog(@"listMyAllThreadPost %@", message);
//    }];
    
    
//    [api favoriteFormsWithId:@"123" handler:^(BOOL isSuccess, id message) {
//        
//    }];
//    
//    
//    [api unfavoriteFormsWithId:@"19" handler:^(BOOL isSuccess, id message) {
//        
//    }];
    
//    [api listfavoriteThreadPosts:^(BOOL isSuccess, NSString* message) {
//        NSLog(@"listfavoriteThreadPosts %@", message);
//    }];
    
    
    
//    [api fetchNewThreadPosts:^(BOOL isSuccess, id message) {
//        NSLog(@"fetchNewThreadPosts %@", message);
//    }];
    
    
    
//    [api fetchTodayNewThreads:^(BOOL isSuccess, id message) {
//        NSLog(@"fetchTodayNewThreads %@", message);
//    }];
    
    
//    [api favoriteThreadPostWithId:@"1335339" handler:^(BOOL isSuccess, id message) {
//        NSLog(@"favoriteThreadPostWithId %@", message);
//    }];
    
//    [api listFavoriteThreadPosts:^(BOOL isSuccess, id message) {
//        
//    }];


//    [api listNewThreadPosts:^(BOOL isSuccess, id message) {
//        NSLog(@"listNewThreadPosts %@", message);
//    }];

//    [api listTodayNewThreads:^(BOOL isSuccess, CCFSearchResultPage* message) {
//        NSLog(@"listTodayNewThreads %ld", message.searchResults.count);
//    }];


//    [api listMyAllThreadsWithPage:1 handler:^(BOOL isSuccess, id message) {
//        NSLog(@"listMyAllThreadWithPage ---- %@", message);
//    }];

    
//    [api showProfileWithUserId:@"71250" handler:^(BOOL isSuccess, id message) {
//        
//    }];
    
    
//    [api showPrivateContentById:2030751 handler:^(BOOL isSuccess, id message) {
//        
//    }];
    
    [api formList:^(BOOL isSuccess, id message) {
        
    }];

}


@end
