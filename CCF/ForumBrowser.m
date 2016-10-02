//
//  CCFBrowser.m
//  CCF
//
//  Created by 迪远 王 on 15/12/30.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import "ForumBrowser.h"
#import "NSString+Extensions.h"
#import <AFImageDownloader.h>
#import <UIImageView+AFNetworking.h>
#import "Utils.h"
#import "ForumBrowser.h"

#import <vBulletinForumEngine/vBulletinForumEngine.h>

#import "NSUserDefaults+Extensions.h"
#import "AFHTTPSessionManager+SimpleAction.h"

#import "NSUserDefaults+Setting.h"

#import "CCFForumParser.h"

#define kCCFCookie_User @"bbuserid"
#define kCCFCookie_LastVisit @"bblastvisit"
#define kCCFCookie_IDStack @"IDstack"
#define kCCFSecurityToken @"securitytoken"
#import "ForumConfig.h"
#import <iOSDeviceName/iOSDeviceName.h>

@implementation ForumBrowser{
    NSString * listMyThreadSearchId;

    NSMutableDictionary * listUserThreadRedirectUrlDictionary;
    
    NSString *todayNewThreadPostSearchId;
    NSString *newThreadPostSearchId;
    
    CCFForumParser * parser;
    
    NSString * iPhoneName;
}


-(id)init{
    
    if (self = [super init]) {
        _browser = [AFHTTPSessionManager manager];
        _browser.responseSerializer = [AFHTTPResponseSerializer serializer];
        _browser.responseSerializer.acceptableContentTypes = [_browser.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        
        parser = [[CCFForumParser alloc] init];
        

        iPhoneName = [DeviceName deviceNameDetail];
        [self loadCookie];
    }
    
    return self;
}



-(void)browseWithUrl:(NSURL *)url :(HandlerWithBool)callBack{
    
    [_browser GETWithURLString:[url absoluteString] requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString * token = [parser parseSecurityToken:html];
            if (token != nil) {
                [self saveSecurityToken:token];
            }
            callBack(YES,html);
        } else{
            callBack(NO, html);
        }
    }];
}

// 获取所有的论坛列表
-(void) formList:(HandlerWithBool)handler{
    [_browser GETWithURLString:BBS_ARCHIVE requestCallback:^(BOOL isSuccess, NSString *html) {
        
        handler(isSuccess, html);
    }];
}


-(void) loginWithName:(NSString *)name andPassWord:(NSString *)passWord :(HandlerWithBool)callBack{
    NSURL * loginUrl = [NSURL URLWithString:BBS_LOGIN];
    NSString * md5pwd = [passWord md5HexDigest];
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:name forKey:@"vb_login_username"];
    [parameters setValue:@"" forKey:@"vb_login_password"];
    [parameters setValue:@"1" forKey:@"cookieuser"];
    [parameters setValue:@"" forKey:@"vcode"];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:@"guest" forKey:@"securitytoken"];
    [parameters setValue:@"login" forKey:@"do"];
    [parameters setValue:md5pwd forKey:@"vb_login_md5password"];
    [parameters setValue:md5pwd forKey:@"vb_login_md5password_utf"];
    
    [_browser POSTWithURLString:[loginUrl absoluteString] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            callBack(YES,html);
            
            NSString * userName = [html stringWithRegular:@"<p><strong>.*</strong></p>" andChild:@"，.*。"];
            
            userName = [userName substringWithRange:NSMakeRange(1, [userName length] -2)];
            
            [self saveUserName:userName];
            
            // 保存Cookie
            [self saveCookie];
        } else{
            callBack(NO,html);
        }
    }];
}


-(void)refreshVCodeToUIImageView:(UIImageView* ) vCodeImageView{

    NSString * url = BBS_VCODE;
    
    AFImageDownloader *downloader = [[vCodeImageView class] sharedImageDownloader];
    id <AFImageRequestCache> imageCache = downloader.imageCache;
    [imageCache removeImageWithIdentifier:url];
    
    
    
    NSURL *URL = [NSURL URLWithString:url];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    UIImageView * view = vCodeImageView;
    
    [vCodeImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {

        [view setImage:image];
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {

        NSLog(@"refreshDoor failed");
    }];

}

-(LoginUser *)getCurrentCCFUser{
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    LoginUser * user = [[LoginUser alloc] init];
    user.userName = [self userName];
    
    for (int i = 0; i < cookies.count; i ++) {
        NSHTTPCookie * cookie = cookies[i];
        
        if ([cookie.name isEqualToString:kCCFCookie_LastVisit]) {
            user.lastVisit = cookie.value;
        } else if([cookie.name isEqualToString:kCCFCookie_User]){
            user.userID = cookie.value;
        } else if ([cookie.name isEqualToString:kCCFCookie_IDStack]){
            user.expireTime = cookie.expiresDate;
        }
    }
    return user;
}


-(void) saveUserName:(NSString*) name{
    [[NSUserDefaults standardUserDefaults] saveUserName:name];
}

-(NSString*) userName{
    return [[NSUserDefaults standardUserDefaults] userName];
}

-(void) saveCookie{
        [[NSUserDefaults standardUserDefaults] saveCookie];
}

-(NSString *) loadCookie{
    return [[NSUserDefaults standardUserDefaults] loadCookie];
}


-(void) saveSecurityToken:(NSString *) token{
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:kCCFSecurityToken];
}

