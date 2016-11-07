//
//  ForumFavFormController.m
//  CCF
//
//  Created by 迪远 王 on 16/1/10.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumFavFormController.h"
#import "ForumCoreDataManager.h"
#import "NSUserDefaults+Extensions.h"
#import "UIStoryboard+CCF.h"
#import "ForumThreadListTableViewController.h"
#import "ForumTabBarController.h"
#import "MGSwipeTableCellWithIndexPath.h"
#import "UIViewController+TransBundle.h"

@interface ForumFavFormController () <MGSwipeTableCellDelegate> {

}

@end

@implementation ForumFavFormController

- (BOOL)setPullRefresh:(BOOL)enable {
    return YES;
}

- (BOOL)setLoadMore:(BOOL)enable {
    return NO;
}

- (BOOL)autoPullfresh {
    return NO;
}


- (void)onPullRefresh {

    [self.ccfApi listFavoriteForms:^(BOOL isSuccess, NSMutableArray<Forum *> *message) {


        [self.tableView.mj_header endRefreshing];

        if (isSuccess) {
            self.dataList = message;
            [self.tableView reloadData];
        }

    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];

    if (userDef.favFormIds == nil) {
        [self.ccfApi listFavoriteForms:^(BOOL isSuccess, NSMutableArray<Forum *> *message) {
            self.dataList = message;
            [self.tableView reloadData];
        }];
    } else {
        ForumCoreDataManager *manager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
        NSArray *forms = [[manager selectFavForms:userDef.favFormIds] mutableCopy];

        [self.dataList addObjectsFromArray:forms];

        [self.tableView reloadData];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowThreadListFormFavForumList"]) {
        ForumThreadListTableViewController *controller = segue.destinationViewController;
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        Forum *select = self.dataList[(NSUInteger) path.row];
        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putObjectValue:select forKey:@"TransForm"];
        [self transBundle:bundle forController:controller];
    }

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"CCFFavFormControllerCell";
    MGSwipeTableCellWithIndexPath *cell = [tableView dequeueReusableCellWithIdentifier:ID];

    cell.indexPath = indexPath;
    cell.delegate = self;
    //configure right buttons
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"取消订阅" backgroundColor:[UIColor lightGrayColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;


    Forum *form = self.dataList[(NSUInteger) indexPath.row];

    cell.textLabel.text = form.formName;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 54;
}

- (BOOL)swipeTableCell:(MGSwipeTableCellWithIndexPath *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {


    Forum *parent = self.dataList[(NSUInteger) cell.indexPath.row];

    [self.ccfApi unfavoriteFormsWithId:[NSString stringWithFormat:@"%d", parent.formId] handler:^(BOOL isSuccess, id message) {

    }];

    [self.dataList removeObjectAtIndex:(NSUInteger) cell.indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationLeft];

    return YES;
}


- (IBAction)showLeftDrawer:(id)sender {
    ForumTabBarController *controller = (ForumTabBarController *) self.tabBarController;


    UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
    UINavigationController *myProfileControllder = [storyboard instantiateViewControllerWithIdentifier:@"CCFMyProfileNavigationController"];
    [controller presentViewController:myProfileControllder animated:YES completion:^{

    }];
}
@end
