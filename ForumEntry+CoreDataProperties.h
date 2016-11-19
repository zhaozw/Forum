//
//  ForumEntry+CoreDataProperties.h
//  
//
//  Created by 迪远 王 on 2016/11/19.
//
//

#import "ForumEntry+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ForumEntry (CoreDataProperties)

+ (NSFetchRequest<ForumEntry *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *formId;
@property (nullable, nonatomic, copy) NSString *formName;
@property (nullable, nonatomic, copy) NSNumber *parentFormId;

@end

NS_ASSUME_NONNULL_END
