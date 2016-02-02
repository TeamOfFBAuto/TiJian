//
//  GBrandTabHeaderView.h
//  TiJian
//
//  Created by gaomeng on 16/1/29.
//  Copyright © 2016年 lcw. All rights reserved.
//


//品牌店首页tableviewHeader

#import <UIKit/UIKit.h>

typedef void(^fourBtnClickedBlock)(NSInteger index , BOOL state);
typedef void(^classImvClickedBlock)(NSInteger index);
typedef void(^bannerImvClickedBlock)();

@interface GBrandTabHeaderView : UIView
{
    BOOL _priceState;
}
@property(nonatomic,strong)UIImageView *brandBannerImv;//背景图
@property(nonatomic,strong)UIImageView *logoImv;//logo
@property(nonatomic,strong)UILabel *brandName;
@property(nonatomic,strong)UILabel *liulanNum;

@property(nonatomic,strong)UIView *classView;//分类view
@property(nonatomic,strong)UIView *fourBtnView;//四个按钮view
@property(nonatomic,strong)NSMutableArray *fourBtnArray;//四个按钮的数组


@property(nonatomic,copy)fourBtnClickedBlock fourBtnClickedBlock;
@property(nonatomic,copy)classImvClickedBlock classImvClickedBlock;
@property(nonatomic,copy)bannerImvClickedBlock bannerImvClickedBlock;

-(id)initWithFrame:(CGRect)frame;

-(UIView *)getFourBtnView;

-(void)reloadViewWithBrandDic:(NSDictionary *)theBranddic classDic:(NSDictionary *)theClassDic;

-(void)setFourBtnClickedBlock:(fourBtnClickedBlock)fourBtnClickedBlock;

-(void)setClassImvClickedBlock:(classImvClickedBlock)classImvClickedBlock;

-(void)setBannerImvClickedBlock:(bannerImvClickedBlock)bannerImvClickedBlock;

@end
