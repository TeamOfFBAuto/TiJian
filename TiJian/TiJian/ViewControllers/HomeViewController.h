//
//  HomeViewController.h
//  TiJian
//
//  Created by lichaowei on 15/10/21.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "MyViewController.h"

@interface HomeViewController : MyViewController


@property(nonatomic,strong)UILabel *leftLabel;

-(void)setLocationDataWithCityStr:(NSString *)city provinceStr:(NSString *)province;


@end
