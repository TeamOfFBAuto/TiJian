//
//  PeopleManageController.h
//  TiJian
//
//  Created by lichaowei on 15/11/6.
//  Copyright © 2015年 lcw. All rights reserved.
//
// 人员管理

#import "MyViewController.h"
@class AppointModel;

@interface PeopleManageController : MyViewController

@property(nonatomic,assign)BOOL isChoose;//是否是选择人

/**
 *  预约参数传值
 *
 *  @param orderId
 *  @param productId
 *  @param examCenterId     体检机构id
 *  @param date             预约的时间 格式如：2015-11-13
 *  @param noAppointNum     套餐未预约个数
 */
- (void)setAppointOrderId:(NSString *)orderId
                productId:(NSString *)productId
             examCenterId:(NSString *)examCenterId
                     date:(NSString *)date
             noAppointNum:(int)noAppointNum;

@end
