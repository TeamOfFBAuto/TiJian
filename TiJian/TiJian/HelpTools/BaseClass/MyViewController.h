//
//  MyViewController.h
//  FBCircle
//
//  Created by soulnear on 14-5-12.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultView.h"
#import "RefreshTableView.h"
typedef enum
{
    MyViewControllerLeftbuttonTypeBack = 0,//返回按钮
    MyViewControllerLeftbuttonTypeOther,//自定义image
    MyViewControllerLeftbuttonTypeText ,//文字
    MyViewControllerLeftbuttonTypeNull, //无返回按钮
    MyViewControllerLeftbuttonTypeDouble //左侧两个

}MyViewControllerLeftbuttonType;


typedef enum
{
    MyViewControllerRightbuttonTypeNull = 0,//空
    MyViewControllerRightbuttonTypeText ,//文字
    MyViewControllerRightbuttonTypeOther, //图片
    MyViewControllerRightbuttonTypeDouble //右侧两个按钮
    
}MyViewControllerRightbuttonType;

typedef enum {
 
    NAVIGATIONSTYLE_WHITE = 0,//白色
    NAVIGATIONSTYLE_BLUE = 1 ,//蓝色
    NAVIGATIONSTYLE_CUSTOM = 2 //自定义
    
}NAVIGATIONSTYLE;//导航栏类型

typedef void(^UpdateParamsBlock)(NSDictionary *params);

@interface MyViewController : UIViewController
{
    ResultView *_resultView;
    RefreshTableView *_tableView;
}
@property(nonatomic,strong)NSString * rightString;//navigationbar right button text
@property(nonatomic,strong)NSString * leftString;//navigationbar left button text
@property(nonatomic,strong)NSString * leftString2;//navigationbar left button text
@property(nonatomic,strong)NSString * leftImageName;
@property(nonatomic,strong)NSString * leftImageName2;

@property(nonatomic,strong)NSString * rightImageName;//图片名字
@property(nonatomic,strong)UIImage * rightImage;//image
@property(nonatomic,strong)UIImage * rightImage2;//image 右1


@property(nonatomic,copy)UpdateParamsBlock updateParamsBlock;//用户视图间数据回调
@property(nonatomic,assign)BOOL lastPageNavigationHidden;//上一级是否隐藏navigationBar
@property(nonatomic,assign)UIViewController *lastViewController;//上一个视图

@property(nonatomic,strong)NSString * myTitle;//视图标题
@property(nonatomic,retain)UIView *resultView;//结果view

@property(nonatomic,strong)UIButton *right_button;//右边文字button
@property(nonatomic,strong)UIButton *right_button2;//右边button,左1

@property(nonatomic,strong)RefreshTableView *tableView;

/**
 *  设置block回调
 *
 *  @param updateParamsBlock block
 */
-(void)setUpdateParamsBlock:(UpdateParamsBlock)updateParamsBlock;

-(void)setMyViewControllerLeftButtonType:(MyViewControllerLeftbuttonType)theType
                     WithRightButtonType:(MyViewControllerRightbuttonType)rightType;

/**
 *  设置导航栏左、右按钮以及navigationTitle
 *
 *  @param theType   左侧按钮type
 *  @param rightType 右侧按钮type
 *  @param title     navigationBar标题
 */
-(void)setMyViewControllerLeftButtonType:(MyViewControllerLeftbuttonType)theType
                     withRightButtonType:(MyViewControllerRightbuttonType)rightType
                         navigationTitle:(NSString *)title;

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
-(void)rightButtonTap2:(UIButton *)sender;

/**
 *  请求数据结果页
 *
 *  @param type           结果类型
 *  @param title          信息提示title
 *  @param errMsg         信息提示信息
 *  @param btnTitle       按钮信息
 *  @param updateSelector 点击行为
 *
 *  @return
 */
-(ResultView *)resultViewWithType:(PageResultType)type
                            title:(NSString *)title
                              msg:(NSString *)errMsg
                         btnTitle:(NSString *)btnTitle
                         selector:(SEL)selector;

@end
