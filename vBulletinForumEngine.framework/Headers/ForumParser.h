//
//  ForumParser.h
//  vBulletinForumEngine
//
//  Created by 迪远 王 on 16/10/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <vBulletinForumEngine/LoginUser.h>
#import <vBulletinForumEngine/PrivateMessage.h>
#import <vBulletinForumEngine/ShowPrivateMessage.h>
#import <vBulletinForumEngine/Post.h>
#import <vBulletinForumEngine/User.h>
#import <vBulletinForumEngine/Forum.h>
#import <vBulletinForumEngine/Thread.h>
#import <vBulletinForumEngine/UserProfile.h>
#import <vBulletinForumEngine/SimpleThread.h>
#import <vBulletinForumEngine/NormalThread.h>
#import <vBulletinForumEngine/ShowThreadPage.h>
#import <vBulletinForumEngine/ForumDisplayPage.h>
#import <vBulletinForumEngine/ThreadInSearch.h>
#import <vBulletinForumEngine/SearchForumDisplayPage.h>

@protocol ForumParser <NSObject>

- (ShowThreadPage *) parseShowThreadWithHtml:(NSString*)html;


- (ForumDisplayPage *) parseThreadListFromHtml: (NSString *) html withThread:(int) threadId andContainsTop:(BOOL)containTop;

- (ForumDisplayPage *) parseFavThreadListFormHtml: (NSString *) html;

- (NSString *) parseSecurityToken:(NSString *)html;

- (NSString *) parsePostHash:(NSString *)html;

- (NSString *) parserPostStartTime:(NSString *)html;


- (NSString *) parseLoginErrorMessage:(NSString *)html;

- (SearchForumDisplayPage *) parseSearchPageFromHtml:( NSString*) html;

- (NSMutableArray<Forum *> *) parseFavFormFormHtml:(NSString *)html;

- (ForumDisplayPage*) parsePrivateMessageFormHtml:(NSString*) html;

- (ShowPrivateMessage *) parsePrivateMessageContent:(NSString*) html;

- (NSString *) parseQuickReplyQuoteContent:(NSString*) html;

- (NSString *) parseQuickReplyTitle:(NSString *)html;

- (NSString *) parseQuickReplyTo:(NSString *)html;

- (NSString *) parseUserAvatar:(NSString *)html userId:(NSString*) userId;

- (NSString *) parseListMyThreadSearchid:(NSString *)html;

- (UserProfile *) parserProfile:(NSString*)html userId:(NSString*)userId;

- (NSArray<Forum *> *) parserForms:(NSString *) html;

@end
