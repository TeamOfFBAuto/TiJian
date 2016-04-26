//
//  ArticleCell.m
//  TiJian
//
//  Created by lichaowei on 15/11/13.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "ArticleCell.h"
#import "ArticleModel.h"

@implementation ArticleCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 100)];
        view.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:view];
        //图标
        self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12.5, 120, 75)];
//        _iconImageView.backgroundColor = DEFAULT_TEXTCOLOR;
        [self.contentView addSubview:_iconImageView];
        [_iconImageView addCornerRadius:5.f];
        //title
        CGFloat left = _iconImageView.right + 10;
        self.titleLable = [[UILabel alloc]initWithFrame:CGRectMake(left, _iconImageView.top, DEVICE_WIDTH - left - 10, 30) title:nil font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE];
        [self.contentView addSubview:_titleLable];
        //subtitle
        self.subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(_titleLable.left, _titleLable.bottom + 5, _titleLable.width, 30) title:nil font:12 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB];
        _subTitleLabel.numberOfLines = 2;
        _subTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.subTitleLabel];
        //时间
        CGFloat width = 150;
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 10 - width, _subTitleLabel.bottom + 10, width, 14) title:@" " font:13 align:NSTextAlignmentRight textColor:DEFAULT_TEXTCOLOR_TITLE_THIRD];
        [self.contentView addSubview:_timeLabel];
    }
    return self;
}

-(void)setCellWithModel:(ArticleModel *)aModel
{
    self.titleLable.text = aModel.title;
    self.subTitleLabel.text = aModel.summary;
    self.timeLabel.text = [GMAPI timechangeYMD:aModel.add_time];
    [self.iconImageView l_setImageWithURL:[NSURL URLWithString:aModel.cover_pic] placeholderImage:DEFAULT_HEADIMAGE];
}

@end
