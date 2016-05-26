//
//  LeftDrawerView.m
//  iOSMaps
//
//  Created by WDY on 15/12/8.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import "DrawerView.h"

#define kEdge 5
#define kDefaultDrawerRatio 4/5
#define kMaxMaskAlpha 0.6f

#import "CCFNavigationController.h"
#import "UIStoryboard+CCF.h"
#import "CCFFavFormController.h"
#import "UrlBuilder.h"
#import "LoginUser.h"
#import "CCFPrivateMessageTableViewController.h"
#import "CCFMyThreadPostTableViewController.h"
#import "CCFMyThreadTableViewController.h"
#import "CCFShowNewThreadPostTableViewController.h"
#import "CCFFavThreadPostTableViewController.h"
#import "CCFMyProfileUITableViewController.h"
#import "LeftDrawerItem.h"
#import <UIImageView+WebCache.h>
#import "ForumCoreDataManager.h"
#import "UserEntry+CoreDataProperties.h"
#import "ForumApi.h"
#import "LoginUser.h"
#import "DRLTabBarController.h"
#import "DRLForumTableViewController.h"


@interface DrawerView(){
    
    UIButton *_drawerMaskView;
    
    ForumApi * _ccfapi;
    
    UIView *_rightEageView;
    
    UIImage *defaultAvatar;
    
    ForumCoreDataManager *coreDateManager;
}

@end


@implementation DrawerView

@synthesize leftDrawerView = _leftDrawerView;
@synthesize rightDrawerView = _rightDrawerView;


- (void)showUserAvatar {
    LoginUser * loginUser = [_ccfapi getLoginUser];
    // 设置登录名称
    NSString * userName = loginUser.userName;
    [self.userName setText:userName];
    
    coreDateManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeUser];
    NSArray *cacheUsers = [[coreDateManager selectData:^NSPredicate *{
        return [NSPredicate predicateWithFormat:@"userID = %@", loginUser.userID];
    }] copy];
    
    if (cacheUsers.count > 0) {
        UserEntry * entry = cacheUsers.firstObject;
        if ([entry.userAvatar isEqualToString:@"defaultAvatar"]) {
            [self getAvatar:loginUser];
        } else{
            NSURL * avatarUrl = [UrlBuilder buildAvatarURL:entry.userAvatar];
            NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:avatarUrl];
            if (cacheImageKey) {
                [self.avatarUIImageView sd_setImageWithURL:avatarUrl placeholderImage:defaultAvatar];
            }
        }
        
    } else{
        // 设置登录用户的头像
        [self getAvatar:loginUser];
    }
}

-(id)init{
    if (self = [super init]) {
        
        _ccfapi = [[ForumApi alloc] init];
        [self setDrawerType:DrawerViewTypeLeft];
        
        [self initLeftDrawerView];
        [self setUpLeftDrawer];
        
        [self initMaskView];
        
        defaultAvatar = [UIImage imageNamed:@"logo.jpg"];
        
        UIScreenEdgePanGestureRecognizer *leftEdgePanRecognizer = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(handleLeftEdgePan:)];
        leftEdgePanRecognizer.edges = UIRectEdgeLeft;
        
        [self addGestureRecognizer:leftEdgePanRecognizer];
        
        [self setLeftDrawerEnadbled:YES];
        
        [self showUserAvatar];
        
    }
    return self;
}

- (void)getAvatar:(LoginUser *)loginUser {
    // 设置登录用户的头像
    [_ccfapi getAvatarWithUserId:loginUser.userID handler:^(BOOL isSuccess, id avatar) {
        
        if (isSuccess) {
            // 存入数据库
            [coreDateManager insertOneData:^(id src) {
                UserEntry * user =(UserEntry *)src;
                user.userID = loginUser.userID;
                user.userAvatar = avatar == nil ? @"defaultAvatar" : avatar;
            }];
            
            // 显示头像
            if (avatar == nil) {
                [self.avatarUIImageView setImage:defaultAvatar];
            } else{
                NSURL * avatarUrl = [UrlBuilder buildAvatarURL:avatar];
                [self.avatarUIImageView sd_setImageWithURL:avatarUrl placeholderImage:defaultAvatar];
            }
        } else{
            [self.avatarUIImageView setImage:defaultAvatar];
        }
        
        
    }];
}

