//
//  ForumHtmlParser.m
//
//  Created by 迪远 王 on 16/10/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumHtmlParser.h"
#import "CCFForumHtmlParser.h"
#import "DRLForumHtmlParser.h"
#import "AppDelegate.h"

static CCFForumHtmlParser *_ccfParser;
static DRLForumHtmlParser *_drlParser;

@implementation ForumHtmlParser

+ (instancetype)parserWithForumConfig:(ForumConfig *)config{

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *bundleId = [appDelegate bundleIdentifier];

    if ([bundleId isEqualToString:@"com.andforce.et8"]){
        if (_ccfParser == nil){
            _ccfParser = [[CCFForumHtmlParser alloc] init];
        }
        return _ccfParser;
    } else if ([bundleId isEqualToString:@"com.andforce.DRL"]){
        if (_drlParser == nil){
            _drlParser = [[DRLForumHtmlParser alloc] init];
            _drlParser.config = config;
        }
        return _drlParser;
    } else{
        if ([config.host isEqualToString:@"bbs.et8.net"]) {
            if (_ccfParser == nil){
                _ccfParser = [[CCFForumHtmlParser alloc] init];
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
}


@end
