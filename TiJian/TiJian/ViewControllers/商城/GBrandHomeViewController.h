//
//  GBrandHomeViewController.h
//  TiJian
//
//  Created by gaomeng on 16/1/28.
//  Copyright © 2016年 lcw. All rights reserved.
//


//
#import "MyViewController.h"

@interface GBrandHomeViewController : MyViewController


@property(nonatomic,strong)UITextField *searchTf;//搜索栏输入框;
@property(nonatomic,strong)NSDictionary *shaixuanDic;
@property(nonatomic,assign)BOOL haveChooseGender;
@property(nonatomic,strong)NSArray *brand_city_list;


//下列两个属性必传
@property(nonatomic,strong)NSString *brand_id;//品牌id
@property(nonatomic,strong)NSString *brand_name;//品牌名 控制筛选的品牌选择


-(void)searchBtnClickedWithStr:(NSString*)theWord isHotSearch:(BOOL)isHot;

-(void)setEffectViewAlpha:(CGFloat)theAlpha;


@end
