//
//  BrandRecomendCell.h
//  TiJian
//
//  Created by lichaowei on 16/1/27.
//  Copyright © 2016年 lcw. All rights reserved.
/**
 *  品牌推荐cell
 */

#import "BasicTableViewCell.h"

typedef NS_ENUM(NSInteger,SelectStyle) {
    SelectStyle_main = 0,//选择主套餐
    SelectStyle_addition //选择附加套餐
};

#define Select_main @"selectMain"//主套餐
#define Select_additon @"selectAddition"//附加套餐

@interface BrandRecomendCell : BasicTableViewCell

@property(nonatomic,retain)UIButton *selectedButton;//选择状态按钮
@property(nonatomic,assign)int selectIndex;//选择的下标
@property (nonatomic,copy)void(^ AdditonSelectBlock)(int index,BOOL add,NSDictionary *dic);

+ (CGFloat)heightForCellWithModel:(id)model;

/**
 *  重置选择状态
 */
- (void)resetSelectState;

/**
 *  选择主套餐
 *
 *  @param btn
 */
- (void)clickToSelectMain:(UIButton *)btn;

@end
