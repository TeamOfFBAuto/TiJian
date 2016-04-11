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
    PEOPLEACTIONTYPE_SELECT_Single, //仅选择一个体检人信息
    PEOPLEACTIONTYPE_SELECT_Mul, //选择多个体检人
    PEOPLEACTIONTYPE_NOPAYAPPOINT //不支付去预约
}PEOPLEACTIONTYPE;

@interface PeopleManageController : MyViewController

@property(nonatomic,assign)int noAppointNum;//未预约个数
@property(nonatomic,assign)PEOPLEACTIONTYPE actionType;

@property(nonatomic,assign)Gender gender;
@property(nonatomic,retain)id productModel;//直接预约的单品详情model


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

/**
 *  选择多个体检人信息 回调
 *  @param examCenterName   体检机构name
 *  @param examCenterId     体检机构id
 *  @param date             预约的时间 格式如：2015-11-13
 *  @param noAppointNum     套餐未预约个数
 */
- (void)selectMulPeopleWithExamCenterId:(NSString *)examCenterId
                         examCenterName:(NSString *)examName
                               examDate:(NSString *)date
                           noAppointNum:(int)noAppointNum
                            updateBlock:(UpdateParamsBlock)updateBlock;

/**
 *  选择多个体检人信息(根据已选择分院显示对应已选体检人) 回调
 *  @param examCenterName   体检机构name
 *  @param examCenterId     体检机构id
 *  @param date             预约的时间 格式如：2015-11-13
 *  @param noAppointNum     套餐未预约个数
 */
- (void)selectMulPeopleWithHospitalArray:(NSArray *)hospitalArray
                            examCenterId:(NSString *)examCenterId
                          examCenterName:(NSString *)examName
                                examDate:(NSString *)date
                            noAppointNum:(int)noAppointNum
                             updateBlock:(UpdateParamsBlock)updateBlock;

/**
 *  更新体检人
 *
 *  @param userArray    体检人数组
 *  @param noAppointNum 剩余可预约数
 *  @param updateBlock
 */
- (void)replaceUserArray:(NSArray *)userArray
            noAppointNum:(int)noAppointNum
             updateBlock:(UpdateParamsBlock)updateBlock;

@end
