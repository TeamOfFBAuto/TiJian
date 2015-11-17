//
//  AppointUpdateController.m
//  TiJian
//
//  Created by lichaowei on 15/11/17.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "AppointUpdateController.h"
#import "AppointModel.h"

@interface AppointUpdateController ()
{
    BOOL _isAppointAgain;//是否是再次预约
    AppointModel *_appointModel;
}

@end

@implementation AppointUpdateController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.myTitle = @"预约修改";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建
#pragma mark - 网络请求
#pragma mark - 数据解析处理

/**
 *  设置参数
 *
 *  @param aModel         预约详情model
 *  @param isAppointAgain 是否是重新预约
 */
- (void)setParamsWithModel:(AppointModel *)aModel
            isAppointAgain:(BOOL)isAppointAgain

{
    if (isAppointAgain) {
        self.myTitle = @"重新预约";
    }else{
        self.myTitle = @"预约修改";
    }
}

#pragma mark - 事件处理
#pragma mark - 代理


@end