-(id)initWithDrawerType:(DrawerViewType)drawerType andXib:(NSString *)name{
    if (self = [super init]) {
        _ccfapi = [[ForumApi alloc] init];
        
        // 和 xib 绑定
        [[NSBundle mainBundle] loadNibNamed:name owner:self options:nil];
        
        [self setDrawerType:drawerType];
        
        
        switch (_drawerType) {
            case DrawerViewTypeLeft:{
                
                //_leftDrawerView = nibViews.firstObject;
                
                [self setUpLeftDrawer];
                
                [self setLeftDrawerEnadbled:YES];
                break;
            }
            case DrawerViewTypeRight:{
                
                //_rightDrawerView = nibViews.firstObject;
                [self setUpRightDrawer];
                [self setRightDrawerEnadbled:YES];
                break;
            }
            case DrawerViewTypeLeftAndRight:{
                
                //_leftDrawerView = nibViews.firstObject;
                [self setUpLeftDrawer];
                
                
                //_rightDrawerView = nibViews.lastObject;
                [self setUpRightDrawer];
                
                
                [self setLeftDrawerEnadbled:YES];
                [self setRightDrawerEnadbled: YES];
                break;
            }
        }
        
        [self initMaskView];
        
        [self showUserAvatar];
        
    }
    
    return self;
}

-(id)initWithDrawerType:(DrawerViewType)drawerType{
    
    if (self = [super init]) {
        
        _ccfapi = [[ForumApi alloc] init];
        
        [self setDrawerType:drawerType];
        
        switch (_drawerType) {
            case DrawerViewTypeLeft:{
                [self initLeftDrawerView];
                [self setUpLeftDrawer];
                
                [self setLeftDrawerEnadbled:YES];
                break;
            }
            case DrawerViewTypeRight:{
                
                [self initRightDrawerView];
                [self setUpRightDrawer];
                [self setRightDrawerEnadbled:YES];
                break;
            }
            case DrawerViewTypeLeftAndRight:{
                [self initLeftDrawerView];
                [self setUpLeftDrawer];
                
                
                [self initRightDrawerView];
                [self setUpRightDrawer];
                
                
                [self setLeftDrawerEnadbled:YES];
                [self setRightDrawerEnadbled: YES];
                break;
            }
                
            default:{
                
                [self initLeftDrawerView];
                [self setUpLeftDrawer];
                
                [self setLeftDrawerEnadbled:YES];
                break;
            }
        }
        
        [self initMaskView];
    }
    
    
    return self;
}

-(UIView *) findDrawerWithDrawerIndex:(DrawerIndex)type{
    return type == DrawerViewTypeLeft ? _leftDrawerView : _rightDrawerView;
}



-(void)didMoveToSuperview{
    
    UIView *rootView = [self superview];
    
    self.frame = CGRectMake(0, 0, kEdge, rootView.frame.size.height);
    
    NSLog(@"didMoveToSuperview %f", rootView.frame.size.width);
    
    
    _drawerMaskView.frame = CGRectMake(0, 0, rootView.frame.size.width, rootView.frame.size.height);
    
    [rootView addSubview:_drawerMaskView];
    
    
    
    if (_drawerType != DrawerViewTypeLeft) {
        _rightEageView = [[UIView alloc]init];
        _rightEageView.frame = CGRectMake(rootView.frame.size.width - kEdge, 0, kEdge, rootView.frame.size.height);
        // _rightEageView.backgroundColor = [UIColor redColor];
        
        [rootView addSubview:_rightEageView];
        
        UIScreenEdgePanGestureRecognizer *rightedgePab = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(handleRightEdgePan:)];
        rightedgePab.edges = UIRectEdgeRight;
        
        [_rightEageView addGestureRecognizer:rightedgePab];
    }
    
    
    CGFloat with = rootView.frame.size.width * kDefaultDrawerRatio;
    
    
    if (_drawerType != DrawerViewTypeRight) {
        // init Left Drawer
        _leftDrawerView.frame = CGRectMake(- with, 0, with, rootView.frame.size.height);
        [rootView addSubview:_leftDrawerView];
        
        if ([_delegate respondsToSelector:@selector(didDrawerMoveToSuperview:)]) {
            [_delegate didDrawerMoveToSuperview:DrawerIndexLeft];
        }
        
        
        UIScreenEdgePanGestureRecognizer *leftEdgePanRecognizer = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(handleLeftEdgePan:)];
        leftEdgePanRecognizer.edges = UIRectEdgeLeft;
        
        [self addGestureRecognizer:leftEdgePanRecognizer];
        
        NSArray *subViews = _leftDrawerView.subviews;
        
        int width = self.frame.size.width;
        
        for (UIView * view in subViews) {
            if ([view isKindOfClass:[LeftDrawerItem class]]) {
                CGRect childFrame = view.frame;
                childFrame.size.width = width;
                view.frame = childFrame;
                
            }
        }
        NSLog(@"左侧     %@", subViews);
    }
    
    if (_drawerType != DrawerViewTypeLeft) {
        // init right Drawer
        _rightDrawerView.frame = CGRectMake(rootView.frame.size.width, 0, with, rootView.frame.size.height);
        [rootView addSubview:_rightDrawerView];
        
        if ([_delegate respondsToSelector:@selector(didDrawerMoveToSuperview:)]) {
            [_delegate didDrawerMoveToSuperview:DrawerIndexRight];
        }
    }
    
    [rootView bringSubviewToFront:self];
    
}

