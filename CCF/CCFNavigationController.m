//
//  CCFNavigationController.m
//  CCF
//
//  Created by WDY on 16/1/12.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFNavigationController.h"
#import "DrawerView.h"

@interface CCFNavigationController (){
    DrawerView * _leftDrawerView;
}

@end

@implementation CCFNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _leftDrawerView = [[DrawerView alloc] initWithDrawerType:DrawerViewTypeLeft andXib:@"DrawerView"];
    [self.view addSubview:_leftDrawerView];
    
}



-(void)setRootViewController:(UIViewController *)rootViewController {
    //rootViewController.navigationItem.hidesBackButton = YES;
    [self popToRootViewControllerAnimated:NO];
//    [self popToViewController:fakeRootViewController animated:NO];
    [self pushViewController:rootViewController animated:NO];
}

-(void)showLeftDrawer{
    [_leftDrawerView openLeftDrawer];
}

-(BOOL)shouldAutorotate{
    return NO;
}

@end
