//
//  ForumConfig.m
//  Forum
//
//  Created by WDY on 2016/12/8.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumConfig.h"
#import "CCFForumConfig.h"
#import "DRLForumConfig.h"

#import "AppDelegate.h"

static CCFForumConfig *_ccfForumConfig;
static DRLForumConfig *_drlForumConfig;

static ForumConfig * _defForumConfig;

@implementation ForumConfig

- (NSString *)url {
    return nil;
}

- (NSString *)cookieUserIdKey {
    return nil;
}

- (NSString *)cookieLastVisitTimeKey {
    return nil;
}

- (NSString *)cookieExpTimeKey {
    return nil;
}


+ (ForumConfig *)configWithForumHost:(NSString *)host {

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *bundleId = [appDelegate bundleIdentifier];

    if ([bundleId isEqualToString:@"com.andforce.et8"]){
        if (_ccfForumConfig == nil) {
            _ccfForumConfig = [[CCFForumConfig alloc] init];
        }
        return _ccfForumConfig;
    } else if ([bundleId isEqualToString:@"com.andforce.DRL"]){
        if (_drlForumConfig == nil) {
            _drlForumConfig = [[DRLForumConfig alloc] init];
        }
        return _drlForumConfig;
    } else{
        if ([host isEqualToString:@"bbs.et8.net"]) {
            if (_ccfForumConfig == nil) {
                _ccfForumConfig = [[CCFForumConfig alloc] init];
            }
            return _ccfForumConfig;
        } else if ([host isEqualToString:@"dream4ever.org"]) {
            if (_drlForumConfig == nil) {
                _drlForumConfig = [[DRLForumConfig alloc] init];
            }
            return _drlForumConfig;
        }

        if (_defForumConfig == nil) {
            _defForumConfig = [[ForumConfig alloc] init];
        }
        return _defForumConfig;
    }

}


- (NSString *)host {
    return nil;
}

- (UIColor *)themeColor {
    return [[UIColor alloc] initWithRed:29.f/255.f green:67.f/255.f blue:71.f/255.f alpha:1];;
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

- (NSString *)searchMyThreadWithUserName:(NSString *)userId {
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