- (NSString *) readSecurityToken{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kCCFSecurityToken];
}

-(NSString *) buildSignature{
    NSString * sigature = [NSString stringWithFormat:@"\n\n发自 %@ 使用 CCF客户端", iPhoneName];
    return sigature;
    
}
-(void)replyThreadWithId:(int)threadId withMessage:(NSString *)message handler:(HandlerWithBool)result{
    
    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[self buildSignature]];
    }
    
    
    NSURL * loginUrl = [NSURL URLWithString:BBS_REPLY(threadId)];
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    
    NSString * securitytoken = [self readSecurityToken];
    
    [parameters setValue:securitytoken forKey:@"securitytoken"];
    [parameters setValue:message forKey:@"message"];
    
    [parameters setValue:@"postreply" forKey:@"do"];
    [parameters setValue:[NSString stringWithFormat:@"%d", threadId] forKey:@"t"];
    [parameters setValue:@"who cares" forKey:@"p"];
    
    [parameters setValue:@"0" forKey:@"specifiedpost"];
    
    [parameters setValue:@"1" forKey:@"parseurl"];
    
    LoginUser * user = [self getCurrentCCFUser];
    
    [parameters setValue:user.userID forKey:@"loggedinuser"];
    [parameters setValue:@"1" forKey:@"fromquickreply"];
    
    [parameters setValue:@"0" forKey:@"styleid"];
    [parameters setValue:@"0" forKey:@"wysiwyg"];
    
    
    [parameters setValue:@"" forKey:@"s"];
    
    [_browser POSTWithURLString:[loginUrl absoluteString] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            // 保存Cookie
            [self saveCookie];
            
            result(YES,html);
            
        } else{
            result(NO,html);
        }
    }];

}

-(void)listSearchResultWithSearchid:(NSString *)searchid andPage:(int)page handler:(HandlerWithBool)handler{
    NSString * searchedUrl = BBS_SEARCH_WITH_SEARCHID(searchid, page);
    [_browser GETWithURLString:searchedUrl requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess,html);
    }];
}

-(void)searchWithKeyWord:(NSString *)keyWord forType:(int)type searchDone:(HandlerWithBool)callback{

    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    
    
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:@"process" forKey:@"do"];
    [parameters setValue:@"" forKey:@"searchthreadid"];
    
    if (type == 0) {
        [parameters setValue:keyWord forKey:@"query"];
        [parameters setValue:@"1" forKey:@"titleonly"];
        [parameters setValue:@"" forKey:@"searchuser"];
        [parameters setValue:@"0" forKey:@"starteronly"];
    } else if (type == 1){
        [parameters setValue:keyWord forKey:@"query"];
        [parameters setValue:@"0" forKey:@"titleonly"];
        [parameters setValue:@"" forKey:@"searchuser"];
        [parameters setValue:@"0" forKey:@"starteronly"];
    } else if (type == 2){
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
    
    [_browser GETWithURLString:BBS_SEARCH requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString * token = [parser parseSecurityToken:html];
            if (token != nil) {
                [self saveSecurityToken:token];
            }
            
            NSString * securitytoken = [self readSecurityToken];
            [parameters setValue:securitytoken forKey:@"securitytoken"];

            [_browser POSTWithURLString:BBS_SEARCH parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
                if (isSuccess) {
                    [self saveCookie];
                    
                    callback(YES, html);
                } else{
                    callback(NO, html);
                }
                
            }];
        } else{
            callback(NO,html);
        }
    }];
    
}

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
    }
    return nil;
}

