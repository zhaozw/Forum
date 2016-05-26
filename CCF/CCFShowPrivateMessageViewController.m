//
//  CCFShowPrivateMessageViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/3/25.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFShowPrivateMessageViewController.h"

#import "CCFThreadDetailCell.h"
#import "UrlBuilder.h"
#import "CCFParser.h"

#import "MJRefresh.h"
#import "AutoRelayoutUITextView.h"

#import "ShowThreadPage.h"
#import "SVProgressHUD.h"

#import <UITableView+FDTemplateLayoutCell.h>
#import "ShowPrivateMessage.h"
#import "CCFShowPMTableViewCell.h"
#import "PrivateMessage.h"
#import "CCFProfileTableViewController.h"



#import "ForumApi.h"

@interface CCFShowPrivateMessageViewController ()< UITextViewDelegate, AutoRelayoutUITextViewDelegate, CCFThreadDetailCellDelegate, TransValueDelegate, CCFThreadListCellDelegate>{
    NSMutableDictionary<NSIndexPath *, NSNumber *> *cellHeightDictionary;

    PrivateMessage * transPrivateMessage;

    AutoRelayoutUITextView * field;
    ForumApi *_api;
    
    UIStoryboardSegue * selectSegue;
}

@end

@implementation CCFShowPrivateMessageViewController


-(void)transValue:(PrivateMessage *)value{
    transPrivateMessage = value;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataList = [NSMutableArray array];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    field = [[AutoRelayoutUITextView alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    field.heightDelegate = self;
    field.delegate = self;
    
    [_floatToolbar sizeToFit];
    
    
    
    NSArray<UIBarButtonItem*> * items  = _floatToolbar.items;
    
    for (UIBarButtonItem * item in items) {
        if (item.customView != nil) {
            item.customView = field;
        }
        
        UIEdgeInsets insets = item.imageInsets;
        insets.bottom = - CGRectGetHeight(_floatToolbar.frame) + 44;
        item.imageInsets = insets;
        
        
    }
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    CGRect frame = _floatToolbar.frame;
    frame.origin.y = screenSize.size.height - 44;
    _floatToolbar.frame = frame;
    
    
    [self.view addSubview:_floatToolbar];
    
    _api = [[ForumApi alloc] init];
    
    cellHeightDictionary = [NSMutableDictionary<NSIndexPath *, NSNumber *> dictionary];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        
        [_api showPrivateContentById:[transPrivateMessage.pmID intValue] handler:^(BOOL isSuccess, ShowPrivateMessage* message) {
            [self.tableView.mj_header endRefreshing];
            
            if (isSuccess) {
                [self.dataList removeAllObjects];
                [self.dataList addObject:message];
                [self.tableView reloadData];
            }
        }];
    }];

    
    [self.tableView.mj_header beginRefreshing];
    
}


-(void)textViewDidChange:(UITextView *)textView{
    
    [field showPlaceHolder:[textView.text isEqualToString:@""]];
}



-(void)heightChanged:(CGFloat)height{
    
    CGRect rect = _floatToolbar.frame;
    CGFloat addHeight = height - rect.size.height;
    
    rect.size.height = height + 14;
    rect.origin.y = rect.origin.y - addHeight - 14;
    
    _floatToolbar.frame = rect;
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *QuoteCellIdentifier = @"CCFShowPMTableViewCell";
    
    CCFShowPMTableViewCell *cell = (CCFShowPMTableViewCell*)[tableView dequeueReusableCellWithIdentifier:QuoteCellIdentifier];
    cell.delegate = self;
    cell.showProfileDelegate = self;
    
    ShowPrivateMessage *privateMessage = self.dataList[indexPath.row];
    
    [cell setData:privateMessage forIndexPath:indexPath];
    
    return cell;
}

-(void)relayoutContentHeigt:(NSIndexPath *)indexPath with:(CGFloat)height{
    NSNumber * nsheight = [cellHeightDictionary objectForKey:indexPath];
    if (nsheight == nil) {
        [cellHeightDictionary setObject:[NSNumber numberWithFloat:height] forKey:indexPath];
        //        [self.tableView reloadData];
        NSIndexPath *indexPathReload=[NSIndexPath indexPathForRow:indexPath.row inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPathReload,nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber * nsheight = [cellHeightDictionary objectForKey:indexPath];
    if (nsheight == nil) {
        return  115.0;
    }
    return nsheight.floatValue;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return [tableView fd_heightForCellWithIdentifier:@"CCFShowPMTableViewCell" configuration:^(CCFShowPMTableViewCell *cell) {
//        CCFShowPM *privateMessage = self.dataList[indexPath.row];
//        
//        [cell setData:privateMessage forIndexPath:indexPath];
//    }];
//}

-(void)showUserProfile:(NSIndexPath *)indexPath{
    CCFProfileTableViewController * controller = (CCFProfileTableViewController *)selectSegue.destinationViewController;
    self.transValueDelegate = (id<TransValueDelegate>)controller;
    
    ShowPrivateMessage * message = self.dataList[indexPath.row];
    
    [self.transValueDelegate transValue:message];
}

#pragma mark Controller跳转
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"ShowUserProfile"]){
        selectSegue = segue;
    }
}

- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)floatReplyClick:(id)sender {
    
    [field resignFirstResponder];
    
    
    [SVProgressHUD showWithStatus:@"正在回复" maskType:SVProgressHUDMaskTypeBlack];
    
    [_api replyPrivateMessageWithId:[transPrivateMessage.pmID intValue]  andMessage:field.text handler:^(BOOL isSuccess, id message) {
        
        [SVProgressHUD dismiss];
         
         if (isSuccess) {
            
            field.text = @"";

             [SVProgressHUD showSuccessWithStatus:@"发送成功" maskType:SVProgressHUDMaskTypeBlack];
            
            
        } else{
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"发送失败" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
        }
    }];
    
}


@end
