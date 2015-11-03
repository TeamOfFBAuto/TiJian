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

@end