-(void)createNewThreadWithFormId:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message withImages:(NSArray *)images handler:(HandlerWithBool)handler{
    
    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[self buildSignature]];
        
    }

    
    
    // 准备发帖
    [self createNewThreadPrepair:fId :^(NSString *token, NSString *hash, NSString *time) {
        
        if (images == nil || images.count == 0) {
            // 没有图片，直接发送主题
            [self doPostThread:fId withSubject:subject andMessage:message withToken:token withHash:hash postTime:time handler:^(BOOL isSuccess, id result) {
                handler(isSuccess,result);
            }];
        } else{
            // 如果有图片，先传图片
            [self uploadImagePrepair:fId startPostTime:time postHash:hash :^(BOOL isSuccess, NSString* result) {
                
                // 解析出上传图片需要的参数
                NSString * uploadToken = [parser parseSecurityToken:result];
                NSString * uploadTime = [[token componentsSeparatedByString:@"-"] firstObject];
                NSString * uploadHash = [parser parsePostHash:result];
                
                __block BOOL uploadSuccess = YES;
                for (int i = 0; i < images.count && uploadSuccess; i++) {
                    NSData * image = images[i];
                    
                    [NSThread sleepForTimeInterval:2.0f];
                    
                    NSURL * url = [NSURL URLWithString:BBS_MANAGE_ATT];
                    [self uploadImage:url :uploadToken fId:fId postTime:uploadTime hash:uploadHash :image callback:^(BOOL isSuccess, id result) {
                        uploadSuccess = isSuccess;
                        
                        if (i == images.count -1) {
                            [NSThread sleepForTimeInterval:2.0f];
                            [self doPostThread:fId withSubject:subject andMessage:message withToken:token withHash:hash postTime:time handler:^(BOOL isSuccess ,id result) {
                                handler(isSuccess, result);
                            }];
                        }
                    }];
                }
                
                if (!uploadSuccess) {
                    handler(NO, @"上传图片失败！");
                }
                
            }];
        }

    }];
}




// 正式开始发送
-(void) doPostThread:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message withToken:(NSString*) token withHash:(NSString*) hash postTime:(NSString*)time handler:(HandlerWithBool) handler{
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:subject forKey:@"subject"];
    [parameters setValue:message forKey:@"message"];
    [parameters setValue:@"0" forKey:@"wysiwyg"];
    [parameters setValue:@"0" forKey:@"iconid"];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    NSString * formId = [NSString stringWithFormat:@"%d", fId];
    [parameters setValue:formId forKey:@"f"];
    [parameters setValue:@"postthread" forKey:@"do"];
    [parameters setValue:hash forKey:@"posthash"];
    
    
    [parameters setValue:time forKey:@"poststarttime"];
    
    LoginUser *user = [self getCurrentCCFUser];
    [parameters setValue:user.userID forKey:@"loggedinuser"];
    [parameters setValue:@"发表主题" forKey:@"sbutton"];
    [parameters setValue:@"1" forKey:@"parseurl"];
    [parameters setValue:@"9999" forKey:@"emailupdate"];
    [parameters setValue:@"4" forKey:@"polloptions"];

    
    [_browser POSTWithURLString:BBS_NEW_THREAD(fId) parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            [self saveCookie];
        }
        handler(isSuccess, html);
        
    }];
}


// 进入图片管理页面，准备上传图片
-(void)uploadImagePrepair:(int)formId startPostTime:(NSString*)time postHash:(NSString*)hash :(HandlerWithBool) callback{
    
    [_browser GETWithURLString:BBS_NEWATTACHMENT_FORM(formId, time, hash) requestCallback:^(BOOL isSuccess, NSString *html) {
      callback(isSuccess, html);
    }];
}

-(void)uploadImagePrepairFormSeniorReply:(int)threadId startPostTime:(NSString*)time postHash:(NSString*)hash :(HandlerWithBool) callback{
    NSString * url = BBS_NEWATTACHMENT_THREAD(threadId, time, hash);
    [_browser GETWithURLString:url requestCallback:^(BOOL isSuccess, NSString *html) {
        callback(isSuccess, html);
    }];
}

