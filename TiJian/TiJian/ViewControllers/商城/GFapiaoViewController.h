//
//  GFapiaoViewController.h
//  TiJian
//
//  Created by gaomeng on 16/1/11.
//  Copyright © 2016年 lcw. All rights reserved.
//


//发票信息vc

#import "MyViewController.h"
@class ConfirmOrderViewController;

@interface GFapiaoViewController : MyViewController

@property(nonatomic,strong)NSString *fapiaotaitou;//发票抬头
@property(nonatomic,assign)ConfirmOrderViewController *delegate;


@end
