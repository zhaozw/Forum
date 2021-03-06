//
// Created by WDY on 2016/12/8.
// Copyright (c) 2016 andforce. All rights reserved.
//

#import "CCFForumBrowser.h"

#import "NSString+Extensions.h"
#import "NSUserDefaults+Extensions.h"
#import "NSUserDefaults+Setting.h"
#import <AFImageDownloader.h>
#import "ForumHtmlParser.h"
#import "AFHTTPSessionManager+SimpleAction.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

//#define kCookieUser @"bbuserid"
//#define kCookieLastVisit @"bblastvisit"
//#define kCookieIDStack @"IDstack"
#define kSecurityToken @"securitytoken"

typedef void (^CallBack)(NSString *token, NSString *hash, NSString *time);

@implementation CCFForumBrowser {
    NSString *listMyThreadSearchId;

    NSMutableDictionary *listUserThreadRedirectUrlDictionary;

    NSString *todayNewThreadPostSearchId;
    
    // senior post
    NSArray *toUploadImages;
    HandlerWithBool _handlerWithBool;
    NSString *_message;
    NSString *_subject;
}
//------
// private
- (NSString *)loadCookie {
    return [[NSUserDefaults standardUserDefaults] loadCookie];
}

// private
- (void)saveUserName:(NSString *)name {
    [[NSUserDefaults standardUserDefaults] saveUserName:name];
}

//private
- (NSString *)userName {
    return [[NSUserDefaults standardUserDefaults] userName];
}

//private
- (void)saveCookie {
    [[NSUserDefaults standardUserDefaults] saveCookie];
}

// private
- (NSString *)buildSignature {
    NSString *sigature = [NSString stringWithFormat:@"\n\n发自 %@ 使用 CCF客户端", self.phoneName];
    return sigature;
}

//------

- (void)loginWithName:(NSString *)name andPassWord:(NSString *)passWord withCode:(NSString *)code handler:(HandlerWithBool)handler {

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:name forKey:@"vb_login_username"];
    [parameters setValue:@"" forKey:@"vb_login_password"];
    [parameters setValue:@"1" forKey:@"cookieuser"];
    [parameters setValue:@"" forKey:@"vcode"];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:@"guest" forKey:@"securitytoken"];
    [parameters setValue:@"login" forKey:@"do"];

    NSString *md5pwd = [passWord md5HexDigest];
    [parameters setValue:md5pwd forKey:@"vb_login_md5password"];
    [parameters setValue:md5pwd forKey:@"vb_login_md5password_utf"];

    [self.browser POSTWithURLString:self.config.login parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {

            NSString *userName = [html stringWithRegular:@"<p><strong>.*</strong></p>" andChild:@"，.*。"];
            userName = [userName substringWithRange:NSMakeRange(1, [userName length] - 2)];

            if (userName != nil) {
                // 保存Cookie
                [self saveCookie];
                // 保存用户名
                [self saveUserName:userName];
                handler(YES, @"登录成功");
            } else {
                handler(NO, [self.htmlParser parseLoginErrorMessage:html]);
            }

        } else {
            handler(NO, [self.htmlParser parseLoginErrorMessage:html]);
        }
    }];
}

- (void)refreshVCodeToUIImageView:(UIImageView *)vCodeImageView {
    NSString *url = self.config.loginvCode;

    AFImageDownloader *downloader = [[vCodeImageView class] sharedImageDownloader];
    id <AFImageRequestCache> imageCache = downloader.imageCache;
    [imageCache removeImageWithIdentifier:url];

    NSURL *URL = [NSURL URLWithString:url];

    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    UIImageView *view = vCodeImageView;

    [vCodeImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *_Nonnull urlRequest, NSHTTPURLResponse *_Nullable response, UIImage *_Nonnull image) {
        [view setImage:image];
    }                              failure:^(NSURLRequest *_Nonnull urlRequest, NSHTTPURLResponse *_Nullable response, NSError *_Nonnull error) {
        NSLog(@"refreshDoor failed");
    }];
}

- (LoginUser *)getLoginUser {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    LoginUser *user = [[LoginUser alloc] init];
    user.userName = [self userName];

    for (int i = 0; i < cookies.count; i++) {
        NSHTTPCookie *cookie = cookies[(NSUInteger) i];

        if ([cookie.name isEqualToString:self.config.cookieLastVisitTimeKey]) {
            user.lastVisit = cookie.value;
        } else if ([cookie.name isEqualToString:self.config.cookieUserIdKey]) {
            user.userID = cookie.value;
        } else if ([cookie.name isEqualToString:self.config.cookieExpTimeKey]) {
            user.expireTime = cookie.expiresDate;
        }
    }
    return user;
}

- (void)logout {
    [[NSUserDefaults standardUserDefaults] clearCookie];

    NSURL *url = [NSURL URLWithString:self.config.url];
    if (url) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        for (int i = 0; i < [cookies count]; i++) {
            NSHTTPCookie *cookie = (NSHTTPCookie *) cookies[(NSUInteger) i];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

- (void)listAllForums:(HandlerWithBool)handler {

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"2" forKey:@"styleid"];
    [parameters setValue:@"1" forKey:@"langid"];
    
    [self.browser GETWithURLString:self.config.archive parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSArray<Forum *> *parserForums = [self.htmlParser parserForums:html];
            if (parserForums != nil && parserForums.count > 0) {
                handler(YES, parserForums);
            } else {
                handler(NO, html);
            }
        } else {
            handler(NO, html);
        }
    }];
}

