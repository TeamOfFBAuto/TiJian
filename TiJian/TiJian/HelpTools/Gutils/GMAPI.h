//
//  GMAPI.h
//  TiJian
//
//  Created by gaomeng on 15/11/3.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+GJson.h"

@interface GMAPI : NSObject

//出入宽或高和比例 想计算的值传0
+(CGFloat)scaleWithHeight:(CGFloat)theH width:(CGFloat)theW theWHscale:(CGFloat)theWHS;

//提示浮层
+ (void)showAutoHiddenMBProgressWithText:(NSString *)text addToView:(UIView *)aView;

//时间转换 —— 年-月-日
+(NSString *)timechangeYMD:(NSString *)placetime;


//测试authcode
+(NSString *)getAuthkey;
+(NSString *)testAuth;


//地区选择相关
+ (int)cityIdForName:(NSString *)cityName;

+ (NSString *)cityNameForId:(int)cityId;





@end
