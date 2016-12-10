//
//  NSUserDefaults+Extensions.h
//
//  Created by WDY on 16/1/13.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSUserDefaults (Extensions)

- (NSString *)loadCookie;

- (void)saveCookie;

- (void)saveFavFormIds:(NSArray *)ids;

- (NSArray *)favFormIds;

- (int)dbVersion;

- (void)setDBVersion:(int)version;

- (void)clearCookie;

- (void)saveUserName:(NSString *)name;

- (NSString *)userName;

- (NSString *)currentForumURL;

- (void) saveCurrentForumURL:(NSString*) url;

@end