// private 正式开始发送
- (void)doPostThread:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message withToken:(NSString *)token withHash:(NSString *)hash postTime:(NSString *)time handler:(HandlerWithBool)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:subject forKey:@"subject"];
    [parameters setValue:message forKey:@"message"];
    [parameters setValue:@"0" forKey:@"wysiwyg"];
    [parameters setValue:@"0" forKey:@"iconid"];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    NSString *forumId = [NSString stringWithFormat:@"%d", fId];
    [parameters setValue:forumId forKey:@"f"];
    [parameters setValue:@"postthread" forKey:@"do"];
    [parameters setValue:hash forKey:@"posthash"];


    [parameters setValue:time forKey:@"poststarttime"];

    LoginUser *user = [self getLoginUser];
    [parameters setValue:user.userID forKey:@"loggedinuser"];
    [parameters setValue:@"发表主题" forKey:@"sbutton"];
    [parameters setValue:@"1" forKey:@"parseurl"];
    [parameters setValue:@"9999" forKey:@"emailupdate"];
    [parameters setValue:@"4" forKey:@"polloptions"];


    [self.browser POSTWithURLString:[self.config newThreadWithForumId:[NSString stringWithFormat:@"%d", fId]] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            [self saveCookie];
        }
        handler(isSuccess, html);

    }];
}

// private 进入图片管理页面，准备上传图片
- (void)uploadImagePrepair:(int)forumId startPostTime:(NSString *)time postHash:(NSString *)hash :(HandlerWithBool)callback {

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"2" forKey:@"styleid"];
    [parameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:[self.config newattachmentForForum:forumId time:time postHash:hash] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        callback(isSuccess, html);
    }];
}

// private
- (void)uploadImagePrepairFormSeniorReply:(int)threadId startPostTime:(NSString *)time postHash:(NSString *)hash :(HandlerWithBool)callback {
    NSString *url = [self.config newattachmentForThread:threadId time:time postHash:hash];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"2" forKey:@"styleid"];
    [parameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        callback(isSuccess, html);
    }];
}


// private
- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];

    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
        default:
            return nil;
    }
}

// private
- (void)uploadImage:(NSURL *)url :(NSString *)token fId:(int)fId postTime:(NSString *)postTime hash:(NSString *)hash uploadImage:(NSData *)imageData callback:(HandlerWithBool)callback {


    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    [request setHTTPShouldHandleCookies:YES];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];

    NSString *cookie = [self loadCookie];
    [request setValue:cookie forHTTPHeaderField:@"Cookie"];

    NSString *boundary = [NSString stringWithFormat:@"----WebKitFormBoundary%@", [self uploadParamDivider]];

    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

    [request setValue:token forHTTPHeaderField:@"securitytoken"];



    // post body
    NSMutableData *body = [NSMutableData data];



    // add params (all params are strings)
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    [parameters setValue:@"manageattach" forKey:@"do"];
    [parameters setValue:@"" forKey:@"t"];
    NSString *forumId = [NSString stringWithFormat:@"%d", fId];
    [parameters setValue:forumId forKey:@"f"];
    [parameters setValue:@"" forKey:@"p"];
    [parameters setValue:postTime forKey:@"poststarttime"];
    [parameters setValue:@"0" forKey:@"editpost"];
    [parameters setValue:hash forKey:@"posthash"];
    [parameters setValue:@"16777216" forKey:@"MAX_FILE_SIZE"];
    [parameters setValue:@"上传" forKey:@"upload"];


    NSString *name = [NSString stringWithFormat:@"Forum_Client_%f.jpg", [[NSDate date] timeIntervalSince1970]];

    [parameters setValue:name forKey:@"attachment[]"];

    [parameters setValue:name forKey:@"attachmenturl[]"];


    for (NSString *param in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameters[param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }



    // add image data
    if (imageData) {

        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"attachment[]", name] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    // setting the body of the post to the reqeust
    [request setHTTPBody:body];

    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long) [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];


    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        if (data.length > 0) {
            //success
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            callback(YES, responseString);
        } else {
            callback(NO, @"failed");
        }
    }];
}

//private  获取发新帖子的Posttime hash 和token
- (void)createNewThreadPrepair:(int)forumId :(CallBack)callback {

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"2" forKey:@"styleid"];
    [parameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:[self.config newThreadWithForumId:[NSString stringWithFormat:@"%d", forumId]] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {

        if (isSuccess) {
            NSString *token = [self.htmlParser parseSecurityToken:html];
            NSString *postTime = [[token componentsSeparatedByString:@"-"] firstObject];
            NSString *hash = [self.htmlParser parsePostHash:html];

            callback(token, hash, postTime);
        } else {
            callback(nil, nil, nil);
        }

    }];
}

// private
- (NSString *)checkError:(NSString *)html {
    NSString *duplicate = @"<p><strong>此帖是您在最后 5 分钟发表的帖子的副本，您将返回该主题。</strong></p>";
    NSString *tooShot = @"<ol><li>您输入的信息太短，您发布的信息至少为 5 个字符。</li></ol>";
    NSString *tooFast = @"<ol><li>本论坛允许的发表两个帖子的时间间隔必须大于 30 秒。请等待";

    NSString *searchFailed = @"<ol><li>对不起，没有匹配记录。请尝试采用其他条件查询。";
    NSString *searchTooFast = @"<ol><li>本论坛允许的进行两次搜索的时间间隔必须大于 30 秒";

    NSString *urlLost = @"<div style=\"margin: 10px\">没有指定 主题 。如果您来自一个有效链接，请通知<a href=\"sendmessage.php\">管理员</a></div>";
    NSString *permission = @"<li>您的账号可能没有足够的权限访问此页面或执行需要授权的操作。</li>";

    if ([html containsString:duplicate]) {
        return @"内容重复";
    } else if ([html containsString:tooFast]) {
        return @"30秒发帖限制";
    } else if ([html containsString:tooFast]) {
        return @"少于5个字";
    } else if ([html containsString:searchFailed]) {
        return @"未查到结果";
    } else if ([html containsString:searchTooFast]) {
        return @"30秒搜索限制";
    } else if ([html containsString:urlLost]) {
        return @"无效链接";
    } else if ([html containsString:permission]) {
        return @"无权查看";
    } else {
        return nil;
    }
}

