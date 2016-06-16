//
//  LDatePicker.h
//  FBAuto
//
//  Created by lichaowei on 14-8-28.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DateBlock)(ACTIONTYPE type, NSString *dateString);

@interface LDatePicker : UIView
{
    UIView *bgView;
    DateBlock dateBlock;
    UIDatePicker *datePicker;
}

/**
 *  设置显示日期
 *
 *  @param date
 *  @param animated
 */
- (void)setInitDate:(NSDate *)date;

- (void)showDateBlock:(DateBlock)aBlock;

@end
