//
//  CCFSearchResultCell.m
//  CCF
//
//  Created by WDY on 16/1/11.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFSearchResultCell.h"
#import "ThreadInSearch.h"


@implementation CCFSearchResultCell{
    NSIndexPath * selectIndexPath;
}


-(void)setData:(ThreadInSearch*)data{
    
    
    NSString * title = [NSString stringWithFormat:@"[%@]%@", data.threadCategory, data.threadTitle];
    
    self.postTitle.text = title;
    self.postAuthor.text = data.threadAuthorName;
    self.postTime.text = data.lastPostTime;
    self.postBelongForm.text = data.fromFormName;
    self.postCategory.text = data.threadCategory;
    
    [self showAvatar:self.postAuthorAvatar userId:data.threadAuthorID];
}

-(void)showAvatar:(UIImageView *)avatarImageView userId:(NSString *)userId{
    [super showAvatar:avatarImageView userId:userId];
    [self circle:avatarImageView];
    
}

-(void)circle:(UIImageView *) view{
    //开始对imageView进行画图
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 1.0);
    //使用贝塞尔曲线画出一个圆形图
    [[UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:view.frame.size.width] addClip];
    [view drawRect:view.bounds];
    
    view.image = UIGraphicsGetImageFromCurrentImageContext();
    //结束画图
    UIGraphicsEndImageContext();
}


-(void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath{
    selectIndexPath = indexPath;
    [self setData:data];
}

- (IBAction)showUserProfile:(UIButton *)sender {
    [self.showUserProfileDelegate showUserProfile:selectIndexPath];
}

@end