- (void)createNewThreadWithForumId:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message withImages:(NSArray *)images handler:(HandlerWithBool)handler {
    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[self buildSignature]];

    }

    // 准备发帖
    [self createNewThreadPrepair:fId :^(NSString *token, NSString *hash, NSString *time) {

        if (images == nil || images.count == 0) {
            // 没有图片，直接发送主题
            [self doPostThread:fId withSubject:subject andMessage:message withToken:token withHash:hash postTime:time handler:^(BOOL isSuccess, NSString *result) {
                if (isSuccess) {
                    NSString *error = [self checkError:result];
                    if (error != nil) {
                        handler(NO, error);
                    } else {
                        ViewThreadPage *thread = [self.htmlParser parseShowThreadWithHtml:result];
                        if (thread.postList.count > 0) {
                            handler(YES, thread);
                        } else {
                            handler(NO, @"未知错误");
                        }
                    }
                } else {
                    handler(NO, result);
                }

            }];
        } else {
            // 如果有图片，先传图片
            [self uploadImagePrepair:fId startPostTime:time postHash:hash :^(BOOL isSuccess, NSString *result) {

                if (isSuccess) {
                    // 解析出上传图片需要的参数
                    NSString *uploadToken = [self.htmlParser parseSecurityToken:result];
                    NSString *uploadTime = [[token componentsSeparatedByString:@"-"] firstObject];
                    NSString *uploadHash = [self.htmlParser parsePostHash:result];

                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createThreadUploadImages:) name:@"CREATE_THREAD_UPLOAD_IMAGE" object:nil];

                    toUploadImages = images;
                    _handlerWithBool = handler;
                    _message = message;
                    _subject = subject;

                    [[NSNotificationCenter defaultCenter] postNotificationName:@"CREATE_THREAD_UPLOAD_IMAGE" object:self userInfo:@{@"uploadToken": uploadToken, @"fId": @(fId), @"uploadTime": uploadTime, @"uploadHash": uploadHash, @"imageId": @(0)}];
                } else {
                    handler(NO, result);
                }


            }];
        }

    }];

}

- (void)createThreadUploadImages:(NSNotification *)notification {

    NSDictionary *dictionary = [notification userInfo];
    NSString *uploadToken = [dictionary valueForKey:@"uploadToken"];
    int fId = [dictionary[@"fId"] intValue];
    NSString *uploadTime = [dictionary valueForKey:@"uploadTime"];
    NSString *uploadHash = [dictionary valueForKey:@"uploadHash"];

    int imageId = [dictionary[@"imageId"] intValue];

    if (imageId < toUploadImages.count) {
        NSData *image = toUploadImages[(NSUInteger) imageId];
        [self uploadImage:[NSURL URLWithString:self.config.newattachment] :uploadToken fId:fId postTime:uploadTime hash:uploadHash uploadImage:image callback:^(BOOL success, id html) {
            [NSThread sleepForTimeInterval:2.0f];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"CREATE_THREAD_UPLOAD_IMAGE" object:self userInfo:@{@"uploadToken": uploadToken, @"fId": @(fId), @"uploadTime": uploadTime, @"uploadHash": uploadHash, @"imageId": @(imageId + 1)}];

        }];
    } else {
        [self doPostThread:fId withSubject:_subject andMessage:_message withToken:uploadToken withHash:uploadHash postTime:uploadTime handler:^(BOOL postSuccess, id doPostResult) {

            [[NSNotificationCenter defaultCenter] removeObserver:self];
            if (postSuccess) {

                NSString *error = [self checkError:doPostResult];
                if (error != nil) {
                    _handlerWithBool(NO, error);
                } else {
                    ViewThreadPage *thread = [self.htmlParser parseShowThreadWithHtml:doPostResult];
                    if (thread.postList.count > 0) {
                        _handlerWithBool(YES, thread);
                    } else {
                        _handlerWithBool(NO, @"未知错误");
                    }
                }
            } else {
                _handlerWithBool(NO, doPostResult);
            }
        }];
    }
}

// private
- (NSString *)readSecurityToken {
    return [[NSUserDefaults standardUserDefaults] valueForKey:kSecurityToken];
}

- (void)replyThreadWithId:(int)threadId andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[self buildSignature]];
    }

    NSURL *loginUrl = [NSURL URLWithString:[self.config newReplyWithThreadId:threadId]];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    NSString *securitytoken = [self readSecurityToken];

    [parameters setValue:securitytoken forKey:@"securitytoken"];
    [parameters setValue:message forKey:@"message"];

    [parameters setValue:@"postreply" forKey:@"do"];
    [parameters setValue:[NSString stringWithFormat:@"%d", threadId] forKey:@"t"];
    [parameters setValue:@"who cares" forKey:@"p"];

    [parameters setValue:@"0" forKey:@"specifiedpost"];

    [parameters setValue:@"1" forKey:@"parseurl"];

    LoginUser *user = [self getLoginUser];

    [parameters setValue:user.userID forKey:@"loggedinuser"];
    [parameters setValue:@"1" forKey:@"fromquickreply"];

    [parameters setValue:@"0" forKey:@"styleid"];
    [parameters setValue:@"0" forKey:@"wysiwyg"];

    [parameters setValue:@"" forKey:@"s"];

    [self.browser POSTWithURLString:[loginUrl absoluteString] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {

        if (isSuccess) {
            // 保存Cookie
            [self saveCookie];

            NSString *error = [self checkError:html];
            if (error != nil) {
                handler(NO, error);
            } else {
                ViewThreadPage *thread = [self.htmlParser parseShowThreadWithHtml:message];
                if (thread.postList.count > 0) {
                    handler(YES, thread);
                } else {
                    handler(NO, @"未知错误");
                }
            }
        } else {
            handler(NO, html);
        }

        if (isSuccess) {
            // 保存Cookie
            [self saveCookie];

            handler(YES, html);

        } else {
            handler(NO, html);
        }
    }];
}

