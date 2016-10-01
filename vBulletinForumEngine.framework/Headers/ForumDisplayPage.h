//
//  CCFPage.h
//  CCF
//
//  Created by WDY on 16/3/16.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForumDisplayPage : NSObject

@property (nonatomic, strong) NSMutableArray * dataList;

@property (nonatomic, assign) NSUInteger totalCount;
@property (nonatomic, assign) NSUInteger totalPageCount;
@property (nonatomic, assign) NSUInteger currentPage;

@property (nonatomic, strong) NSString * securityToken;
@property (nonatomic, strong) NSString * ajaxLastPost;


@end
