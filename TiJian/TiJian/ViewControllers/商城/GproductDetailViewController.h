//
//  GproductDetailViewController.h
//  TiJian
//
//  Created by gaomeng on 15/11/2.
//  Copyright © 2015年 lcw. All rights reserved.
//


//商品详情页

#import "MyViewController.h"
@class ProductModel;

@interface GproductDetailViewController : MyViewController

@property(nonatomic,strong)NSString *productId;

@property(nonatomic,assign)BOOL isShopCarPush;

@property(nonatomic,strong)ProductModel *theProductModel;//产品model
@property(nonatomic,strong)UIImage *gouwucheProductImage;//动画image

@property(nonatomic,assign)BOOL isVoucherPush;//是否是代金券过来

@property(nonatomic,strong)NSString *uc_id;//代金卷和用户信息绑定

@property(nonatomic,strong)NSString *VoucherId;//代金券id

@property(nonatomic,strong)NSDictionary *userChooseLocationDic;//用户选择筛选的地址


-(void)goToCommentVc;

-(void)goToProductDetailVcWithId:(NSString *)productId;

@end
