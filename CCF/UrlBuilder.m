//
//  CCFUrlBuilder.m
//  CCF
//
//  Created by 迪远 王 on 15/12/30.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import "UrlBuilder.h"
#import "ForumConfig.h"

@implementation UrlBuilder

+(NSURL *)buildMemberURL:(NSString *)userId{
    
    return [NSURL URLWithString:BBS_USER(userId)];
}


+(NSURL *)buildFormURL:(int)formId withPage:(int) page{
    NSString * url = BBS_FORMDISPLAY_PAGE(formId, page);
    return [NSURL URLWithString:url];
}

+(NSURL *)buildIndexURL{
    return [NSURL URLWithString:BBS_URL];
}

+(NSURL *)buildThreadURL:(int)threadId withPage:(int)page{
    return [NSURL URLWithString:BBS_SHOWTHREAD_PAGE(threadId,page)];
}

+(NSURL *)buildLoginURL{
    return  [NSURL URLWithString:BBS_LOGIN];
}

+(NSURL *)buildVCodeURL{
    return [NSURL URLWithString:BBS_VCODE];
}

+(NSURL *) buildReplyURL:(int)threadId{
    return [NSURL URLWithString:BBS_REPLY(threadId)];
}

+(NSURL *) buildFavFormURL{
    return [NSURL URLWithString:BBS_USER_CP];
}

+(NSURL *)buildSearchUrl{
    return [NSURL URLWithString:BBS_SEARCH];
}

+(NSURL *)buildNewThreadURL:(int)formId{
    return [NSURL URLWithString:BBS_NEW_THREAD(formId)];
}

+(NSURL *)buildUploadFileURL{
    return [NSURL URLWithString:BBS_MANAGE_ATT];
}

+(NSURL *)buildManageFileURL:(int)formId postTime:(NSString *)time postHash:(NSString *)hash{
    return [NSURL URLWithString:BBS_NEWATTACHMENT_FORM(formId, time, hash)];
}


+(NSURL *) buildPrivateMessageWithType:(int)type andPage:(int)page{
    NSString * url = BBS_PM_WITH_TYPE(type, page);
    return [NSURL URLWithString:url];
}

+(NSURL *)buildShowPrivateMessageURLWithId:(int)messageId{
    NSString * url = BBS_SHOW_PM(messageId);
    return [NSURL URLWithString:url];
}

+(NSURL *)buildReplyPrivateMessageURLWithReplyedID:(int)messageId{
    NSString * url = BBS_REPLY_PM(messageId);
    return [NSURL URLWithString:url];
}

+(NSURL *)buildSendPrivateMessageURL{
    NSString * url = BBS_SEND_PM;
    return [NSURL URLWithString:url];
}

+(NSURL *)buildNewPMUR{
    NSString * url = BBS_NEW_PM;
    return [NSURL URLWithString:url];
}

+(NSURL *)buildMyThreadPostsURLWithUserId:(NSString*)Id{
    NSString * url = BBS_FIND_USER_WITH_USERID(Id);
    return [NSURL URLWithString:url];
}

+(NSURL *)buildMyThreadWithName:(NSString *)name{
    NSString * url = BBS_FIND_USER_WITH_NAME(name);
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:url];
}
@end
