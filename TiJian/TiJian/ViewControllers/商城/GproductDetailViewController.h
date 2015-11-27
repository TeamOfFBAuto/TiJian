//
//  GproductDetailViewController.h
//  TiJian
//
//  Created by gaomeng on 15/11/2.
//  Copyright © 2015年 lcw. All rights reserved.
//


//商品详情页

#import "MyViewController.h"

@interface GproductDetailViewController : MyViewController

@property(nonatomic,strong)NSString *productId;

@property(nonatomic,assign)BOOL isShopCarPush;

-(void)goToCommentVc;

-(void)goToProductDetailVcWithId:(NSString *)productId;

@end
