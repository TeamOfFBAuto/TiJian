//
//  ArticleCell.h
//  TiJian
//
//  Created by lichaowei on 15/11/13.
//  Copyright © 2015年 lcw. All rights reserved.
/**
 *  文章资讯cell
 */

#import "BasicTableViewCell.h"

@interface ArticleCell : BasicTableViewCell
@property(nonatomic,retain)UIImageView *iconImageView;
@property(nonatomic,retain)UILabel *titleLable;
@property(nonatomic,retain)UILabel *subTitleLabel;
@property(nonatomic,retain)UILabel *timeLabel;

@end
