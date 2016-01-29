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
@class GoneClassListViewController;

@protocol GsearchViewDelegate <NSObject>

@property(nonatomic,strong)UITextField *searchTf;//搜索栏输入框;
-(void)searchBtnClickedWithStr:(NSString*)theWord isHotSearch:(BOOL)isHot;
-(void)setEffectViewAlpha:(CGFloat)theAlpha;

@end

typedef void (^kuangBlock)(NSString *theStr);//定义block  cell点击block

@interface GSearchView : UIView<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property(nonatomic,strong)NSArray *hotSearch;//热搜
@property(nonatomic,strong)UITableView *tab;//历史搜索tableview

@property(nonatomic,assign)id<GsearchViewDelegate>delegate;//代理


@property(nonatomic,strong)NSArray *dataArray;//数据源


@property(nonatomic,copy)kuangBlock kuangBlock;//弄成属性
-(void)setKuangBlock:(kuangBlock)kuangBlock;//block的set方法


@end
