//
//  GMyOrderViewController.m
//  TiJian
//
//  Created by gaomeng on 15/11/25.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GMyOrderViewController.h"

@interface GMyOrderViewController ()

@end

@implementation GMyOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"我的订单";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