- (void)quickReplyPostWithThreadId:(int)threadId forPostId:(int)postId andMessage:(NSString *)message securitytoken:(NSString *)token ajaxLastPost:(NSString *)ajax_lastpost handler:(HandlerWithBool)handler {
    NSString *url = [self.config newReplyWithThreadId:threadId];

    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[self buildSignature]];
    }

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [parameters setValue:message forKey:@"message"];
    [parameters setValue:@"0" forKey:@"wysiwyg"];
    [parameters setValue:@"0" forKey:@"styleid"];
    [parameters setValue:@"1" forKey:@"signature"];
    [parameters setValue:@"1" forKey:@"quickreply"];
    [parameters setValue:@"1" forKey:@"fromquickreply"];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    [parameters setValue:@"postreply" forKey:@"do"];
    [parameters setValue:[NSString stringWithFormat:@"%d", threadId] forKey:@"t"];
    [parameters setValue:[NSString stringWithFormat:@"%d", postId] forKey:@"p"];
    [parameters setValue:@"1" forKey:@"specifiedpost"];
    [parameters setValue:@"1" forKey:@"parseurl"];

    LoginUser *user = [self getLoginUser];
    [parameters setValue:user.userID forKey:@"loggedinuser"];
    [parameters setValue:@"sbutton" forKey:@"快速回复帖子"];

    [self.browser POSTWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {

            NSString *error = [self checkError:html];
            if (error != nil) {
                handler(NO, error);
            } else {
                ViewThreadPage *thread = [self.htmlParser parseShowThreadWithHtml:html];
                if (thread.postList.count > 0) {
                    handler(YES, thread);
                } else {
                    handler(NO, @"未知错误");
                }
            }
        } else {
            handler(NO, html);
        }
    }];

}

// private
- (void)seniorReplyWithThreadId:(int)threadId andMessage:(NSString *)message securitytoken:(NSString *)token posthash:(NSString *)posthash poststarttime:(NSString *)poststarttime handler:(HandlerWithBool)handler {

    NSString *url = [self.config newReplyWithThreadId:threadId];

    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[self buildSignature]];
    }


    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:message forKey:@"message"];
    [parameters setValue:@"0" forKey:@"wysiwyg"];
    [parameters setValue:@"0" forKey:@"iconid"];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    [parameters setValue:@"postreply" forKey:@"do"];
    [parameters setValue:[NSString stringWithFormat:@"%d", threadId] forKey:@"t"];
    [parameters setValue:@"" forKey:@"p"];
    [parameters setValue:@"0" forKey:@"specifiedpost"];
    [parameters setValue:posthash forKey:@"posthash"];
    [parameters setValue:poststarttime forKey:@"poststarttime"];
    LoginUser *user = [self getLoginUser];
    [parameters setValue:user.userID forKey:@"loggedinuser"];
    [parameters setValue:@"" forKey:@"multiquoteempty"];
    [parameters setValue:@"提交回复" forKey:@"sbutton"];
    [parameters setValue:@"1" forKey:@"signature"];

    [parameters setValue:@"1" forKey:@"parseurl"];
    [parameters setValue:@"9999" forKey:@"emailupdate"];

    [self.browser POSTWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}

// private
- (NSString *)uploadParamDivider {
    static const NSString *kRandomAlphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    NSMutableString *randomString = [NSMutableString stringWithCapacity:16];
    for (int i = 0; i < 16; i++) {
        [randomString appendFormat:@"%C", [kRandomAlphabet characterAtIndex:arc4random_uniform((u_int32_t) [kRandomAlphabet length])]];
    }
    return randomString;
}

// private
- (void)uploadImageForSeniorReply:(NSURL *)url :(NSString *)token fId:(int)fId threadId:(int)threadId postTime:(NSString *)postTime hash:(NSString *)hash :(NSData *)imageData callback:(HandlerWithBool)callback {


    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    [request setHTTPShouldHandleCookies:YES];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];

    NSString *cookie = [self loadCookie];
    [request setValue:cookie forHTTPHeaderField:@"Cookie"];

    NSString *boundary = [NSString stringWithFormat:@"----WebKitFormBoundary%@", [self uploadParamDivider]];

    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

    [request setValue:token forHTTPHeaderField:@"securitytoken"];



    // post body
    NSMutableData *body = [NSMutableData data];



    // add params (all params are strings)
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    [parameters setValue:@"manageattach" forKey:@"do"];
    [parameters setValue:[NSString stringWithFormat:@"%d", threadId] forKey:@"t"];
    NSString *forumId = [NSString stringWithFormat:@"%d", fId];
    [parameters setValue:forumId forKey:@"f"];
    [parameters setValue:@"" forKey:@"p"];
    [parameters setValue:postTime forKey:@"poststarttime"];

    [parameters setValue:@"0" forKey:@"editpost"];
    [parameters setValue:hash forKey:@"posthash"];

    [parameters setValue:@"16777216" forKey:@"MAX_FILE_SIZE"];
    [parameters setValue:@"上传" forKey:@"upload"];

    NSString *name = [NSString stringWithFormat:@"Forum_Client_%f.jpg", [[NSDate date] timeIntervalSince1970]];

    [parameters setValue:name forKey:@"attachment[]"];

    [parameters setValue:@"" forKey:@"attachmenturl[]"];


    for (NSString *param in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameters[param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }



    // add image data
    if (imageData) {

        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"attachment[]", name] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    // setting the body of the post to the reqeust
    [request setHTTPBody:body];

    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long) [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];


    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        if (data.length > 0) {
            //success
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            callback(YES, responseString);
        } else {
            callback(NO, @"failed");
        }
    }];
}

