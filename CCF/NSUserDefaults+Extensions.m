//
//  NSUserDefaults+CCF.m
//  CCF
//
//  Created by WDY on 16/1/13.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "NSUserDefaults+Extensions.h"

#define kCCFCookie @"CCF-Cookies"
#define kCCFFavFormIds @"CCF-FavIds"

#define kDB_VERSION @"DB_VERSION"
#define kUserName @"CCF-UserName"



@implementation NSUserDefaults(Extensions)

-(NSString *)loadCookie{
    NSData *cookiesdata = [self objectForKey:kCCFCookie];
    
    
    if([cookiesdata length]) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
        
        NSHTTPCookie *cookie;
        for (cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    
    

    NSString *result = [[NSString alloc] initWithData:cookiesdata encoding:NSUTF8StringEncoding];

    return result;
}


-(void)saveCookie{
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    [self setObject:data forKey:kCCFCookie];
}

-(void)saveFavFormIds:(NSArray *)ids{
    [self setObject:ids forKey:kCCFFavFormIds];
}

-(NSArray *)favFormIds{
    return [self objectForKey:kCCFFavFormIds];
}



-(int)dbVersion{
    return [[self objectForKey:kDB_VERSION] intValue];
}

-(void)setDBVersion:(int)version{
    [self setObject:[NSNumber numberWithInt:version] forKey:kDB_VERSION];
}

-(void)clearCookie{
    [self removeObjectForKey:kCCFCookie];
}


-(void)saveUserName:(NSString *)name{
    [self setValue:name forKey:kUserName];
}

-(NSString*)userName{
    return [self valueForKey:kUserName];
}
@end
