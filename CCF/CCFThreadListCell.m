//
//  CCFThreadListCell.m
//  CCF
//
//  Created by 迪远 王 on 16/1/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFThreadListCell.h"
#import "NormalThread.h"
#import "UrlBuilder.h"
#import "NSString+Extensions.h"
#import <UIImageView+AFNetworking.h>
#import "ForumCoreDataManager.h"
#import "UserEntry+CoreDataProperties.h"
#import "ForumApi.h"

@implementation CCFThreadListCell{

    ForumCoreDataManager *_coreDateManager;
    ForumApi * ccfapi;
    NSIndexPath * selectIndexPath;
}

@synthesize threadAuthor = _threadAuthor;
@synthesize threadPostCount = _threadPostCount;
@synthesize threadTitle = _threadTitle;
@synthesize threadCreateTime = _threadCreateTime;
@synthesize threadType = _threadType;
@synthesize avatarImage = _avatarImage;

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {

        ccfapi = [[ForumApi alloc] init];
        _coreDateManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeUser];
        
        [self.avatarImage setContentScaleFactor:[[UIScreen mainScreen] scale]];
        self.avatarImage.contentMode =  UIViewContentModeScaleAspectFit;
        self.avatarImage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.avatarImage.clipsToBounds  = YES;

    }
    return self;
}

-(void)setData:(NormalThread *)data{
    self.threadAuthor.text = data.threadAuthorName;
    
    self.threadType.text = data.threadCategory;
    self.threadPostCount.text = data.postCount;
    self.threadOpenCount.text = data.openCount;
    self.threadCreateTime.text = data.lastPostTime;
    
    self.threadTopFlag.hidden = !data.isTopThread;

    
    self.threadContainsImage.hidden = !data.isContainsImage;
    
    if (data.isGoodNess) {
        NSString * goodNessTitle = [@"[精]" stringByAppendingString:data.threadTitle];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:goodNessTitle];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 3)];
        
        self.threadTitle.attributedText = attrStr;
    } else{
        self.threadTitle.text = data.threadTitle;
    }
    [self showAvatar:self.avatarImage userId:data.threadAuthorID];
}

-(void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath{
    selectIndexPath = indexPath;
    [self setData:data];
}

- (IBAction)showUserProfile:(UIButton *)sender {
    [self.showUserProfileDelegate showUserProfile:selectIndexPath];
}
@end
