//
//  MyViewController.h
//  FBCircle
//
//  Created by soulnear on 14-5-12.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    MyViewControllerLeftbuttonTypeBack=0,
    MyViewControllerLeftbuttonTypelogo=1,
    MyViewControllerLeftbuttonTypeOther=2,
    MyViewControllerLeftbuttonTypeNull=3,
    MyViewControllerLeftbuttonTypeText = 4
}MyViewControllerLeftbuttonType;


typedef enum
{
    MyViewControllerRightbuttonTypeRefresh=0,
    MyViewControllerRightbuttonTypeSearch=1,
    MyViewControllerRightbuttonTypeText=2,
    MyViewControllerRightbuttonTypePerson=3,
    MyViewControllerRightbuttonTypeDelete=4,
    MyViewControllerRightbuttonTypeNull=5,
    MyViewControllerRightbuttonTypeOther
}MyViewControllerRightbuttonType;

typedef enum {
 
    NAVIGATIONSTYLE_WHITE = 0,//白色
    NAVIGATIONSTYLE_BLUE = 1 ,//蓝色
    NAVIGATIONSTYLE_CUSTOM = 2 //自定义
    
}NAVIGATIONSTYLE;//导航栏类型

typedef void(^UpdateParamsBlock)(NSDictionary *params);

@interface MyViewController : UIViewController
{
    UIBarButtonItem * spaceButton;
    
    MyViewControllerLeftbuttonType leftType;
    MyViewControllerRightbuttonType myRightType;
    
    UpdateParamsBlock _aParmasBlock;
    
}

@property(nonatomic,assign)UpdateParamsBlock updateParamsBlock;

@property(nonatomic,assign)MyViewControllerLeftbuttonType * leftButtonType;

@property(nonatomic,strong)NSString * rightString;

@property(nonatomic,strong)NSString * leftString;

@property(nonatomic,strong)NSString * leftImageName;

@property(nonatomic,strong)NSString * rightImageName;


@property(nonatomic,assign)BOOL lastPageNavigationHidden;//上一级是否隐藏navigationBar
@property(nonatomic,retain)UIViewController *lastViewController;

///标题
@property(nonatomic,strong)UILabel * myTitleLabel;
@property(nonatomic,strong)NSString * myTitle;
//右上角按钮
@property(nonatomic,strong)UIButton * my_right_button;
///是否添加滑动到侧边栏手势
@property(nonatomic,assign)BOOL isAddGestureRecognizer;

@property(nonatomic,assign)BOOL customNavigationTitleView;//是否自定义导航栏view


-(void)setMyViewControllerLeftButtonType:(MyViewControllerLeftbuttonType)theType WithRightButtonType:(MyViewControllerRightbuttonType)rightType;

- (void)setNavigationStyle:(NAVIGATIONSTYLE)style
                     title:(NSString *)title;
-(void)leftButtonTap:(UIButton *)sender;

-(void)rightButtonTap:(UIButton *)sender;


@end
