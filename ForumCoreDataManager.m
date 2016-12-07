//
//  ForumCoreDataManager.m
//
//  Created by WDY on 16/1/12.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumCoreDataManager.h"
#import "ForumEntry+CoreDataClass.h"
#import "ForumConfig.h"


@implementation ForumCoreDataManager

- (instancetype)initWithEntryType:(EntryType)enrty {
    if (enrty == EntryTypeForm) {

        return [self initWithXcdatamodeld:kFormXcda andWithPersistentName:kFormDBName andWithEntryName:kFormEntry];
    } else if (enrty == EntryTypeUser) {

        return [self initWithXcdatamodeld:kFormXcda andWithPersistentName:kFormDBName andWithEntryName:kUserEntry];
    }
    return nil;

}


- (NSArray<Forum *> *)selectFavForums:(NSArray *)ids {

    NSArray<ForumEntry *> *entrys = [self selectData:^NSPredicate * {
        return [NSPredicate predicateWithFormat:@"forumHost = %@ AND forumId IN %@", [NSURL URLWithString:BBS_URL].host, ids];
    }];

    NSMutableArray<Forum *> *forms = [NSMutableArray arrayWithCapacity:entrys.count];

    for (ForumEntry *entry in entrys) {
        Forum *form = [[Forum alloc] init];
        form.forumName = entry.forumName;
        form.forumId = [entry.forumId intValue];
        [forms addObject:form];
    }
    return [forms copy];
}


- (NSArray<Forum *> *)selectAllForums {

    NSArray<ForumEntry *> *entrys = [self selectData:^NSPredicate * {
        return [NSPredicate predicateWithFormat:@"forumHost = %@ AND parentForumId = %d", [NSURL URLWithString:BBS_URL].host , -1];
    }];

    NSMutableArray<Forum *> *forms = [NSMutableArray arrayWithCapacity:entrys.count];

    for (ForumEntry *entry in entrys) {
        Forum *form = [[Forum alloc] init];
        form.forumName = entry.forumName;
        form.forumId = [entry.forumId intValue];
        form.parentForumId = [entry.parentForumId intValue];
        [forms addObject:form];
    }

    for (Forum *form in forms) {
        form.childForums = [self selectChildForumsById:form.forumId];
    }


    return [forms copy];
}


- (NSArray<Forum *> *)selectChildForumsById:(int)forumId {

    NSArray<ForumEntry *> *entrys = [self selectData:^NSPredicate * {
        return [NSPredicate predicateWithFormat:@"parentForumId = %d", forumId];
    }];

    NSMutableArray<Forum *> *forms = [NSMutableArray arrayWithCapacity:entrys.count];

    for (ForumEntry *entry in entrys) {
        Forum *form = [[Forum alloc] init];
        form.forumName = entry.forumName;
        form.forumId = [entry.forumId intValue];
        form.parentForumId = [entry.parentForumId intValue];
        [forms addObject:form];
    }
    return [forms copy];
}


@end
