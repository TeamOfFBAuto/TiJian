//
//  LocationChooseViewController.h
//  WJXC
//
//  Created by gaomeng on 15/7/19.
//  Copyright (c) 2015年 lcw. All rights reserved.
//



//首页点击左上角进入的vc 选择城市

#import "MyViewController.h"

@protocol LocationChooseDelegate <NSObject>
@optional
@property(nonatomic,strong)UILabel *leftLabel;
@required
-(void)afterChooseCity:(NSString *)theCity province:(NSString *)theProvince;

@end


@interface LocationChooseViewController : MyViewController


@property(nonatomic,strong)UIButton *nowLocationBtn_c;

@property(nonatomic,assign)int nowLocationBtn_cityid;


@property(nonatomic,assign)id<LocationChooseDelegate>delegate;

//@property(nonatomic,assign)HomeViewController *delegate;
//
//@property(nonatomic,assign)GStoreHomeViewController *delegate1;

@end
