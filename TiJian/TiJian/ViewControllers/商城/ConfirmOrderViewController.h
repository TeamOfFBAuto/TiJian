//
//  ConfirmOrderViewController.h
//  TiJian
//
//  Created by gaomeng on 15/11/12.
//  Copyright © 2015年 lcw. All rights reserved.
//


//确认订单

#import "MyViewController.h"

@interface ConfirmOrderViewController : MyViewController


@property(nonatomic,strong)NSArray *dataArray;//数据源
@property(nonatomic,assign)BOOL is_appoint;//是否是预约页面跳转过来的

//用户选择的优惠券
@property(nonatomic,strong)NSArray *userSelectYouhuiquanArray;

//用户选择的代金券
@property(nonatomic,strong)NSArray *userSelectDaijinquanArray;


-(void)jisuanPrice;

@end
