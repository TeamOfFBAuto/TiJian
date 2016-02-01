//
//  SetmealModel.h
//  TiJian
//
//  Created by lichaowei on 16/1/27.
//  Copyright © 2016年 lcw. All rights reserved.
/**
 *  套餐
 */

#import "BaseModel.h"

@interface SetmealModel : BaseModel

@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSString *price;
@property(nonatomic,assign)int startNum;
@property(nonatomic,retain)NSString *content;
@property(nonatomic,assign)int brand_num;//推荐品牌个数

@end
