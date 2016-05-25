//
//  WebviewController.h
//  TiJian
//
//  Created by lichaowei on 15/11/13.
//  Copyright © 2015年 lcw. All rights reserved.
/**
 *  内置浏览器
 */

#import "MyViewController.h"

@interface WebviewController : MyViewController

@property(nonatomic,retain)NSString *webUrl;
@property(nonatomic,assign)BOOL moreInfo;//是否显示更多
@property(nonatomic,retain)NSString *navigationTitle;//标题

@property(nonatomic,assign)BOOL guaHao;//是否是对接挂号网
@property(nonatomic,assign)int type;//对接type 1~14  20为医生详情
@property(nonatomic,retain)NSString *detail_url;//type为20时需要此参数
@property(nonatomic,retain)NSString *familyuid;//type为2时,转诊预约（VIP）需要此参数

@property(nonatomic,retain)NSDictionary *extensionParams;//拓展参数

@end
