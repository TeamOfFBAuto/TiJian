//
//  BrandRecommendController.h
//  TiJian
//
//  Created by lichaowei on 16/1/27.
//  Copyright © 2016年 lcw. All rights reserved.
/**
 *  品牌推荐
 */

#import "MyViewController.h"

@interface BrandRecommendController : MyViewController


@property(nonatomic,assign)RecommendType recommendType;

//疾病项目推荐套餐
@property (nonatomic,retain)NSString *diseaseId;

//个性化定制
@property(nonatomic,retain)NSString *result_id;//结果id


@property(nonatomic,assign)int starNum;//星星个数
@property(nonatomic,retain)NSString *min_price;//价格

@end
