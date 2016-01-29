//
//  GBrandTabHeaderView.h
//  TiJian
//
//  Created by gaomeng on 16/1/29.
//  Copyright © 2016年 lcw. All rights reserved.
//


//品牌店首页tableviewHeader

#import <UIKit/UIKit.h>

@interface GBrandTabHeaderView : UIView

@property(nonatomic,strong)UIImageView *brandBannerImv;//背景图
@property(nonatomic,strong)UIImageView *logoImv;//logo
@property(nonatomic,strong)UILabel *brandName;
@property(nonatomic,strong)UILabel *liulanNum;

@property(nonatomic,strong)UIView *classView;//分类view
@property(nonatomic,strong)UIView *fourBtnView;//四个按钮view

-(id)initWithFrame:(CGRect)frame;

-(void)reloadViewWithBrandDic:(NSDictionary *)theBranddic classDic:(NSDictionary *)theClassDic;

@end
