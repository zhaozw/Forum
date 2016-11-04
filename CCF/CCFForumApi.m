//
//  CCFApi.m
//  CCF
//
//  Created by 迪远 王 on 16/2/28.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFForumApi.h"
#import "NSUserDefaults+Extensions.h"
#import <vBulletinForumEngine/vBulletinForumEngine.h>


#import "CCFPCH.pch"
#import "ForumConfig.h"
#import "CCFForumBrowser.h"
#import "CCFForumParser.h"


#define kCCFCookie_User @"bbuserid"
#define kCCFCookie_LastVisit @"bblastvisit"
#define kCCFCookie_IDStack @"IDstack"
#define kCCFSecurityToken @"securitytoken"

#define kErrorMessageTooShort @"您输入的信息太短，您发布的信息至少为 5 个字符。"
#define kErrorMessageTimeTooShort @"此帖是您在最后 5 分钟发表的帖子的副本，您将返回该主题。"

#define kSearchErrorTooshort @"对不起，没有匹配记录。请尝试采用其他条件查询。"
#define kSearchErrorTooFast @"本论坛允许的进行两次搜索的时间间隔必须大于 30 秒。"

@implementation CCFForumApi {
    CCFForumBrowser *_browser;
    CCFForumParser *_praser;

}

- (instancetype)init {
    if (self = [super init]) {
        _browser = [[CCFForumBrowser alloc] init];
        _praser = [[CCFForumParser alloc] init];
    }
    return self;
}


- (void)loginWithName:(NSString *)name andPassWord:(NSString *)passWord handler:(HandlerWithBool)handler {
    [_browser loginWithName:name andPassWord:passWord handler:^(BOOL isSuccess, id message) {
        if (isSuccess) {
            LoginUser *user = [self getLoginUser];
            if (user.userID == nil) {
                NSString *faildMessage = [_praser parseLoginErrorMessage:message];
                handler(NO, faildMessage);
            } else {
                handler(YES, @"登录成功");
            }
        } else {
            handler(NO, message);
        }
    }];
}

- (LoginUser *)getLoginUser {
    return [_browser getLoginUser];
}

- (void)logout {

    [[NSUserDefaults standardUserDefaults] clearCookie];

    NSURL *url = [NSURL URLWithString:BBS_URL];
    if (url) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        for (int i = 0; i < [cookies count]; i++) {
            NSHTTPCookie *cookie = (NSHTTPCookie *) [cookies objectAtIndex:i];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }

}


- (void)formList:(HandlerWithBool)handler {
    [_browser formList:^(BOOL isSuccess, id result) {
        if (isSuccess) {

            NSArray<Forum *> *forms = [_praser parserForms:result];
            handler(YES, forms);
        } else {

            handler(NO, result);
        }

    }];
}

- (void)createNewThreadWithFormId:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message withImages:(NSArray *)images handler:(HandlerWithBool)handler {
    [_browser createNewThreadWithFormId:fId withSubject:subject andMessage:message withImages:images handler:^(BOOL isSuccess, NSString *result) {
        if (isSuccess) {
            NSString *error = kErrorMessageTimeTooShort;
            NSRange range = [result rangeOfString:error];
            if (range.location != NSNotFound) {
                handler(NO, error);
                return;
            }

            error = kErrorMessageTooShort;
            range = [result rangeOfString:error];
            if (range.location != NSNotFound) {
                handler(NO, error);
                return;
            }

            ShowThreadPage *thread = [_praser parseShowThreadWithHtml:result];


            if (thread.dataList.count > 0) {
                handler(YES, thread);

            } else {
                handler(NO, @"未知错误");
            }
        } else {
            handler(NO, message);
        }


    }];

}


- (void)replyThreadWithId:(int)threadId andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    [_browser replyThreadWithId:threadId andMessage:message handler:^(BOOL isSuccess, id message) {
        if (isSuccess) {
            NSString *error = kErrorMessageTimeTooShort;
            NSRange range = [message rangeOfString:error];
            if (range.location != NSNotFound) {
                handler(NO, error);
                return;
            }

            error = kErrorMessageTooShort;
            range = [message rangeOfString:error];
            if (range.location != NSNotFound) {
                handler(NO, error);
                return;
            }

            ShowThreadPage *thread = [_praser parseShowThreadWithHtml:message];


            if (thread.dataList.count > 0) {
                handler(YES, thread);

            } else {
                handler(NO, @"未知错误");
            }
        } else {
            handler(NO, message);
        }
    }];
}


