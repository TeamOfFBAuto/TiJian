//
//  AppointModel.h
//  TiJian
//
//  Created by lichaowei on 15/11/16.
//  Copyright © 2015年 lcw. All rights reserved.
/**
 *  预约model
 */

#import "BaseModel.h"

@interface AppointModel : BaseModel

@property(nonatomic,retain)NSString *appoint_id;
@property(nonatomic,retain)NSString *order_id;
@property(nonatomic,retain)NSString *user_relation;
@property(nonatomic,retain)NSString *user_name;
@property(nonatomic,retain)NSString *exam_center_id;
@property(nonatomic,retain)NSString *appointment_exam_time;
@property(nonatomic,retain)NSString *center_name;
@property(nonatomic,retain)NSString *days;//天数 过期多少天,或者剩余多少天去条件;需要结合expired

//预约详情
@property(nonatomic,retain)NSString *age;//预约人年龄
@property(nonatomic,retain)NSString *appointment_no;
@property(nonatomic,retain)NSString *appointment_status;
@property(nonatomic,retain)NSString *appointment_time;
@property(nonatomic,retain)NSString *cancel_time;
@property(nonatomic,retain)NSString *center_phone;//分院电话
@property(nonatomic,retain)NSString *company_id;
@property(nonatomic,retain)NSString *company_name;
@property(nonatomic,retain)NSString *company_user_id;
@property(nonatomic,retain)NSString *expired;//1过期 0 未过期
@property(nonatomic,retain)NSString *gender;
@property(nonatomic,retain)NSString *id_card;
@property(nonatomic,retain)NSString *mobile;
@property(nonatomic,retain)NSString *setmeal_name;//套餐内容或者名称
@property(nonatomic,retain)NSString *setmeal_gender;//套餐对应的性别
@property(nonatomic,retain)NSString *product_id;//套餐对应id
@property(nonatomic,retain)NSString *cover_pic;//套餐图

@property(nonatomic,retain)NSString *status;
@property(nonatomic,retain)NSString *center_latitude;//维度
@property(nonatomic,retain)NSString *center_longitude;//经度



@end
