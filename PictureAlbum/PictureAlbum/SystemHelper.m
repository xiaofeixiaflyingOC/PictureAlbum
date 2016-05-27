//
//  SystemHelper.m
//  PictureAlbum
//
//  Created by shengxin on 16/5/5.
//  Copyright © 2016年 shengxin. All rights reserved.
//

#import "SystemHelper.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/PHPhotoLibrary.h>
#import <UIKit/UIKit.h>


@implementation SystemHelper

#pragma mark - public
+ (instancetype)shareInstance{
    static SystemHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[SystemHelper alloc] init];
    });
    return helper;
}

//请求相册的权限
- (void)requestPhotoPermissionWithBlock:(sysPermission)block
{
    __block BOOL isGrantPhoto = NO;
    dispatch_group_t permissionGroup = dispatch_group_create();
    //    //获取相机的权限
    if (iOSVersionGreaterThan(@"8")) {
        PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
        if (authorizationStatus == PHAuthorizationStatusNotDetermined) {
            dispatch_group_enter(permissionGroup);
            //还未选择权限，请求权限
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized){
                    isGrantPhoto = YES;
                }else{
                    isGrantPhoto = NO;
                }
                dispatch_group_leave(permissionGroup);
            }];
        }else if (authorizationStatus == PHAuthorizationStatusAuthorized) {
            isGrantPhoto = YES;
        }
    }else{
        ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
        if (authorizationStatus == ALAuthorizationStatusAuthorized) {
            isGrantPhoto = YES;
        }else if (authorizationStatus == ALAuthorizationStatusNotDetermined) {
            //还未选择权限，请求权限
            dispatch_group_enter(permissionGroup);
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (*stop) {
                    isGrantPhoto = YES;
                    dispatch_group_leave(permissionGroup);
                    return;
                }
                *stop = YES;
            } failureBlock:^(NSError *error) {
                isGrantPhoto = NO;
                dispatch_group_leave(permissionGroup);
            }];
        }else if (authorizationStatus == ALAuthorizationStatusRestricted) {
//            DDLogDebug(@"微家园没有被授权访问的照片数据,可能是家长控制权限");
        }
    }
    dispatch_group_notify(permissionGroup, dispatch_get_main_queue(), ^{
        block(isGrantPhoto);
    });
}


@end
