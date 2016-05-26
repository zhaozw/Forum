//
//  CCFCoreDataManager.h
//  CCF
//
//  Created by WDY on 16/1/12.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CoreDataManager.h"
#import "Forum.h"


typedef NS_ENUM(NSInteger, EntryType) {
    EntryTypeForm = 0,
    EntryTypePost,
    EntryTypeUser
    
};


#pragma mark Form 相关
#define kFormEntry @"FormEntry"
#define kFormXcda @"db"
#define kFormDBName @"db.sqlite"

#define kUserEntry @"UserEntry"

@interface ForumCoreDataManager : CoreDataManager

-(instancetype)initWithEntryType:(EntryType) enrty;

-(NSArray<Forum *> *)selectFavForms:(NSArray *) ids;

-(NSArray<Forum *> *)selectChildFormsForId:(int)formId;

-(NSArray<Forum *> *)selectAllForms;

@end
