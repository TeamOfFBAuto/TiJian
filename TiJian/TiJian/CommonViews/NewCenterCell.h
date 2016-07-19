//
//  NewCenterCell.h
//  TiJian
//
//  Created by lichaowei on 16/7/18.
//  Copyright © 2016年 lcw. All rights reserved.
/**
 *  新 分院列表cell
 */

#import "BasicTableViewCell.h"

@interface NewCenterCell : BasicTableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *iconImgeView;//分院封面
@property (strong, nonatomic) IBOutlet UILabel *centerNameLabel;//分院name
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;//地址
@property (strong, nonatomic) IBOutlet UILabel *pLabelOne;//套餐一
@property (strong, nonatomic) IBOutlet UILabel *pLabelTwo;//套餐二
@property (strong, nonatomic) IBOutlet UILabel *recommendLabel;//推荐标识

@property (nonatomic,retain)id centerModel;//分院model
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;

@end
