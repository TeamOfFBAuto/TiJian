//
//  GMAPI.m
//  TiJian
//
//  Created by gaomeng on 15/11/3.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GMAPI.h"

@implementation GMAPI
+(CGFloat)scaleWithHeight:(CGFloat)theH width:(CGFloat)theW theWHscale:(CGFloat)theWHS{
    CGFloat value = 0;
    
    //  theW/theH = theWHS
    
    if (theH == 0) {//计算高
        value = theW/theWHS;
    }else if (theW == 0){
        value = theWHS * theH;
    }
    
    return value;
}
@end
