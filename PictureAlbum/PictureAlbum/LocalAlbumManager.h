//
//  LocalAlbumManager.h
//  PictureAlbum
//
//  Created by shengxin on 16/5/24.
//  Copyright © 2016年 shengxin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
/**
 *  返回系统相册数据
 *
 *  @param photoListAssetArr 返回每个相册的PHAsset数组
 *  @param photoListNameArr  返回每个相册的名称
 */
typedef void (^photoDataBlock)(NSMutableArray *photoListAssetArr,NSMutableArray *photoListNameArr);
/**
 *  返回图片信息
 *
 *  @param result
 *  @param info   
 */
typedef void (^photoImageBlock)(UIImage *result, NSDictionary *info);

@interface LocalAlbumManager : NSObject

@property (nonatomic, strong) PHCachingImageManager *imageManager;

+ (instancetype)shareInstance;
- (void)getAssetList:(photoDataBlock)block;
- (void)getImageAsset:(PHAsset *)asset andImageSize:(CGSize)imageSize resultImage:(photoImageBlock)block;
- (void)cacheAssets:(NSMutableArray*)aAssetArray andImageSize:(CGSize)imageSize;



@end
