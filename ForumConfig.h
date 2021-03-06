//
//  ForumConfig.h
//  Forum
//
//  Created by WDY on 2016/12/8.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define THREAD_PAGE [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_view" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil]
#define THREAD_PAGE_NOTITLE [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_view_notitle" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil]
#define POST_MESSAGE [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_message" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil]
#define PRIVATE_MESSAGE [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"private_message" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil]

@interface ForumConfig : NSObject

+ (ForumConfig*)configWithForumHost:(NSString *)host;

- (UIColor *) themeColor;

- (NSString *) host;

- (NSString *) url;

- (NSString *) archive;

- (NSString *) cookieUserIdKey;

- (NSString *) cookieLastVisitTimeKey;

- (NSString *) cookieExpTimeKey;

// 附件相关
- (NSString *)newattachmentForThread:(int) threadId time:(NSString *)time postHash:(NSString *)postHash;
- (NSString *)newattachmentForForum:(int) forumId time:(NSString *)time postHash:(NSString *)postHash;
- (NSString *)newattachment;

// 搜索相关
- (NSString *) search;
- (NSString *) searchWithSearchId:(NSString *)searchId withPage:(int)page;
- (NSString *) searchThreadWithUserId:(NSString *)userId;
- (NSString *) searchMyPostWithUserId:(NSString *)userId;
- (NSString *)searchMyThreadWithUserName:(NSString *)name;

// 收藏论坛
- (NSString *) favForumWithId:(NSString *)forumId;
- (NSString *) favForumWithIdParam:(NSString *)forumId;
- (NSString *) unfavForumWithId:(NSString *)forumId;

// 收藏主题
- (NSString *) favThreadWithIdPre:(NSString *)threadId;
- (NSString *) favThreadWithId:(NSString *)threadId;
- (NSString *) unfavThreadWithId:(NSString *)threadId;
- (NSString *) listfavThreadWithId:(int)page;

// FormDisplay
- (NSString *) forumDisplayWithId:(NSString *)forumId;
- (NSString *) forumDisplayWithId:(NSString *)forumId withPage:(int)page;



// 查看新帖
- (NSString *) searchNewThread;
- (NSString *) searchNewThreadToday;

// 回帖
- (NSString *) newReplyWithThreadId:(int) threadId;

// ShowThread
- (NSString *) showThreadWithThreadId:(NSString *) threadId;
- (NSString *) showThreadWithThreadId:(NSString *) threadId withPage:(int)page;
- (NSString *) showThreadWithPostId:(NSString *) postId withPostCout:(int) postCount;
- (NSString *) showThreadWithP:(NSString *) p;

// 头像
- (NSString *) avatar:(NSString *)avatar;
- (NSString *) avatarBase;
- (NSString *) avatarNo;

// User Page
- (NSString *) memberWithUserId:(NSString *)userId;

// 登录
- (NSString *) login;
- (NSString *) loginvCode;


// 发表新帖子
- (NSString *) newThreadWithForumId:(NSString *)forumId;

// 站内短信
- (NSString *) privateWithType:(int)type withPage:(int)page;
- (NSString *) privateShowWithMessageId:(int)messageId;
- (NSString *) privateReplyWithMessageIdPre:(int)messageId;
- (NSString *) privateReplyWithMessage;
- (NSString *) privateNewPre;

// UserCP
- (NSString *) usercp;

// report
- (NSString *) report;
- (NSString *) reportWithPostId:(int) postId;

@end
