//
//  CCFSearchResultCell.h
//  CCF
//
//  Created by WDY on 16/1/11.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThreadInSearch.h"
#import "UICircleImageView.h"
#import "BaseCCFTableViewCell.h"


@interface CCFSearchResultCell : BaseCCFTableViewCell


@property (weak, nonatomic) IBOutlet UILabel *postTitle;
@property (weak, nonatomic) IBOutlet UILabel *postAuthor;
@property (weak, nonatomic) IBOutlet UILabel *postTime;
@property (weak, nonatomic) IBOutlet UILabel *postBelongForm;
@property (weak, nonatomic) IBOutlet UICircleImageView *postAuthorAvatar;
@property (weak, nonatomic) IBOutlet UILabel *postCategory;

-(void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath;

- (IBAction)showUserProfile:(UIButton *)sender;

@end
