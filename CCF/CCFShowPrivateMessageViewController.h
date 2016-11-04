//
//  CCFShowPrivateMessageViewController.h
//  CCF
//
//  Created by 迪远 王 on 16/3/25.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoRelayoutToolbar.h"
#import <vBulletinForumEngine/vBulletinForumEngine.h>
#import "TransValueDelegate.h"
#import "ForumApiBaseViewController.h"
#import "TransValueDelegate.h"
#import "ReplyTransValueDelegate.h"


@interface CCFShowPrivateMessageViewController : ForumApiBaseViewController


@property(nonatomic, strong) NSMutableArray<ShowPrivateMessage *> *dataList;


- (IBAction)back:(id)sender;

@property(weak, nonatomic) IBOutlet UIWebView *webView;

@property(weak, nonatomic) id <TransValueDelegate> transValueDelegate;

@end