// 开始上传图片
- (void)uploadFile:(NSString *)token fId:(NSString *)fId postTime:(NSString *)postTime hash:(NSString *)hash image:(NSData *)image {
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    [parameters setValue:@"manageattach" forKey:@"do"];
    [parameters setValue:@"" forKey:@"t"];
    [parameters setValue:fId forKey:@"f"];
    [parameters setValue:@"" forKey:@"p"];
    [parameters setValue:postTime forKey:@"poststarttime"];
    [parameters setValue:@"0" forKey:@"editpost"];
    [parameters setValue:hash forKey:@"posthash"];
    [parameters setValue:@"16777216" forKey:@"MAX_FILE_SIZE"];
    [parameters setValue:@"上传" forKey:@"upload"];
    NSString * name = [NSString stringWithFormat:@"CCF_CLIENT_%f.jpg", [[NSDate date] timeIntervalSince1970]];
    
    [parameters setValue:name forKey:@"attachment[]"];
    
    [parameters setValue:@"" forKey:@"attachmenturl[]"];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置时间格式
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    [parameters setValue:fileName forKey:@"attachment[]"];
    

    
    //[_browser.requestSerializer setValue:@"multipart/form-data; boundary=----WebKitFormBoundaryG9KMXkoSxJnZByFF" forHTTPHeaderField:@"Content-Type"];

    [_browser POSTWithURLString:BBS_MANAGE_ATT parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSString * type = [self contentTypeForImageData:image];
        
        //[formData appendPartWithFileData:image name:@"attachment[]" fileName:@"abc123.jpeg" mimeType:type];
        
        UIImage *image = [UIImage imageNamed:@"test.jpg"];
        NSData *data = UIImageJPEGRepresentation(image, 1);
        
        
        [formData appendPartWithFileData:data name:@"attachment[]" fileName:fileName mimeType:type];
        
        //[formData appendPartWithFormData:data name:fileName];
        
    } requestCallback:^(BOOL isSuccess, NSString *html) {
        
        NSLog(@"上传结果-------->>>>>>>> :   %@", html);
        NSLog(@"上传结果-------->>>>>>>> 上传结束");
    }];
    
}


// 获取发新帖子的Posttime hash 和token
-(void) createNewThreadPrepair:(int)formId :(CallBack) callback{
    
    [_browser GETWithURLString:BBS_NEW_THREAD(formId) requestCallback:^(BOOL isSuccess, NSString *html) {
        
        if (isSuccess) {
            NSString * token = [parser parseSecurityToken:html];
            NSString * postTime = [[token componentsSeparatedByString:@"-"] firstObject];
            NSString * hash = [parser parsePostHash:html];
            
            callback(token, hash, postTime);
        } else{
            callback(nil, nil, nil);
        }
        
    }];

}

-(void) uploadImage:(NSURL *)url :(NSString *)token fId:(int)fId postTime:(NSString *)postTime hash:(NSString *)hash :(NSData *) imageData callback:(HandlerWithBool)callback{
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPShouldHandleCookies:YES];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    NSString * cookie = [self loadCookie];
    [request setValue:cookie forHTTPHeaderField:@"Cookie"];
    
    NSString *boundary = [NSString stringWithFormat:@"----WebKitFormBoundary%@", [self uploadParamDivider]];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    [request setValue:token forHTTPHeaderField:@"securitytoken"];
    
    
    
    // post body
    NSMutableData *body = [NSMutableData data];

    
    
    // add params (all params are strings)
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    [parameters setValue:@"manageattach" forKey:@"do"];
    [parameters setValue:@"" forKey:@"t"];
    NSString * formID = [NSString stringWithFormat:@"%d", fId];
    [parameters setValue:formID forKey:@"f"];
    [parameters setValue:@"" forKey:@"p"];
    [parameters setValue:postTime forKey:@"poststarttime"];
    [parameters setValue:@"0" forKey:@"editpost"];
    [parameters setValue:hash forKey:@"posthash"];
    [parameters setValue:@"16777216" forKey:@"MAX_FILE_SIZE"];
    [parameters setValue:@"上传" forKey:@"upload"];
    
    
    NSString * name = [NSString stringWithFormat:@"CCF_CLIENT_%f.jpg", [[NSDate date] timeIntervalSince1970]];
    
    [parameters setValue:name forKey:@"attachment[]"];
    
    [parameters setValue:name forKey:@"attachmenturl[]"];
    

    for (NSString *param in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
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
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        if(data.length > 0) {
            //success
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            callback(YES, responseString);
        } else{
            callback(NO, @"failed");
        }
    }];
}

-(void)privateMessageWithType:(int)type andpage:(int)page handler:(HandlerWithBool)handler{
    [_browser GETWithURLString:BBS_PM_WITH_TYPE(type, page) requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}

-(void)showPrivateContentById:(int)pmId handler:(HandlerWithBool)handler{
    [_browser GETWithURLString:BBS_SHOW_PM(pmId) requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}

-(void)replyPrivateMessageWithId:(int)pmId andMessage:(NSString *)message handler:(HandlerWithBool)handler{

    [_browser GETWithURLString:BBS_SHOW_PM(pmId) requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString * token = [parser parseSecurityToken:html];
            
            NSString * quote = [parser parseQuickReplyQuoteContent:html];
            
            NSString * title = [parser parseQuickReplyTitle:html];
            NSString * name = [parser parseQuickReplyTo:html];
            
            NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
            
            NSString * realMessage = [[quote stringByAppendingString:@"\n"] stringByAppendingString:message];
            
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
            
            [_browser POSTWithURLString:BBS_REPLY_PM(pmId) parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
                handler(isSuccess, html);
            }];

        } else{
            handler(NO, nil);
        }
    }];
}

