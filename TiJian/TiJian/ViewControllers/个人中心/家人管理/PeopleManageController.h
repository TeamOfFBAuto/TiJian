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

typedef enum{
    PEOPLEACTIONTYPE_NORMAL = 0,//普通家人管理
    PEOPLEACTIONTYPE_SELECT_APPOINT, //选择并提交预约
    PEOPLEACTIONTYPE_SELECT //仅选择体检人信息
}PEOPLEACTIONTYPE;

@interface PeopleManageController : MyViewController

//@property(nonatomic,assign)BOOL isChoose;//是否是选择人
@property(nonatomic,assign)int noAppointNum;//未预约个数
@property(nonatomic,assign)PEOPLEACTIONTYPE actionType;


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
