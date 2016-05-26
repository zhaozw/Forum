//
//  CCFBrowser.h
//  CCF
//
//  Created by 迪远 王 on 15/12/30.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking.h>

#import "LoginUser.h"
#import "Forum.h"

@class ShowThreadPage;


typedef void(^Handler) (BOOL isSuccess, id result);

typedef void (^Reply) (BOOL isSuccess, id result);

typedef void (^CallBack) (NSString* token, NSString * hash, NSString* time );


@interface CCFBrowser : NSObject

@property (nonatomic, strong) AFHTTPSessionManager * browser;


-(void) loginWithName:(NSString*)name andPassWord:(NSString*)passWord : (Handler) callBack;

-(void) refreshVCodeToUIImageView:(UIImageView* ) vCodeImageView;

-(void) replyThreadWithId:(NSString *) threadId withMessage:(NSString *) message handler: (Handler) result;

-(LoginUser *) getCurrentCCFUser;

// 获取所有的论坛列表
-(void) formList:(Handler)handler;

-(void) searchWithKeyWord:(NSString*) keyWord searchDone:(Handler) callback;


-(void)createNewThreadWithFormId:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message withImages:(NSArray *)images handler:(Handler)handler;

// 读取论坛站内私信   type 0 表示收件箱   1表示发件箱
-(void) privateMessageWithType:(int) type andpage:(int)page handler:(Handler) handler;

// 根据PM ID 显示一条私信内容
-(void) showPrivateContentById:(int)pmId handler:(Handler)handler;

// 回复站内短信
-(void) replyPrivateMessageWithId:(int)pmId andMessage:(NSString*) message handler:(Handler)handler;

// 发送站内短信
-(void) sendPrivateMessageToUserName:(NSString*)name andTitle:(NSString*)title andMessage:(NSString*) message handler:(Handler)handler;

// 获取收藏的论坛板块
-(void) listfavoriteForms:(Handler) handler;

// 显示我的回帖
-(void) listMyAllThreadPost:(Handler)handler;

// 显示我发表的主题
-(void) listMyAllThreadsWithPage:(int)page handler:(Handler)handler;

-(void)favoriteFormsWithId:(NSString *)formId handler:(Handler) handler;

-(void)unfavoriteFormsWithId:(NSString *)formId handler:(Handler) handler;

// 取消收藏一个主题帖子
-(void)unfavoriteThreadPostWithId:(NSString *)threadPostId handler:(Handler) handler;

// 获取收藏的主题帖子
-(void)listFavoriteThreadPostsWithPage:(int)page handler:(Handler)handler;

-(void)listNewThreadPostsWithPage:(int)page handler:(Handler)handler;

-(void)listTodayNewThreadsWithPage:(int)page handler:(Handler)handler;

-(void)favoriteThreadPostWithId:(NSString *)threadPostId handler:(Handler) handler;

-(void)showThreadWithId:(int)threadId andPage:(int)page handler:(Handler) handler;

-(void) forumDisplayWithId:(int) formId andPage:(int)page handler:(Handler)handler;

-(void)showProfileWithUserId:(NSString *)userId handler:(Handler)handler;

-(void) listSearchResultWithUrl:(NSString *) url andPage:(int) page handler:(Handler)handler;

-(void)listAllUserThreads:(int)userId withPage:(int)page handler:(Handler)handler;

-(void)quickReplyPostWithThreadId:(int)threadId forPostId:(int)postId andMessage:(NSString *)message securitytoken:(NSString *)token ajaxLastPost:(NSString *)ajax_lastpost handler:(Handler)handler;

-(void)seniorReplyWithThreadId:(int)threadId forFormId:(int) formId andMessage:(NSString *)message withImages:(NSArray *)images securitytoken:(NSString *)token handler:(Handler)handler;

@end
