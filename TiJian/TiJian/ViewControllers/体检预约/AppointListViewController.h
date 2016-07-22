//
//  AppointListViewController.h
//  TiJian
//
//  Created by lichaowei on 16/7/19.
//  Copyright © 2016年 lcw. All rights reserved.
/**
 *  未预约列表(公司或者个人)
 */

typedef enum {
    ListType_Normal = 0,//普通个人
    ListType_Company //公司
}ListType;

#import "MyViewController.h"

@interface AppointListViewController : MyViewController

@property(nonatomic,assign)ListType listType;//套餐列表

@end
