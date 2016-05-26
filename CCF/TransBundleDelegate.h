//
//  TransBundleDelegate.h
//  CCF
//
//  Created by 迪远 王 on 16/4/24.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TransBundleDelegate<NSObject>


@required
-(void)transBundle:(TransValueBundle *)bundle;

@end
