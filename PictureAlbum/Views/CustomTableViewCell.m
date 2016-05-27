//
//  CustomTableViewCell.m
//  PictureAlbum
//
//  Created by shengxin on 16/5/6.
//  Copyright © 2016年 shengxin. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.cImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10,60, 60)];
        [self.contentView addSubview:self.cImageView];
        
        self.cNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 30, 250, 20)];
        [self.contentView addSubview:self.cNameLabel];
        
    }
    return self;
}
@end
