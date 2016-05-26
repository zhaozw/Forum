//
//  BaseCCFTableViewCell.m
//  CCF
//
//  Created by 迪远 王 on 16/3/19.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "BaseCCFTableViewCell.h"
#import <UIImageView+WebCache.h>

@implementation BaseCCFTableViewCell{
    UIImage * defaultAvatar;
    
    ForumCoreDataManager *coreDateManager;
    ForumApi * ccfapi;
    
    NSMutableDictionary * avatarCache;
    
    NSMutableArray<UserEntry*> * cacheUsers;
}

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
    defaultAvatar = [UIImage imageNamed:@"logo.jpg"];
    
    ccfapi = [[ForumApi alloc] init];
    
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




-(void)setData:(id)data{
    
}

-(void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)showAvatar:(UIImageView *)avatarImageView userId:(NSString*)userId{
    
    // 不知道什么原因，userID可能是nil
    if (userId == nil) {
        [avatarImageView setImage:defaultAvatar];
        return;
    }
    NSString * avatarInArray = [avatarCache valueForKey:userId];
    
    NSLog( @"showAvatar incache -> %@", avatarInArray);
    
    if (avatarInArray == nil) {
        
        [ccfapi getAvatarWithUserId:userId handler:^(BOOL isSuccess, NSString *avatar) {
            
            if (isSuccess) {
                // 存入数据库
                [coreDateManager insertOneData:^(id src) {
                    UserEntry * user =(UserEntry *)src;
                    user.userID = userId;
                    user.userAvatar = avatar == nil ? @"defaultAvatar" : avatar;
                }];
                // 添加到Cache中
                [avatarCache setValue:avatar == nil ? @"defaultAvatar": avatar forKey:userId];
                
                // 显示头像
                if (avatar == nil) {
                    [avatarImageView setImage:defaultAvatar];
                } else{
                    NSURL * avatarUrl = [UrlBuilder buildAvatarURL:avatar];
                    [avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:defaultAvatar];
                }
            } else{
                [avatarImageView setImage:defaultAvatar];
            }

        }];
    } else{
        
        NSLog( @"showAvatar %@", avatarInArray);
        if ([avatarInArray isEqualToString:@"defaultAvatar"]) {
            [avatarImageView setImage:defaultAvatar];
        } else{
            
            NSURL * avatarUrl = [UrlBuilder buildAvatarURL:avatarInArray];
            
            NSLog( @"showAvatar abs -> %@", [avatarUrl absoluteString]);
            
            if (/* DISABLES CODE */ (NO)) {
                NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:avatarUrl];
                NSString *cacheImagePath = [[SDImageCache sharedImageCache] defaultCachePathForKey:cacheImageKey];
                NSLog(@"cache_image_path %@", cacheImagePath);
            }


            [avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:defaultAvatar];
        }
    }
}
@end
