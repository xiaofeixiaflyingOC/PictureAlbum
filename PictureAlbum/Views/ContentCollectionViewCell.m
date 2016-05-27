//
//  ContentCollectionViewCell.m
//  PictureAlbum
//
//  Created by shengxin on 16/5/24.
//  Copyright © 2016年 shengxin. All rights reserved.
//

#import "ContentCollectionViewCell.h"

@implementation ContentCollectionViewCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        CGFloat kScreenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat itemWidth = (kScreenWidth - (24 + 12) *1.0)/3;
        CGSize size = CGSizeMake(itemWidth,itemWidth);
        
        self.iImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-itemWidth)/2, (self.frame.size.height-itemWidth)/2,itemWidth,itemWidth)];
        self.iImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.iImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.iImageView];
    }
    return self;
}

@end
