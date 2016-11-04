//
//  ForumSettingTableViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/4/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumSettingTableViewController.h"
#import "UIStoryboard+CCF.h"
#import "NSUserDefaults+Setting.h"

@interface ForumSettingTableViewController ()

@end

@implementation ForumSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    [self.signatureSwitch setOn:[NSUserDefaults standardUserDefaults].isSignatureEnabled];
    [self.topThreadPostSwitch setOn:[NSUserDefaults standardUserDefaults].isTopThreadPostCanShow];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
        ForumSettingTableViewController *settingController = [storyboard instantiateViewControllerWithIdentifier:@"ForumSettingTableViewController"];
        [self.navigationController pushViewController:settingController animated:YES];
    }

}


- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)switchSignature:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setSignature:sender.isOn];
}

- (IBAction)switchTopThread:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setTopThreadPost:sender.isOn];
}

@end