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
//用户选择的优惠券
@property(nonatomic,strong)NSArray *userSelectYouhuiquanArray;
//用户选择的代金券
@property(nonatomic,strong)NSArray *userSelectDaijinquanArray;

//代金券购买 (默认选择传过来的代金券)
@property(nonatomic,assign)BOOL isVoucherPush;//代金券过来的 是否是预约页面跳转过来的
@property(nonatomic,strong)NSString *voucherId;//代金券id
@property(nonatomic,strong)NSString *uc_id;//用户代金券绑定id
//is_appoint = 1   固定：1
//appoint_vouchers_id  这张体检金(代金券)id, 整形
//company_user_id  公司员工id 当前用户id

-(void)jisuanPrice;

@end
