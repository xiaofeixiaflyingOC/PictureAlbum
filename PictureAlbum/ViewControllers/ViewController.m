//
//  ViewController.m
//  PictureAlbum
//
//  Created by shengxin on 16/5/5.
//  Copyright © 2016年 shengxin. All rights reserved.
//

#import "ViewController.h"
#import "SystemHelper.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "LocalAlbumManager.h"
#import "CustomTableViewCell.h"
#import "ContentViewController.h"

typedef void (^grandImage) (BOOL isGrand);
@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *collectionsFetchResults;
@property (nonatomic, strong) NSMutableArray *iPhotoListAssetArr;
@property (nonatomic, strong) NSMutableArray *iPhotoListNameArr;
@property (nonatomic, strong) UITableView *iTableView;
@property (nonatomic, strong) NSMutableArray *iAllImageArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.iAllImageArray = [NSMutableArray array];
    [self initTableView];
    __weak ViewController *weslef= self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weslef initAlert];
    });
}

- (void)initAlert{
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert's cancel action occured.");
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self isGrant:^(BOOL isGrand){
            if (isGrand==YES
                ) {
                [self getImagePicker];
            }
        }];
    }];
    
   
    UIAlertAction *otherAction1 = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
       
        [self isGrant:^(BOOL isGrand){
            if (isGrand==YES
                ) {
                [self getAlbumList];
            }
        }];
        
    }];
    UIAlertController *v = [UIAlertController alertControllerWithTitle:@"取图" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [v addAction:otherAction];
    [v addAction:otherAction1];
    [v addAction:cancelAction];
    [self presentViewController:v animated:YES completion:nil];
}
    
- (void)isGrant:(grandImage)block{
    [[SystemHelper shareInstance] requestPhotoPermissionWithBlock:^(BOOL photoGranted){
        if (photoGranted==YES) {
            NSLog(@"已授权");
            block(YES);
        }else{
            NSLog(@"未授权");
            block(NO);
        }
    }];
}

- (void)initTableView{
    self.iPhotoListAssetArr = [NSMutableArray array];
    self.iPhotoListNameArr = [NSMutableArray array];
    
    self.iTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.iTableView.delegate = self;
    self.iTableView.dataSource = self;
    self.iTableView.rowHeight = 80.0;
    [self.view addSubview:self.iTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- <UIImagePickerControllerDelegate>
// 获取图片后的操作
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        //如果是 来自照相机的image，那么先保存
        UIImage* original_image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSLog(@"%f,%f",original_image.size.width,original_image.size.height);
    }
    // 销毁控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.iPhotoListNameArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *a = @"tableView111";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:a];
    if (cell==nil) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:a];
    }
    PHFetchResult *fetchResult = [self.iPhotoListAssetArr objectAtIndex:indexPath.row];
    
    cell.cNameLabel.text = [NSString stringWithFormat:@"%@ (%lu)张",[self.iPhotoListNameArr objectAtIndex:indexPath.row],(unsigned long)fetchResult.count];
    PHAsset *asset = [fetchResult firstObject];
    CGSize size = CGSizeMake(60*2,60*2);
    [[LocalAlbumManager shareInstance] getImageAsset:asset andImageSize:size resultImage:^(UIImage *result, NSDictionary *info){
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.cImageView.image = result;
        });
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ContentViewController *v = [[ContentViewController alloc] initWithNibName:nil bundle:nil];
    [v setData:[self.iPhotoListAssetArr objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:v animated:YES];
}

#pragma mark - getAllImage
- (void)getAllImage{
     __weak ViewController *weself = self;
    //得到CollectionList 相册（得到PHFetchResult的集合）
    [[LocalAlbumManager shareInstance] getAssetList:^(NSMutableArray *photoListAssetArr,NSMutableArray *photoListNameArr){
        
        weself.iPhotoListAssetArr = [NSMutableArray arrayWithArray:(NSArray*)photoListAssetArr];
        weself.iPhotoListNameArr = [NSMutableArray arrayWithArray:(NSArray*)photoListNameArr];
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //遍历CollectionList相册得到Asset Collections（PHFetchResult）
            [photoListAssetArr enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock: ^(id obj,NSUInteger idx, BOOL *stop){
                dispatch_group_enter(group);
                
                NSMutableArray *imageArray = [NSMutableArray array];
                NSMutableArray *assetArray = [NSMutableArray array];
                
                PHFetchResult *fetchResult = (PHFetchResult *)obj;
                dispatch_group_t group1 = dispatch_group_create();
                //取图
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    for (PHAsset *asset in fetchResult) {
                        dispatch_group_enter(group1);
                        CGSize imageSize = CGSizeMake(1080, (float)asset.pixelHeight * 1080 / (float)asset.pixelWidth);
                        imageSize = CGSizeMake(2000, 2000);
                        [[LocalAlbumManager shareInstance] getImageAsset:asset andImageSize:imageSize resultImage:^(UIImage *result, NSDictionary *info){
                            NSLog(@"%f,%f",result.size.width,result.size.height);
                            [imageArray addObject:result];
                            [assetArray addObject:asset];
                        }];
                        dispatch_group_leave(group1);
                    }
                    dispatch_group_notify(group1, dispatch_get_main_queue(), ^{
                        [weself.iAllImageArray addObject:imageArray];
                        CGSize imageSize = CGSizeMake(2000, 2000);
                        //缓存
                        [[LocalAlbumManager shareInstance] cacheAssets:assetArray andImageSize:(CGSize)imageSize];
                        dispatch_group_leave(group);
                    });
                });
                
            }];
            
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                NSLog(@"%@",weself.iAllImageArray);
            });
        });
    }];
}

- (void)getAlbumList{
    __weak ViewController *weself = self;
    //得到CollectionList 相册（得到PHFetchResult的集合）
    [[LocalAlbumManager shareInstance] getAssetList:^(NSMutableArray *photoListAssetArr,NSMutableArray *photoListNameArr){
        
        weself.iPhotoListAssetArr = [NSMutableArray arrayWithArray:(NSArray*)photoListAssetArr];
        weself.iPhotoListNameArr = [NSMutableArray arrayWithArray:(NSArray*)photoListNameArr];
        dispatch_async(dispatch_get_main_queue(),^{
            [weself.iTableView reloadData];
        });
    }];

}

- (void)getImagePicker{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        NSLog(@"相册不可打开！！！");
        return;
    }
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    /**
     typedef NS_ENUM(NSInteger, UIImagePickerControllerSourceType) {
     UIImagePickerControllerSourceTypePhotoLibrary, // 相册
     UIImagePickerControllerSourceTypeCamera, // 用相机拍摄获取
     UIImagePickerControllerSourceTypeSavedPhotosAlbum // 相簿
     }
     */
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
}
@end
