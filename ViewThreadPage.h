//
//  ViewThreadPage.h
//
//  Created by WDY on 15/12/29.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewForumPage.h"
#import "Post.h"

@interface ViewThreadPage : ViewForumPage

@property(nonatomic, strong) NSString *threadID;
@property(nonatomic, strong) NSString *threadLink;
@property(nonatomic, strong) NSString *threadTitle;
@property(nonatomic, strong) NSString *forumId;            // 主题所属论坛

@end
