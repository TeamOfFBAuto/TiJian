//
//  GoneClassListViewController.h
//  TiJian
//
//  Created by gaomeng on 15/11/2.
//  Copyright © 2015年 lcw. All rights reserved.
//



//商城单一分类列表页
#import "MyViewController.h"

@interface GoneClassListViewController : MyViewController

@property(nonatomic,assign)int category_id;//分类id

@property(nonatomic,strong)NSString *className;//分类名称 控制title显示

@property(nonatomic,strong)NSString *brand_id;//品牌id 控制筛选的品牌选择 品牌店套餐列表
@property(nonatomic,strong)NSString *brand_name;//品牌名 控制筛选的品牌选择

@property(nonatomic,strong)NSArray *brand_city_list;

@property(nonatomic,strong)NSDictionary *shaixuanDic;//筛选参数字典

@property(nonatomic,assign)BOOL isProductDetailVcPush;//是否从单品详情品牌店点击跳转过来的

@property(nonatomic,assign)BOOL haveChooseGender;//yes 可以选择性别  no 限定性别

@property(nonatomic,assign)BOOL isShowShaixuanAuto;//自动显示筛选


@property(nonatomic,strong)NSString *theSearchWorld;//是否为搜索跳转过来的

//代金券购买套餐
@property(nonatomic,strong)NSString *vouchers_id;//代金券id
@property(nonatomic,strong)NSString *uc_id;//代金券绑定了个人信息
@property(nonatomic,strong)NSString *brandId;//品牌id
@property(nonatomic,strong)NSString *brandName;//品牌name


//搜索框相关
@property(nonatomic,strong)UITextField *searchTf;

-(void)therightSideBarDismiss;

-(void)shaixuanFinishWithDic:(NSDictionary *)dic;

-(void)searchBtnClickedWithStr:(NSString*)theWord isHotSearch:(BOOL)isHot;

@end