-(void)sendPrivateMessageToUserName:(NSString *)name andTitle:(NSString *)title andMessage:(NSString *)message handler:(HandlerWithBool)handler{
    
    [_browser GETWithURLString:BBS_NEW_PM requestCallback:^(BOOL isSuccess,NSString *html) {
        if (isSuccess) {
            NSString * token = [parser parseSecurityToken:html];
            
            NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
            
            
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
            
            [_browser POSTWithURLString:BBS_SEND_PM parameters:parameters requestCallback:^(BOOL isSuccess, NSString *sendresult) {
                handler(isSuccess, sendresult);
            }];
        } else{
            handler(NO, nil);
        }
        
    
    }];
}

-(void)listfavoriteForms:(HandlerWithBool)handler{
    
    [_browser GETWithURLString:BBS_USER_CP requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            handler(YES, html);
        } else{
            handler(NO, html);
        }
    }];
}

-(void)listMyAllThreadPost:(HandlerWithBool)handler{
    LoginUser * user = [self getCurrentCCFUser];
    if (user == nil || user.userID == nil) {
        handler(NO,@"未登录");
        return;
    }
    
    NSString * userId = user.userID;
    
    [_browser GETWithURLString:BBS_FIND_USER_WITH_USERID(userId) requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}

-(void)listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler{
    LoginUser * user = [self getCurrentCCFUser];
    if (user == nil || user.userID == nil) {
        handler(NO,@"未登录");
        return;
    }
    
    if (listMyThreadSearchId == nil) {
        
        [_browser GETWithURLString:BBS_FIND_USER_WITH_NAME(user.userName) requestCallback:^(BOOL isSuccess, NSString *html) {
            
            if (listMyThreadSearchId == nil) {
                listMyThreadSearchId = [parser parseListMyThreadSearchid:html];
            }
            
            handler(isSuccess, html);
        }];
    } else{
        NSString * url = BBS_SEARCH_WITH_SEARCHID(listMyThreadSearchId, page);
        [_browser GETWithURLString:url requestCallback:^(BOOL isSuccess, NSString *html) {
            handler(isSuccess, html);
        }];
    }
    
}

-(void)favoriteFormsWithId:(NSString *)formId handler:(HandlerWithBool)handler{
    NSString* preUrl = BBS_SUBSCRIPTION(formId);
    
    [_browser GETWithURLString:preUrl requestCallback:^(BOOL isSuccess, NSString *html) {
        if (!isSuccess) {
            handler(NO, html);
        } else{
            NSString * token = [parser parseSecurityToken:html];
            
            NSString * url = BBS_SUBSCRIPTION_PARAM(formId);
            NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
            
            NSString * paramUrl = BBS_FORMDISPLAY(formId);
            
            [parameters setValue:@"" forKey:@"s"];
            [parameters setValue:token forKey:@"securitytoken"];
            [parameters setValue:@"doaddsubscription" forKey:@"do"];
            [parameters setValue:formId forKey:@"formid"];
            [parameters setValue:paramUrl forKey:@"url"];
            [parameters setValue:@")" forKey:@"emailupdate"];
            
            
            [_browser POSTWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
                handler(isSuccess, html);
            }];
           
        }
    }];
}


-(void)unfavoriteFormsWithId:(NSString *)formId handler:(HandlerWithBool)handler{
    NSString * url = BBS_UNFAV_FORM(formId);
    [_browser GETWithURLString:url requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess,html);
    }];
}

