//
//  CCFApiBaseViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/4/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFApiBaseViewController.h"

@interface CCFApiBaseViewController ()

@end

@implementation CCFApiBaseViewController

#pragma mark initData
- (void)initData {
    self.ccfApi = [[ForumApi alloc]init];
}

#pragma mark override-init
-(instancetype)init{
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

#pragma mark overide-initWithCoder
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initData];
    }
    return self;
}

#pragma mark overide-initWithName
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initData];
    }
    return self;
}


@end
