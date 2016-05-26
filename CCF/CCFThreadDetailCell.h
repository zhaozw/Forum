//
//  CCFThreadDetailCell.h
//  CCF
//
//  Created by 迪远 王 on 16/1/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DTCoreText/DTCoreText.h>

#import "Post.h"
#import "TransValueUITableViewCell.h"

@protocol CCFThreadDetailCellDelegate <NSObject>

@required
-(void) relayoutContentHeigt:(NSIndexPath*) indexPath with:(CGFloat) height;

@end



@interface CCFThreadDetailCell : TransValueUITableViewCell<DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate>



@property (weak, nonatomic) IBOutlet DTAttributedTextContentView *htmlView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *louCeng;
@property (weak, nonatomic) IBOutlet UILabel *postTime;

@property (nonatomic, strong) id<CCFThreadDetailCellDelegate> detailDelegate;

-(void) setPost:(Post *)post forIndexPath:(NSIndexPath*)indexPath;

@property (nonatomic, strong) NSURL *lastActionLink;

@property (nonatomic, strong) NSURL *baseURL;

- (IBAction)showUserProfile:(UIButton *)sender;

@end
