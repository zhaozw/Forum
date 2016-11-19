//
//  UserEntry+CoreDataProperties.m
//  
//
//  Created by 迪远 王 on 2016/11/19.
//
//

#import "UserEntry+CoreDataProperties.h"

@implementation UserEntry (CoreDataProperties)

+ (NSFetchRequest<UserEntry *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"UserEntry"];
}

@dynamic userAvatar;
@dynamic userID;

@end
