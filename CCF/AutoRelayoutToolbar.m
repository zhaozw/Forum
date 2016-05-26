//
//  CCFToolbar.m
//  CCF
//
//  Created by 迪远 王 on 16/1/8.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "AutoRelayoutToolbar.h"

@implementation AutoRelayoutToolbar{
    CGRect screenSize;
}


-(void)didMoveToSuperview{
    screenSize = [UIScreen mainScreen].bounds;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(id)sender {
    
    CGRect keyboardFrame;
    //    UIKeyboardBoundsUserInfoKey
    [[[((NSNotification *)sender) userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
//    int keyboardHeight = CGRectGetHeight(keyboardFrame);
    
    
    //CGSize keyboardSize = CGSizeMake(CGRectGetWidth(screenSize), keyboardHeight);
    
    [UIView beginAnimations:nil context:NULL];
    // 设置动画
    [UIView setAnimationDuration:0.3];
    // 将toolBar的位置放到键盘上方
    CGRect frame = self.frame;
    float screenHeight = CGRectGetHeight(screenSize);
    float toolbarHeight = CGRectGetHeight(self.frame);
    float keyboardHeight = CGRectGetHeight(keyboardFrame);
    frame.origin.y = screenHeight - toolbarHeight - 64 - keyboardHeight;
    self.frame = frame;
    
    [UIView commitAnimations];
    
}

-(void)keyboardWillHide:(id)sender{
    CGRect keyboardFrame;
    
    [[[((NSNotification *)sender) userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];

    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect frame = self.frame;
    float screenHeight = CGRectGetHeight(screenSize);
    float toolbarHeight = CGRectGetHeight(self.frame);
    frame.origin.y = screenHeight - toolbarHeight - 64;
    
    self.frame = frame;

    
    [UIView commitAnimations];

}


@end
