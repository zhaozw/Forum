//
//  ForumHtmlParser.m
//
//  Created by 迪远 王 on 16/10/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumHtmlParser.h"

#import "IGXMLNode+Children.h"
#import "ForumConfig.h"

@implementation ForumHtmlParser
- (ShowThreadPage *)parseShowThreadWithHtml:(NSString *)html {
    // 需要自己实现
    return nil;
}

- (ForumDisplayPage *)parseThreadListFromHtml:(NSString *)html withThread:(int)threadId andContainsTop:(BOOL)containTop {
    // 需要自己实现
    return nil;
}

- (ForumDisplayPage *)parseFavThreadListFormHtml:(NSString *)html {
    // 需要自己实现
    return nil;
}

- (NSString *)parseSecurityToken:(NSString *)html {
    // 需要自己实现
    return nil;
}

- (NSString *)parsePostHash:(NSString *)html {
    // 需要自己实现
    return nil;
}

- (NSString *)parserPostStartTime:(NSString *)html {
    // 需要自己实现
    return nil;
}

- (NSString *)parseLoginErrorMessage:(NSString *)html {
    // 需要自己实现
    return nil;
}

- (SearchForumDisplayPage *)parseSearchPageFromHtml:(NSString *)html {
    // 需要自己实现
    return nil;
}

- (NSMutableArray<Forum *> *)parseFavFormFormHtml:(NSString *)html {
    // 需要自己实现
    return nil;
}

- (ForumDisplayPage *)parsePrivateMessageFormHtml:(NSString *)html {
    // 需要自己实现
    return nil;
}

- (ShowPrivateMessage *)parsePrivateMessageContent:(NSString *)html {
    // 需要自己实现
    return nil;
}

- (NSString *)parseQuickReplyQuoteContent:(NSString *)html {
    // 需要自己实现
    return nil;
}

- (NSString *)parseQuickReplyTitle:(NSString *)html {
    // 需要自己实现
    return nil;
}

- (NSString *)parseQuickReplyTo:(NSString *)html {
    // 需要自己实现
    return nil;
}

- (NSString *)parseUserAvatar:(NSString *)html userId:(NSString *)userId {
    // 需要自己实现
    return nil;
}

- (NSString *)parseListMyThreadSearchid:(NSString *)html {
    // 需要自己实现
    return nil;
}

- (UserProfile *)parserProfile:(NSString *)html userId:(NSString *)userId {
    // 需要自己实现
    return nil;
}

- (NSArray<Forum *> *)parserForms:(NSString *)html {
    // 需要自己实现
    return nil;
}


@end
