//
//  CCFProfileTableViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/3/20.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFProfileTableViewController.h"
#import "CCFProfileTableViewCell.h"
#import "PrivateMessage.h"
#import "ShowPrivateMessage.h"
#import "ThreadInSearch.h"
#import "TransValueUITableViewCell.h"
#import "CCFUserThreadTableViewController.h"
#import "Post.h"
#import "CCFWritePMNavigationController.h"
#import <UIImageView+WebCache.h>
#import "UIStoryboard+CCF.h"
#import "UserProfile.h"

@interface CCFProfileTableViewController ()<TransValueDelegate>{
    
    UserProfile * userProfile;
    int userId;
    
    UIImage * defaultAvatar;
    
    ForumCoreDataManager *coreDateManager;
    ForumApi * ccfapi;
    
    NSMutableDictionary * avatarCache;
    
    NSMutableArray<UserEntry*> * cacheUsers;
}

@end

@implementation CCFProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    defaultAvatar = [UIImage imageNamed:@"logo.jpg"];
    
    ccfapi = [[ForumApi alloc] init];
    coreDateManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeUser];
    avatarCache = [NSMutableDictionary dictionary];
    
    if (cacheUsers == nil) {
        cacheUsers = [[coreDateManager selectData:^NSPredicate *{
            return [NSPredicate predicateWithFormat:@"userID > %d", 0];
        }] copy];
    }
    
    for (UserEntry * user in cacheUsers) {
        [avatarCache setValue:user.userAvatar forKey:user.userID];
    }
    
}

-(BOOL)setLoadMore:(BOOL)enable{
    return NO;
}

-(void)transValue:(id)value{
    
    
    if ([value isKindOfClass:[PrivateMessage class]]) {
        PrivateMessage * message = value;
        userId = [message.pmAuthorId intValue];
    } else if ([value isKindOfClass:[NormalThread class]]){
        NormalThread * thread = value;
        userId = [thread.threadAuthorID intValue];
    } else if([value isKindOfClass:[ShowPrivateMessage class]]){
        ShowPrivateMessage * message = value;
        userId = [message.pmUserInfo.userID intValue];
    } else if ([value isKindOfClass:[ThreadInSearch class]]){
        ThreadInSearch * message = value;
        userId = [message.threadAuthorID intValue];
    } else if([value isKindOfClass:[Post class]]){
        Post * message = value;
        userId = [message.postUserInfo.userID intValue];
    }
}


-(void)onPullRefresh{
    NSString * userIdString = [NSString stringWithFormat:@"%d", userId];
    [self.ccfApi showProfileWithUserId:userIdString handler:^(BOOL isSuccess, UserProfile* message) {
        userProfile = message;
        
        [self.tableView.mj_header endRefreshing];
        
        
        
        
        [self showAvatar:self.userAvatar userId:userProfile.profileUserId];
        self.userName.text = userProfile.profileName;
        self.userRankName.text = userProfile.profileRank;
        self.userSignDate.text = userProfile.profileRegisterDate;
        self.userCurrentLoginDate.text = userProfile.profileRecentLoginDate;
        self.userPostCount.text = userProfile.profileTotalPostCount;
        
        [self.tableView reloadData];
    }];
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
//
//#pragma mark - Table view data source
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return userProfile == nil ? 0: 1;
    } else if (section == 1){
        return 2;
    } else{
        return 3;
    }
}

#pragma mark 跳转
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"ShowCCFUserThreadTableViewController"]) {
        CCFUserThreadTableViewController * controller = segue.destinationViewController;
        
        self.transValueDelegate = (id<TransValueDelegate>)controller;
        
        [self.transValueDelegate transValue:userProfile];
    } 
    
}

-(void)showAvatar:(UIImageView *)avatarImageView userId:(NSString*)profileUserId{
    

    NSString * avatarInArray = [avatarCache valueForKey:profileUserId];
    
    if (avatarInArray == nil) {
        
        [ccfapi getAvatarWithUserId:profileUserId handler:^(BOOL isSuccess, NSString *avatar) {
            // 存入数据库
            [coreDateManager insertOneData:^(id src) {
                UserEntry * user =(UserEntry *)src;
                user.userID = profileUserId;
                user.userAvatar = avatar == nil ? @"defaultAvatar" : avatar;
            }];
            // 添加到Cache中
            [avatarCache setValue:avatar == nil ? @"defaultAvatar": avatar forKey:profileUserId];
            
            // 显示头像
            if (avatar == nil) {
                [avatarImageView setImage:defaultAvatar];
            } else{
                [avatarImageView sd_setImageWithURL:[UrlBuilder buildAvatarURL:avatar] placeholderImage:defaultAvatar];
            }
        }];
    } else{
        if ([avatarInArray isEqualToString:@"defaultAvatar"]) {
            [avatarImageView setImage:defaultAvatar];
        } else{
            NSURL * url = [UrlBuilder buildAvatarURL:avatarInArray];
            [avatarImageView sd_setImageWithURL:url placeholderImage:defaultAvatar];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        CCFWritePMNavigationController * controller = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:@"CCFWritePMNavigationController"];
        TransValueBundle * bundle = [[TransValueBundle alloc] init];
        [bundle putStringValue:userProfile.profileName forKey:@"PROFILE_NAME"];
        
        self.transBundleDelegate = (id<TransBundleDelegate>)controller;
        
        [self.transBundleDelegate transBundle:bundle];
        
        [self.navigationController presentViewController:controller animated:YES completion:^{
            
        }];
    }
}



- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
