//
//  ForumTableViewController.m
//  DRL
//
//  Created by 迪远 王 on 16/5/21.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "SupportForumTableViewController.h"
#import "ForumThreadListTableViewController.h"
#import "ForumTabBarController.h"
#import "NSUserDefaults+Extensions.h"
#import "UIStoryboard+Forum.h"
#import "SupportForums.h"
#import "Forums.h"
#import "ForumLoginViewController.h"


@interface SupportForumTableViewController ()

@end

@implementation SupportForumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"supportForums" ofType:@"json"]];

    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

    SupportForums *supportForums = [SupportForums modelObjectWithDictionary:dictionary];


    [self.dataList removeAllObjects];

    [self.dataList addObjectsFromArray:supportForums.forums];

    [self.tableView reloadData];

}

- (BOOL)setPullRefresh:(BOOL)enable {
    return NO;
}

- (BOOL)setLoadMore:(BOOL)enable {
    return NO;
}

- (BOOL)autoPullfresh {
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"SupportForum"];


    Forums *forums = self.dataList[indexPath.row];

    cell.textLabel.text = forums.name;

    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0,16,0,16);
    [cell setSeparatorInset:edgeInsets];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowThreadList"]) {
        ForumThreadListTableViewController *controller = segue.destinationViewController;

        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        Forum *select = self.dataList[(NSUInteger) path.section];
        Forum *child = select.childForums[(NSUInteger) path.row];

        TransBundle * bundle = [[TransBundle alloc] init];
        [bundle putObjectValue:child forKey:@"TransForm"];
        [self transBundle:bundle forController:controller];

    }
}

- (BOOL)isUserHasLogin:(NSString*)host {
    // 判断是否登录
    ForumBrowser *browser = [ForumBrowser browserWithForumConfig:[ForumConfig configWithForumHost:host]];
    LoginUser *loginUser = [browser getLoginUser];
    
    NSDate *date = [NSDate date];
    return (loginUser.userID != nil && [loginUser.expireTime compare:date] != NSOrderedAscending);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Forums *forums = self.dataList[indexPath.row];
    
    NSURL * url = [NSURL URLWithString:forums.url];
    
    [[NSUserDefaults standardUserDefaults] saveCurrentForumURL:forums.url];
    
    if ([self isUserHasLogin:url.host]) {
        UIStoryboard *stortboard = [UIStoryboard mainStoryboard];
        [stortboard changeRootViewControllerTo:@"DRLTabBarController"];
        
    } else{
        UIStoryboard *stortboard = [UIStoryboard mainStoryboard];
        [stortboard changeRootViewControllerToController:[[ForumLoginViewController alloc] init]];
    }

}


- (IBAction)showLeftDrawer:(id)sender {
    ForumTabBarController *controller = (ForumTabBarController *) self.tabBarController;

    [controller showLeftDrawer];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end



