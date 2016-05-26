//
//  TransValueDelegate.h
//  CCF
//
//  Created by 迪远 王 on 16/3/20.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TransValueDelegate<NSObject>


@required
-(void)transValue:(id)value;

@end
