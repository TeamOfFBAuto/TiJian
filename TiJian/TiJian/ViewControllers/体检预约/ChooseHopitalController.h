//
//  ChooseHopitalController.h
//  TiJian
//
//  Created by lichaowei on 15/11/12.
//  Copyright © 2015年 lcw. All rights reserved.
/**
 *  选择时间和分院
 */

#import "MyViewController.h"
#import "FSCalendar.h"
#import "ProductModel.h"

typedef enum {
    ChooseType_appoint = 0,//选择时间、分院之后进行预约
    ChooseType_center,//仅选择时间和分院,不预约
    ChooseType_centerAndPeople,//选择时间分院和人，不预约
    ChooseType_nopayAppoint, // 未支付预约,跳转至确认订单
    ChooseType_centerAndConfirmOrder // 未支付预约,选择分院之后跳转至确认订单

}ChooseType;

@interface ChooseHopitalController : MyViewController<FSCalendarDataSource, FSCalendarDelegate>

@property(nonatomic,retain)FSCalendar *calendar;
@property(nonatomic,retain)NSString *productId;//商品id
@property(nonatomic,retain)NSString *order_id;
@property(nonatomic,assign)int noAppointNum;//剩余未预约个数

@property(nonatomic,assign)Gender gender;//性别
@property(nonatomic,retain)ProductModel *productModel;//直接预约model
@property(nonatomic,assign)ChooseType chooseType;

/**
 *  普通预约 选择时间、分院直接预约
 */
- (void)appointWithProductId:(NSString *)productId
                     orderId:(NSString *)orderid
                noAppointNum:(int)noAppointNum;

/**
 *  直接预约,未支付
 *
 *  @param productId
 *  @param gender       套餐适用性别
 *  @param noAppointNum 剩余可预约数
 *  @param centerId       选择分院id(需要传,不需要不传)
 *  @param centerName 选择分院name(需要传,不需要不传)
 */
- (void)apppointNoPayWithProductModel:(ProductModel *)productModel
                               gender:(Gender)gender
                         noAppointNum:(int)noAppointNum
                             centerId:(NSString *)examCenterId
                           centerName:(NSString *)examCenterName;

/**
 *  公司预约参数
 *
 *  @param orderId
 *  @param productId
 *  @param companyId          公司id
 *  @param order_checkuper_id 公司订单特有
 *  @param gender 套餐对应性别
 *  @param noAppointNum
 */
- (void)companyAppointWithOrderId:(NSString *)orderId
                       productId:(NSString *)productId
                       companyId:(NSString *)companyId
              order_checkuper_id:(NSString *)order_checkuper_id
                    noAppointNum:(int)noAppointNum
                          gender:(Gender)gender;


/**
 *  仅选择时间和分院,不做其他操作
 *
 *  @param productId
 *  @param examCenterId 分院id
 */
- (void)selectCenterWithProductId:(NSString *)productId
                     examCenterId:(NSString *)examCenterId
                   examCenterName:(NSString *)examCenterName
                      updateBlock:(UpdateParamsBlock)updateBlock;

/**
 *  选择时间、分院以及人
 *
 *  @param productId
 *  @param gender       套餐对应性别
 *  @param noAppointNum 可预约个数
 *  @param updateBlcok  返回字典
 *  key:hospital;//分院
 *  key:userInfo;//用户model数组
 */
- (void)selectCenterAndPeopleWithProductId:(NSString *)productId
                                    gender:(Gender)gender
                              noAppointNum:(int)noAppointNum
                               updateBlock:(UpdateParamsBlock)updateBlcok;

/**
 *  选择时间、分院以及人(可选择传入已选择分院)
 *
 *  @parsm hospitalArray 分院数组,包含分院对应的体检人
 *  @param productId
 *  @param gender       套餐对应性别
 *  @param noAppointNum 可预约个数
 *  @param updateBlcok
 */
- (void)selectCenterAndPeopleWithHospitalArray:(NSArray *)hospitalArray
                                     productId:(NSString *)productId
                                        gender:(Gender)gender
                                  noAppointNum:(int)noAppointNum
                                   updateBlock:(UpdateParamsBlock)updateBlcok;

/**
 *  代金卷直接预约
 *
 *  @param voucherId    代金卷id
 *  @param userInfo    代金卷绑定体检人
 *  @param productModel
 */
- (void)appointWithVoucherId:(NSString *)voucherId
                    userInfo:(id)userInfo
                productModel:(ProductModel *)productModel;

/**
 *  仅选择时间和分院,不做其他操作
 *
 *  @param productId
 *  @param examCenterId 分院id
 */
- (void)selectCenterUserInfo:(UserInfo *)userInfo
                productModel:(ProductModel *)productModel
                 updateBlock:(UpdateParamsBlock)updateBlock;


@end
