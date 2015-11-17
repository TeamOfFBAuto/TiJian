//
//  AppointUpdateController.h
//  TiJian
//
//  Created by lichaowei on 15/11/17.
//  Copyright © 2015年 lcw. All rights reserved.
/**
 *  预约修改或者重新预约
 */

#import "MyViewController.h"
@class AppointModel;

@interface AppointUpdateController : MyViewController

/**
 *  设置参数
 *
 *  @param aModel         预约详情model
 *  @param isAppointAgain 是否是重新预约
 */
- (void)setParamsWithModel:(AppointModel *)aModel
            isAppointAgain:(BOOL)isAppointAgain;

@end
