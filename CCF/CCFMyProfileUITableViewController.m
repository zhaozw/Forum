//
//  CCFMyProfileUITableViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/3/21.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFMyProfileUITableViewController.h"
#import "CCFProfileTableViewCell.h"

#import "CCFPrivateMessageTableViewController.h"
#import "CCFMyThreadPostTableViewController.h"
#import "CCFMyThreadTableViewController.h"
#import "CCFShowNewThreadPostTableViewController.h"
#import "CCFFavThreadPostTableViewController.h"
#import "CCFMyProfileUITableViewController.h"
#import "CCFNavigationController.h"
#import "CCFSettingTableViewController.h"
#import "LoginViewController.h"
#import "UIStoryboard+CCF.h"
#import "NSUserDefaults+Extensions.h"
#import "UserProfile.h"
#import "CCFShowThreadViewController.h"
#import "NormalThread.h"

@interface CCFMyProfileUITableViewController (){
    UserProfile * userProfile;
    
}

@end

@implementation CCFMyProfileUITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(BOOL)setLoadMore:(BOOL)enable{
    return NO;
}

-(void)onPullRefresh{
    
    NSString * currentUserId = self.ccfApi.getLoginUser.userID;
    
    [self.ccfApi showProfileWithUserId:currentUserId handler:^(BOOL isSuccess, UserProfile* message) {
        userProfile = message;
        
        [self.tableView.mj_header endRefreshing];
        
        [self.tableView reloadData];
    }];
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return userProfile == nil ? 0 : 1;;
    } else if (section == 1){
        return 3;
    } else{
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        static NSString *QuoteCellIdentifier = @"CCFProfileTableViewCell";
        CCFProfileTableViewCell *cell = (CCFProfileTableViewCell*)[tableView dequeueReusableCellWithIdentifier:QuoteCellIdentifier];
        
        [cell setData:userProfile];
        
        return cell;
    } else if (indexPath.section == 1){
        static NSString *QuoteCellIdentifier = @"CCFProfileActionCell";
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:QuoteCellIdentifier];
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"设置";
        } else if (indexPath.row == 1){
            cell.textLabel.text = @"注销";
        } else if (indexPath.row == 2){
            cell.textLabel.text = @"我发表的主题";
        }
        return cell;
        
    } else{
        static NSString *QuoteCellIdentifier = @"CCFProfileShowCell";
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:QuoteCellIdentifier];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"注册日期";
            cell.detailTextLabel.text = userProfile.profileRegisterDate;
        } else if (indexPath.row == 1){
            cell.textLabel.text = @"最近活动时间";
            cell.detailTextLabel.text = userProfile.profileRecentLoginDate;
        } else if (indexPath.row == 2){
            cell.textLabel.text = @"帖子总数";
            cell.detailTextLabel.text = userProfile.profileTotalPostCount;
        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        
        UIStoryboard * storyboard = [UIStoryboard mainStoryboard];
        CCFSettingTableViewController *settingController = [storyboard instantiateViewControllerWithIdentifier:@"CCFSettingTableViewController"];
        [self.navigationController pushViewController:settingController animated:YES];
        
        
    } else if (indexPath.row == 1){
        
        [self.ccfApi logout];
        
        
        LoginViewController * rootController = [[LoginViewController alloc] init];
        
        UIStoryboard *stortboard = [UIStoryboard mainStoryboard];
        [stortboard changeRootViewControllerToController:rootController];
        
    } else if (indexPath.row == 2){
        
        UIStoryboard * storyboard = [UIStoryboard mainStoryboard];
        CCFMyThreadTableViewController * myThreadController = [storyboard instantiateViewControllerWithIdentifier:@"CCFMyThreadTableViewController"];
        [self.navigationController pushViewController:myThreadController animated:YES];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark Controller跳转

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 56;
    } else if (indexPath.section == 1){
        return 44;
    } else{
        return 44;
    }
}

- (IBAction)back:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
