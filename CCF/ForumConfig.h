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
#define BBS_NEWATTACHMENT_THREAD(threadId, time, hash) [NSString stringWithFormat:@"%@newattachment.php?t=%d&poststarttime=%@&posthash=%@", BBS_URL, threadId, time, hash]
#define BBS_NEWATTACHMENT_FORM(formId, time, hash) [NSString stringWithFormat:@"%@newattachment.php?f=%d&poststarttime=%@&posthash=%@", BBS_URL, formId, time, hash]
// 管理附件
#define BBS_MANAGE_ATT [NSString stringWithFormat:@"%@newattachment.php?do=manageattach&p=", BBS_URL]
//#define BBS_NEWATTACHMENT(...) [NSString stringWithFormat:BBS_NEWATTACHMENT_PATTERN,##__VA_ARGS__]

// 搜索相关
#define BBS_SEARCH_WITH_SEARCHID(searchid, page)[NSString stringWithFormat:@"%@search.php?searchid=%@&pp=30&page=%d",BBS_URL, searchid, page]

// Find User
#define BBS_FIND_USER_THREADS(userId) [NSString stringWithFormat:@"%@search.php?do=finduser&u=%d&starteronly=1", BBS_URL ,userId]

// 收藏论坛
#define BBS_SUBSCRIPTION(formId) [NSString stringWithFormat:@"%@subscription.php?do=addsubscription&f=%@", BBS_URL,formId]
// 收藏论坛参数
#define BBS_SUBSCRIPTION_PARAM(formId) [NSString stringWithFormat:@"%@subscription.php?do=doaddsubscription&forumid=%@",BBS_URL,formId]

// 取消收藏论坛
#define BBS_UNFAV_FORM(formId) [NSString stringWithFormat:@"%@subscription.php?do=removesubscription&f=%@",BBS_URL, formId]

// 收藏主题
#define BBS_FAV_THREAD(threadId) [NSString stringWithFormat:@"%@subscription.php?do=addsubscription&t=%@",BBS_URL, threadId]
#define BBS_SUBSCRIPTION_THREAD(threadId) [NSString stringWithFormat:@"%@subscription.php?do=doaddsubscription&threadid=%@", BBS_URL, threadId]

// 取消收藏主题
#define BBS_UNFAV_THREAD(threadId) [NSString stringWithFormat:@"%@subscription.php?do=removesubscription&t=%@",BBS_URL, threadId]

// FormDisplay
#define BBS_FORMDISPLAY(formId) [NSString stringWithFormat:@"%@forumdisplay.php?f=%@", BBS_URL, formId]
#define BBS_FORMDISPLAY_PAGE(formId, page) [NSString stringWithFormat:@"%@forumdisplay.php?f=%d&order=desc&page=%d", BBS_URL, formId, page]

// 列出收藏的帖子
#define BBS_LIST_FAV_POST(page) [NSString stringWithFormat:@"%@subscription.php?do=viewsubscription&pp=35&folderid=0&sort=lastpost&order=desc&page=%d", BBS_URL, page]

// 查看新帖
#define BBS_GET_NEW [NSString stringWithFormat:@"%@search.php?do=getnew", BBS_URL]

// 今日新帖
#define BBS_GET_DAILY [NSString stringWithFormat:@"%@search.php?do=getdaily",BBS_URL]

// 回帖
#define BBS_REPLY(threadId) [NSString stringWithFormat:@"%@newreply.php?do=postreply&t=%d",BBS_URL, threadId]

// ShowThread
#define BBS_SHOWTHREAD(threadId) [NSString stringWithFormat:@"%@showthread.php?t=%@",BBS_URL, threadId]
#define BBS_SHOWTHREAD_POSTCOUNT(postId, postcount) [NSString stringWithFormat:@"%@showpost.php?p=%d&postcount=%@",BBS_URL, postId, postcount]
#define BBS_SHOWTHREAD_PAGE(threadId, page) [NSString stringWithFormat:@"%@showthread.php?t=%d&page=%d",BBS_URL, threadId, page]
// 头像
#define BBS_AVATAR(avatar) [NSString stringWithFormat:@"%@customavatars%@",BBS_URL, avatar]

// User Page
#define BBS_USER(userId) [NSString stringWithFormat:@"%@member.php?u=%@", BBS_URL, userId]

// 登录
#define BBS_LOGIN [NSString stringWithFormat:@"%@login.php?do=login", BBS_URL]

// 验证码
#define BBS_VCODE [NSString stringWithFormat:@"%@login.php?do=vcode", BBS_URL]

// 收件箱
#define BBS_INBOX [NSString stringWithFormat:@"%@private.php?folderid=0", BBS_URL]

// 发表新帖子
#define BBS_NEW_THREAD(formId) [NSString stringWithFormat:@"%@newthread.php?do=newthread&f=%d", BBS_URL,formId]

// 站内短信
#define BBS_PM_WITH_TYPE(type, page) [NSString stringWithFormat:@"%@private.php?folderid=%d&pp=30&sort=date&page=%d", BBS_URL,type, page]
#define BBS_SHOW_PM(messageId) [NSString stringWithFormat:@"%@private.php?do=showpm&pmid=%d", BBS_URL,messageId]
#define BBS_REPLY_PM(messageId) [NSString stringWithFormat:@"%@private.php?do=insertpm&pmid=%d", BBS_URL,messageId]
#define BBS_SEND_PM [NSString stringWithFormat:@"%@private.php?do=insertpm&pmid=0", BBS_URL]

#define BBS_NEW_PM [NSString stringWithFormat:@"%@private.php?do=newpm", BBS_URL]




































