//
//  ReplyCallbackDelegate.h
//  CCF
//
//  Created by 迪远 王 on 16/4/18.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShowThreadPage.h"

@protocol ReplyCallbackDelegate<NSObject>

-(void) transReplyValue:(ShowThreadPage *) value;

@end
