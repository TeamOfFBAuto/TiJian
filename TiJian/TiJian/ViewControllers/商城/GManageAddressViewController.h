//
//  GManageAddressViewController.h
//  TiJian
//
//  Created by gaomeng on 15/11/24.
//  Copyright © 2015年 lcw. All rights reserved.
//

//管理收货地址

#import "MyViewController.h"
@class AddressModel;

@interface GManageAddressViewController : MyViewController


@property(nonatomic,strong)RefreshTableView *rtab;



-(void)oneCellEditBtnClicked:(AddressModel*)passModel;

@end