-(void)favoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler{
    NSString * preUrl = BBS_FAV_THREAD(threadPostId);
    [_browser GETWithURLString:preUrl requestCallback:^(BOOL isSuccess, NSString *html) {
        if (!isSuccess) {
            handler(NO, html);
        } else{
            NSString * token = [parser parseSecurityToken:html];
            
            NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"" forKey:@"s"];
            [parameters setValue:token forKey:@"securitytoken"];
            [parameters setValue:@"doaddsubscription" forKey:@"do"];
            [parameters setValue:threadPostId forKey:@"threadid"];
            NSString * urlPram = BBS_SHOWTHREAD(threadPostId);
            
            [parameters setValue:urlPram forKey:@"url"];
            [parameters setValue:@"0" forKey:@"emailupdate"];
            [parameters setValue:@"0" forKey:@"folderid"];
            
            NSString * fav = BBS_SUBSCRIPTION_THREAD(threadPostId);
            [_browser POSTWithURLString:fav parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
                handler(isSuccess, html);
            }];
        }
    }];
}

-(void)unfavoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler{
    NSString * url = BBS_UNFAV_THREAD(threadPostId);
    [_browser GETWithURLString:url requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess,html);
    }];
}

-(void)listFavoriteThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler{
    NSString * url = BBS_LIST_FAV_POST(page);
    
    [_browser GETWithURLString:url requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess,html);
    }];
}


-(void)listNewThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler{
    if (newThreadPostSearchId == nil) {
        [_browser GETWithURLString:BBS_GET_NEW requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                newThreadPostSearchId = [parser parseListMyThreadSearchid:html];
            }
            handler(isSuccess, html);
        }];
    } else{
        NSString * url = BBS_SEARCH_WITH_SEARCHID(newThreadPostSearchId, page);
        [_browser GETWithURLString:url requestCallback:^(BOOL isSuccess, NSString *html) {
            handler(isSuccess, html);
        }];
    }
    

}


-(void)listTodayNewThreadsWithPage:(int)page handler:(HandlerWithBool)handler{
    if (todayNewThreadPostSearchId == nil) {
        [_browser GETWithURLString:BBS_GET_DAILY requestCallback:^(BOOL isSuccess, NSString *html) {
            
            if (isSuccess) {
                todayNewThreadPostSearchId = [parser parseListMyThreadSearchid:html];
            }
            handler(isSuccess, html);
        }];
    } else{
        NSString * url = BBS_SEARCH_WITH_SEARCHID(todayNewThreadPostSearchId, page);
        [_browser GETWithURLString:url requestCallback:^(BOOL isSuccess, NSString *html) {
            handler(isSuccess, html);
        }];
    }

}

-(void)quickReplyPostWithThreadId:(int)threadId forPostId:(int)postId andMessage:(NSString *)message securitytoken:(NSString *)token ajaxLastPost:(NSString *)ajax_lastpost handler:(HandlerWithBool)handler{
    NSString * url = BBS_REPLY(threadId);
    
    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[self buildSignature]];
    }
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    
    [parameters setValue:token forKey:@"securitytoken"];
    
    [parameters setValue:@"1" forKey:@"ajax"];
    [parameters setValue:ajax_lastpost forKey:@"ajax_lastpost"];
    
    [parameters setValue:message forKey:@"message"];
    [parameters setValue:@"0" forKey:@"wysiwyg"];
    [parameters setValue:@"0" forKey:@"styleid"];
    [parameters setValue:@"1" forKey:@"quickreply"];
    [parameters setValue:@"1" forKey:@"fromquickreply"];
    
    [parameters setValue:@"postreply" forKey:@"do"];
    [parameters setValue:[NSString stringWithFormat:@"%d",threadId] forKey:@"t"];
    [parameters setValue:[NSString stringWithFormat:@"%d",postId] forKey:@"p"];
    [parameters setValue:@"1" forKey:@"specifiedpost"];
    [parameters setValue:@"1" forKey:@"parseurl"];
    
    LoginUser * user = [self getCurrentCCFUser];
    
    [parameters setValue:user.userID forKey:@"loggedinuser"];
    
    
    [_browser POSTWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}



-(void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool)handler{
    NSURL * url = [NSURL URLWithString:BBS_SHOWTHREAD_PAGE(threadId, page)];
    [self browseWithUrl:url :^(BOOL isSuccess, id result) {
        handler(isSuccess, result);
    }];
}

