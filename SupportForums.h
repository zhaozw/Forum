//
//  SupportForums.h
//
//  Created by   on 2016/12/10
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SupportForums : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSArray *forums;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
