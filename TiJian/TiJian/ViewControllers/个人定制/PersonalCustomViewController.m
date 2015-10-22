//
//  PersonalCustomViewController.m
//  TiJian
//
//  Created by lichaowei on 15/10/21.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "PersonalCustomViewController.h"
#import "LQuestionView.h"

@interface PersonalCustomViewController ()
{
    UIView *_view_sex;//性别选择
    UIView *_view_Age;//年龄
    UIView *_bottomView;//底部view
    UIScrollView *_scroll;//底部scroll
    
    UIView *_lastView;//上一个view
    UIView *_currentView;//当前view
    UIView *_newView;//下一个view
}

@end

@implementation PersonalCustomViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _scroll = [[UIScrollView alloc]init];
    _scroll.scrollEnabled = NO;
    [self.view addSubview:_scroll];
    [_scroll mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self prepareSexView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 视图创建

/**
 *  性别选择视图
 */
- (void)prepareSexView
{
    //选择性别
    _view_sex = [[UIView alloc]init];
    _view_sex.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_view_sex];
    [_view_sex mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    _currentView = _view_sex;
    
    UIImage *bgImage = [UIImage imageNamed:@"1_1_bg"];
    CGFloat width = bgImage.size.width;
    CGFloat height = bgImage.size.height;
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, [LTools fitHeight:85], FitScreen(width), FitScreen(height))];
    imageView.image = bgImage;
    imageView.centerX = self.view.centerX;
    [_view_sex addSubview:imageView];
    
    //选项
    UIImage *boyImage = [UIImage imageNamed:@"1_2_boy"];
    UIImage *girlImage = [UIImage imageNamed:@"1_3_girl"];
    CGFloat imageWidth = boyImage.size.width;
    CGFloat imageHeight = boyImage.size.height;
    CGFloat aWidth = (DEVICE_WIDTH - imageWidth * 2)/ 3.f;//每个选项宽度
    for (int i = 0; i < 2; i ++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == 0) {
            [btn setImage:boyImage forState:UIControlStateNormal];
        }else if (i == 1){
            [btn setImage:girlImage forState:UIControlStateNormal];
        }
        btn.tag = 100 + i;//100 为男 101 为女
        [_view_sex addSubview:btn];
        [btn addTarget:self action:@selector(clickToSelectSex:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(aWidth + (imageWidth + aWidth) * i, [LTools fitHeight:50] + imageView.bottom, imageWidth, imageHeight);

    }
}

- (void)prepareBottom
{
    if (_bottomView) {
        return;
    }
    _bottomView = [[UIView alloc]init];
    [self.view addSubview:_bottomView];
    _bottomView.backgroundColor = [UIColor redColor];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(0);
        make.size.mas_equalTo(CGSizeMake(DEVICE_WIDTH, FitScreen(40)));
    }];
    
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, 0, FitScreen(40), FitScreen(40));
    [backBtn setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
    [_bottomView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(clickToLast:) forControlEvents:UIControlEventTouchUpInside];

    CGFloat left = DEVICE_WIDTH - FitScreen(40);
    //前进按钮
    UIButton *forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forwardBtn.frame = CGRectMake(left, 0, FitScreen(40), FitScreen(40));
    [forwardBtn setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
    [_bottomView addSubview:forwardBtn];
    [forwardBtn addTarget:self action:@selector(clickToForward:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma - mark 事件处理

- (void)clickToSelectSex:(UIButton *)sender
{
    int tag = (int)sender.tag - 100;
    
    //年龄view
    _view_Age = [[LQuestionView alloc]initAgeViewWithFrame:CGRectZero gender:tag == 1 ? Gender_Girl : Gender_Boy initNum:0 resultBlock:^(QUESTIONTYPE type, id object, NSDictionary *result) {
        
        
    }];
    [self.view addSubview:_view_Age];
    _view_Age.backgroundColor = [UIColor whiteColor];
    [_view_Age mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, DEVICE_WIDTH, 0, 0));
    }];
    
    [self prepareBottom];
    
    [self swapView:_view_sex toView:_view_Age back:NO];
}

/**
 *  返回上一步
 *
 *  @param sender
 */
- (void)clickToLast:(UIButton *)sender
{
    [self swapView:_view_sex toView:_view_Age back:YES];

}

/**
 *  前进一步
 *
 *  @param sender
 */
- (void)clickToForward:(UIButton *)sender
{
    
}

/**
 *  切换view
 *
 *  @param oneView 目标view
 *  @param toView  切换至目标view
 */
- (void)swapView:(UIView *)oneView
          toView:(UIView *)toView
            back:(BOOL)back
{
    
    
    if (back) {
        
        oneView.left = 0.f;
        toView.left = -DEVICE_WIDTH;
        
    }else
    {
        oneView.left = 0.f;
        toView.left = DEVICE_WIDTH;
    }
    [UIView animateWithDuration:0.5 animations:^{
        
        toView.left = 0.f;
        
    }];

}

@end
