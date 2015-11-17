//
//  ShopModel.h
//  YiYiProject
//
//  Created by lichaowei on 15/9/11.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  确认订单 店铺model (单品按照店铺分组)
 */
#import "BaseModel.h"

@interface ShopModel : BaseModel

@property(nonatomic,retain)NSString *product_shop_id;
@property(nonatomic,retain)NSArray *productsArray;//单品列表
@property(nonatomic,retain)NSArray *products;//存字典
@property(nonatomic,retain)NSArray *couponsArray;//优惠劵

@property(nonatomic,retain)NSString *mall_name;//商场或者店铺名
@property(nonatomic,retain)NSString *brand_name;//品牌名
@property(nonatomic,retain)NSString *brand_logo;//品牌logo
@property(nonatomic,retain)NSString *total_price;//对应单品的总价
@property(nonatomic,retain)NSString *productNum;//单品总数

//@property(nonatomic,retain)NSString *productPrice;//记录单品单价
@property(nonatomic,retain)NSString *note;//备注
@property(nonatomic,retain)NSString *order_note;//备注

@property(nonatomic,retain)id couponModel;//使用的优惠券

@property(nonatomic,assign)BOOL onlyShow;//是否是只用于展示

- (id)initWithShopId:(NSString *)shopId
       productsArray:(NSArray *)productsArray
        couponsArray:(NSArray *)couponsArray
            mallName:(NSString *)mallName
           brandName:(NSString *)brandName
           brandLogo:(NSString *)brandLogo
          totalPrice:(NSString *)totalPrice
          productNum:(NSString *)productNum;

@end
