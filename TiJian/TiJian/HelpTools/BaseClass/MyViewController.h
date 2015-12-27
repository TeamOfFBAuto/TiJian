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
    MyViewControllerLeftbuttonTypeBack = 0,//返回按钮
    MyViewControllerLeftbuttonTypeOther,//自定义image
    MyViewControllerLeftbuttonTypeText ,//文字
    MyViewControllerLeftbuttonTypeNull //无返回按钮

}MyViewControllerLeftbuttonType;


typedef enum
{
    MyViewControllerRightbuttonTypeNull = 0,//空
    MyViewControllerRightbuttonTypeText ,//文字
    MyViewControllerRightbuttonTypeOther //图片
    
}MyViewControllerRightbuttonType;

typedef enum {
 
    NAVIGATIONSTYLE_WHITE = 0,//白色
    NAVIGATIONSTYLE_BLUE = 1 ,//蓝色
    NAVIGATIONSTYLE_CUSTOM = 2 //自定义
    
}NAVIGATIONSTYLE;//导航栏类型

typedef void(^UpdateParamsBlock)(NSDictionary *params);

@interface MyViewController : UIViewController
{
    UIView *_resultView;
}
@property(nonatomic,strong)NSString * rightString;//navigationbar right button text
@property(nonatomic,strong)NSString * leftString;//navigationbar left button text
@property(nonatomic,strong)NSString * leftImageName;
@property(nonatomic,strong)NSString * rightImageName;//图片名字
@property(nonatomic,strong)UIImage * rightImage;//image

@property(nonatomic,copy)UpdateParamsBlock updateParamsBlock;//用户视图间数据回调
@property(nonatomic,assign)BOOL lastPageNavigationHidden;//上一级是否隐藏navigationBar
@property(nonatomic,retain)UIViewController *lastViewController;//上一个视图

@property(nonatomic,strong)NSString * myTitle;//视图标题
@property(nonatomic,retain)UIView *resultView;//结果view

@property(nonatomic,strong)UIButton *right_button;//右边文字button


-(void)setMyViewControllerLeftButtonType:(MyViewControllerLeftbuttonType)theType WithRightButtonType:(MyViewControllerRightbuttonType)rightType;

- (void)setNavigationStyle:(NAVIGATIONSTYLE)style
                     title:(NSString *)title;

/**
 *  控制置顶按钮,需要时在scrollDelegate里面调用
 *
 *  @param scrollView
 */
- (void)controlTopButtonWithScrollView:(UIScrollView *)scrollView;

-(void)leftButtonTap:(UIButton *)sender;

-(void)rightButtonTap:(UIButton *)sender;


@end
