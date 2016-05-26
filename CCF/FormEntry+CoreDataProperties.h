//
//  FormEntry+CoreDataProperties.h
//  CCF
//
//  Created by 迪远 王 on 16/5/22.
//  Copyright © 2016年 andforce. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FormEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface FormEntry (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *formId;
@property (nullable, nonatomic, retain) NSString *formName;
@property (nullable, nonatomic, retain) NSNumber *parentFormId;

@end

NS_ASSUME_NONNULL_END
