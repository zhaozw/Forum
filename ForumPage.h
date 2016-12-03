//
//  ForumPage.h
//
//  Created by WDY on 16/3/16.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Thread.h"

@interface ForumPage : NSObject


@property (nonatomic, strong) NSString * originalHtml;

@property(nonatomic, strong) NSMutableArray<Thread *> *threadList;

@property(nonatomic, assign) NSUInteger totalCount;
@property(nonatomic, assign) NSUInteger totalPageCount;
@property(nonatomic, assign) NSUInteger currentPage;

@property(nonatomic, strong) NSString *securityToken;
@property(nonatomic, strong) NSString *ajaxLastPost;


@end
