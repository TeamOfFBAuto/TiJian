//
//  BrandSearchViewController.h
//  TiJian
//
//  Created by gaomeng on 16/2/26.
//  Copyright © 2016年 lcw. All rights reserved.
//


//品牌店搜索界面

#import "MyViewController.h"

@interface BrandSearchViewController : MyViewController

@property(nonatomic,strong)NSString *brand_id;//品牌id
@property(nonatomic,strong)NSString *brand_name;//品牌名
@property(nonatomic,strong)NSString *category_id;//分类id
@property(nonatomic,strong)UITextField *searchTf;//搜索框
@property(nonatomic,strong)NSString *theSearchWorld;//搜索词


@property(nonatomic,strong)UIView *fourBtnView;
@property(nonatomic,strong)NSMutableArray *fourBtnArray;


@end
