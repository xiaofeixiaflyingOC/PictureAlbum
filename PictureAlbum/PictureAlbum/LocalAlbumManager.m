//
//  LocalAlbumManager.m
//  PictureAlbum
//
//  Created by shengxin on 16/5/24.
//  Copyright © 2016年 shengxin. All rights reserved.
//

#import "LocalAlbumManager.h"
#import <Photos/Photos.h>

@interface LocalAlbumManager()

@property (nonatomic, strong) PHImageRequestOptions *phImageRequestOptions;
@property (nonatomic, assign) CGSize assetSize;
@end

@implementation LocalAlbumManager

#pragma mark - public
+ (instancetype)shareInstance{
    static LocalAlbumManager *m = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m = [[LocalAlbumManager alloc] init];
    });
    return m;
}

- (void)getAssetList:(photoDataBlock)block{
    //用户智能相册
    NSMutableArray *smartAlbumsArr = [self getSmartAlbum];
    //照片流
    NSMutableArray *photoStreamAlbum = [self getMyPhotoStreamAlbum];
    //用户创建的相册
    NSMutableArray *userAlbumsArr = [self getUserCollectionAlbum];
    
    NSMutableArray *photoListAssetArr = [NSMutableArray array];
    NSMutableArray *photoListNameArr = [NSMutableArray array];
    [photoListAssetArr addObjectsFromArray:[smartAlbumsArr lastObject]];
    [photoListAssetArr addObjectsFromArray:[photoStreamAlbum lastObject]];
    [photoListAssetArr addObjectsFromArray:[userAlbumsArr lastObject]];
    
    [photoListNameArr addObjectsFromArray:[smartAlbumsArr firstObject]];
    [photoListNameArr addObjectsFromArray:[photoStreamAlbum firstObject]];
    [photoListNameArr addObjectsFromArray:[userAlbumsArr firstObject]];

    block(photoListAssetArr,photoListNameArr);
}

- (void)getImageAsset:(PHAsset *)asset andImageSize:(CGSize)imageSize resultImage:(photoImageBlock)block{
    [self.imageManager requestImageForAsset:asset
                                 targetSize:imageSize
                                contentMode:PHImageContentModeDefault
                                    options:self.phImageRequestOptions
                              resultHandler:^(UIImage *result, NSDictionary *info){
                                  block(result,info);
     }];
}

- (void)cacheAssets:(NSMutableArray*)aAssetArray andImageSize:(CGSize)imageSize{
    [self.imageManager startCachingImagesForAssets:aAssetArray
                                                                     targetSize:imageSize
                                                                    contentMode:PHImageContentModeAspectFill
                                                                        options:self.phImageRequestOptions];
    [self.imageManager stopCachingImagesForAssets:aAssetArray
                                                                    targetSize:imageSize
                                                                   contentMode:PHImageContentModeAspectFill
                                                                       options:self.phImageRequestOptions];
}
#pragma mark - private
// 列出所有相册智能相册
- (NSMutableArray*)getSmartAlbum{
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    NSMutableArray *smartFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *smartFetchResultLabel = [[NSMutableArray alloc] init];
//    NSArray *subType = @[@(PHAssetCollectionSubtypeAlbumMyPhotoStream),@(PHAssetCollectionSubtypeSmartAlbumFavorites),
//    @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
//    @(PHAssetCollectionSubtypeSmartAlbumVideos),
//    @(PHAssetCollectionSubtypeSmartAlbumSlomoVideos),
//    @(PHAssetCollectionSubtypeSmartAlbumTimelapses),
//    @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
//    @(PHAssetCollectionSubtypeSmartAlbumScreenshots)];
//注释为过滤相册
    NSArray *subType = [NSArray array];

    for(PHCollection *collection in smartAlbums)
    {
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            if(![subType containsObject:@(assetCollection.assetCollectionSubtype)])
            {
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", @[@(PHAssetMediaTypeImage)]];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                if(assetsFetchResult.count>0)
                {
                    [smartFetchResultArray addObject:assetsFetchResult];
                  NSLog(@"%@,%zd",collection.localizedTitle,assetsFetchResult.count);
                    [smartFetchResultLabel addObject:collection.localizedTitle];
                }
            }
        }
    }

    NSMutableArray *array = [NSMutableArray array];
    [array addObject:smartFetchResultLabel];
    [array addObject:smartFetchResultArray];
    
    return  array;
}

// 列出所有用户创建的相册
- (NSMutableArray*)getUserCollectionAlbum{
    
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    NSMutableArray *userFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *userFetchResultLabel = [[NSMutableArray alloc] init];
    for(PHCollection *collection in topLevelUserCollections)
    {
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            //只取图片
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", @[@(PHAssetMediaTypeImage)]];
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            if (assetsFetchResult.count>0) {
                [userFetchResultArray addObject:assetsFetchResult];
                NSLog(@"%@,%zd",collection.localizedTitle,assetsFetchResult.count);
                [userFetchResultLabel addObject:collection.localizedTitle];
            }
        }
    }
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:userFetchResultLabel];
    [array addObject:userFetchResultArray];
    return  array;
}

- (NSMutableArray*)getMyPhotoStreamAlbum{
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    NSMutableArray *smartFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *smartFetchResultLabel = [[NSMutableArray alloc] init];
    //    NSArray *subType = @[@(PHAssetCollectionSubtypeAlbumMyPhotoStream),@(PHAssetCollectionSubtypeSmartAlbumFavorites),
    //    @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
    //    @(PHAssetCollectionSubtypeSmartAlbumVideos),
    //    @(PHAssetCollectionSubtypeSmartAlbumSlomoVideos),
    //    @(PHAssetCollectionSubtypeSmartAlbumTimelapses),
    //    @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
    //    @(PHAssetCollectionSubtypeSmartAlbumScreenshots)];
    //注释为过滤相册
    NSArray *subType = [NSArray array];
    
    for(PHCollection *collection in smartAlbums)
    {
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            if(![subType containsObject:@(assetCollection.assetCollectionSubtype)])
            {
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", @[@(PHAssetMediaTypeImage)]];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                if(assetsFetchResult.count>0)
                {
                    [smartFetchResultArray addObject:assetsFetchResult];
                    NSLog(@"%@,%zd",collection.localizedTitle,assetsFetchResult.count);
                    [smartFetchResultLabel addObject:collection.localizedTitle];
                }
            }
        }
    }
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:smartFetchResultLabel];
    [array addObject:smartFetchResultArray];
    
    return  array;
}

- (PHCachingImageManager*)imageManager{
    if (_imageManager==nil) {
        _imageManager = [[PHCachingImageManager alloc] init];
        _assetSize = CGSizeMake(2000, 2000);
        [_imageManager stopCachingImagesForAllAssets];
    }
    return _imageManager;
}

- (PHImageRequestOptions*)phImageRequestOptions{
    if (_phImageRequestOptions==nil) {
        _phImageRequestOptions = [PHImageRequestOptions new];
        _phImageRequestOptions.synchronous = YES;
        _phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    }
    return  _phImageRequestOptions;
}
@end
