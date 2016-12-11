//
//  NSUserDefaults+Extensions.m
//
//  Created by WDY on 16/1/13.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "NSUserDefaults+Extensions.h"

#define kDB_VERSION @"DB_VERSION"

@implementation NSUserDefaults (Extensions)

- (NSString *)loadCookie {
    NSData *cookiesdata = [self objectForKey:[[self currentForumHost] stringByAppendingString:@"-Cookies"]];


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
    [self setObject:data forKey:[[self currentForumHost] stringByAppendingString:@"-Cookies"]];
}

- (void)clearCookie {
    [self removeObjectForKey:[[self currentForumHost] stringByAppendingString:@"-Cookies"]];
}

- (void)saveFavFormIds:(NSArray *)ids {
    [self setObject:ids forKey:[[self currentForumHost] stringByAppendingString:@"-FavIds"]];
}


- (NSArray *)favFormIds {
    return [self objectForKey:[[self currentForumHost] stringByAppendingString:@"-FavIds"]];
}

- (int)dbVersion {
    return [[self objectForKey:kDB_VERSION] intValue];
}

- (void)setDBVersion:(int)version {
    [self setObject:@(version) forKey:kDB_VERSION];
}


- (void)saveUserName:(NSString *)name {
    [self setValue:name forKey:[[self currentForumHost] stringByAppendingString:@"-UserName"]];
}

- (NSString *)userName {
    return [self valueForKey:[[self currentForumHost] stringByAppendingString:@"-UserName"]];
}

- (NSString *)currentForumURL {
    return [self valueForKey:@"currentForumURL"];
}

- (void)saveCurrentForumURL:(NSString *)url {
    [self setValue:url forKey:@"currentForumURL"];
}

- (NSString*) currentForumHost{
    NSURL * nsurl = [NSURL URLWithString:[self currentForumURL]];
    return [nsurl host];
}

@end