- (void)seniorReplyWithThreadId:(int)threadId forForumId:(int)forumId andMessage:(NSString *)message withImages:(NSArray *)images securitytoken:(NSString *)token handler:(HandlerWithBool)handler {
    NSString *url = [self.config newReplyWithThreadId:threadId];


    NSMutableDictionary *presparameters = [NSMutableDictionary dictionary];
    [presparameters setValue:@"" forKey:@"message"];
    [presparameters setValue:@"0" forKey:@"wysiwyg"];
    [presparameters setValue:@"2" forKey:@"styleid"];
    [presparameters setValue:@"1" forKey:@"signature"];
    [presparameters setValue:@"1" forKey:@"fromquickreply"];
    [presparameters setValue:@"" forKey:@"s"];
    [presparameters setValue:token forKey:@"securitytoken"];
    [presparameters setValue:@"postreply" forKey:@"do"];
    [presparameters setValue:[NSString stringWithFormat:@"%d", threadId] forKey:@"t"];
    [presparameters setValue:@"who cares" forKey:@"p"];
    [presparameters setValue:@"0" forKey:@"specifiedpost"];
    [presparameters setValue:@"1" forKey:@"parseurl"];
    LoginUser *user = [self getLoginUser];
    [presparameters setValue:user.userID forKey:@"loggedinuser"];
    [presparameters setValue:@"进入高级模式" forKey:@"preview"];

    [self.browser POSTWithURLString:url parameters:presparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {

            NSString *securityToken = [self.htmlParser parseSecurityToken:html];
            NSString *postHash = [self.htmlParser parsePostHash:html];
            NSString *postStartTime = [self.htmlParser parserPostStartTime:html];

            if (images == nil || [images count] == 0) {
                [self seniorReplyWithThreadId:threadId andMessage:message securitytoken:securityToken posthash:postHash poststarttime:postStartTime handler:^(BOOL success, id result) {
                    if (success) {

                        NSString *error = [self checkError:result];
                        if (error != nil) {

                            handler(NO, error);
                        } else {
                            ViewThreadPage *thread = [self.htmlParser parseShowThreadWithHtml:result];
                            if (thread.postList.count > 0) {
                                handler(YES, thread);
                            } else {
                                handler(NO, @"未知错误");
                            }
                        }
                    } else {
                        handler(NO, html);
                    }
                }];

            } else {

                __block NSString *uploadImageToken = @"";
                // 如果有图片，先传图片
                [self uploadImagePrepairFormSeniorReply:threadId startPostTime:postStartTime postHash:postHash :^(BOOL success, id result) {

                    if (success) {
                        // 解析出上传图片需要的参数
                        uploadImageToken = [self.htmlParser parseSecurityToken:result];
                        NSString *uploadTime = [[securityToken componentsSeparatedByString:@"-"] firstObject];
                        NSString *uploadHash = [self.htmlParser parsePostHash:result];

                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(seniorReplyUploadImage:) name:@"SENIOR_REPLY_UPLOAD_IMAGE" object:nil];

                        toUploadImages = images;
                        _handlerWithBool = handler;
                        _message = message;

                        [[NSNotificationCenter defaultCenter] postNotificationName:@"SENIOR_REPLY_UPLOAD_IMAGE" object:self userInfo:@{@"uploadImageToken": uploadImageToken, @"forumId": @(forumId),
                                @"threadId": @(threadId), @"uploadTime": uploadTime, @"uploadHash": uploadHash, @"imageId": @(0)}];
                    } else {
                        handler(NO, result);
                    }


                }];
            }
        } else {
            handler(NO, @"回复失败");
        }
    }];
}

// private
- (void)seniorReplyUploadImage:(NSNotification *)notification {
    NSDictionary *dictionary = [notification userInfo];
    NSString *uploadImageToken = [dictionary valueForKey:@"uploadImageToken"];
    int forumId = [dictionary[@"forumId"] intValue];
    int threadId = [dictionary[@"threadId"] intValue];
    NSString *uploadTime = [dictionary valueForKey:@"uploadTime"];
    NSString *uploadHash = [dictionary valueForKey:@"uploadHash"];

    int imageId = [dictionary[@"imageId"] intValue];

    if (imageId < toUploadImages.count) {
        NSData *image = toUploadImages[(NSUInteger) imageId];
        [NSThread sleepForTimeInterval:2.0f];

        [self uploadImageForSeniorReply:[NSURL URLWithString:self.config.newattachment] :uploadImageToken fId:forumId threadId:threadId postTime:uploadTime hash:uploadHash :image callback:^(BOOL isSuccess, id uploadResultHtml) {

            // 更新token
            NSString *newUploadImageToken = [self.htmlParser parseSecurityToken:uploadResultHtml];

            NSLog(@" 上传第 %d 张图片", imageId);

            [[NSNotificationCenter defaultCenter] postNotificationName:@"SENIOR_REPLY_UPLOAD_IMAGE" object:self userInfo:@{@"uploadImageToken": newUploadImageToken, @"forumId": @(forumId),
                    @"threadId": @(threadId), @"uploadTime": uploadTime, @"uploadHash": uploadHash, @"imageId": @(imageId + 1)}];

        }];

    } else {

        [[NSNotificationCenter defaultCenter] removeObserver:self];

        [self seniorReplyWithThreadId:threadId andMessage:_message securitytoken:uploadImageToken posthash:uploadHash poststarttime:uploadTime handler:^(BOOL isSuccess, id result) {

            if (isSuccess) {

                NSString *error = [self checkError:result];
                if (error != nil) {
                    _handlerWithBool(NO, error);
                } else {
                    ViewThreadPage *thread = [self.htmlParser parseShowThreadWithHtml:result];
                    if (thread.postList.count > 0) {
                        _handlerWithBool(YES, thread);
                    } else {
                        _handlerWithBool(NO, @"未知错误");
                    }
                }
            } else {
                _handlerWithBool(NO, result);
            }

        }];
    }

}

// private
- (void)saveSecurityToken:(NSString *)token {
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:kSecurityToken];
}