-(void)openLeftDrawer{
    if (_leftDrawerView != nil && _leftDrawerEnadbled && !_leftDrawerOpened) {
        [self showLeftDrawerWithAdim:_leftDrawerView];
    }
}
-(void)closeLeftDrawer{
    if (_leftDrawerView != nil &&  _leftDrawerEnadbled && _leftDrawerOpened) {
        [self hideLeftDrawerWithAnim:_leftDrawerView];
    }
}

-(void)openRightDrawer{
    if (_rightDrawerView != nil && _rightDrawerEnadbled && !_rightDrawerOpened) {
        [self showRightDrawerWithAdim:_rightDrawerView];
    }
}
-(void)closeRightDrawer{
    if (_rightDrawerView != nil && _rightDrawerEnadbled && _rightDrawerOpened) {
        [self hideRightDrawerWithAnim:_rightDrawerView];
    }
}







// 切换Controller
- (IBAction)showMyFavForm:(id)sender {
    if ([self.window.rootViewController isKindOfClass:[CCFNavigationController class]]) {
        [self closeLeftDrawer];
        
        CCFNavigationController * controller = (CCFNavigationController*)self.window.rootViewController;
        UIStoryboard * storyboard = [UIStoryboard mainStoryboard];
        CCFFavFormController * favController = [storyboard instantiateViewControllerWithIdentifier:kCCFFavFormController];
        [controller setRootViewController:favController];
    }
    
}

- (IBAction)showMessage:(id)sender {
    if ([self.window.rootViewController isKindOfClass:[CCFNavigationController class]]) {
        [self closeLeftDrawer];
        
        CCFNavigationController * controller = (CCFNavigationController*)self.window.rootViewController;
        UIStoryboard * storyboard = [UIStoryboard mainStoryboard];
        
        CCFPrivateMessageTableViewController * privateMessageController = [storyboard instantiateViewControllerWithIdentifier:@"CCFPrivateMessageTableViewController"];
        
        [controller setRootViewController:privateMessageController];
    }
}

- (IBAction)showFavThread:(id)sender {
    if ([self.window.rootViewController isKindOfClass:[CCFNavigationController class]]) {
        [self closeLeftDrawer];
        
        CCFNavigationController * controller = (CCFNavigationController*)self.window.rootViewController;
        UIStoryboard * storyboard = [UIStoryboard mainStoryboard];
        
        CCFFavThreadPostTableViewController * favThreadController = [storyboard instantiateViewControllerWithIdentifier:@"CCFFavThreadPostTableViewController"];
        
        [controller setRootViewController:favThreadController];
    }
}

- (IBAction)showNewThread:(id)sender {
    if ([self.window.rootViewController isKindOfClass:[CCFNavigationController class]]) {
        [self closeLeftDrawer];
        
        CCFNavigationController * controller = (CCFNavigationController*)self.window.rootViewController;
        UIStoryboard * storyboard = [UIStoryboard mainStoryboard];
        
        CCFShowNewThreadPostTableViewController * showNewThreadController = [storyboard instantiateViewControllerWithIdentifier:@"CCFShowNewThreadPostTableViewController"];
        
        [controller setRootViewController:showNewThreadController];
    }
}

