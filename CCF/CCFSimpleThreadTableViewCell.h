//
//  CCFSimpleThreadTableViewCell.h
//  CCF
//
//  Created by WDY on 16/3/17.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleThread.h"
#import "BaseCCFTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"

@interface CCFSimpleThreadTableViewCell : BaseCCFTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *threadAuthorName;
@property (weak, nonatomic) IBOutlet UILabel *lastPostTime;
@property (weak, nonatomic) IBOutlet UILabel *threadTitle;
@property (weak, nonatomic) IBOutlet UIImageView *ThreadAuthorAvatar;
@property (weak, nonatomic) IBOutlet UILabel *threadCategory;

@end
