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

@property(nonatomic,strong)UIButton *allChooseBtn;

-(void)updateRtabTotolPrice;

-(void)setOpenArray1WithIndex:(int)index;
-(void)setOpenArray0WithIndex:(int)index;

-(void)isAllChooseAndUpdateState;

@end
