//
//  MyProfileTableViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/10/9.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "MyProfileTableViewController.h"
#import <UIImageView+WebCache.h>
#import "ForumConfig.h"
#import "ForumCoreDataManager.h"
#import "UserEntry+CoreDataProperties.h"


@interface MyProfileTableViewController (){
    UserProfile * userProfile;
    
    UIImage * defaultAvatarImage;
    
    ForumCoreDataManager *coreDateManager;
    
    NSMutableDictionary * avatarCache;
    
    NSMutableArray<UserEntry*> * cacheUsers;
}

@end

@implementation MyProfileTableViewController

-(instancetype)init{
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initData];
    }
    return self;
}

-(void) initData{
    
    defaultAvatarImage = [UIImage imageNamed:@"logo.jpg"];
    
    avatarCache = [NSMutableDictionary dictionary];
    
    
    coreDateManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeUser];
    if (cacheUsers == nil) {
        cacheUsers = [[coreDateManager selectData:^NSPredicate *{
            return [NSPredicate predicateWithFormat:@"userID > %d", 0];
        }] copy];
    }
    
    for (UserEntry * user in cacheUsers) {
        [avatarCache setValue:user.userAvatar forKey:user.userID];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

-(BOOL)setLoadMore:(BOOL)enable{
    return NO;
}


-(void)onPullRefresh{
    CCFForumApi * api = self.ccfApi;
    
    NSString * currentUserId = api.getLoginUser.userID;
    
    [self.ccfApi showProfileWithUserId:currentUserId handler:^(BOOL isSuccess, UserProfile* message) {
        userProfile = message;
        
        [self.tableView.mj_header endRefreshing];
        
        [self showAvatar:_prifileAvatar userId:userProfile.profileUserId];
    }];
}

-(void)showAvatar:(UIImageView *)avatarImageView userId:(NSString*)userId{
    
    // 不知道什么原因，userID可能是nil
    if (userId == nil) {
        [avatarImageView setImage:defaultAvatarImage];
        return;
    }
    NSString * avatarInArray = [avatarCache valueForKey:userId];
    
    NSLog( @"showAvatar incache -> %@", avatarInArray);
    
    if (avatarInArray == nil) {
        
        [self.ccfApi getAvatarWithUserId:userId handler:^(BOOL isSuccess, NSString *avatar) {
            
            if (isSuccess) {
                // 存入数据库
                [coreDateManager insertOneData:^(id src) {
                    UserEntry * user =(UserEntry *)src;
                    user.userID = userId;
                    user.userAvatar = avatar;
                }];
                // 添加到Cache中
                [avatarCache setValue:avatar forKey:userId];
                
                // 显示头像
                if (avatar == nil) {
                    [avatarImageView setImage:defaultAvatarImage];
                } else{
                    NSURL * avatarUrl = [NSURL URLWithString:avatar];
                    [avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:defaultAvatarImage];
                }
            } else{
                [avatarImageView setImage:defaultAvatarImage];
            }
            
        }];
    } else{
        
        NSLog( @"showAvatar %@", avatarInArray);
        
        if ([avatarInArray isEqualToString:NO_AVATAR_URL]) {
            [avatarImageView setImage:defaultAvatarImage];
        } else{
            
            NSURL * avatarUrl = [NSURL URLWithString:avatarInArray];
            
            if (/* DISABLES CODE */ (NO)) {
                NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:avatarUrl];
                NSString *cacheImagePath = [[SDImageCache sharedImageCache] defaultCachePathForKey:cacheImageKey];
                NSLog(@"cache_image_path %@", cacheImagePath);
            }
            
            [avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:defaultAvatarImage];
        }
    }
    
}

@end