- (IBAction)showMyPost:(id)sender {
    if ([self.window.rootViewController isKindOfClass:[CCFNavigationController class]]) {
        [self closeLeftDrawer];
        
        CCFNavigationController * controller = (CCFNavigationController*)self.window.rootViewController;
        UIStoryboard * storyboard = [UIStoryboard mainStoryboard];
        
        CCFMyThreadPostTableViewController * myThreadPostController = [storyboard instantiateViewControllerWithIdentifier:@"CCFMyThreadPostTableViewController"];
        
        [controller setRootViewController:myThreadPostController];
    }
}

- (IBAction)showMyThread:(id)sender {
    if ([self.window.rootViewController isKindOfClass:[CCFNavigationController class]]) {
        [self closeLeftDrawer];
        
        CCFNavigationController * controller = (CCFNavigationController*)self.window.rootViewController;
        UIStoryboard * storyboard = [UIStoryboard mainStoryboard];
        
        CCFMyThreadTableViewController * myThreadController = [storyboard instantiateViewControllerWithIdentifier:@"CCFMyThreadTableViewController"];
        
        [controller setRootViewController:myThreadController];
    }
}

- (IBAction)showAllForms:(id)sender {
    
    if ([self.window.rootViewController isKindOfClass:[CCFNavigationController class]]) {
        [self closeLeftDrawer];
        
        CCFNavigationController * controller = (CCFNavigationController*)self.window.rootViewController;
        UIStoryboard * storyboard = [UIStoryboard mainStoryboard];
        DRLForumTableViewController * favController = [storyboard instantiateViewControllerWithIdentifier:@"DRLForumTableViewController"];
        [controller setRootViewController:favController];
    }
}

- (IBAction)showTodayNewThreadPost:(LeftDrawerItem *)sender {
    if ([self.window.rootViewController isKindOfClass:[CCFNavigationController class]]) {
        [self closeLeftDrawer];
        
        CCFNavigationController * controller = (CCFNavigationController*)self.window.rootViewController;
        UIStoryboard * storyboard = [UIStoryboard mainStoryboard];
        CCFShowNewThreadPostTableViewController * todayNewThreadPostController = [storyboard instantiateViewControllerWithIdentifier:@"CCFShowTodayNewThreadPostTableViewController"];
        [controller setRootViewController:todayNewThreadPostController];
    }
}

- (IBAction)showMyProfile:(id)sender {
    
    [self closeLeftDrawer];
    DRLTabBarController * controller = (DRLTabBarController*)self.window.rootViewController;
    
    
    UIStoryboard * storyboard = [UIStoryboard mainStoryboard];
    CCFNavigationController * myProfileControllder = [storyboard instantiateViewControllerWithIdentifier:@"CCFMyProfileNavigationController"];
    [controller presentViewController:myProfileControllder animated:YES completion:^{
        
    }];
    
    
    //    if ([self.window.rootViewController isKindOfClass:[CCFNavigationController class]]) {
    //        [self closeLeftDrawer];
    //
    //        CCFNavigationController * controller = (CCFNavigationController*)self.window.rootViewController;
    //        UIStoryboard * storyboard = [UIStoryboard mainStoryboard];
    //        CCFMyProfileUITableViewController * myProfileControllder = [storyboard instantiateViewControllerWithIdentifier:@"CCFMyProfileUITableViewController"];
    //        [controller setRootViewController:myProfileControllder];
    //    }
    
}
// 切换Controller结束





- (void) showRightDrawerWithAdim:(UIView *)view{
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect currentRect = view.frame;
        currentRect.origin.x = [view superview].frame.size.width - view.frame.size.width;
        
        view.frame = currentRect;
        _drawerMaskView.alpha =  kMaxMaskAlpha;
        
        view.layer.shadowOpacity = 0.5f;
    } completion:^(BOOL finished) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(rightDrawerDidOpened)]) {
            [_delegate rightDrawerDidOpened];
        }
        [self setRightDrawerOpened:YES];
    }];
    
}


