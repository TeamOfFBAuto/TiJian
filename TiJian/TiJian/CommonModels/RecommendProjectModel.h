//
//  RecommendProjectModel.h
//  TiJian
//
//  Created by lichaowei on 16/1/28.
//  Copyright © 2016年 lcw. All rights reserved.
/**
 *  个性化定制 - 推荐套餐model
 */

#import "BaseModel.h"

@interface RecommendProjectModel : BaseModel

@property(nonatomic,retain)NSNumber *star_num;//星级
@property(nonatomic,retain)NSNumber *brand_num;//有对应套餐的品牌个数
@property(nonatomic,retain)NSNumber *min_price;//推荐价格
@property(nonatomic,retain)NSArray *project_list;//项目列表

@end