- (void)searchWithKeyWord:(NSString *)keyWord forType:(int)type handler:(HandlerWithBool)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];


    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:@"process" forKey:@"do"];
    [parameters setValue:@"" forKey:@"searchthreadid"];

    if (type == 0) {
        [parameters setValue:keyWord forKey:@"query"];
        [parameters setValue:@"1" forKey:@"titleonly"];
        [parameters setValue:@"" forKey:@"searchuser"];
        [parameters setValue:@"0" forKey:@"starteronly"];
    } else if (type == 1) {
        [parameters setValue:keyWord forKey:@"query"];
        [parameters setValue:@"0" forKey:@"titleonly"];
        [parameters setValue:@"" forKey:@"searchuser"];
        [parameters setValue:@"0" forKey:@"starteronly"];
    } else if (type == 2) {
        [parameters setValue:@"1" forKey:@"starteronly"];
        [parameters setValue:@"" forKey:@"query"];
        [parameters setValue:@"1" forKey:@"titleonly"];
        [parameters setValue:keyWord forKey:@"searchuser"];
    }


    [parameters setValue:@"1" forKey:@"exactname"];
    [parameters setValue:@"0" forKey:@"replyless"];
    [parameters setValue:@"0" forKey:@"replylimit"];
    [parameters setValue:@"0" forKey:@"searchdate"];
    [parameters setValue:@"after" forKey:@"beforeafter"];
    [parameters setValue:@"lastpost" forKey:@"sortby"];
    [parameters setValue:@"descending" forKey:@"order"];
    [parameters setValue:@"0" forKey:@"showposts"];
    [parameters setValue:@"" forKey:@"tag"];
    [parameters setValue:@"0" forKey:@"forumchoice[]"];
    [parameters setValue:@"1" forKey:@"childforums"];
    [parameters setValue:@"1" forKey:@"saveprefs"];

    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:self.config.search parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [self.htmlParser parseSecurityToken:html];
            if (token != nil) {
                [self saveSecurityToken:token];
            }

            NSString *securitytoken = [self readSecurityToken];
            [parameters setValue:securitytoken forKey:@"securitytoken"];

            [self.browser POSTWithURLString:self.config.search parameters:parameters requestCallback:^(BOOL searchSuccess, NSString *searchResult) {

                if (searchSuccess) {
                    NSString *error = [self checkError:searchResult];
                    if (error != nil) {
                        handler(NO, error);
                    } else {
                        ViewSearchForumPage *page = [self.htmlParser parseSearchPageFromHtml:searchResult];
                        [self saveCookie];

                        if (page != nil && page.threadList != nil && page.threadList.count > 0) {
                            handler(YES, page);
                        } else {
                            handler(NO, @"未知错误");
                        }
                    }
                } else {
                    handler(NO, searchResult);
                }

            }];
        } else {
            handler(NO, html);
        }
    }];

}

- (void)showPrivateContentById:(int)pmId handler:(HandlerWithBool)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"2" forKey:@"styleid"];
    [parameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:[self.config privateShowWithMessageId:pmId] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewMessagePage *content = [self.htmlParser parsePrivateMessageContent:html];
            handler(YES, content);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)sendPrivateMessageToUserName:(NSString *)name andTitle:(NSString *)title andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"2" forKey:@"styleid"];
    [parameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:self.config.privateNewPre parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [self.htmlParser parseSecurityToken:html];

            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:message forKey:@"message"];
            [parameters setValue:title forKey:@"title"];
            [parameters setValue:@"0" forKey:@"pmid"];
            [parameters setValue:name forKey:@"recipients"];
            [parameters setValue:@"0" forKey:@"wysiwyg"];
            [parameters setValue:@"" forKey:@"s"];
            [parameters setValue:token forKey:@"securitytoken"];
            [parameters setValue:@"0" forKey:@"forward"];
            [parameters setValue:@"1" forKey:@"savecopy"];
            [parameters setValue:@"提交信息" forKey:@"sbutton"];
            [parameters setValue:@"1" forKey:@"parseurl"];
            [parameters setValue:@"insertpm" forKey:@"do"];
            [parameters setValue:@"" forKey:@"bccrecipients"];
            [parameters setValue:@"0" forKey:@"iconid"];

            [self.browser POSTWithURLString:self.config.privateReplyWithMessage parameters:parameters requestCallback:^(BOOL success, NSString *result) {
                if (success) {
                    if ([result containsString:@"信息提交时发生如下错误:"]) {
                        handler(NO, @"收件人未找到或者未填写标题");
                    } else {
                        handler(YES, @"");
                    }
                } else {
                    handler(NO, result);
                }
            }];
        } else {
            handler(NO, nil);
        }


    }];
}

- (void)replyPrivateMessageWithId:(int)pmId andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:[self.config privateShowWithMessageId:pmId] parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [self.htmlParser parseSecurityToken:html];

            NSString *quote = [self.htmlParser parseQuickReplyQuoteContent:html];

            NSString *title = [self.htmlParser parseQuickReplyTitle:html];
            NSString *name = [self.htmlParser parseQuickReplyTo:html];

            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

            NSString *realMessage = [[quote stringByAppendingString:@"\n"] stringByAppendingString:message];

            [parameters setValue:realMessage forKey:@"message"];
            [parameters setValue:@"0" forKey:@"wysiwyg"];
            [parameters setValue:@"6" forKey:@"styleid"];
            [parameters setValue:@"1" forKey:@"fromquickreply"];
            [parameters setValue:@"" forKey:@"s"];
            [parameters setValue:token forKey:@"securitytoken"];
            [parameters setValue:@"insertpm" forKey:@"do"];
            [parameters setValue:[NSString stringWithFormat:@"%d", pmId] forKey:@"pmid"];
            //[parameters setValue:@"0" forKey:@"loggedinuser"]; 经过测试，这个参数不写也行
            [parameters setValue:@"1" forKey:@"parseurl"];
            [parameters setValue:@"1" forKey:@"signature"];
            [parameters setValue:title forKey:@"title"];
            [parameters setValue:name forKey:@"recipients"];

            [parameters setValue:@"0" forKey:@"forward"];
            [parameters setValue:@"1" forKey:@"savecopy"];
            [parameters setValue:@"提交信息" forKey:@"sbutton"];

            [self.browser POSTWithURLString:[self.config privateReplyWithMessageIdPre:pmId] parameters:parameters requestCallback:^(BOOL success, NSString *result) {
                handler(success, result);
            }];

        } else {
            handler(NO, nil);
        }
    }];
}

