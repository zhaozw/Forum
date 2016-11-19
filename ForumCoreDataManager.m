//
//  ForumCoreDataManager.m
//
//  Created by WDY on 16/1/12.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumCoreDataManager.h"
#import "ForumEntry+CoreDataClass.h"


@implementation ForumCoreDataManager

- (instancetype)initWithEntryType:(EntryType)enrty {
    if (enrty == EntryTypeForm) {

        return [self initWithXcdatamodeld:kFormXcda andWithPersistentName:kFormDBName andWithEntryName:kFormEntry];
    } else if (enrty == EntryTypeUser) {

        return [self initWithXcdatamodeld:kFormXcda andWithPersistentName:kFormDBName andWithEntryName:kUserEntry];
    }
    return nil;

}


- (NSArray<Forum *> *)selectFavForms:(NSArray *)ids {

    NSArray<ForumEntry *> *entrys = [self selectData:^NSPredicate * {
        return [NSPredicate predicateWithFormat:@"forumId IN %@", ids];
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


- (NSArray<Forum *> *)selectAllForms {

    NSArray<ForumEntry *> *entrys = [self selectData:^NSPredicate * {
        return [NSPredicate predicateWithFormat:@"parentForumId = %d", -1];
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
        form.childForums = [self selectChildFormsForId:form.forumId];
    }


    return [forms copy];
}


- (NSArray<Forum *> *)selectChildFormsForId:(int)formId {

    NSArray<ForumEntry *> *entrys = [self selectData:^NSPredicate * {
        return [NSPredicate predicateWithFormat:@"parentForumId = %d", formId];
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