-(void)showThreadWithP:(NSString*)p handler:(HandlerWithBool)handler{
    NSString * url = BBS_SHOWTHREAD_WITH_P(p);
    [_browser GETWithURLString:url requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}

-(void)forumDisplayWithId:(int)formId andPage:(int)page handler:(HandlerWithBool)handler{
    NSURL * url = [NSURL URLWithString:BBS_FORMDISPLAY_PAGE(formId, page)];
    [self browseWithUrl:url :^(BOOL isSuccess, id result) {
        handler(isSuccess, result);
    }];
}

-(void)showProfileWithUserId:(NSString *)userId handler:(HandlerWithBool)handler{
    NSURL * url = [NSURL URLWithString:BBS_USER(userId)];
    [self browseWithUrl:url :^(BOOL isSuccess, id result) {
        handler(isSuccess, result);
    }];
}

-(void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler{
    NSString * baseUrl = BBS_FIND_USER_THREADS(userId);
    if (listUserThreadRedirectUrlDictionary == nil || [listUserThreadRedirectUrlDictionary objectForKey:[NSNumber numberWithInt:userId]] == nil) {
        
    
        [_browser GETWithURLString:baseUrl requestCallback:^(BOOL isSuccess, NSString *html) {
            if (listUserThreadRedirectUrlDictionary == nil) {
                listUserThreadRedirectUrlDictionary = [NSMutableDictionary dictionary];
            }
            
            NSString * searchId = [parser parseListMyThreadSearchid:html];
            
            [listUserThreadRedirectUrlDictionary setObject:searchId forKey:[NSNumber numberWithInt:userId]];
            
            handler(isSuccess, html);
        }];
    } else{
        NSString * searchId = [listUserThreadRedirectUrlDictionary objectForKey:[NSNumber numberWithInt:userId]];
        
        NSString * url = BBS_SEARCH_WITH_SEARCHID(searchId, page);
        [_browser GETWithURLString:url requestCallback:^(BOOL isSuccess, NSString *html) {
            handler(isSuccess, html);
        }];
    }
}

-(void)seniorReplyWithThreadId:(int)threadId andMessage:(NSString *)message securitytoken:(NSString *)token posthash:(NSString *)posthash poststarttime:(NSString *)poststarttime handler:(HandlerWithBool)handler{
    
    NSString * url = BBS_REPLY(threadId);
    
    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[self buildSignature]];
    }

    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:message forKey:@"message"];
    [parameters setValue:@"0" forKey:@"wysiwyg"];
    [parameters setValue:@"0" forKey:@"iconid"];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    [parameters setValue:@"postreply" forKey:@"do"];
    [parameters setValue:[NSString stringWithFormat:@"%d",threadId] forKey:@"t"];
    [parameters setValue:@"" forKey:@"p"];
    [parameters setValue:@"0" forKey:@"specifiedpost"];
    [parameters setValue:posthash forKey:@"posthash"];
    [parameters setValue:poststarttime forKey:@"poststarttime"];
    LoginUser * user = [self getCurrentCCFUser];
    [parameters setValue:user.userID forKey:@"loggedinuser"];
    [parameters setValue:@"" forKey:@"multiquoteempty"];
    [parameters setValue:@"提交回复" forKey:@"sbutton"];
    [parameters setValue:@"1" forKey:@"signature"];
    
    [parameters setValue:@"1" forKey:@"parseurl"];
    [parameters setValue:@"9999" forKey:@"emailupdate"];
    
    [_browser POSTWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}


