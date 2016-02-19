//
//  HospitalModel.h
//  TiJian
//
//  Created by lichaowei on 15/11/12.
//  Copyright © 2015年 lcw. All rights reserved.
//
/**
 *  分院model
 */
#import "BaseModel.h"

@interface HospitalModel : BaseModel

@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSString *time;

@property(nonatomic,retain)NSArray *usersArray;//对应的user

@property(nonatomic,retain)NSString *exam_center_id;
@property(nonatomic,retain)NSString *center_name;
@property(nonatomic,retain)NSString *brand_id;
@property(nonatomic,retain)NSString *appoint_percent;
@property(nonatomic,retain)NSString *province_id;
@property(nonatomic,retain)NSString *city_id;
@property(nonatomic,retain)NSString *town_id;
@property(nonatomic,retain)NSString *address;
@property(nonatomic,retain)NSString *distance;//距离
@property(nonatomic,retain)NSString *province;
@property(nonatomic,retain)NSString *city;
@property(nonatomic,retain)NSString *brand_name;
@property(nonatomic,retain)NSString *latitude;
@property(nonatomic,retain)NSString *longitude;
@property(nonatomic,retain)NSString *center_phone;
@property(nonatomic,retain)NSString *rest_day;
@property(nonatomic,retain)NSString *status;
@property(nonatomic,retain)NSString *add_time;

@property(nonatomic,retain)NSString *desc;//品牌介绍
@property(nonatomic,retain)NSArray *pic;//分院介绍图
@property(nonatomic,retain)NSString *bus_route;//公交路线

@end
