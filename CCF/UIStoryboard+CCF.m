//
//  UIStoryboard+CCF.m
//  CCF
//
//  Created by WDY on 16/1/12.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "UIStoryboard+CCF.h"

#import "AppDelegate.h"


#define kCCFStoryboard @"Main"



@implementation UIStoryboard(CCF)

+(UIStoryboard *)mainStoryboard{
    return [UIStoryboard storyboardWithName:kCCFStoryboard bundle:nil];
}


-(void)changeRootViewControllerTo:(NSString *)identifier{
    
    UITabBarController *rootViewController = [self instantiateViewControllerWithIdentifier:identifier];
    
    [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
    
     AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    [UIView transitionWithView:app.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromTop
                    animations:^{
                        app.window.rootViewController = rootViewController;
                    }
                    completion:nil];
}

-(void)changeRootViewControllerToController:(UIViewController *)controller{
    
    [[UIApplication sharedApplication].keyWindow setRootViewController:controller];
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    [UIView transitionWithView:app.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromTop
                    animations:^{
                        app.window.rootViewController = controller;
                    }
                    completion:nil];
}



@end
