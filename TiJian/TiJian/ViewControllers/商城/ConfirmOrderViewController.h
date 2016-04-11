//
//  ConfirmOrderViewController.h
//  TiJian
//
//  Created by gaomeng on 15/11/12.
//  Copyright © 2015年 lcw. All rights reserved.
//


//确认订单

#import "MyViewController.h"
@class HospitalModel;
@class ProductModel;

@interface ConfirmOrderViewController : MyViewController

@property(nonatomic,strong)NSArray *dataArray;//数据源
//用户选择的优惠券
@property(nonatomic,strong)NSArray *userSelectYouhuiquanArray;
//用户选择的代金券
@property(nonatomic,strong)NSArray *userSelectDaijinquanArray;

//代金券购买 (默认选择传过来的代金券)
@property(nonatomic,strong)NSString *voucherId;//代金券id
//代金券预约
@property(nonatomic,strong)UserInfo *user_voucher;//代金券绑定的人

//单品详情直接预约
//@property(nonatomic,strong)NSString *exam_center_id;//体检中心id
//@property(nonatomic,strong)NSString *date;//预约时间
//@property(nonatomic,strong)NSString *myself;//预约是否自己
//@property(nonatomic,strong)NSArray *family_uid;//预约家人




//计算金额
-(void)jisuanPrice;

//设置发票信息
-(void)setUserSelectFapiaoWithStr:(NSString *)str;

/**
 *  单品详情直接预约
 *  add by lcw
 *
 *  @param productModel  套餐model
 *  @param hospital  分院model
 *  @param userArray 体检人信息model
 */
- (void)appointWithProductModel:(ProductModel *)productModel
                       hospital:(HospitalModel *)hospital
                      userArray:(NSArray *)userArray;

@end
