//
//  MyCouponViewController.h
//  TiJian
//
//  Created by gaomeng on 15/11/29.
//  Copyright © 2015年 lcw. All rights reserved.
//

/**
 *  我的优惠券 我的代金券
 */

#import "MyViewController.h"
#import "CouponModel.h"
@class ConfirmOrderViewController;

@interface MyCouponViewController : MyViewController

@property(nonatomic,assign)GCouponType type;
@property(nonatomic,strong)CouponModel *couponModel;


@property(nonatomic,assign)ConfirmOrderViewController *delegate;

//使用优惠券
@property(nonatomic,strong)NSString *coupon;

//使用代金券
@property(nonatomic,strong)NSString *brand_ids;

//用户选择使用的优惠券
@property(nonatomic,strong)NSArray *userChooseYouhuiquanArray;

//用户选择使用的优惠券
@property(nonatomic,strong)NSArray *userChooseDaijinquanArray;


//cell的selectButton点击回调方法
-(void)cellSelectBtnClickedWithIndex:(NSIndexPath *)theIndex select:(BOOL)theState;


@end
