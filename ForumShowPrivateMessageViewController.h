//
//  ForumShowPrivateMessageViewController.h
//
//  Created by 迪远 王 on 16/3/25.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "vBulletinForumEngine.h"
#import "ForumApiBaseViewController.h"


@interface ForumShowPrivateMessageViewController : ForumApiBaseViewController


@property(nonatomic, strong) NSMutableArray<ShowPrivateMessage *> *dataList;


- (IBAction)back:(id)sender;

@property(weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)replyPM:(id)sender;

@end
