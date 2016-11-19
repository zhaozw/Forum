//
//  UserEntry+CoreDataProperties.h
//  
//
//  Created by 迪远 王 on 2016/11/19.
//
//

#import "UserEntry+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UserEntry (CoreDataProperties)

+ (NSFetchRequest<UserEntry *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *userAvatar;
@property (nullable, nonatomic, copy) NSString *userID;

@end

NS_ASSUME_NONNULL_END
