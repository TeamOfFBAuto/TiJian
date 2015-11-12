//
//  ProductModel.h
//  TiJian
//
//  Created by lichaowei on 15/11/4.
//  Copyright © 2015年 lcw. All rights reserved.
//

/**
 *  产品model
 */
#import "BaseModel.h"

@interface ProductModel : BaseModel
@property(nonatomic,retain)NSString *add_time;
@property(nonatomic,retain)NSString *brand_id;
@property(nonatomic,retain)NSArray  *city_info;
@property(nonatomic,retain)NSString *comment_num;
@property(nonatomic,retain)NSString *cover_pic;
@property(nonatomic,retain)NSString *cover_pic_height;
@property(nonatomic,retain)NSString *cover_pic_width;
@property(nonatomic,retain)NSString *favor_num;
@property(nonatomic,retain)NSString *gender;
@property(nonatomic,retain)NSString *is_common;
@property(nonatomic,retain)NSString *product_id;
@property(nonatomic,retain)NSString *setmeal_id;
@property(nonatomic,retain)NSString *setmeal_inprice;
@property(nonatomic,retain)NSString *setmeal_name;
@property(nonatomic,retain)NSString *setmeal_original_price;
@property(nonatomic,retain)NSString *setmeal_price;
@property(nonatomic,retain)NSString *shelf_status;
@property(nonatomic,retain)NSString *status;
@property(nonatomic,retain)NSString *type_id;

//购物车相关
@property(nonatomic,strong)NSString *product_name;
@property(nonatomic,strong)NSString *current_price;
@property(nonatomic,strong)NSString *product_num;
@property(nonatomic,assign)BOOL userChoose;//用户是否选择
@property(nonatomic,strong)NSString *brand_name;
@property(nonatomic,strong)NSString *cart_pro_id;//购物车id
@property(nonatomic,strong)NSString *original_price;//原价

@end
