//
//  AppointmentCell.h
//  TiJian
//
//  Created by lichaowei on 15/11/13.
//  Copyright © 2015年 lcw. All rights reserved.
/**
 *  预约cell
 */

#import "BasicTableViewCell.h"

@interface AppointmentCell : BasicTableViewCell

@property(nonatomic,retain)PropertyButton *buyButton;//购买套餐button
@property(nonatomic,retain)PropertyButton *customButton;//定制button

/**
 *  cell初始化
 *
 *  @param style
 *  @param reuseIdentifier
 *  @param type            1 公司购买套餐 2 公司代金券 3 普通套餐
 *
 *  @return
 */
-(instancetype)initWithStyle:(UITableViewCellStyle)style
             reuseIdentifier:(NSString *)reuseIdentifier
                        type:(int)type;
/**
 *  获取cell高度
 *
 *  @param type 1 公司购买套餐 2 公司代金券 3 普通套餐
 *
 *  @return
 */
+ (CGFloat)heightForCellWithType:(int)type;

@end
