//
//  ShopModel.m
//  YiYiProject
//
//  Created by lichaowei on 15/9/11.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

/**
 *  店铺model
 */
#import "ShopModel.h"

@implementation ShopModel

- (id)initWithShopId:(NSString *)shopId
       productsArray:(NSArray *)productsArray
        couponsArray:(NSArray *)couponsArray
            mallName:(NSString *)mallName
           brandName:(NSString *)brandName
           brandLogo:(NSString *)brandLogo
          totalPrice:(NSString *)totalPrice
          productNum:(NSString *)productNum
{
    self = [super init];
    if (self) {
        
        self.product_shop_id = shopId;
        self.productsArray = productsArray;
        self.couponsArray = couponsArray;
        self.mall_name = mallName;
        self.brand_name = brandName;
        self.brand_logo = brandLogo;
        self.total_price = totalPrice;
        self.productNum = productNum;
    }
    return self;
}

@end