- (void)favoriteForumsWithId:(NSString *)forumId handler:(HandlerWithBool)handler {
    NSString *preUrl = [self.config favForumWithId:forumId];

    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:preUrl parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (!isSuccess) {
            handler(NO, html);
        } else {
            NSString *token = [self.htmlParser parseSecurityToken:html];

            NSString *url = [self.config favForumWithIdParam:forumId];
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

            NSString *paramUrl = [self.config forumDisplayWithId:forumId];

            [parameters setValue:@"" forKey:@"s"];
            [parameters setValue:token forKey:@"securitytoken"];
            [parameters setValue:@"doaddsubscription" forKey:@"do"];
            [parameters setValue:forumId forKey:@"forumid"];
            [parameters setValue:paramUrl forKey:@"url"];
            [parameters setValue:@"0" forKey:@"emailupdate"];


            [self.browser POSTWithURLString:url parameters:parameters requestCallback:^(BOOL success, NSString *result) {
                handler(success, result);
            }];

        }
    }];
}

- (void)unfavouriteForumsWithId:(NSString *)forumId handler:(HandlerWithBool)handler {
    NSString *url = [self.config unfavForumWithId:forumId];
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:url parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}

- (void)favoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {
    NSString *preUrl = [self.config favThreadWithIdPre:threadPostId];
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:preUrl parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (!isSuccess) {
            handler(NO, html);
        } else {
            NSString *token = [self.htmlParser parseSecurityToken:html];

            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"" forKey:@"s"];
            [parameters setValue:token forKey:@"securitytoken"];
            [parameters setValue:@"doaddsubscription" forKey:@"do"];
            [parameters setValue:threadPostId forKey:@"threadid"];
            NSString *urlPram = [self.config showThreadWithThreadId:threadPostId];

            [parameters setValue:urlPram forKey:@"url"];
            [parameters setValue:@"0" forKey:@"emailupdate"];
            [parameters setValue:@"0" forKey:@"folderid"];

            NSString *fav = [self.config favThreadWithId:threadPostId];
            [self.browser POSTWithURLString:fav parameters:parameters requestCallback:^(BOOL success, NSString *result) {
                handler(success, result);
            }];
        }
    }];
}

- (void)unfavoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {
    NSString *url = [self.config unfavThreadWithId:threadPostId];
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:url parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}

