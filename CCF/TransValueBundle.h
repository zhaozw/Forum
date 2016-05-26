//
//  TransValueBundle.h
//  CCF
//
//  Created by 迪远 王 on 16/4/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransValueBundle : NSObject

-(void) putIntValue:(int)value forKey:(NSString *)key;

-(void) putStringValue:(NSString *)value forKey:(NSString *)key;

-(int) getIntValue:(NSString*)key;

-(NSString *) getStringValue:(NSString*) key;

@end
