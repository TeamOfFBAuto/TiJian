//
//  GBrandListViewController.h
//  TiJian
//
//  Created by gaomeng on 16/1/26.
//  Copyright © 2016年 lcw. All rights reserved.
//


//按品牌分类的viewcontroller

#import "MyViewController.h"

@interface GBrandListViewController : MyViewController

@property(nonatomic,strong)NSString *class_Id;//分类id
@property(nonatomic,strong)NSString *className;//分类名
@property(nonatomic,assign)BOOL haveChooseGender;//是否有性别选项

@property(nonatomic,strong)NSArray *brand_city_list;
@property(nonatomic,strong)NSDictionary *shaixuanDic;


@end