- (void)searchWithKeyWord:(NSString *)keyWord forType:(int)type handler:(HandlerWithBool)handler {
    [_browser searchWithKeyWord:keyWord forType:type handler:^(BOOL isSuccess, id message) {
        if (isSuccess) {

            NSRange range = [message rangeOfString:kSearchErrorTooshort];
            if (range.location != NSNotFound) {
                handler(NO, kSearchErrorTooshort);
                return;
            }

            range = [message rangeOfString:kSearchErrorTooFast];
            if (range.location != NSNotFound) {
                handler(NO, kSearchErrorTooFast);
                return;
            }

            SearchForumDisplayPage *page = [_praser parseSearchPageFromHtml:message];

            if (page != nil && page.dataList != nil && page.dataList.count > 0) {
                handler(YES, page);
            } else {
                handler(NO, @"未知错误");
            }
        } else {
            handler(NO, message);
        }
    }];
}

- (void)listPrivateMessageWithType:(int)type andPage:(int)page handler:(HandlerWithBool)handler {
    [_browser listPrivateMessageWithType:type andPage:page handler:^(BOOL isSuccess, id message) {
        if (isSuccess) {
            ForumDisplayPage *page = [_praser parsePrivateMessageFormHtml:message];
            handler(YES, page);
        } else {
            handler(NO, message);
        }
    }];
}

- (void)showPrivateContentById:(int)pmId handler:(HandlerWithBool)handler {
    [_browser showPrivateContentById:pmId handler:^(BOOL isSuccess, NSString *result) {
        if (isSuccess) {
            ShowPrivateMessage *content = [_praser parsePrivateMessageContent:result];
            handler(YES, content);
        } else {
            handler(NO, result);
        }

    }];
}

- (void)sendPrivateMessageToUserName:(NSString *)name andTitle:(NSString *)title andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    [_browser sendPrivateMessageToUserName:name andTitle:title andMessage:message handler:^(BOOL isSuccess, NSString *result) {
        if (isSuccess) {
            if ([result containsString:@"信息提交时发生如下错误:"] || [result containsString:@"訊息提交時發生如下錯誤:"]) {
                handler(NO, @"收件人未找到或者未填写标题");
            } else {
                handler(YES, @"");
            }
        } else {
            handler(NO, result);
        }

    }];
}

- (void)replyPrivateMessageWithId:(int)pmId andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    [_browser replyPrivateMessageWithId:pmId andMessage:message handler:^(BOOL isSuccess, NSString *result) {
        handler(isSuccess, result);

    }];
}

- (void)listFavoriteForms:(HandlerWithBool)handler {
    [_browser listFavoriteForms:^(BOOL isSuccess, id message) {
        if (isSuccess) {
            NSMutableArray<Forum *> *favForms = [_praser parseFavFormFormHtml:message];
            handler(YES, favForms);
        } else {
            handler(NO, nil);
        }
    }];
}

- (void)listMyAllThreadPost:(HandlerWithBool)handler {
    [_browser listMyAllThreadPost:^(BOOL isSuccess, id result) {
        handler(isSuccess, result);
    }];
}

- (void)listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler {
    [_browser listMyAllThreadsWithPage:page handler:^(BOOL isSuccess, id result) {
        ForumDisplayPage *sarchPage = [_praser parseSearchPageFromHtml:result];
        handler(isSuccess, sarchPage);
    }];
}

- (void)favoriteFormsWithId:(NSString *)formId handler:(HandlerWithBool)handler {
    [_browser favoriteFormsWithId:formId handler:^(BOOL isSuccess, id result) {
        handler(isSuccess, result);
    }];
}

- (void)unfavoriteFormsWithId:(NSString *)formId handler:(HandlerWithBool)handler {
    [_browser unfavoriteFormsWithId:formId handler:^(BOOL isSuccess, id result) {
        handler(isSuccess, result);
    }];
}

- (void)listFavoriteThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler {
    [_browser listFavoriteThreadPostsWithPage:page handler:^(BOOL isSuccess, NSString *result) {
        ForumDisplayPage *page = [_praser parseFavThreadListFormHtml:result];
        handler(isSuccess, page);
    }];
}

- (void)listNewThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler {
    [_browser listNewThreadPostsWithPage:page handler:^(BOOL isSuccess, id result) {
        ForumDisplayPage *sarchPage = [_praser parseSearchPageFromHtml:result];
        handler(isSuccess, sarchPage);
    }];
}

- (void)listTodayNewThreadsWithPage:(int)page handler:(HandlerWithBool)handler {
    [_browser listTodayNewThreadsWithPage:page handler:^(BOOL isSuccess, id result) {
        ForumDisplayPage *sarchPage = [_praser parseSearchPageFromHtml:result];
        handler(isSuccess, sarchPage);
    }];
}

- (void)unfavoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {
    [_browser unfavoriteThreadPostWithId:threadPostId handler:^(BOOL isSuccess, id result) {
        handler(isSuccess, result);
    }];
}

