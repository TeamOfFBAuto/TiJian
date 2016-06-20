//
//  GoHealthChooseCityViewController.h
//  TiJian
//
//  Created by gaomeng on 16/6/16.
//  Copyright © 2016年 lcw. All rights reserved.
//
/**
 *  选择预约地址
 */
#import "MyViewController.h"

typedef void(^userSelectCityBlock)(NSDictionary *userSelectCityDic);

@interface GoHealthChooseCityViewController : MyViewController

@property(nonatomic,strong)NSString *productId;

@property(nonatomic,copy)userSelectCityBlock userSelectCityBlock;

-(void)setUserSelectCityBlock:(userSelectCityBlock)userSelectCityBlock;

@end
