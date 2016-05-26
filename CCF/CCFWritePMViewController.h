//
//  CCFWritePMViewController.h
//  CCF
//
//  Created by 迪远 王 on 16/4/9.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFApiBaseViewController.h"

@interface CCFWritePMViewController : CCFApiBaseViewController
- (IBAction)back:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *toWho;
@property (weak, nonatomic) IBOutlet UITextField *privateMessageTitle;
@property (weak, nonatomic) IBOutlet UITextView *privateMessageContent;
- (IBAction)sendPrivateMessage:(id)sender;

@end
