//
//  GStoreHomeViewController+ios11NavigationBar.m
//  TiJian
//
//  Created by gaomeng on 2017/12/9.
//  Copyright © 2017年 lcw. All rights reserved.
//

#import "GStoreHomeViewController+ios11NavigationBar.h"
#import "DLNavigationEffectKit.h"

@implementation GStoreHomeViewController (ios11NavigationBar)

/**
 自定义导航栏
 */
-(void)setUpNavitationBar{
    
    [self resetShowCustomNavigationBar:YES];
    
    //自定义view
    UIView * view_custom_navigationBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.currentNavigationBar.width, self.currentNavigationBar.height)];

    //返回按钮
    [view_custom_navigationBar addSubview:[self creatLeftBtn]];

    //搜索view
    [view_custom_navigationBar addSubview:[self creatSearchView]];

    //右侧按钮
    [view_custom_navigationBar addSubview:[self creatRightBtn]];

    //添加自定义navigationView
    [self.currentNavigationBar addSubview:view_custom_navigationBar];


    UIView *effectView = self.currentNavigationBar.effectContainerView;
    if (effectView) {
        UIView *alphaView = [[UIView alloc] initWithFrame:effectView.bounds];
        [effectView addSubview:alphaView];
        alphaView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.8];
        alphaView.tag = 10000;
    };
    

    //编辑状态
    self.editState = 0;
    [self setEffectViewAlpha:0];
    [self changeNavigationBarSearchViewState:0];
    
}



#pragma mark - 编辑状态 常态 切换
-(void)changeNavigationBarSearchViewState:(int)state{
    self.editState = state;
    if (state == 0) {//常态
        [self.myNavcRightBtn setTitle:nil forState:UIControlStateNormal];
        [self.myNavcRightBtn setImage:[UIImage imageNamed:@"fenyuan_storehome.png"] forState:UIControlStateNormal];
        
        UIView *effectView = self.currentNavigationBar.effectContainerView;
        if (effectView) {
            for (UIView *view in effectView.subviews) {
                if (view.tag == 10000) {
                    view.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.8];
                }
            }
        };
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.searchView setFrame:CGRectMake(44, iPhoneX ? 27 + 20 : 27, DEVICE_WIDTH - 90, 30)];
            [self.kuangView setFrame:CGRectMake(0, 0, self.searchView.frame.size.width, 30)];
            [self.searchTf setFrame:CGRectMake(30, 0, self.kuangView.frame.size.width - 30, 30)];
        }];
        
        
        
        if (!self.panGestureRecognizer) {
            self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        }
        [self.view addGestureRecognizer:self.panGestureRecognizer];
        
        
    }else if (state == 1){//编辑状态
        [self.myNavcRightBtn setImage:nil forState:UIControlStateNormal];
        [self.myNavcRightBtn setTitle:@"取消" forState:UIControlStateNormal];
        
        UIView *effectView = self.currentNavigationBar.effectContainerView;
        if (effectView) {
            for (UIView *view in effectView.subviews) {
                if (view.tag == 10000) {
                    view.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:1];
                }
            }
        };
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.searchView setFrame:CGRectMake(15, iPhoneX ? 27 + 20 : 27, DEVICE_WIDTH - 60, 30)];
            [self.kuangView setFrame:CGRectMake(0, 0, self.searchView.frame.size.width, 30)];            
            [self.searchTf setFrame:CGRectMake(30, 0, self.kuangView.frame.size.width-30, 30)];
        }];
        
        [self.view removeGestureRecognizer:self.panGestureRecognizer];
    }
}



#pragma mark - 视图创建
//左侧返回按钮
-(UIButton*)creatLeftBtn{
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(5, iPhoneX ? 25 + 20 : 25, 32, 32)];
    [leftBtn setImage:[UIImage imageNamed:@"back_storehome.png"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(gogoback) forControlEvents:UIControlEventTouchUpInside];
    return leftBtn;
}

//中间搜索view
-(UIView *)creatSearchView{
    self.searchView = [[UIView alloc]initWithFrame:CGRectZero];
    self.searchView.layer.cornerRadius = 5;
    self.searchView.backgroundColor = [UIColor whiteColor];
    
    //带框的view
    self.kuangView = [[UIView alloc]initWithFrame:CGRectZero];
    self.kuangView.layer.cornerRadius = 5;
    self.kuangView.layer.borderColor = [RGBCOLOR(192, 193, 194)CGColor];
    self.kuangView.layer.borderWidth = 0.5;
    [self.searchView addSubview:self.kuangView];
    
    //输入框
    self.searchTf = [[UITextField alloc]initWithFrame:CGRectZero];
    self.searchTf.font = [UIFont systemFontOfSize:13];
    self.searchTf.backgroundColor = [UIColor whiteColor];
    self.searchTf.layer.cornerRadius = 5;
    self.searchTf.placeholder = @"输入您要找的商品";
    self.searchTf.delegate = self;
    self.searchTf.returnKeyType = UIReturnKeySearch;
    self.searchTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.kuangView addSubview:self.searchTf];
    
    //放大镜
    UIImageView *fdjImv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 13, 13)];
    [fdjImv setImage:[UIImage imageNamed:@"search_fangdajing.png"]];
    [self.searchView addSubview:fdjImv];
    
    return self.searchView;
}

//右侧按钮
-(UIButton *)creatRightBtn{
    self.myNavcRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.myNavcRightBtn setFrame:CGRectMake(DEVICE_WIDTH - 40, iPhoneX ? 25 + 20 : 25, 30, 30)];
    self.myNavcRightBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.myNavcRightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.myNavcRightBtn addTarget:self action:@selector(myNavcRightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    return self.myNavcRightBtn;
}



@end