-(void)seniorReplyWithThreadId:(int)threadId forFormId:(int) formId andMessage:(NSString *)message withImages:(NSArray *)images securitytoken:(NSString *)token handler:(HandlerWithBool)handler{
    NSString * url = BBS_REPLY(threadId);
    
    
    NSMutableDictionary * presparameters = [NSMutableDictionary dictionary];
    [presparameters setValue:@"" forKey:@"message"];
    [presparameters setValue:@"0" forKey:@"wysiwyg"];
    [presparameters setValue:@"2" forKey:@"styleid"];
    [presparameters setValue:@"1" forKey:@"signature"];
    [presparameters setValue:@"1" forKey:@"fromquickreply"];
    [presparameters setValue:@"" forKey:@"s"];
    [presparameters setValue:token forKey:@"securitytoken"];
    [presparameters setValue:@"postreply" forKey:@"do"];
    [presparameters setValue:[NSString stringWithFormat:@"%d",threadId] forKey:@"t"];
    [presparameters setValue:@"who cares" forKey:@"p"];
    [presparameters setValue:@"0" forKey:@"specifiedpost"];
    [presparameters setValue:@"1" forKey:@"parseurl"];
    LoginUser * user = [self getCurrentCCFUser];
    [presparameters setValue:user.userID forKey:@"loggedinuser"];
    [presparameters setValue:@"进入高级模式" forKey:@"preview"];
    
    [_browser POSTWithURLString:url parameters:presparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            
            NSString * token = [parser parseSecurityToken:html];
            NSString * postHash = [parser parsePostHash:html];
            NSString * postStartTime = [parser parserPostStartTime:html];
            
            if (images == nil || [images count] == 0) {
                [self seniorReplyWithThreadId:threadId andMessage:message securitytoken:token posthash:postHash poststarttime:postStartTime handler:^(BOOL isSuccess, id result) {
                    if (isSuccess) {
                        handler(YES,result);
                    } else{
                        handler(NO,@"回复失败");
                    }
                }];

            } else{
                
                __block NSString * uploadImageToken = @"";
                NSString * urlStr = BBS_MANAGE_ATT;
                NSURL *uploadImageUrl = [NSURL URLWithString:urlStr];
                // 如果有图片，先传图片
                [self uploadImagePrepairFormSeniorReply:threadId startPostTime:postStartTime postHash:postHash :^(BOOL isSuccess, id result) {
                    // 解析出上传图片需要的参数
                    uploadImageToken = [parser parseSecurityToken:result];
                    NSString * uploadTime = [[token componentsSeparatedByString:@"-"] firstObject];
                    NSString * uploadHash = [parser parsePostHash:result];
                    
                    __block BOOL uploadSuccess = YES;
                    int uploadCount = (int)images.count;
                    for (int i = 0; i < uploadCount && uploadSuccess; i++) {
                        NSData * image = images[i];
                        
                        [NSThread sleepForTimeInterval:2.0f];
                        [self uploadImageForSeniorReply:uploadImageUrl :uploadImageToken fId:formId threadId:threadId postTime:uploadTime hash:uploadHash :image callback:^(BOOL isSuccess, id uploadResultHtml) {
                            uploadSuccess = isSuccess;
                            // 更新token
                            uploadImageToken = [parser parseSecurityToken:uploadResultHtml];
                            
                            NSLog(@" 上传第 %d 张图片", i);
                            
                            if (i == images.count -1) {
                                [NSThread sleepForTimeInterval:2.0f];
                                [self seniorReplyWithThreadId:threadId andMessage:message securitytoken:uploadImageToken posthash:postHash poststarttime:postStartTime handler:^(BOOL isSuccess, id result) {
                                    if (isSuccess) {
                                        handler(YES,result);
                                    } else{
                                        handler(NO,@"回复失败");
                                    }
                                }];
                            }
                        }];
                    }
                    
                    if (!uploadSuccess) {
                        handler(NO, @"上传图片失败！");
                    }
                }];
            }
        } else{
            handler(NO,@"回复失败");
        }
    }];
    
    
}

-(NSString *) uploadParamDivider{
    static const NSString *kRandomAlphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity:16];
    for (int i = 0; i < 16; i++) {
        [randomString appendFormat: @"%C", [kRandomAlphabet characterAtIndex:arc4random_uniform((u_int32_t)[kRandomAlphabet length])]];
    }
    return randomString;
}

-(void) uploadImageForSeniorReply:(NSURL *)url :(NSString *)token fId:(int)fId threadId:(int) threadId postTime:(NSString *)postTime hash:(NSString *)hash :(NSData *) imageData callback:(HandlerWithBool)callback{
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPShouldHandleCookies:YES];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    NSString * cookie = [self loadCookie];
    [request setValue:cookie forHTTPHeaderField:@"Cookie"];
    
    NSString *boundary = [NSString stringWithFormat:@"----WebKitFormBoundary%@", [self uploadParamDivider]];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    [request setValue:token forHTTPHeaderField:@"securitytoken"];
    
    
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    
    
    // add params (all params are strings)
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    [parameters setValue:@"manageattach" forKey:@"do"];
    [parameters setValue:[NSString stringWithFormat:@"%d", threadId] forKey:@"t"];
    NSString * formID = [NSString stringWithFormat:@"%d", fId];
    [parameters setValue:formID forKey:@"f"];
    [parameters setValue:@"" forKey:@"p"];
    [parameters setValue:postTime forKey:@"poststarttime"];
    
    [parameters setValue:@"0" forKey:@"editpost"];
    [parameters setValue:hash forKey:@"posthash"];
    
    [parameters setValue:@"16777216" forKey:@"MAX_FILE_SIZE"];
    [parameters setValue:@"上传" forKey:@"upload"];
    
    NSString * name = [NSString stringWithFormat:@"CCF_CLIENT_%f.jpg", [[NSDate date] timeIntervalSince1970]];
    
    [parameters setValue:name forKey:@"attachment[]"];

    [parameters setValue:@"" forKey:@"attachmenturl[]"];
    
    
    for (NSString *param in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
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
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if(data.length > 0) {
            //success
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            callback(YES, responseString);
        } else{
            callback(NO, @"failed");
        }
    }];
}




















@end
