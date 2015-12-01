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

-(void)therightSideBarDismiss;

-(void)shaixuanFinishWithDic:(NSDictionary *)dic;

@end
