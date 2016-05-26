//
//  CCFSettingTableViewController.h
//  CCF
//
//  Created by 迪远 王 on 16/4/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCFSettingTableViewController : UITableViewController
- (IBAction)back:(UIBarButtonItem *)sender;
- (IBAction)switchSignature:(UISwitch *)sender;
- (IBAction)switchTopThread:(UISwitch *)sender;


@property (weak, nonatomic) IBOutlet UISwitch *signatureSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *topThreadPostSwitch;

@end
