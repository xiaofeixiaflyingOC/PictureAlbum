//
//  ContentViewController.m
//  PictureAlbum
//
//  Created by shengxin on 16/5/24.
//  Copyright © 2016年 shengxin. All rights reserved.
//

#import "ContentViewController.h"
#import "ContentCollectionViewCell.h"
#import "LocalAlbumManager.h"
#import <Photos/Photos.h>

@implementation NSIndexSet (Convenience)
- (NSArray *)aapl_indexPathsFromIndexesWithSection:(NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}
@end
@implementation UICollectionView (Convenience)
- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}
@end

@interface ContentViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *iCollectionView;
@property (nonatomic, strong) NSMutableArray *iCollectionViewArr;
@property CGRect previousPreheatRect;

@end

@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public
- (void)setData:(NSMutableArray*)aArray{
    [self resetCachedAssets];
    
    self.iCollectionViewArr = [NSMutableArray array];
    [self.iCollectionViewArr  addObjectsFromArray:(NSArray*)aArray];
    [self initCollectionView];
    [self.iCollectionView reloadData];
}

#pragma mark - init
- (void)initCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.iCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.iCollectionView.backgroundColor = [UIColor whiteColor];
    self.iCollectionView.delegate = self;
    self.iCollectionView.dataSource = self;
    [self.view addSubview:self.iCollectionView];
    
    [self.iCollectionView registerClass:[ContentCollectionViewCell class] forCellWithReuseIdentifier:@"ChildhoodTimeAlbumCollectionViewCell"];
}

- (void)resetCachedAssets
{
    [[LocalAlbumManager shareInstance].imageManager stopCachingImagesForAllAssets];

}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.iCollectionViewArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ContentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ChildhoodTimeAlbumCollectionViewCell" forIndexPath:indexPath];
     PHAsset *asset = [self.iCollectionViewArr objectAtIndex:indexPath.row];
     CGSize imageSize = CGSizeMake(800/3.0, 800/3.0);
    
    [[LocalAlbumManager shareInstance] getImageAsset:asset andImageSize:imageSize resultImage:^(UIImage *result, NSDictionary *info){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%f,%f",result.size.width,result.size.height);
            cell.iImageView.image = result;
        });
    }];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0,0,0,0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat kScreenWidth = [UIScreen mainScreen].bounds.size.width;
    if ([UIScreen mainScreen].bounds.size.width==320) {
        CGFloat itemWidth = (kScreenWidth - (24 + 12) *1.0)/3;
        return CGSizeMake(itemWidth,itemWidth);
    }
    CGFloat itemWidth = (kScreenWidth - (24 + 12) *1.0)/3;
    return CGSizeMake(itemWidth,itemWidth);
}

// 设置最小行间距，也就是前一行与后一行的中间最小间隔
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 6;
}

// 设置最小列间距，也就是左行与右一行的中间最小间隔  根据最小距离推算一共有每行有多少个cell
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 6;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}

#pragma mark - ForCache
- (void)updateCachedAssets
{
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.iCollectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.iCollectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.iCollectionView aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.iCollectionView aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        CGSize imageSize = CGSizeMake(800/3.0, 800/3.0);
        
        [[LocalAlbumManager shareInstance].imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:imageSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [[LocalAlbumManager shareInstance].imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:imageSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.iCollectionViewArr[indexPath.item];
        [assets addObject:asset];
    }
    return assets;
}

@end
