//
//  ViewMessagePage.h
//
//  Created by 迪远 王 on 16/3/25.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface ViewMessagePage : NSObject

@property(nonatomic, strong) User *pmUserInfo;
@property(nonatomic, strong) NSString *pmID;
@property(nonatomic, strong) NSString *pmTitle;
@property(nonatomic, strong) NSString *pmTime;
@property(nonatomic, strong) NSString *pmContent;

@end
