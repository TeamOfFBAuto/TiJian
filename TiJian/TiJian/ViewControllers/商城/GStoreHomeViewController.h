//
//  GStoreHomeViewController.h
//  TiJian
//
//  Created by gaomeng on 15/10/27.
//  Copyright © 2015年 lcw. All rights reserved.
//


//商城首页
#import "MyViewController.h"
@class GTranslucentSideBar;

@interface GStoreHomeViewController : MyViewController

@property(nonatomic,strong)UITextField *searchTf;//搜索栏输入框;

@property(nonatomic,strong)NSArray *brand_city_list;
@property (nonatomic, strong) GTranslucentSideBar *rightSideBar;//筛选view
@property(nonatomic,strong)NSDictionary *shaixuanDic;
@property(nonatomic,assign)BOOL haveChooseGender;

-(void)searchBtnClickedWithStr:(NSString*)theWord isHotSearch:(BOOL)isHot;

-(void)setEffectViewAlpha:(CGFloat)theAlpha;


-(void)afterChangeCityUpdateTableWithCstr:(NSString *)cStr Pstr:(NSString *)pStr;

@end
