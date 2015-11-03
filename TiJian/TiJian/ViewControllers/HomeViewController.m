//
//  HomeViewController.m
//  TiJian
//
//  Created by lichaowei on 15/10/21.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "HomeViewController.h"
#import "PersonalCustomViewController.h"
#import "GStoreHomeViewController.h"
#import "RecommendMedicalCheckController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"个人定制" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn addTarget:self action:@selector(clickToPush:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.left.equalTo(self.view).offset(100);
        make.size.mas_equalTo(CGSizeMake(100, 50));
    }];
    
    
    
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setTitle:@"商城" forState:UIControlStateNormal];
    btn1.backgroundColor = [UIColor orangeColor];
    [btn1 addTarget:self action:@selector(shangcheng) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.left.equalTo(self.view).offset(100);
        make.size.mas_equalTo(CGSizeMake(100, 50));
    }];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:@"问卷结束界面" forState:UIControlStateNormal];
    btn2.backgroundColor = [UIColor orangeColor];
    [btn2 addTarget:self action:@selector(clickToQuestionResult) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(210);
        make.left.equalTo(self.view).offset(100);
        make.size.mas_equalTo(CGSizeMake(150, 50));
    }];
    
}

-(void)shangcheng{
    GStoreHomeViewController *cc= [[GStoreHomeViewController alloc]init];
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 事件处理
- (void)clickToPush:(UIButton *)btn
{
    PersonalCustomViewController *custom = [[PersonalCustomViewController alloc]init];
    custom.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:custom animated:YES];
}

- (void)clickToQuestionResult
{
    RecommendMedicalCheckController *recommend = [[RecommendMedicalCheckController alloc]init];
    recommend.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:recommend animated:YES];
}

@end
