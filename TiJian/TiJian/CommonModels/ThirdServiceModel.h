//
//  ThirdServiceModel.h
//  TiJian
//
//  Created by lichaowei on 16/6/23.
//  Copyright © 2016年 lcw. All rights reserved.
/**
 *  go健康服务详情model
 */

#import "BaseModel.h"

@interface ThirdServiceModel : BaseModel

@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSNumber *idNumber;
@property(nonatomic,retain)NSString *corServiceId;
@property(nonatomic,retain)NSString *corOwnerId;
@property(nonatomic,retain)NSString *serviceId;
@property(nonatomic,retain)NSNumber *state;
@property(nonatomic,retain)NSNumber *serviceType;
@property(nonatomic,retain)NSNumber *bookType;
@property(nonatomic,retain)NSString *bookTime;
@property(nonatomic,retain)NSDictionary *contact; //联系人
@property(nonatomic,retain)NSArray *testees;//体检人
@property(nonatomic,retain)NSDictionary *address;//上门地址
@property(nonatomic,retain)NSArray *productionIds;//套餐id
@property(nonatomic,retain)NSNumber *isFasting;
@property(nonatomic,retain)NSDictionary *timeLogs;
@property(nonatomic,retain)NSString *nurseId;
@property(nonatomic,retain)NSDictionary *nurse;//护士信息
@property(nonatomic,retain)NSNumber *isMark;


@end
