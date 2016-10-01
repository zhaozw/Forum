//
//  CCFSearchResult.h
//  CCF
//
//  Created by WDY on 16/1/11.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Thread.h"

@interface ThreadInSearch : Thread

@property (nonatomic, strong) NSString* fromFormName;       // 所属论坛名称

@end
