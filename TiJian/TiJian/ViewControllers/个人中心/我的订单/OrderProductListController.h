//
//  OrderProductListController.h
//  TiJian
//
//  Created by lichaowei on 15/11/26.
//  Copyright © 2015年 lcw. All rights reserved.
/**
 *  订单对应的套餐列表
 */

#import "MyViewController.h"

@interface OrderProductListController : MyViewController

@property(nonatomic,retain)NSString *orderId;
@property(nonatomic,assign)PlatformType platformType;//区分体检商城、go健康、自测用药等

@end
