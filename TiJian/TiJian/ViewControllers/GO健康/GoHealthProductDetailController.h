//
//  GoHealthProductDetailController.h
//  TiJian
//
//  Created by lichaowei on 16/6/8.
//  Copyright © 2016年 lcw. All rights reserved.
/**
 *  Go健康产品详情
 */

#import "MyViewController.h"
typedef enum {
    DetailType_default = 0, //go健康产品详情
    DetailType_serviceDetail //服务详情
}DetailType;

@interface GoHealthProductDetailController : MyViewController

@property(nonatomic,assign)DetailType detailType;//区分 产品详情、服务详情
@property(nonatomic,retain)NSString *productId;
@property(nonatomic,retain)NSString *serviceId;//服务id
@property(nonatomic,retain)NSString *orderNum;//订单号

@end
