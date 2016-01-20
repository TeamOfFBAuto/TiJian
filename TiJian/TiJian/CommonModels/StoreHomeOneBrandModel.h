//
//  StoreHomeOneBrandModel.h
//  TiJian
//
//  Created by gaomeng on 16/1/20.
//  Copyright © 2016年 lcw. All rights reserved.
//

/**
 *  商城首页精品推荐一个品牌model
 */

#import "BaseModel.h"
#import "ProductModel.h"

@interface StoreHomeOneBrandModel : BaseModel

@property(nonatomic,strong)NSArray *list;//里面装的是productmodel
@property(nonatomic,strong)NSString *brand_id;//品牌id
@property(nonatomic,strong)NSString *brand_name;//品牌名
@property(nonatomic,strong)NSString *brand_logo;//品牌logo

@end
