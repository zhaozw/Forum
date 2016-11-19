//
//  ForumEntry+CoreDataProperties.m
//  
//
//  Created by 迪远 王 on 2016/11/19.
//
//

#import "ForumEntry+CoreDataProperties.h"

@implementation ForumEntry (CoreDataProperties)

+ (NSFetchRequest<ForumEntry *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ForumEntry"];
}

@dynamic forumId;
@dynamic forumName;
@dynamic parentForumId;

@end
