//
//  AFHTTPSessionManager+SimpleAction.h
//  CCF
//
//  Created by WDY on 16/1/15.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef void(^RequestCallback)(BOOL isSuccess, NSString *html);

@interface AFHTTPSessionManager (SimpleAction)

- (void)GETWithURLString:(NSString *)url requestCallback:(RequestCallback)callback;

- (void)POSTWithURLString:(NSString *)url parameters:(id)parameters requestCallback:(RequestCallback)callback;

- (void)POSTWithURLString:(NSString *)url parameters:(id)parameters constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block requestCallback:(RequestCallback)callback;

@end
