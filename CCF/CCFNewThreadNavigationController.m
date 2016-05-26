//
//  CCFNewThreadNavigationController.m
//  CCF
//
//  Created by 迪远 王 on 16/4/24.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFNewThreadNavigationController.h"

@interface CCFNewThreadNavigationController ()<TransBundleDelegate>

@end

@implementation CCFNewThreadNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)transBundle:(TransValueBundle *)bundle{
    self.bundle = bundle;
}
@end
