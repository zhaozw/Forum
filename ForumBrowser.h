//
//  ForumBrowser.h
//
//  Created by 迪远 王 on 16/10/3.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vBulletinForumEngine.h"

@class AFHTTPSessionManager;
@class ForumHtmlParser;

@interface ForumBrowser : NSObject <ForumEngine>

//- (instancetype)initWithForumHost:(NSString *)host;

+ (ForumBrowser*)browserWithForumHost:(NSString *)host;

@property(nonatomic, strong) NSString *phoneName;
@property(nonatomic, strong) ForumHtmlParser *htmlParser;
@property(nonatomic, strong) AFHTTPSessionManager *browser;

@end
