//
//  CCFForumBrowser.h
//  CCF
//
//  Created by 迪远 王 on 16/10/3.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vBulletinForumEngine.h"

@interface ForumBrowser : NSObject <ForumEngine>

- (void)reportThreadPost:(int)postId andMessage:(NSString *)message handler:(HandlerWithBool)handler;

@end
