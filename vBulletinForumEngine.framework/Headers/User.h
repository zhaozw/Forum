//
//  CCFUser.h
//  CCF
//
//  Created by WDY on 15/12/29.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) NSString* userID;
@property (nonatomic, strong) NSString* userAvatar;
@property (nonatomic, strong) NSString* userRank;
@property (nonatomic, strong) NSString* userLink;
@property (nonatomic, strong) NSString* userSignDate;
@property (nonatomic, strong) NSString* userPostCount;
@property (nonatomic, strong) NSString* userSolveCount;

@end
