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

@property (nullable, nonatomic, copy) NSNumber *forumId;
@property (nullable, nonatomic, copy) NSString *forumName;
@property (nullable, nonatomic, copy) NSNumber *parentForumId;

@end

NS_ASSUME_NONNULL_END
