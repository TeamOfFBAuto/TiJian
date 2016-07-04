//
//  ThirdProductModel.h
//  TiJian
//
//  Created by lichaowei on 16/6/7.
//  Copyright © 2016年 lcw. All rights reserved.
/**
 *  三方产品id
 */

#import "BaseModel.h"

@interface ThirdProductModel : BaseModel

@property(nonatomic,retain)NSString *id;
@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSString *serviceType;
@property(nonatomic,retain)NSString *testeeNum;
@property(nonatomic,retain)NSString *state;
@property(nonatomic,retain)NSString *isFasting;
@property(nonatomic,retain)NSNumber *price;
@property(nonatomic,retain)NSNumber *discountPrice;
@property(nonatomic,retain)NSNumber *settlePrice;//结算价格
@property(nonatomic,retain)NSArray *items;//体检项目
@property(nonatomic,retain)NSArray *avaliableCities;//可用城市
@property(nonatomic,retain)NSArray *pictures;
@property(nonatomic,retain)NSNumber *noFreeService;
@property(nonatomic,retain)NSNumber *profitPrice;
//@property(nonatomic,retain)NSString *description;//产品描述
@property(nonatomic,retain)NSNumber *idNumber;

@end

