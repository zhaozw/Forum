//
//  CCFCoreDataManager.m
//  CCF
//
//  Created by WDY on 16/1/12.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumCoreDataManager.h"
#import "FormEntry.h"


@implementation ForumCoreDataManager

-(instancetype)initWithEntryType:(EntryType)enrty{
    if (enrty == EntryTypeForm) {
    
        return [self initWithXcdatamodeld:kFormXcda andWithPersistentName:kFormDBName andWithEntryName:kFormEntry];
    } else if (enrty == EntryTypeUser){
        
        return [self initWithXcdatamodeld:kFormXcda andWithPersistentName:kFormDBName andWithEntryName:kUserEntry];
    }
    return nil;
    
}


-(NSArray<Forum *> *)selectFavForms:(NSArray *)ids{
    
    NSArray<FormEntry *> *entrys = [self selectData:^NSPredicate *{
        return [NSPredicate predicateWithFormat:@"formId IN %@", ids];
    }];
    
    NSMutableArray<Forum *> *forms = [NSMutableArray arrayWithCapacity:entrys.count];
    
    for (FormEntry *entry in entrys) {
        Forum * form = [[Forum alloc] init];
        form.formName = entry.formName;
        form.formId = [entry.formId intValue];
        [forms addObject:form];
    }
    return [forms copy];
}



-(NSArray<Forum *> *)selectAllForms{
    
    NSArray<FormEntry *> *entrys = [self selectData:^NSPredicate *{
        return [NSPredicate predicateWithFormat:@"parentFormId = %d", -1];
    }];
    
    NSMutableArray<Forum *> *forms = [NSMutableArray arrayWithCapacity:entrys.count];
    
    for (FormEntry *entry in entrys) {
        Forum * form = [[Forum alloc] init];
        form.formName = entry.formName;
        form.formId = [entry.formId intValue];
        form.parentFormId = [entry.parentFormId intValue];
        [forms addObject:form];
    }
    
    for (Forum * form in forms) {
        form.childForms = [self selectChildFormsForId:form.formId];
    }
    
    
    
    
    return [forms copy];
}


-(NSArray<Forum *> *)selectChildFormsForId:(int)formId{
    
    NSArray<FormEntry *> *entrys = [self selectData:^NSPredicate *{
        return [NSPredicate predicateWithFormat:@"parentFormId = %d", formId];
    }];
    
    NSMutableArray<Forum *> *forms = [NSMutableArray arrayWithCapacity:entrys.count];
    
    for (FormEntry *entry in entrys) {
        Forum * form = [[Forum alloc] init];
        form.formName = entry.formName;
        form.formId = [entry.formId intValue];
        form.parentFormId = [entry.parentFormId intValue];
        [forms addObject:form];
    }
    return [forms copy];
}



@end
