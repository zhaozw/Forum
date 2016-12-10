//
//  ForumHtmlParser.m
//
//  Created by 迪远 王 on 16/10/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumHtmlParser.h"
#import "CCFForumHtmlParser.h"


static CCFForumHtmlParser *_ccfParser;

@implementation ForumHtmlParser

+ (instancetype)parserWithForumConfig:(ForumConfig *)config{
    
    if ([config.host isEqualToString:@"bbs.et8.net"]) {
        if (_ccfParser == nil){
            _ccfParser = [[CCFForumHtmlParser alloc] init];
            _ccfParser.config = config;
        }
        return _ccfParser;
    }
    return self;
}

- (instancetype)initWithForumConfig:(ForumConfig *)config {
    self = [super init];
    self.config = config;

    if ([config.host isEqualToString:@"bbs.et8.net"]){
        return [[CCFForumHtmlParser alloc] init];
    }
    return self;
}

@end
