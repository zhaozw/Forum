//
//  ForumConfig.h
//  CCF
//
//  Created by 迪远 王 on 16/6/10.
//  Copyright © 2016年 andforce. All rights reserved.
//

#define THREAD_PAGE [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_view" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil]
#define THREAD_PAGE_NOTITLE [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_view_notitle" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil]
#define POST_MESSAGE [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_message" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil]
#define PRIVATE_MESSAGE [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"private_message" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil]

#define BBS_URL @"https://bbs.et8.net/bbs/"
#define AVATAR_BASE_URL [BBS_URL stringByAppendingString:@"customavatars"]
#define NO_AVATAR_URL [AVATAR_BASE_URL stringByAppendingString:@"/no_avatar.gif"]

//#define S(f,...) [NSString stringWithFormat:f,##__VA_ARGS__]
#define BBS_ARCHIVE [BBS_URL stringByAppendingString:@"archive/index.php"]
#define BBS_SEARCH [BBS_URL stringByAppendingString:@"search.php"]

// 附件相关
#define BBS_NEWATTACHMENT_PATTERN [BBS_URL stringByAppendingString:@"newattachment.php?t=%d&poststarttime=%@&posthash=%@"]
#define BBS_NEWATTACHMENT(...) [NSString stringWithFormat:BBS_NEWATTACHMENT_PATTERN,##__VA_ARGS__]

// 搜索相关
#define BBS_SEARCH_PATTERN [BBS_URL stringByAppendingString:@"search.php?searchid=%@&pp=30&page=%d"]
#define BBS_SEARCH_WITH_SEARCHID(searchid, page)[NSString stringWithFormat:BBS_SEARCH_PATTERN,searchid, page]