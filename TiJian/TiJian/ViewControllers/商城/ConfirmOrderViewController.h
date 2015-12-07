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

//代金卷购买 (默认选择传过来的代金卷)
@property(nonatomic,assign)BOOL isVoucherPush;//代金卷过来的
@property(nonatomic,strong)NSString *voucherId;//代金卷id
//is_appoint = 1   固定：1
//appoint_vouchers_id  这张体检金(代金券)id, 整形
//company_user_id  公司员工id

-(void)jisuanPrice;

@end
