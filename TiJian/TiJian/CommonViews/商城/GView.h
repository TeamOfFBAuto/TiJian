//
//  GView.h
//  TiJian
//
//  Created by gaomeng on 16/5/10.
//  Copyright © 2016年 lcw. All rights reserved.
//


//商城首页分类自定义view
#import <UIKit/UIKit.h>

typedef void(^classViewClickedBlock)(int theTag);

typedef enum{
    ClassViewType_qiyetijian,
    ClassViewType_youshang,
    ClassViewType_smallfenlei
}ClassViewType;

@interface GView : UIView

@property(nonatomic,strong)UIImageView *logoImv;//小图
@property(nonatomic,strong)UILabel *titleLabel_black;//黑色文字描述
@property(nonatomic,strong)UILabel *titleLabel_gray;//灰色文字描述
@property(nonatomic,copy)classViewClickedBlock classViewClickedBlock;

-(void)setClassViewClickedBlock:(classViewClickedBlock)classViewClickedBlock;
-(id)initWithFrame:(CGRect)frame tag:(int)theTag type:(ClassViewType)theType;

@end
