//
//  ActivityView.h
//  TiJian
//
//  Created by lichaowei on 16/1/11.
//  Copyright © 2016年 lcw. All rights reserved.
//
/**
 *  首页活动 弹框
 */
#import <UIKit/UIKit.h>
typedef enum {
    ActionStyle_Close = 1,//点击关闭
    ActionStyle_Select //选择活动
}ActionStyle;

typedef void(^ActionBlock)(ActionStyle actionStyle,NSInteger index);

@interface ActivityView : UIView

- (id)initWithActivityArray:(NSArray *)aModel
                actionBlock:(void(^)(ActionStyle style,NSInteger index))actionBlock;
- (void)show;

@end
