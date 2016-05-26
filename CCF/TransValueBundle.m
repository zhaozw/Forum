//
//  TransValueBundle.m
//  CCF
//
//  Created by 迪远 王 on 16/4/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "TransValueBundle.h"

@implementation TransValueBundle{
    NSMutableDictionary * dictonary;
}

-(instancetype)init{
    if (self = [super init]) {
        dictonary = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)putIntValue:(int)value forKey:(NSString *)key{
    [dictonary setValue:[NSNumber numberWithInt:value] forKey:key];
}

-(void)putStringValue:(NSString *)value forKey:(NSString *)key{
    [dictonary setValue:value forKey:key];
}

-(int)getIntValue:(NSString *)key{
    NSNumber *value = [dictonary valueForKey:key];
    if (value == nil) {
        return -1;
    }
    return value.intValue;
}

-(NSString *)getStringValue:(NSString *)key{
    return [dictonary valueForKey:key];
}

@end
