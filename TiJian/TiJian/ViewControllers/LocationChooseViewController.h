//
//  LocationChooseViewController.h
//  WJXC
//
//  Created by gaomeng on 15/7/19.
//  Copyright (c) 2015年 lcw. All rights reserved.
//



//首页点击左上角进入的vc 选择城市

#import "MyViewController.h"
@class HomeViewController;
@class GStoreHomeViewController;

@interface LocationChooseViewController : MyViewController


@property(nonatomic,strong)UIButton *nowLocationBtn_c ;

@property(nonatomic,assign)int nowLocationBtn_cityid;

@property(nonatomic,assign)HomeViewController *delegate;

@property(nonatomic,assign)GStoreHomeViewController *delegate1;

@end
