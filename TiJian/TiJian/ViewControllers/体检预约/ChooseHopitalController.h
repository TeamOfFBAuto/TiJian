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

@class ProductModel;
@interface ChooseHopitalController : MyViewController<FSCalendarDataSource, FSCalendarDelegate>

@property(nonatomic,retain)FSCalendar *calendar;
@property(nonatomic,retain)NSString *productId;//商品id
@property(nonatomic,retain)NSString *order_id;
@property(nonatomic,assign)int noAppointNum;//剩余未预约个数

///**
// *  仅选择时间和分院,不做其他操作
// *
// *  @param productId
// *  @param examCenterId 分院id
// */
//- (void)setSelectParamWithProductId:(NSString *)productId
//                       examCenterId:(NSString *)examCenterId;

/**
 *  仅选择时间和分院,不做其他操作
 *
 *  @param productId
 *  @param examCenterId 分院id
 */
- (void)setSelectParamWithProductId:(NSString *)productId
                       examCenterId:(NSString *)examCenterId
                     examCenterName:(NSString *)examCenterName;

/**
 *  公司预约参数
 *
 *  @param orderId
 *  @param productId
 *  @param companyId          公司id
 *  @param order_checkuper_id 公司订单特有
 *  @param noAppointNum
 */
- (void)setCompanyAppointOrderId:(NSString *)orderId
                       productId:(NSString *)productId
                       companyId:(NSString *)companyId
              order_checkuper_id:(NSString *)order_checkuper_id
                    noAppointNum:(int)noAppointNum;

@end