-(void) hideRightDrawerWithAnim:(UIView *)view{
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect currentRect = view.frame;
        currentRect.origin.x = view.superview.frame.size.width;
        view.frame = currentRect;
        
        view.layer.shadowOpacity = 0.f;
        
        _drawerMaskView.alpha =  0.0f;
    } completion:^(BOOL finished) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(rightDrawerDidClosed)]) {
            [_delegate rightDrawerDidClosed];
        }
        [self setRightDrawerOpened:NO];
    }];
}



- (void) showLeftDrawerWithAdim:(UIView *)view{
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect currentRect = view.frame;
        currentRect.origin.x = 0;
        view.frame = currentRect;
        
        _drawerMaskView.alpha =  kMaxMaskAlpha;
        
        view.layer.shadowOpacity = 0.5f;
    } completion:^(BOOL finished) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(leftDrawerDidOpened)]) {
            [_delegate leftDrawerDidOpened];
        }
        [self setLeftDrawerOpened:YES];
    }];
    
}


-(void) hideLeftDrawerWithAnim:(UIView *)view{
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect currentRect = view.frame;
        currentRect.origin.x = -view.frame.size.width;
        view.frame = currentRect;
        
        view.layer.shadowOpacity = 0.f;
        
        _drawerMaskView.alpha =  0.0f;
    } completion:^(BOOL finished) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(leftDrawerDidOpened)]) {
            [_delegate leftDrawerDidClosed];
        }
        [self setLeftDrawerOpened:NO];
    }];
}

-(void)initRightDrawerView{
    _rightDrawerView = [[UIView alloc]init];
}

-(void) setUpRightDrawer{
    
    _rightDrawerView.backgroundColor = [UIColor whiteColor];
    
    _rightDrawerView.layer.shadowColor = [[UIColor blackColor]CGColor];
    // 阴影的透明度
    _rightDrawerView.layer.shadowOpacity = 0.f;
    //设置View Shadow的偏移量
    _rightDrawerView.layer.shadowOffset = CGSizeMake(-5.f, 0);
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handleRightPan:)];
    [_rightDrawerView addGestureRecognizer:panGestureRecognizer];
}


-(void)initLeftDrawerView{
    
    _leftDrawerView = [[UIView alloc]init];
}

-(void) setUpLeftDrawer{
    
    
    
    _leftDrawerView.backgroundColor = [UIColor whiteColor];
    
    _leftDrawerView.layer.shadowColor = [[UIColor blackColor]CGColor];
    // 阴影的透明度
    _leftDrawerView.layer.shadowOpacity = 0.f;
    //设置View Shadow的偏移量
    _leftDrawerView.layer.shadowOffset = CGSizeMake(5.f, 0);
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handleLeftPan:)];
    [_leftDrawerView addGestureRecognizer:panGestureRecognizer];
    
}

