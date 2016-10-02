//
//  CCFBrowser.h
//  CCF
//
//  Created by 迪远 王 on 15/12/30.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vBulletinForumEngine/vBulletinForumEngine.h>

typedef void (^Reply) (BOOL isSuccess, id result);

typedef void (^CallBack) (NSString* token, NSString * hash, NSString* time );


@interface ForumBrowser : NSObject

// 登录论坛
-(void) loginWithName:(NSString*)name andPassWord:(NSString*)passWord : (HandlerWithBool) callBack;

// 刷新验证码
-(void) refreshVCodeToUIImageView:(UIImageView* ) vCodeImageView;

// 回复帖子
-(void) replyThreadWithId:(int) threadId withMessage:(NSString *) message handler: (HandlerWithBool) result;

// 获取当前登录的用户
-(LoginUser *) getCurrentCCFUser;

// 获取所有的论坛列表
-(void) formList:(HandlerWithBool)handler;

// 搜索论坛
-(void) searchWithKeyWord:(NSString*) keyWord forType:(int)type searchDone:(HandlerWithBool) callback;

// 发一个新主题
-(void)createNewThreadWithFormId:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message withImages:(NSArray *)images handler:(HandlerWithBool)handler;

// 读取论坛站内私信   type 0 表示收件箱   1表示发件箱
-(void) privateMessageWithType:(int) type andpage:(int)page handler:(HandlerWithBool) handler;

// 根据PM ID 显示一条私信内容
-(void) showPrivateContentById:(int)pmId handler:(HandlerWithBool)handler;

// 回复站内短信
-(void) replyPrivateMessageWithId:(int)pmId andMessage:(NSString*) message handler:(HandlerWithBool)handler;

// 发送站内短信
-(void) sendPrivateMessageToUserName:(NSString*)name andTitle:(NSString*)title andMessage:(NSString*) message handler:(HandlerWithBool)handler;

// 获取收藏的论坛板块
-(void) listfavoriteForms:(HandlerWithBool) handler;

// 显示我的回帖
-(void) listMyAllThreadPost:(HandlerWithBool)handler;

// 显示我发表的主题
-(void) listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler;

// 收藏一个论坛
-(void)favoriteFormsWithId:(NSString *)formId handler:(HandlerWithBool) handler;

// 取消收藏一个论坛
-(void)unfavoriteFormsWithId:(NSString *)formId handler:(HandlerWithBool) handler;

// 取消收藏一个主题帖子
-(void)unfavoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool) handler;

// 获取收藏的主题帖子
-(void)listFavoriteThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler;

// 查看新帖
-(void)listNewThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler;

// 查看今天的新帖
-(void)listTodayNewThreadsWithPage:(int)page handler:(HandlerWithBool)handler;

// 收藏一个回帖
-(void)favoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool) handler;

// 查看一个贴子
-(void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool) handler;

-(void)showThreadWithP:(NSString *)p handler:(HandlerWithBool) handler;

// 查看论坛板块
-(void) forumDisplayWithId:(int) formId andPage:(int)page handler:(HandlerWithBool)handler;

// 展示个人页面
-(void)showProfileWithUserId:(NSString *)userId handler:(HandlerWithBool)handler;

// 展示搜索结果
-(void) listSearchResultWithSearchid:(NSString *) searchid andPage:(int) page handler:(HandlerWithBool)handler;

// 查看此用户的帖子
-(void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler;

// 快速回帖
-(void)quickReplyPostWithThreadId:(int)threadId forPostId:(int)postId andMessage:(NSString *)message securitytoken:(NSString *)token ajaxLastPost:(NSString *)ajax_lastpost handler:(HandlerWithBool)handler;

// 高级回帖
-(void)seniorReplyWithThreadId:(int)threadId forFormId:(int) formId andMessage:(NSString *)message withImages:(NSArray *)images securitytoken:(NSString *)token handler:(HandlerWithBool)handler;

@end
