//
//  OrderInfoViewController.h
//  WJXC
//
//  Created by lichaowei on 15/7/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  订单详情
 */
#import "MyViewController.h"

@interface OrderInfoViewController : MyViewController

@property (nonatomic,retain)NSString *order_id;
@property(nonatomic,retain)NSString *msg_id;//消息id
@property(nonatomic,assign)BOOL isPayResultVcPush;//是否为支付结果页面跳转过来的
@property(nonatomic,assign)BOOL cancelOrderSuccess;//支付结果页面跳转过来然后取消订单成功

@end
