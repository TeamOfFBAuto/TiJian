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

@property(nonatomic,strong)NSString *className;//分类名称

@property(nonatomic,strong)NSArray *brand_city_list;

@property(nonatomic,strong)NSDictionary *shaixuanDic;//筛选参数字典

@property(nonatomic,assign)BOOL isProductDetailVcPush;//是否从单品详情品牌店点击跳转过来的

@property(nonatomic,assign)BOOL haveChooseGender;//yes 可以选择性别  no 限定性别

//代金卷购买套餐
@property(nonatomic,assign)BOOL isVoucherPush;//from 公司代金卷前去购买
@property(nonatomic,strong)NSString *vouchers_id;//代金卷id
@property(nonatomic,strong)NSString *uc_id;//代金卷绑定了个人信息
@property(nonatomic,strong)NSString *brandId;//品牌id
@property(nonatomic,strong)NSString *brandName;//品牌name

-(void)therightSideBarDismiss;

-(void)shaixuanFinishWithDic:(NSDictionary *)dic;

@end