- (void)listPrivateMessageWithType:(int)type andPage:(int)page handler:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:[self.config privateWithType:type withPage:page] parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [self.htmlParser parsePrivateMessageFromHtml:html];
            handler(YES, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listFavoriteForums:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:self.config.usercp parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSMutableArray<Forum *> *favForms = [self.htmlParser parseFavForumFromHtml:html];
            handler(YES, favForms);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listFavoriteThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler {
    NSString *url = [self.config listfavThreadWithId:page];
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:url parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [self.htmlParser parseFavThreadListFromHtml:html];
            handler(isSuccess, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listNewThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    NSDate *date = [NSDate date];
    NSInteger timeStamp = (NSInteger) [date timeIntervalSince1970];

    NSInteger searchId = [userDefault integerForKey:[self.config.host stringByAppendingString:@"-search_id"]];
    NSInteger lastTimeStamp = [userDefault integerForKey:[self.config.host stringByAppendingString:@"-search_time"]];

    long spaceTime = timeStamp - lastTimeStamp;
    if (page == 1 && (searchId == 0 || spaceTime > 60 * 10)) {
        NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
        [defparameters setValue:@"2" forKey:@"styleid"];
        [defparameters setValue:@"1" forKey:@"langid"];

        [self.browser GETWithURLString:self.config.searchNewThread parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                NSUInteger newThreadPostSearchId = (NSUInteger) [[self.htmlParser parseListMyThreadSearchid:html] integerValue];
                [userDefault setInteger:timeStamp forKey:[self.config.host stringByAppendingString:@"-search_time"]];
                [userDefault setInteger:newThreadPostSearchId forKey:[self.config.host stringByAppendingString:@"-search_id"]];
            }
            if (isSuccess) {
                ViewForumPage *sarchPage = [self.htmlParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    } else {
        NSString *searchIdStr = [NSString stringWithFormat:@"%ld", (long) searchId];
        NSString *url = [self.config searchWithSearchId:searchIdStr withPage:page];
        NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
        [defparameters setValue:@"2" forKey:@"styleid"];
        [defparameters setValue:@"1" forKey:@"langid"];

        [self.browser GETWithURLString:url parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                ViewForumPage *sarchPage = [self.htmlParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    }
}

- (void)listTodayNewThreadsWithPage:(int)page handler:(HandlerWithBool)handler {
    if (todayNewThreadPostSearchId == nil) {
        NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
        [defparameters setValue:@"2" forKey:@"styleid"];
        [defparameters setValue:@"1" forKey:@"langid"];

        [self.browser GETWithURLString:self.config.searchNewThreadToday parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {

            if (isSuccess) {
                todayNewThreadPostSearchId = [self.htmlParser parseListMyThreadSearchid:html];
            }
            if (isSuccess) {
                ViewForumPage *sarchPage = [self.htmlParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    } else {
        NSString *url = [self.config searchWithSearchId:todayNewThreadPostSearchId withPage:page];

        NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
        [defparameters setValue:@"2" forKey:@"styleid"];
        [defparameters setValue:@"1" forKey:@"langid"];

        [self.browser GETWithURLString:url parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                ViewForumPage *sarchPage = [self.htmlParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    }
}

- (void)listMyAllThreadPost:(HandlerWithBool)handler {
    LoginUser *user = [self getLoginUser];
    if (user == nil || user.userID == nil) {
        handler(NO, @"未登录");
        return;
    }

    NSString *userId = user.userID;

    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:[self.config searchMyPostWithUserId:userId] parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}

- (void)listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler {
    LoginUser *user = [self getLoginUser];
    if (user == nil || user.userID == nil) {
        handler(NO, @"未登录");
        return;
    }

    if (listMyThreadSearchId == nil) {

        NSString *encodeName = [user.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
        [defparameters setValue:@"2" forKey:@"styleid"];
        [defparameters setValue:@"1" forKey:@"langid"];

        [self.browser GETWithURLString:[self.config searchMyThreadWithUserName:encodeName] parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {

            if (listMyThreadSearchId == nil) {
                listMyThreadSearchId = [self.htmlParser parseListMyThreadSearchid:html];
            }

            if (isSuccess) {
                ViewForumPage *sarchPage = [self.htmlParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    } else {
        NSString *url = [self.config searchWithSearchId:listMyThreadSearchId withPage:page];

        NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
        [defparameters setValue:@"2" forKey:@"styleid"];
        [defparameters setValue:@"1" forKey:@"langid"];

        [self.browser GETWithURLString:url parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                ViewForumPage *sarchPage = [self.htmlParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    }
}

- (void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {
    NSString *baseUrl = [self.config searchThreadWithUserId:[NSString stringWithFormat:@"%d",userId]];
    if (listUserThreadRedirectUrlDictionary == nil || listUserThreadRedirectUrlDictionary[@(userId)] == nil) {

        NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
        [defparameters setValue:@"2" forKey:@"styleid"];
        [defparameters setValue:@"1" forKey:@"langid"];

        [self.browser GETWithURLString:baseUrl parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
            if (listUserThreadRedirectUrlDictionary == nil) {
                listUserThreadRedirectUrlDictionary = [NSMutableDictionary dictionary];
            }

            NSString *searchId = [self.htmlParser parseListMyThreadSearchid:html];

            listUserThreadRedirectUrlDictionary[@(userId)] = searchId;

            if (isSuccess) {
                ViewForumPage *sarchPage = [self.htmlParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    } else {
        NSString *searchId = listUserThreadRedirectUrlDictionary[@(userId)];

        NSString *url = [self.config searchWithSearchId:searchId withPage:page];

        NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
        [defparameters setValue:@"2" forKey:@"styleid"];
        [defparameters setValue:@"1" forKey:@"langid"];

        [self.browser GETWithURLString:url parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                ViewForumPage *sarchPage = [self.htmlParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    }
}

- (void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:[self.config showThreadWithThreadId:[NSString stringWithFormat:@"%d", threadId] withPage:page] parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {

        if (isSuccess) {
            NSString *error = [self checkError:html];
            if (error != nil) {
                handler(NO, error);
            } else {
                if (isSuccess) {
                    ViewThreadPage *detail = [self.htmlParser parseShowThreadWithHtml:html];
                    handler(isSuccess, detail);
                } else {
                    handler(NO, html);
                }
            }
        } else {
            handler(NO, html);
        }

    }];
}

- (void)showThreadWithP:(NSString *)p handler:(HandlerWithBool)handler {
    NSString *url = [self.config showThreadWithP:p];
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:url parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {

        if (isSuccess) {
            NSString *error = [self checkError:html];
            if (error != nil) {
                handler(NO, error);
            } else {
                ViewThreadPage *detail = [self.htmlParser parseShowThreadWithHtml:html];
                handler(isSuccess, detail);
            }
        } else {
            handler(NO, html);
        }
    }];
}

- (void)forumDisplayWithId:(int)forumId andPage:(int)page handler:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:[self.config forumDisplayWithId:[NSString stringWithFormat:@"%d", forumId] withPage:page] parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [self.htmlParser parseThreadListFromHtml:html withThread:forumId andContainsTop:YES];
            handler(isSuccess, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)getAvatarWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:[self.config memberWithUserId:userId] parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        NSString *avatar = [self.htmlParser parseUserAvatar:html userId:userId];
        if (avatar) {
            avatar = [self.config.avatarBase stringByAppendingString:avatar];
        } else {
            avatar = self.config.avatarNo;
        }
        handler(isSuccess, avatar);
    }];
}

- (void)listSearchResultWithSearchid:(NSString *)searchid andPage:(int)page handler:(HandlerWithBool)handler {
    NSString *searchedUrl = [self.config searchWithSearchId:searchid withPage:page];

    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:searchedUrl parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {

            NSString *error = [self checkError:html];
            if (error != nil) {
                handler(NO, error);
            } else {
                ViewSearchForumPage *viewSearchForumPage = [self.htmlParser parseSearchPageFromHtml:html];

                if (viewSearchForumPage != nil && viewSearchForumPage.threadList != nil && viewSearchForumPage.threadList.count > 0) {
                    handler(YES, viewSearchForumPage);
                } else {
                    handler(NO, @"未知错误");
                }
            }

        } else {
            handler(NO, html);
        }
    }];
}

- (void)showProfileWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:[self.config memberWithUserId:userId] parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            UserProfile *profile = [self.htmlParser parserProfile:html userId:userId];
            handler(YES, profile);
        } else {
            handler(NO, @"未知错误");
        }
    }];
}

- (void)reportThreadPost:(int)postId andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    [self.browser GETWithURLString:[self.config reportWithPostId:postId] parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {

            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"" forKey:@"s"];
            NSString *token = [self.htmlParser parseSecurityToken:html];
            [parameters setValue:token forKey:@"securitytoken"];
            [parameters setValue:message forKey:@"reason"];
            [parameters setValue:[NSString stringWithFormat:@"%d", postId] forKey:@"postid"];
            [parameters setValue:@"sendemail" forKey:@"do"];
            [parameters setValue:[NSString stringWithFormat:@"showthread.php?p=%d#post%d", postId, postId] forKey:@"url"];

            [self.browser POSTWithURLString:self.config.report parameters:parameters requestCallback:^(BOOL success, NSString *string) {
                handler(success, string);
            }];
        } else {
            handler(NO, html);
        }
    }];
}

@end
