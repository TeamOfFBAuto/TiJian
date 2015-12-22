//
//  UIColor+ConvertColor.h
//  NewChannelInternal
//
//  Created by Lichaowei on 13-11-13.
//  Copyright (c) 2013年 李 沛然. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ConvertColor)
+ (UIColor *) colorWithHexString: (NSString *)color;

+ (UIColor *)randomColor;

+ (UIColor *)randomColorWithoutWhiteAndBlack;//随机颜色去除白色和黑色

@end
