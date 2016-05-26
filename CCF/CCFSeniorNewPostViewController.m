//
//  CCFSeniorNewPostViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/1/16.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFSeniorNewPostViewController.h"

#import "SelectPhotoCollectionViewCell.h"
#import "TransValueDelegate.h"
#import "Thread.h"
#import "Post.h"
#import "TransValueBundle.h"
#import <SVProgressHUD.h>
#import "ShowThreadPage.h"
#import "LCActionSheet.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CCFSimpleReplyNavigationController.h"
#import "Utils.h"

@interface CCFSeniorNewPostViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DeleteDelegate>{
    
    UIImagePickerController *pickControl;
    NSMutableArray<UIImage*> *images;
    TransValueBundle * bundle;
}

@end

@implementation CCFSeniorNewPostViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 传递数据
    CCFSimpleReplyNavigationController * controller = (CCFSimpleReplyNavigationController*)self.navigationController;
    bundle = controller.bundle;
    
    
    
    _insertCollectionView.delegate = self;
    _insertCollectionView.dataSource = self;

    //实例化照片选择控制器
    pickControl=[[UIImagePickerController alloc]init];

    //设置协议
    pickControl.delegate = self;
    //设置编辑
    [pickControl setAllowsEditing:NO];
    //选完图片之后回到的视图界面
    
    images = [NSMutableArray array];
    
    [self.replyContent becomeFirstResponder];
    
    NSString * user = [bundle getStringValue:@"USER_NAME"];
    
    if (user != nil) {
        self.replyContent.text = [NSString stringWithFormat:@"@%@\n", user];
    }
    
}


- (long long) fileSizeAtPathWithString:(NSString*) filePath{
    
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (void) fileSizeAtPath:(NSURL*) filePath{
    //return [self fileSizeAtPathWithString:filePath.path];
    ALAssetsLibrary* alLibrary = [[ALAssetsLibrary alloc] init];
    __block long long fileSize  = 0.0;
    
    [alLibrary assetForURL:filePath resultBlock:^(ALAsset *asset){
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        
        fileSize = [representation size];
        
        
        NSLog(@"图片大小:   %lld", fileSize);
        
    }failureBlock:nil];
    
}


- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}



#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSLog(@"imagePickerController %@", info);
    //    UIImage *image=info[@"UIImagePickerControllerOriginalImage"];
    
    //    UIImage *image=info[@"UIImagePickerControllerEditedImage"];
    
    UIImage * select = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    NSURL * selectUrl = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    NSData * date = UIImageJPEGRepresentation(select, 1.0);
    
    
    NSLog(@"----------&&&&&&&    %@", [self contentTypeForImageData:date]);
    
    [self fileSizeAtPath:selectUrl];
    
    CGSize maxImageSize = CGSizeMake(800, 800);
    
    [images addObject:[Utils scaleUIImage:select andMaxSize:maxImageSize]];
    
    
    [_insertCollectionView reloadData];
    
    
    //    [self.imageView setImage:image];
    
    //选取完图片之后关闭视图
    [self dismissViewControllerAnimated:YES completion:nil];
    
}




-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return images.count;
}


-(void)deleteCurrentImageForIndexPath:(NSIndexPath *)indexPath{
    [images removeObjectAtIndex:indexPath.row];
    [self.insertCollectionView reloadData];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *Identifier = @"CCFSeniorNewPostViewControllerCell";
    
    SelectPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier forIndexPath:indexPath];
    cell.deleteImageDelete = self;
    
    [cell setData:images[indexPath.row] forIndexPath:indexPath];
    
    return cell;
    
}

- (IBAction)insertSmile:(id)sender {
    
}

- (IBAction)insertPhoto:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    LCActionSheet *itemActionSheet = [LCActionSheet sheetWithTitle:nil buttonTitles:@[@"相册", @"拍照"] redButtonIndex:-1 clicked:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [pickControl setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            
            [self presentViewController:pickControl animated:YES completion:nil];
        } else if (buttonIndex == 1){
            [pickControl setSourceType:UIImagePickerControllerSourceTypeCamera];
            
            [self presentViewController:pickControl animated:YES completion:nil];
        }
    }];
    
    [itemActionSheet show];

}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendSeniorMessage:(UIBarButtonItem *)sender {
    [self.replyContent resignFirstResponder];
    
    [SVProgressHUD showWithStatus:@"高级回复" maskType:SVProgressHUDMaskTypeBlack];
    
    int threadId = [bundle getIntValue:@"THREAD_ID"];
    NSString * securityToken = [bundle getStringValue:@"SECYRITY_TOKEN"];

    NSString * formIdStr = [bundle getStringValue:@"FORM_ID"];
    
    NSMutableArray<NSData*> * uploadData = [NSMutableArray array];
    for (UIImage * image in images) {
        NSData * data = UIImageJPEGRepresentation(image, 1.0);
        [uploadData addObject:data];
    }
    
    
    [self.ccfApi seniorReplyWithThreadId:threadId forFormId:[formIdStr intValue]  andMessage:self.replyContent.text withImages:uploadData securitytoken:securityToken handler:^(BOOL isSuccess, id message) {
        if (isSuccess) {
            [SVProgressHUD showSuccessWithStatus:@"回复成功" maskType:SVProgressHUDMaskTypeBlack];
            
            ShowThreadPage * thread = message;
            
            
            CCFSimpleReplyNavigationController * navigationController = (CCFSimpleReplyNavigationController *)self.navigationController;
            
            
            self.delegate = (id<ReplyCallbackDelegate>)navigationController.controller;
            
            [self dismissViewControllerAnimated:YES completion:^{
                [self.delegate transReplyValue:thread];
            }];
            
        } else{
            [SVProgressHUD showErrorWithStatus:@"回复成功" maskType:SVProgressHUDMaskTypeBlack];
        }
    }];
    
}
@end
