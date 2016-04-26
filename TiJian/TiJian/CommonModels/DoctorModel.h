//
//  DoctorModel.h
//  TiJian
//
//  Created by lichaowei on 16/4/25.
//  Copyright © 2016年 lcw. All rights reserved.
//
/**
 *  专家医生
 */
#import "BaseModel.h"

@interface DoctorModel : BaseModel

@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSString *photo;
@property(nonatomic,retain)NSString *titleTypeText;//头衔
@property(nonatomic,retain)NSString *doctorType;
@property(nonatomic,retain)NSString *totalOrderCountShow;
@property(nonatomic,retain)NSString *featureHL;
@property(nonatomic,retain)NSString *doctorPhone;
@property(nonatomic,retain)NSString *hospDeptNameHL;//科室
@property(nonatomic,retain)NSString *detail_url;

@end
