//
//  GuserAddressViewController.h
//  TiJian
//
//  Created by gaomeng on 15/11/20.
//  Copyright © 2015年 lcw. All rights reserved.
//


//选择收货地址

#import "MyViewController.h"
@class AddressModel;

@interface GuserAddressViewController : MyViewController

@property(nonatomic,strong)RefreshTableView *tab;

-(void)oneCellEditBtnClicked:(AddressModel*)passModel;


@end
