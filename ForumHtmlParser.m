//
//  ForumHtmlParser.m
//
//  Created by 迪远 王 on 16/10/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumHtmlParser.h"
#import "CCFForumHtmlParser.h"


@implementation ForumHtmlParser

- (instancetype)initWithForumConfig:(ForumConfig *)config {
    self = [super init];
    self.config = config;

    if ([config.host isEqualToString:@"bbs.et8.net"]){
        return [[CCFForumHtmlParser alloc] init];
    }
    return self;
}

@end
