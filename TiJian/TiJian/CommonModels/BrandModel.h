//
//  BrandModel.h
//  TiJian
//
//  Created by lichaowei on 15/11/26.
//  Copyright © 2015年 lcw. All rights reserved.
/**
 *  品牌model
 */
#import "BaseModel.h"

@interface BrandModel : BaseModel
@property(nonatomic,retain)NSString *brand_id;
@property(nonatomic,retain)NSString *brand_name;//品牌名
@property(nonatomic,retain)NSString *brand_logo;//品牌logo
@property(nonatomic,retain)NSArray *list;
@property(nonatomic,retain)NSArray *productsArray;

@end
