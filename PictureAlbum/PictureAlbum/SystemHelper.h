//
//  SystemHelper.h
//  PictureAlbum
//
//  Created by shengxin on 16/5/5.
//  Copyright © 2016年 shengxin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define iOSVersionGreaterThan(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
typedef void (^sysPermission)(BOOL photoGranted);

@interface SystemHelper : NSObject

+ (instancetype)shareInstance;
- (void)requestPhotoPermissionWithBlock:(sysPermission)block;

@end
