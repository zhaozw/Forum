//
//  SimpleReplyTransValueDelegate.h
//  CCF
//
//  Created by 迪远 王 on 16/4/10.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCFShowThreadViewController.h"
#import "TransValueBundle.h"


@protocol ReplyTransValueDelegate<NSObject>

@required
-(void)transValue:(id)controller withBundle:(TransValueBundle *) transBundle;

@end
