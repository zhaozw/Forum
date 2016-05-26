//
//  DRLForumTableViewController.m
//  DRL
//
//  Created by 迪远 王 on 16/5/21.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "DRLForumTableViewController.h"
#import "ForumCoreDataManager.h"
#import "CCFThreadListTableViewController.h"
#import "ForumListHeaderView.h"
#import "XibInflater.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeTableCellWithIndexPath.h"
#import "DRLTabBarController.h"

@interface DRLForumTableViewController ()<MGSwipeTableCellDelegate>

@end

@implementation DRLForumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ForumCoreDataManager * formManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
    
    self.dataList = [[formManager selectAllForms] copy];
    
    [self.tableView reloadData];
    
}

-(BOOL)setPullRefresh:(BOOL)enable{
    return NO;
}

-(BOOL)setLoadMore:(BOOL)enable{
    return NO;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    ForumListHeaderView *headerView = [XibInflater inflateViewByXibName:@"ForumListHeaderView"];
    Forum * parent = self.dataList[section];
    headerView.textLabel.text = parent.formName;
    return headerView;
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    Forum * forum = self.dataList[section];
    return forum.childForms.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MGSwipeTableCellWithIndexPath *cell = (MGSwipeTableCellWithIndexPath*)[tableView dequeueReusableCellWithIdentifier:@"DRLForumCell"];
    
    cell.indexPath = indexPath;
    cell.delegate = self;
    //configure right buttons
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"订阅此论坛" backgroundColor:[UIColor lightGrayColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
    
    
    
    
    Forum * parent = self.dataList[indexPath.section];
    Forum * child = parent.childForms[indexPath.row];
                     
    cell.textLabel.text = child.formName;
    return cell;
}

-(BOOL)swipeTableCell:(MGSwipeTableCellWithIndexPath *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion{
    
    Forum * parent = self.dataList[cell.indexPath.section];
    Forum * child = parent.childForms[cell.indexPath.row];
    
    [self.ccfApi favoriteFormsWithId:[NSString stringWithFormat:@"%d",child.formId] handler:^(BOOL isSuccess, id message) {
        NSLog(@">>>>>>>>>>>> %@", message);
    }];
    
    return YES;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowThreadList"]) {
        CCFThreadListTableViewController * controller = segue.destinationViewController;
        
        self.transValueDelegate = (id<TransValueDelegate>)controller;
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        
        
        Forum * select = self.dataList[path.section];
        Forum * child = select.childForms[path.row];
        
        [self.transValueDelegate transValue:child];
    }
    
}

- (IBAction)showLeftDrawer:(id)sender {
    DRLTabBarController * root = (DRLTabBarController *)self.tabBarController;
    [root showLeftDrawer];
}
@end
