//
//  PayResultViewController.h
//  WJXC
//
//  Created by lichaowei on 15/7/24.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  支付结果处理页面
 */
#import "MyViewController.h"

@interface PayResultViewController : MyViewController

@property(nonatomic,retain)NSString *orderId;
@property(nonatomic,retain)NSString *orderNum;
@property(nonatomic,assign)CGFloat sumPrice;
@property(nonatomic,retain)NSString *erroInfo;//失败原因
@property(nonatomic,assign)PAY_RESULT_TYPE payResultType;//支付结果
@property(nonatomic,assign)BOOL needAppoint;//需要前去预约
@property(nonatomic,assign)PayActionType payActionType;//区分体检商城、go健康、自测用药等

@end
