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
@property(nonatomic,retain)NSString *main_product_id;//主套餐id,是加强包时才有
@property(nonatomic,retain)NSString *setmeal_id;
@property(nonatomic,retain)NSString *setmeal_inprice;
@property(nonatomic,retain)NSString *setmeal_name;
@property(nonatomic,retain)NSString *setmeal_original_price;
@property(nonatomic,retain)NSString *setmeal_price;
@property(nonatomic,retain)NSString *shelf_status;
@property(nonatomic,retain)NSString *status;
@property(nonatomic,retain)NSString *type_id;
@property(nonatomic,strong)NSString *setmeal_desc;//套餐描述
@property(nonatomic,strong)NSArray *package_project;//加项包包含的项目数组 

@property(nonatomic,retain)NSString *is_recommend;
@property(nonatomic,retain)NSString *is_comment;//是否评论
@property(nonatomic,retain)NSDictionary *small_cover_pic;
//单品详情相关
@property(nonatomic,strong)NSArray *suit_info;
@property(nonatomic,strong)NSString *gender_id;// 1男 2女 99通用 套餐适用性别
@property(nonatomic,strong)NSArray *project_info;
@property(nonatomic,strong)NSArray *coupon_list;
@property(nonatomic,strong)NSString *is_favor;//是否收藏 1收藏 2未收藏
@property(nonatomic,strong)NSString *track_time;//足迹时间
@property(nonatomic,strong)NSString *brand_logo;//品牌logo


//购物车相关
@property(nonatomic,strong)NSString *product_name;
@property(nonatomic,strong)NSString *current_price;
@property(nonatomic,strong)NSString *product_num;
@property(nonatomic,assign)BOOL userChoose;//用户是否选择
@property(nonatomic,strong)NSString *brand_name;
@property(nonatomic,strong)NSString *cart_pro_id;//购物车id
@property(nonatomic,strong)NSString *original_price;//原价
@property(nonatomic,assign)CGFloat afterUsedYouhuiquan_Price;//使用优惠券之后的价钱
@property(nonatomic,assign)CGFloat afterUsedDaijinquan_Price;//使用代金券之后的价钱

//预约相关
@property(nonatomic,strong)NSString *type;//1 公司购买套餐 2 公司代金券 3 普通套餐
@property(nonatomic,strong)NSString *company_id;//公司id
@property(nonatomic,strong)NSString *order_checkuper_id;//绑定的人
@property(nonatomic,strong)NSDictionary *company_info;//"company_id": "1",company_name": "阿里集团"
@property(nonatomic,strong)NSString *coupon_id;
@property(nonatomic,strong)NSString *uc_id;//代金券coupon_id升级-----后台用于获取绑定用户性别
@property(nonatomic,strong)NSString *vouchers_price;//代金券金额
//@property(nonatomic,strong)NSString *description;
@property(nonatomic,strong)NSString *deadline;
@property(nonatomic,strong)NSString *product_total_num;
@property(nonatomic,strong)NSString *product_price;
@property(nonatomic,strong)NSString *appointed_num;
@property(nonatomic,strong)NSString *no_appointed_num;

@property(nonatomic,strong)NSDictionary *checkuper_info;//{age;gender;id_card;mobile;order_checkuper_id;user_name;

@property(nonatomic,strong)NSString *order_id;//对应订单id

@property(nonatomic,retain)NSNumber *is_append;//是否是加项

@property(nonatomic,assign)BOOL isLimitUserInfo;//是否限定体检人


@property(nonatomic,strong)NSMutableArray *hospitalArray;//分院数组 里面装HopitalModel
@property(nonatomic,strong)NSMutableArray *addProductsArray;//加项包数组里面装ProductModel



//套餐加强包
@property(nonatomic,retain)NSString *package_price;
@property(nonatomic,retain)NSString *package_original_price;
@property(nonatomic,retain)NSString *package_name;

//详情web链接
@property(nonatomic,retain)NSString *info_url;//详情web链接

@end
