//
//  CCFApi.h
//  CCF
//
//  Created by 迪远 王 on 16/2/28.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginUser.h"
#import "ForumDisplayPage.h"
#import "ThreadInSearch.h"
#import "SearchForumDisplayPage.h"
#import "Forum.h"

typedef void (^HandlerWithBool) (BOOL isSuccess, id message);

@interface ForumApi : NSObject


// 登录论坛
-(void) loginWithName:(NSString*)name andPassWord:(NSString*) passWord handler:(HandlerWithBool) handler;

// 获取当前登录的账户信息
-(LoginUser *) getLoginUser;

// 退出论坛
-(void) logout;

// 获取所有的论坛列表
-(void) formList:(HandlerWithBool)handler;

// 发表一个新的帖子
-(void) createNewThreadWithFormId:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message withImages:(NSArray *) images handler:(HandlerWithBool) handler;

// 发表一个回帖
-(void) replyThreadWithId:(int) threadId andMessage:(NSString*) message handler:(HandlerWithBool) handler;

// 快速回复
-(void) quickReplyPostWithThreadId:(int)threadId forPostId:(int)postId andMessage:(NSString *)message securitytoken:(NSString *)token ajaxLastPost:(NSString*)ajax_lastpost handler:(HandlerWithBool) handler;

// 高级模式回复
-(void) seniorReplyWithThreadId:(int)threadId  forFormId:(int) formId andMessage:(NSString *)message withImages:(NSArray *)images securitytoken:(NSString *)token handler:(HandlerWithBool)handler;

// 搜索论坛
-(void) searchWithKeyWord:(NSString*) keyWord handler:(HandlerWithBool) handler;

// 根据PM ID 显示一条私信内容
-(void) showPrivateContentById:(int)pmId handler:(HandlerWithBool)handler;

// 发送站内短信
-(void) sendPrivateMessageToUserName:(NSString*)name andTitle:(NSString*)title andMessage:(NSString*) message handler:(HandlerWithBool)handler;

// 回复站内短信
-(void) replyPrivateMessageWithId:(int)pmId andMessage:(NSString*) message handler:(HandlerWithBool)handler;

// 收藏这个论坛
-(void) favoriteFormsWithId:(NSString*)formId handler:(HandlerWithBool)handler;

// 取消收藏论坛
-(void) unfavoriteFormsWithId:(NSString*)formId handler:(HandlerWithBool)handler;

// 收藏一个主题帖子
-(void)favoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler;

// 取消收藏一个主题帖子
-(void)unfavoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler;

//------------------------------读取API-----------------------------------------//
// 读取论坛站内私信List   type 0 表示收件箱   -1表示发件箱
-(void) listPrivateMessageWithType:(int) type andPage:(int)page handler:(HandlerWithBool) handler;

// 获取收藏的论坛板块
-(void) listFavoriteForms:(HandlerWithBool) handler;

// 获取收藏的主题帖子
-(void)listFavoriteThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler;

// 查看新帖
-(void) listNewThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler;

// 查看今日新帖
-(void) listTodayNewThreadsWithPage:(int) page handler:(HandlerWithBool)handler;

// 显示我的回帖
-(void) listMyAllThreadPost:(HandlerWithBool)handler;

// 显示我发表的主题
-(void) listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler;

// 显示用户发表的主题
-(void) listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler;

// 显示主题帖子和所有回帖
-(void) showThreadWithId:(int) threadId andPage:(int)page handler:(HandlerWithBool)handler;

-(void) forumDisplayWithId:(int) formId andPage:(int)page handler:(HandlerWithBool)handler;

-(void) getAvatarWithUserId:(NSString*)userId handler:(HandlerWithBool)handler;

-(void) listSearchResultWithUrl:(NSString *) url andPage:(int) page handler:(HandlerWithBool)handler;

// 显示用户信息页面
-(void) showProfileWithUserId:(NSString*)userId handler:(HandlerWithBool) handler;
@end
