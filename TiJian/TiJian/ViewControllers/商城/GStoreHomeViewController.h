//
//  GStoreHomeViewController.h
//  TiJian
//
//  Created by gaomeng on 15/10/27.
//  Copyright © 2015年 lcw. All rights reserved.
//


//商城首页
#import "MyViewController.h"

@interface GStoreHomeViewController : MyViewController

@property(nonatomic,strong)UITextField *searchTf;//搜索栏输入框;

-(void)searchBtnClickedWithStr:(NSString*)theWord isHotSearch:(BOOL)isHot;

-(void)setEffectViewAlpha:(CGFloat)theAlpha;


-(void)afterChangeCityUpdateTableWithCstr:(NSString *)cStr Pstr:(NSString *)pStr;

@end
