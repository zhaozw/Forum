//
//  CCFWebViewController.h
//  CCF
//
//  Created by 迪远 王 on 16/5/26.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCFApiBaseViewController.h"
#import "TransValueDelegate.h"
#import "ReplyTransValueDelegate.h"


@interface CCFWebViewController : CCFApiBaseViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) UIImageView *animatedFromView;

@property (nonatomic, weak) id<TransValueDelegate> transValueDelegate;

- (IBAction)back:(UIBarButtonItem *)sender;

- (IBAction)showMoreAction:(UIBarButtonItem *)sender;

@property (nonatomic, weak) id<ReplyTransValueDelegate> replyTransValueDelegate;

- (IBAction)changeNumber:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *pageNumber;

- (IBAction)reply:(id)sender;

@end
