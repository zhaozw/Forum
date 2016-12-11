//
//  ForumHtmlParser.m
//
//  Created by 迪远 王 on 16/10/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumHtmlParser.h"
#import "CCFForumHtmlParser.h"
#import "DRLForumHtmlParser.h"


static CCFForumHtmlParser *_ccfParser;
static DRLForumHtmlParser *_drlParser;

@implementation ForumHtmlParser

+ (instancetype)parserWithForumConfig:(ForumConfig *)config{
    
    if ([config.host isEqualToString:@"bbs.et8.net"]) {
        if (_ccfParser == nil){
            _ccfParser = [[CCFForumHtmlParser alloc] init];
            _ccfParser.config = config;
        }
        return _ccfParser;
    } else if ([config.host isEqualToString:@"dream4ever.org"]){
        if (_drlParser == nil){
            _drlParser = [[DRLForumHtmlParser alloc] init];
            _drlParser.config = config;
        }
        return _drlParser;
    }
        
    return self;
}

- (instancetype)initWithForumConfig:(ForumConfig *)config {
    self = [super init];
    self.config = config;

    if ([config.host isEqualToString:@"bbs.et8.net"]){
        return [[CCFForumHtmlParser alloc] init];
    } else if ([config.host isEqualToString:@"dream4ever.org"]){
        return [[DRLForumHtmlParser alloc] init];
    }
    return self;
}

@end