-(void) initMaskView{
    _drawerMaskView = [[UIButton alloc]init];
    _drawerMaskView.backgroundColor = [UIColor blackColor];
    _drawerMaskView.alpha = 0.0f;
    
    [_drawerMaskView addTarget:self action:@selector(handleMaskClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer *maskPan = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(handleMaskPan:)];
    [_drawerMaskView addGestureRecognizer:maskPan];
    
}

-(void) handleMaskClick{
    if(_leftDrawerView != nil && _leftDrawerOpened && _leftDrawerEnadbled){
        [self hideLeftDrawerWithAnim:_leftDrawerView];
    }
    
    if (_rightDrawerView != nil && _rightDrawerOpened && _rightDrawerEnadbled) {
        [self hideRightDrawerWithAnim:_rightDrawerView];
    }
}

-(void) handleLeftEdgePan:(UIScreenEdgePanGestureRecognizer *) recognizer{
    if (![self leftDrawerEnadbled]) {
        return;
    }
    
    if ([self rightDrawerOpened]) {
        [self hideRightDrawerWithAnim:_rightDrawerView];
    }
    
    
    [self handleLeftPan:recognizer];
}

-(void)handleRightEdgePan:(UIScreenEdgePanGestureRecognizer *)recognizer{
    if (![self rightDrawerEnadbled]) {
        return;
    }
    
    if ([self leftDrawerOpened]) {
        [self hideLeftDrawerWithAnim:_leftDrawerView];
    }
    
    [self handleRightPan:recognizer];
}


- (void) handleLeftPan:(UIPanGestureRecognizer*) recognizer{
    
    if (![self leftDrawerEnadbled]) {
        return;
    }
    
    [self dragLeftDrawer:recognizer :^CGFloat(CGFloat x, CGFloat maxX) {
        return x > maxX ? maxX : x;
    }];
}

- (void) handleRightPan:(UIPanGestureRecognizer*) recognizer{
    
    if (![self rightDrawerEnadbled]) {
        return;
    }
    
    [self dragRightDrawer:recognizer :^CGFloat(CGFloat x, CGFloat maxX) {
        return x < maxX ? maxX : x;
    }];
}

- (void) handleMaskPan:(UIPanGestureRecognizer*) recognizer{
    
    if (_leftDrawerOpened) {
        
        [self dragLeftDrawer:recognizer :^CGFloat(CGFloat x, CGFloat maxX) {
            return  x < maxX ? x : maxX;
        }];
    }
    
    if (_rightDrawerOpened) {
        [self dragRightDrawer:recognizer :^CGFloat(CGFloat x, CGFloat maxX) {
            return x < maxX ? maxX : x;
        }];
    }
    
    
}

-(void) showOrHideLeftAfterPan: (UIPanGestureRecognizer*) recognizer :(UIView *)view{
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self];
        
        NSLog(@"Touch ===   %f", velocity.x);
        
        if (velocity.x > 0) {
            [self showLeftDrawerWithAdim: view];
        } else{
            [self hideLeftDrawerWithAnim:view];
        }
    }
}

-(void) showOrHideRightAfterPan: (UIPanGestureRecognizer*) recognizer :(UIView *)view{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self];
        
        NSLog(@"Touch ===   %f", velocity.x);
        
        if (velocity.x > 0) {
            [self hideRightDrawerWithAnim: view];
        } else{
            [self showRightDrawerWithAdim: view];
        }
    }
}

-(void) dragRightDrawer:(UIPanGestureRecognizer *)recognizer :(TouchX) block{
    UIView * panView = [recognizer.view superview];
    
    CGPoint translation = [recognizer translationInView:panView];
    
    CGPoint currentCenter = _rightDrawerView.center;
    
    
    CGFloat x = currentCenter.x + translation.x;
    
    CGFloat maxX = panView.frame.size.width - _rightDrawerView.frame.size.width / 2 ;
    
    
    currentCenter.x = block(x, maxX);
    
    NSLog(@"dragRightDrawer %f             %f " , currentCenter.x, translation.x);
    
    _rightDrawerView.center = currentCenter;
    
    
    
    if (translation.x < 0 ) {
        _rightDrawerView.layer.shadowOpacity = 0.5f;
    }
    
    _drawerMaskView.alpha = (panView.frame.size.width - _rightDrawerView.center.x ) / (_rightDrawerView.frame.size.width / 2) * kMaxMaskAlpha;
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:panView];
    
    [self showOrHideRightAfterPan:recognizer :_rightDrawerView];
}

-(void) dragLeftDrawer:( UIPanGestureRecognizer *)recognizer : (TouchX) block{
    
    UIView * panView = [recognizer.view superview];
    
    CGPoint translation = [recognizer translationInView:panView];
    
    
    CGPoint currentCenter = _leftDrawerView.center;
    
    
    //NSLog(@"dragLeftDrawer %f             %f " , currentCenter.x, translation.x);
    
    
    CGFloat x = currentCenter.x + translation.x;
    
    CGFloat maxX = _leftDrawerView.frame.size.width / 2;
    
    //currentCenter.x = x < maxX ? x : maxX;
    currentCenter.x = block(x, maxX);
    
    _leftDrawerView.center = currentCenter;
    
    if (translation.x > 0 ) {
        _leftDrawerView.layer.shadowOpacity = 0.5f;
    }
    
    _drawerMaskView.alpha = (_leftDrawerView.center.x + maxX ) / (maxX * 2) * kMaxMaskAlpha;
    
    [recognizer setTranslation:CGPointZero inView:panView];
    
    [self showOrHideLeftAfterPan:recognizer :_leftDrawerView];
    
}


@end
