//
//  GoProductCell.h
//  TiJian
//
//  Created by lichaowei on 16/7/13.
//  Copyright © 2016年 lcw. All rights reserved.
/**
 *  go健康单品列表
 */

#import "BasicTableViewCell.h"

@interface GoProductCell : BasicTableViewCell

/**
 *  图片imgView
 */
@property (nonatomic, strong) UIImageView * pictureView;

/**
 *  标题label
 */
@property (nonatomic, strong) UILabel * titleLabel;

/**
 *  内容Label
 */
@property (nonatomic, strong) UILabel * littleLabel;

- (CGFloat)cellOffset;

@end
