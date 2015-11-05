//
//  PhysicalTestResultController.m
//  TiJian
//
//  Created by lichaowei on 15/11/4.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "PhysicalTestResultController.h"
#import "RecommendMedicalCheckController.h"
#import "PersonalCustomViewController.h"

@interface PhysicalTestResultController ()

@end

@implementation PhysicalTestResultController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNavigationStyle:NAVIGATIONSTYLE_CUSTOM title:@"测试结果"];


}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    NSString *title = @"已经完成测试,快来看看结果吧";
    
    CGFloat top = 64 + 40;
    if (iPhone5 || iPhone4) {
        
        top = 64 + 10;
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, top, DEVICE_WIDTH, 35) title:title font:13 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR];
    [self.view addSubview:label];
    
    //小手
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(0, label.bottom, 17.5, 25)];
    icon.image = [UIImage imageNamed:@"xiaoshou"];
    [self.view addSubview:icon];
    icon.centerX = DEVICE_WIDTH / 2.f;
    
    //小人
    
    CGFloat width = FitScreen(138);
    CGFloat height = FitScreen(275);
    
    if (iPhone4) {
        
        width *= 0.6;
        height *= 0.6;
    }
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    imageView.image = [UIImage imageNamed:@"result_nan"];
    [self.view addSubview:imageView];
    imageView.center = self.view.center;
    
    //是否按钮
    CGFloat left = FitScreen(40);
    CGFloat dis = FitScreen(14);
    CGFloat btn_width = DEVICE_WIDTH - left * 2 - dis;
    btn_width /= 2;
    UIButton *btn_no = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_no setTitle:@"否,再测一次" forState:UIControlStateNormal];
    [self.view addSubview:btn_no];
    btn_no.frame = CGRectMake(left, imageView.bottom + 30, btn_width, 33);
    [btn_no setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_no setBackgroundColor:DEFAULT_TEXTCOLOR];
    [btn_no.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [btn_no addTarget:self action:@selector(clickToTest:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn_yes = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_yes setTitle:@"是,立即查看" forState:UIControlStateNormal];
    [self.view addSubview:btn_yes];
    btn_yes.frame = CGRectMake(btn_no.right + dis, imageView.bottom + 30, btn_width, 33);
    [btn_yes setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_yes setBackgroundColor:[UIColor colorWithHexString:@"ec7d23"]];
    [btn_yes.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [btn_yes addTarget:self action:@selector(clickToQuestionResult) forControlEvents:UIControlEventTouchUpInside];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  去个性化定制
 *
 *  @param btn
 */
- (void)clickToTest:(UIButton *)btn
{
    PersonalCustomViewController *custom = [[PersonalCustomViewController alloc]init];
    custom.hidesBottomBarWhenPushed = YES;
    custom.lastViewController = self;
    [self.navigationController pushViewController:custom animated:YES];
}

/**
 *  去推荐项目
 */
- (void)clickToQuestionResult
{
    RecommendMedicalCheckController *recommend = [[RecommendMedicalCheckController alloc]init];
    recommend.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:recommend animated:YES];
}

@end
