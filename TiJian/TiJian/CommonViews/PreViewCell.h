//
//  PreViewCell.h
//  TiJian
//
//  Created by lichaowei on 15/11/11.
//  Copyright © 2015年 lcw. All rights reserved.
//
/**
 *  预约cell
 */
#import <UIKit/UIKit.h>

@interface PreViewCell : UITableViewCell


/**
 *  计算cell高度
 *
 *  @param userCount 体检人信息个数
 *  @param lastNum   套餐剩余份数
 *
 *  @return
 */
//+ (CGFloat)heightForCellWithUsersCount:(int)userCount
//                               lastNum:(int)lastNum;

/**
 *  cell赋值
 *
 *  @param hospitalArray 分院数组
 */
- (void)setCellWithModel:(NSArray *)hospitalArray;

/**
 *  计算cell高度
 *
 *  @param userCount 体检人信息个数
 *  @param lastNum   套餐剩余份数
 *  @param hospitalArray   分院个数
 *
 *  @return
 */
+ (CGFloat)heightForCellWithUsersCount:(int)userCount
                               lastNum:(int)lastNum
                         hospitalArray:(NSArray *)hospitalArray;
@end