- (void)favoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {
    [_browser favoriteThreadPostWithId:threadPostId handler:^(BOOL isSuccess, id result) {
        handler(isSuccess, result);
    }];
}

- (void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool)handler {
    [_browser showThreadWithId:threadId andPage:page handler:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ShowThreadPage *detail = [_praser parseShowThreadWithHtml:html];
            handler(isSuccess, detail);
        } else {
            handler(NO, html);
        }

    }];
}

- (void)showThreadWithP:(NSString *)p handler:(HandlerWithBool)handler {
    [_browser showThreadWithP:p handler:^(BOOL isSuccess, id result) {
        if (isSuccess) {
            ShowThreadPage *detail = [_praser parseShowThreadWithHtml:result];
            handler(isSuccess, detail);
        } else {
            handler(NO, result);
        }
    }];
}

- (void)forumDisplayWithId:(int)formId andPage:(int)page handler:(HandlerWithBool)handler {
    [_browser forumDisplayWithId:formId andPage:page handler:^(BOOL isSuccess, NSString *result) {
        if (isSuccess) {
            ForumDisplayPage *page = [_praser parseThreadListFromHtml:result withThread:formId andContainsTop:YES];
            handler(isSuccess, page);
        } else {
            handler(NO, result);
        }
    }];
}

- (void)getAvatarWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    [_browser showProfileWithUserId:userId handler:^(BOOL isSuccess, NSString *result) {
        NSString *avatar = [_praser parseUserAvatar:result userId:userId];
        if (avatar) {
            avatar = [AVATAR_BASE_URL stringByAppendingString:avatar];
        } else {
            avatar = NO_AVATAR_URL;
        }
        handler(isSuccess, avatar);
    }];
}

- (void)listSearchResultWithSearchid:(NSString *)searchid andPage:(int)page handler:(HandlerWithBool)handler {
    [_browser listSearchResultWithSearchid:searchid andPage:page handler:^(BOOL isSuccess, id result) {
        if (isSuccess) {

            NSRange range = [result rangeOfString:kSearchErrorTooshort];
            if (range.location != NSNotFound) {
                handler(NO, kSearchErrorTooshort);
                return;
            }

            range = [result rangeOfString:kSearchErrorTooFast];
            if (range.location != NSNotFound) {
                handler(NO, kSearchErrorTooFast);
                return;
            }

            SearchForumDisplayPage *page = [_praser parseSearchPageFromHtml:result];

            if (page != nil && page.dataList != nil && page.dataList.count > 0) {
                handler(YES, page);
            } else {
                handler(NO, @"未知错误");
            }
        } else {
            handler(NO, result);
        }
    }];
}

- (void)showProfileWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    [_browser showProfileWithUserId:userId handler:^(BOOL isSuccess, id result) {
        if (isSuccess) {
            UserProfile *profile = [_praser parserProfile:result userId:userId];
            handler(YES, profile);
        } else {
            handler(NO, @"未知错误");
        }
    }];
}

- (void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {
    [_browser listAllUserThreads:userId withPage:page handler:^(BOOL isSuccess, id result) {
        ForumDisplayPage *sarchPage = [_praser parseSearchPageFromHtml:result];
        handler(isSuccess, sarchPage);
    }];
}

- (void)quickReplyPostWithThreadId:(int)threadId forPostId:(int)postId andMessage:(NSString *)message securitytoken:(NSString *)token ajaxLastPost:(NSString *)ajax_lastpost handler:(HandlerWithBool)handler {
    [_browser quickReplyPostWithThreadId:threadId forPostId:postId andMessage:message securitytoken:token ajaxLastPost:ajax_lastpost handler:^(BOOL isSuccess, NSString *result) {
        if (isSuccess) {
            ShowThreadPage *detail = [_praser parseShowThreadWithHtml:result];
            handler(isSuccess, detail);
        } else {
            handler(NO, result);
        }
    }];

}

- (void)seniorReplyWithThreadId:(int)threadId forFormId:(int)formId andMessage:(NSString *)message withImages:(NSArray *)images securitytoken:(NSString *)token handler:(HandlerWithBool)handler {
    [_browser seniorReplyWithThreadId:threadId forFormId:(int) formId andMessage:message withImages:(NSArray *) images securitytoken:token handler:^(BOOL isSuccess, id result) {
        if (isSuccess) {
            ShowThreadPage *detail = [_praser parseShowThreadWithHtml:result];
            handler(isSuccess, detail);
        } else {
            handler(NO, result);
        }
    }];
}

- (void)refreshVCodeToUIImageView:(UIImageView *)vCodeImageView {
    [_browser refreshVCodeToUIImageView:vCodeImageView];
}

@end
