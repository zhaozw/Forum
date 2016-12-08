//
//  CCFForumConfig.m
//  Forum
//
//  Created by WDY on 2016/12/8.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFForumConfig.h"

@implementation CCFForumConfig{
    NSURL *url;
}

- (id)initWithHost:(NSString *)host {
    self = [super init];
    url = [NSURL URLWithString:@"https://bbs.et8.net/bbs/"];
    
    return self;
}

- (NSString *)host {
    return url.host;
}

- (UIColor *)themeColor {
    return nil;
}

- (NSString *)archive {
    return nil;
}

- (NSString *)newattachmentForThread:(int)threadId time:(NSString *)time postHash:(NSString *)postHash {
    return nil;
}

- (NSString *)newattachmentForForum:(int)forumId time:(NSString *)time postHash:(NSString *)postHash {
    return nil;
}

- (NSString *)newattachment {
    return nil;
}

- (NSString *)search {
    return nil;
}

- (NSString *)searchWithSearchId:(NSString *)searchId withPage:(int)page {
    return nil;
}

- (NSString *)searchThreadWithUserId:(NSString *)userId {
    return nil;
}

- (NSString *)searchMyPostWithUserId:(NSString *)userId {
    return nil;
}

- (NSString *)searchMyThreadWithUserId:(NSString *)userId {
    return nil;
}

- (NSString *)favForumWithId:(NSString *)forumId {
    return nil;
}

- (NSString *)favForumWithIdParam:(NSString *)forumId {
    return nil;
}

- (NSString *)unfavForumWithId:(NSString *)forumId {
    return nil;
}

- (NSString *)favThreadWithIdPre:(NSString *)forumId {
    return nil;
}

- (NSString *)favThreadWithId:(NSString *)forumId {
    return nil;
}

- (NSString *)unfavThreadWithId:(NSString *)forumId {
    return nil;
}

- (NSString *)listfavThreadWithId:(NSString *)forumId {
    return nil;
}

- (NSString *)listfavPostWithPage:(int)page {
    return nil;
}

- (NSString *)forumDisplayWithId:(NSString *)forumId {
    return nil;
}

- (NSString *)forumDisplayWithId:(NSString *)forumId withPage:(int)page {
    return nil;
}

- (NSString *)searchNewThread {
    return nil;
}

- (NSString *)searchNewThreadToday {
    return nil;
}

- (NSString *)newReplyWithThreadId:(int)threadId {
    return nil;
}

- (NSString *)showThreadWithThreadId:(NSString *)threadId {
    return nil;
}

- (NSString *)showThreadWithThreadId:(NSString *)threadId withPage:(int)page {
    return nil;
}

- (NSString *)showThreadWithPostId:(NSString *)postId withPostCout:(int)postCount {
    return nil;
}

- (NSString *)showThreadWithP:(NSString *)p {
    return nil;
}

- (NSString *)avatar:(NSString *)avatar {
    return nil;
}

- (NSString *)avatarBase {
    return nil;
}

- (NSString *)avatarNo {
    return nil;
}

- (NSString *)memberWithUserId:(NSString *)userId {
    return nil;
}

- (NSString *)login {
    return nil;
}

- (NSString *)loginvCode {
    return nil;
}

- (NSString *)newThreadWithForumId:(NSString *)forumId {
    return nil;
}

- (NSString *)privateWithType:(int)type withPage:(int)page {
    return nil;
}

- (NSString *)privateShowWithMessageId:(int)messageId {
    return nil;
}

- (NSString *)privateReplyWithMessageIdPre:(int)messageId {
    return nil;
}

- (NSString *)privateReplyWithMessage {
    return nil;
}

- (NSString *)privateNewPre {
    return nil;
}

- (NSString *)usercp {
    return nil;
}

- (NSString *)report {
    return nil;
}

- (NSString *)reportWithPostId:(int)postId {
    return nil;
}

@end
