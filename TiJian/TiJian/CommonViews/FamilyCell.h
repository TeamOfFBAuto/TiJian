//
//  FamilyCell.h
//  TiJian
//
//  Created by lichaowei on 16/7/22.
//  Copyright © 2016年 lcw. All rights reserved.
/**
 *  vip选择就诊人cell
 */

#import "BasicTableViewCell.h"

@interface FamilyCell : BasicTableViewCell

@property (nonatomic,retain)UILabel *nameLabel;
@property (nonatomic,retain)PropertyButton *editButton;
@property (nonatomic,retain)UIButton *selectButton;//选择按钮

@end
