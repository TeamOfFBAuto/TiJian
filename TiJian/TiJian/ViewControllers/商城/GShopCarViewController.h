//
//  GShopCarViewController.h
//  TiJian
//
//  Created by gaomeng on 15/11/6.
//  Copyright © 2015年 lcw. All rights reserved.
//


//购物车
#import "MyViewController.h"

@interface GShopCarViewController : MyViewController

@property(nonatomic,strong)RefreshTableView *rTab;

@property(nonatomic,strong)UILabel *totolPriceLabel;

@property(nonatomic,strong)UILabel *detailPriceLabel;

@property(nonatomic,strong)UIButton *allChooseBtn;

@property(nonatomic,assign)BOOL isPersonalCenterPush;//是从个人中心跳转的购物车

-(void)updateRtabTotolPrice;

-(void)setOpenArray1WithIndex:(int)index;
-(void)setOpenArray0WithIndex:(int)index;

-(void)isAllChooseAndUpdateState;

@end
