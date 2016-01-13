//
//  GSearchView.h
//  TiJian
//
//  Created by gaomeng on 16/1/7.
//  Copyright © 2016年 lcw. All rights reserved.
//



//自定义搜索view

#import <UIKit/UIKit.h>
@class GStoreHomeViewController;
@class GCustomSearchViewController;

typedef void (^kuangBlock)(NSString *theStr);//定义block

@interface GSearchView : UIView<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)NSArray *hotSearch;//热搜
@property(nonatomic,strong)UITableView *tab;//历史搜索tableview
@property(nonatomic,strong)GStoreHomeViewController *d1;//代理
@property(nonatomic,strong)GCustomSearchViewController *d2;//代理
@property(nonatomic,strong)NSArray *dataArray;//数据源


@property(nonatomic,copy)kuangBlock kuangBlock;//弄成属性
-(void)setKuangBlock:(kuangBlock)kuangBlock;//block的set方法


@end
