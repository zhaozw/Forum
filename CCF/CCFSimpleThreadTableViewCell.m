//
//  CCFSimpleThreadTableViewCell.m
//  CCF
//
//  Created by WDY on 16/3/17.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFSimpleThreadTableViewCell.h"

@implementation CCFSimpleThreadTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setData:(SimpleThread *)data{
    self.threadTitle.text = data.threadTitle;
    self.threadAuthorName.text = data.threadAuthorName;
    self.lastPostTime.text = data.lastPostTime;
    self.threadCategory.text = data.threadCategory;
    
    [self showAvatar:self.ThreadAuthorAvatar userId:data.threadAuthorID];
}
@end
