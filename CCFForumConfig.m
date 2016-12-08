//
//  CCFForumConfig.m
//  Forum
//
//  Created by WDY on 2016/12/8.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFForumConfig.h"

@implementation CCFForumConfig {
    NSURL *url;
    NSString *urlString;
}

- (instancetype)init {
    self = [super init];
    urlString = @"https://bbs.et8.net/bbs/";
    url = [NSURL URLWithString:urlString];

    return self;
}

- (NSString *)host {
    return url.host;
}

- (NSString *)url {
    return urlString;
}

- (UIColor *)themeColor {
    return [[UIColor alloc] initWithRed:25.f / 255.f green:67.f / 255.f blue:70.f / 255.f alpha:1];
}

- (NSString *)archive {
    return [urlString stringByAppendingString:@"archive/index.php"];
}

- (NSString *)newattachmentForThread:(int)threadId time:(NSString *)time postHash:(NSString *)postHash {
    return [NSString stringWithFormat:@"%@newattachment.php?t=%d&poststarttime=%@&posthash=%@", urlString, threadId, time, postHash];
}

- (NSString *)newattachmentForForum:(int)forumId time:(NSString *)time postHash:(NSString *)postHash {
    return [NSString stringWithFormat:@"%@newattachment.php?f=%d&poststarttime=%@&posthash=%@", urlString, forumId, time, postHash];
}

- (NSString *)newattachment {
    return [NSString stringWithFormat:@"%@newattachment.php", urlString];
}

- (NSString *)search {
    return [urlString stringByAppendingString:@"search.php"];
}

- (NSString *)searchWithSearchId:(NSString *)searchId withPage:(int)page {
    return [NSString stringWithFormat:@"%@search.php?searchid=%@&pp=30&page=%d",urlString, searchId, page];
}

- (NSString *)searchThreadWithUserId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@search.php?do=finduser&u=%@&starteronly=1", urlString ,userId];
}

- (NSString *)searchMyPostWithUserId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@search.php?do=finduser&userid=%@", urlString ,userId];
}

- (NSString *)searchMyThreadWithUserName:(NSString *)name {
    return [NSString stringWithFormat:@"%@search.php?do=process&showposts=0&starteronly=1&exactname=1&searchuser=%@", urlString ,name];
}

- (NSString *)favForumWithId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@subscription.php?do=addsubscription&f=%@", urlString,forumId];
}

- (NSString *)favForumWithIdParam:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@subscription.php?do=doaddsubscription&forumid=%@",urlString,forumId];
}

- (NSString *)unfavForumWithId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@subscription.php?do=removesubscription&f=%@",urlString, forumId];
}

- (NSString *)favThreadWithIdPre:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@subscription.php?do=addsubscription&t=%@",urlString, threadId];
}

- (NSString *)favThreadWithId:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@subscription.php?do=doaddsubscription&threadid=%@", urlString, threadId];
}

- (NSString *)unfavThreadWithId:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@subscription.php?do=removesubscription&t=%@",urlString, threadId];
}

- (NSString *)listfavThreadWithId:(int)page {
    return [NSString stringWithFormat:@"%@subscription.php?do=viewsubscription&pp=35&folderid=0&sort=lastpost&order=desc&page=%d", urlString, page];
}

- (NSString *)forumDisplayWithId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@forumdisplay.php?f=%@", urlString, forumId];
}

- (NSString *)forumDisplayWithId:(NSString *)forumId withPage:(int)page {
    return [NSString stringWithFormat:@"%@forumdisplay.php?f=%@&order=desc&page=%d", urlString, forumId, page];
}

- (NSString *)searchNewThread {
    return [NSString stringWithFormat:@"%@search.php?do=getnew", urlString];
}

- (NSString *)searchNewThreadToday {
    return [NSString stringWithFormat:@"%@search.php?do=getdaily",urlString];
}

- (NSString *)newReplyWithThreadId:(int)threadId {
    return [NSString stringWithFormat:@"%@newreply.php?do=postreply&t=%d",urlString, threadId];
}

- (NSString *)showThreadWithThreadId:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@showthread.php?t=%@",urlString, threadId];
}

- (NSString *)showThreadWithThreadId:(NSString *)threadId withPage:(int)page {
    return [NSString stringWithFormat:@"%@showthread.php?t=%@&page=%d",urlString, threadId, page];
}

- (NSString *)showThreadWithPostId:(NSString *)postId withPostCout:(int)postCount {
    return [NSString stringWithFormat:@"%@showpost.php?p=%@&postcount=%d",urlString, postId, postCount];
}

- (NSString *)showThreadWithP:(NSString *)p {
    return [NSString stringWithFormat:@"%@showthread.php?p=%@",urlString, p];
}

- (NSString *)avatar:(NSString *)avatar {
    return [NSString stringWithFormat:@"%@customavatars%@",urlString, avatar];
}

- (NSString *)avatarBase {
    return [urlString stringByAppendingString:@"customavatars"];
}

- (NSString *)avatarNo {
    return [[self avatarBase] stringByAppendingString:@"/no_avatar.gif"];
}

- (NSString *)memberWithUserId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@member.php?u=%@", urlString, userId];
}

- (NSString *)login {
    return [NSString stringWithFormat:@"%@login.php?do=login", urlString];
}

- (NSString *)loginvCode {
    return [NSString stringWithFormat:@"%@login.php?do=vcode", urlString];
}

- (NSString *)newThreadWithForumId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@newthread.php?do=newthread&f=%@", urlString,forumId];
}

- (NSString *)privateWithType:(int)type withPage:(int)page {
    return [NSString stringWithFormat:@"%@private.php?folderid=%d&pp=30&sort=date&page=%d", urlString,type, page];
}

- (NSString *)privateShowWithMessageId:(int)messageId {
    return [NSString stringWithFormat:@"%@private.php?do=showpm&pmid=%d", urlString,messageId];
}

- (NSString *)privateReplyWithMessageIdPre:(int)messageId {
    return [NSString stringWithFormat:@"%@private.php?do=insertpm&pmid=%d", urlString,messageId];
}

- (NSString *)privateReplyWithMessage {
    return [NSString stringWithFormat:@"%@private.php?do=insertpm&pmid=0", urlString];
}

- (NSString *)privateNewPre {
    return [NSString stringWithFormat:@"%@private.php?do=newpm", urlString];
}

- (NSString *)usercp {
    return [NSString stringWithFormat:@"%@usercp.php", urlString];
}

- (NSString *)report {
    return [NSString stringWithFormat:@"%@report.php?do=sendemail", urlString];
}

- (NSString *)reportWithPostId:(int)postId {
    return [NSString stringWithFormat:@"%@report.php?p=%d", urlString,postId];
}

@end
