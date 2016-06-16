//
//  GStoreHomeViewController.h
//  TiJian
//
//  Created by gaomeng on 15/10/27.
//  Copyright © 2015年 lcw. All rights reserved.
//


//商城首页
#import "MyViewController.h"
#import "GoHealthAppointViewController.h"
@class GTranslucentSideBar;

@interface GStoreHomeViewController : MyViewController

@property(nonatomic,strong)UITextField *searchTf;//搜索栏输入框;
@property(nonatomic,strong)NSArray *brand_city_list;
@property (nonatomic, strong) GTranslucentSideBar *rightSideBar;//筛选view
@property(nonatomic,strong)NSDictionary *shaixuanDic;//筛选条件集合
@property(nonatomic,assign)BOOL haveChooseGender;//是否选择性别

//点击键盘的搜索按钮
-(void)searchBtnClickedWithStr:(NSString*)theWord isHotSearch:(BOOL)isHot;
//设置导航栏透明度
-(void)setEffectViewAlpha:(CGFloat)theAlpha;
//选择城市后回调
-(void)afterChooseCity:(NSString *)theCity province:(NSString *)theProvince;
//根据城市获取品牌信息
-(void)prepareBrandListWithLocation;
@end
