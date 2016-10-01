//
//  CCGParser.h
//  CCF
//
//  Created by 迪远 王 on 15/12/30.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <vBulletinForumEngine/vBulletinForumEngine.h>

#import "FormEntry+CoreDataProperties.h"



@interface ForumParser : NSObject


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
