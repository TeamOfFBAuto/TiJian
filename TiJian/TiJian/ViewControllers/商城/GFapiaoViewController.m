//
//  GFapiaoViewController.m
//  TiJian
//
//  Created by gaomeng on 16/1/11.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GFapiaoViewController.h"

@interface GFapiaoViewController ()

@end

@implementation GFapiaoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"发票信息";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
