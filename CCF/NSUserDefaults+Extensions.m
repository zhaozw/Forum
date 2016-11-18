//
//  NSUserDefaults+Extensions.m
//
//  Created by WDY on 16/1/13.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "NSUserDefaults+Extensions.h"

#define kCookie @"ForumCookie"
#define kFavForumIds @"FavIds"

#define kDB_VERSION @"DB_VERSION"
#define kUserName @"UserName"


@implementation NSUserDefaults (Extensions)

- (NSString *)loadCookie {
    NSData *cookiesdata = [self objectForKey:kCookie];


    if ([cookiesdata length]) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];

        NSHTTPCookie *cookie;
        for (cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }


    NSString *result = [[NSString alloc] initWithData:cookiesdata encoding:NSUTF8StringEncoding];

    return result;
}


- (void)saveCookie {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    [self setObject:data forKey:kCookie];
}

- (void)saveFavFormIds:(NSArray *)ids {
    [self setObject:ids forKey:kFavForumIds];
}

- (NSArray *)favFormIds {
    return [self objectForKey:kFavForumIds];
}


- (int)dbVersion {
    return [[self objectForKey:kDB_VERSION] intValue];
}

- (void)setDBVersion:(int)version {
    [self setObject:[NSNumber numberWithInt:version] forKey:kDB_VERSION];
}

- (void)clearCookie {
    [self removeObjectForKey:kCookie];
}


- (void)saveUserName:(NSString *)name {
    [self setValue:name forKey:kUserName];
}

- (NSString *)userName {
    return [self valueForKey:kUserName];
}
@end
