//
//  Post.h
//
//  Created by WDY on 15/12/29.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"


@interface Post : NSObject

@property(nonatomic, strong) NSString *postID;

@property(nonatomic, strong) NSString *postLouCeng;    // 帖子楼层
@property(nonatomic, strong) NSString *postTime;
@property(nonatomic, strong) NSString *postContent;

@property(nonatomic, strong) User *postUserInfo;

@end
