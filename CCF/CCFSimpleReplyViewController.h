//
//  CCFSimpleReplyViewController.h
//  CCF
//
//  Created by 迪远 王 on 16/4/10.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumApiBaseViewController.h"
#import <vBulletinForumEngine/vBulletinForumEngine.h>
#import "ReplyCallbackDelegate.h"

@interface CCFSimpleReplyViewController : ForumApiBaseViewController

@property(nonatomic, strong) id <ReplyCallbackDelegate> delegate;

- (IBAction)sendSimpleReply:(id)sender;

- (IBAction)back:(id)sender;

@property(weak, nonatomic) IBOutlet UITextView *replyContent;

@end
