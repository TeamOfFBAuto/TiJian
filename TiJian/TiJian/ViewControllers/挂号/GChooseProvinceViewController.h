//
//  GChooseProvinceViewController.h
//  TiJian
//
//  Created by gaomeng on 16/7/20.
//  Copyright © 2016年 lcw. All rights reserved.
//


//挂号选择地区 具体到省份和直辖市

#import "MyViewController.h"

typedef void(^chooseProvinceBlock)(int theProvinceId);

@interface GChooseProvinceViewController : MyViewController

@property(nonatomic,strong)UIButton *nowLocationBtn_c;

@property(nonatomic,assign)int nowLocationBtn_cityid;



@end
