//
//  PayResultViewController.m
//  WJXC
//
//  Created by lichaowei on 15/7/24.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "PayResultViewController.h"
#import "OrderInfoViewController.h"
#import "OrderProductListController.h"
#import "AppointmentViewController.h"

@interface PayResultViewController ()

@end

@implementation PayResultViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:NSStringFromClass([self class])];
}





- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"支付结果";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.payResultType == PAY_RESULT_TYPE_Success || self.payResultType == PAY_RESULT_TYPE_Waiting) {
        
        //成功
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((DEVICE_WIDTH - 141) / 2.f, 50, 141, 24)];
        [self.view addSubview:imageView];
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, imageView.bottom + 28, DEVICE_WIDTH, 14) title:nil font:13 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR];
        [self.view addSubview:label1];
        NSString *price = [NSString stringWithFormat:@"%.2f",self.sumPrice];
        NSString *text = @"";
        
        if (_payResultType == PAY_RESULT_TYPE_Success) {
            
            imageView.image = [UIImage imageNamed:@"zhifuchenggong"];
            
            if (_needAppoint) { //需要前去预约
                
                text = [NSString stringWithFormat:@"您成功付款%@元",price];

            }else
            {
                text = [NSString stringWithFormat:@"您成功付款%@元,预约已完成!",price];
            }

        }else
        {
            imageView.image = [UIImage imageNamed:@"zhifuchulizhong"];
            imageView.width = 211;
            imageView.height = 27;
            text = [NSString stringWithFormat:@"付款金额%@元",price];
        }
        NSAttributedString *string = [LTools attributedString:text keyword:price color:DEFAULT_TEXTCOLOR];
        [label1 setAttributedText:string];
        imageView.centerX = DEVICE_WIDTH / 2.f;
        
        text = [NSString stringWithFormat:@"订单编号:%@",self.orderNum];
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, label1.bottom + 7, DEVICE_WIDTH, 14) title:text font:13 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"959595"]];
        [self.view addSubview:label2];
        
        CGFloat btnWith = (DEVICE_WIDTH - 74 - 20) / 2.f;
        
        //查看订单
        UIButton *btn1 = [[UIButton alloc]initWithframe:CGRectMake(46, label2.bottom + 30, btnWith, 33) buttonType:UIButtonTypeCustom normalTitle:@"查看订单" selectedTitle:nil target:self action:@selector(clickToSeeOrderInfo:)];
        [self.view addSubview:btn1];
        [btn1 addCornerRadius:5.f];
        [btn1 setBorderWidth:0.5 borderColor:[UIColor colorWithHexString:@"323232"]];
        [btn1.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn1 setTitleColor:[UIColor colorWithHexString:@"323232"] forState:UIControlStateNormal];
        
        NSString *title;
        SEL selector;
        if (_needAppoint) {
            
            title = @"前去预约";
            selector = @selector(clickToAppoint);
        }else
        {
            title = @"查看预约";
            selector = @selector(clickToMyAppointment:);
        }
        
        //继续购买
        UIButton *btn2 = [[UIButton alloc]initWithframe:CGRectMake(btn1.right + 20, label2.bottom + 30, btnWith, 33) buttonType:UIButtonTypeCustom normalTitle:title selectedTitle:nil target:self action:selector];
        [self.view addSubview:btn2];
        [btn2 addCornerRadius:5.f];
        [btn2 setBorderWidth:0.5 borderColor:DEFAULT_TEXTCOLOR];
        [btn2.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn2 setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
        
    }else if(_payResultType == PAY_RESULT_TYPE_Fail)
    {
        //失败
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((DEVICE_WIDTH - 141) / 2.f, 50, 141, 24)];
        imageView.image = [UIImage imageNamed:@"zhifushibai"];
        [self.view addSubview:imageView];
        imageView.centerX = DEVICE_WIDTH / 2.f;
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, imageView.bottom + 28, DEVICE_WIDTH, 14) title:nil font:13 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR];
        [self.view addSubview:label1];
        NSString *text = [NSString stringWithFormat:@"%@",self.erroInfo];
        label1.text = text;
        
        CGFloat btnWith = (DEVICE_WIDTH - 74 - 20) / 2.f;
        
        //查看订单
        UIButton *btn1 = [[UIButton alloc]initWithframe:CGRectMake(46, label1.bottom + 30, btnWith, 33) buttonType:UIButtonTypeCustom normalTitle:@"查看订单" selectedTitle:nil target:self action:@selector(clickToSeeOrderInfo:)];
        [self.view addSubview:btn1];
        [btn1 addCornerRadius:5.f];
        [btn1 setBorderWidth:0.5 borderColor:[UIColor colorWithHexString:@"323232"]];
        [btn1.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn1 setTitleColor:[UIColor colorWithHexString:@"323232"] forState:UIControlStateNormal];
        
        //继续购买
        UIButton *btn2 = [[UIButton alloc]initWithframe:CGRectMake(btn1.right + 20, label1.bottom + 30, btnWith, 33) buttonType:UIButtonTypeCustom normalTitle:@"重新支付" selectedTitle:nil target:self action:@selector(clickToRePay:)];
        [self.view addSubview:btn2];
        [btn2 addCornerRadius:5.f];
        [btn2 setBorderWidth:0.5 borderColor:DEFAULT_TEXTCOLOR];
        [btn2.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn2 setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 事件处理
/**
 *  查看订单
 *
 *  @param sender
 */
- (void)clickToSeeOrderInfo:(UIButton *)sender
{
    OrderInfoViewController *orderInfo = [[OrderInfoViewController alloc]init];
    orderInfo.order_id = self.orderId;
    orderInfo.isPayResultVcPush = YES;
    orderInfo.platformType = self.platformType;
    [self.navigationController pushViewController:orderInfo animated:YES];
}

/**
 *  重新支付
 *
 *  @param sender
 */
- (void)clickToRePay:(UIButton *)sender
{
    [self leftButtonTap:sender];
}

/**
 *  再去逛逛
 *
 *  @param btn
 */
- (void)clickToShopping:(UIButton *)btn
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    UITabBarController *root = (UITabBarController *)ROOTVIEWCONTROLLER;
    if ([root isKindOfClass:[UITabBarController class]]) {
        root.selectedIndex = 1;
    }
}

/**
 *  前去个人中心-我的预约
 *
 *  @param btn
 */
- (void)clickToMyAppointment:(UIButton *)btn
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    UITabBarController *root = (UITabBarController *)ROOTVIEWCONTROLLER;
    if ([root isKindOfClass:[UITabBarController class]]) {
        root.selectedIndex = 2;
        
        LNavigationController *naviagationVc = [root.viewControllers objectAtIndex:2];
        if (naviagationVc && [naviagationVc isKindOfClass:[UINavigationController class]]) {
            //@"我的预约";
            AppointmentViewController *m_order = [[AppointmentViewController alloc]init];
            m_order.hidesBottomBarWhenPushed = YES;
            [naviagationVc pushViewController:m_order animated:YES];
        }
    }
}

///前去预约
- (void)clickToAppoint
{
    OrderProductListController *list = [[OrderProductListController alloc]init];
    list.orderId = self.orderId;
    list.platformType = self.platformType;
    [self.navigationController pushViewController:list animated:YES];
}

@end
