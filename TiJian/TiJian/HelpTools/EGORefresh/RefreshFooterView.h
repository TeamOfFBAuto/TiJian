//
//  RefreshFooterView.h
//  TiJian
//
//  Created by lichaowei on 15/12/21.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  上拉加载更多数据类型
 */
typedef NS_ENUM(NSInteger,RefreshLoadingMoreStyle) {
    RefreshLoadingMoreStyleDefault = 0,//默认上拉加载更多
    RefreshLoadingMoreStyleNoMore,//没有更多数据
    RefreshLoadingMoreStyleNoMoreAndHidden //没有更多数据但是显示
};

@interface RefreshFooterView : UIView

/**
 *  初始化
 *
 *  @param frame
 *
 *  @return
 */
-(instancetype)initWithFrame:(CGRect)frame;

/**
 *  开始加载
 */
- (void)startLoading;

/**
 *  停止加载
 *
 *  @param loadingStyle
 */
- (void)stopLoadingMoreStyle:(RefreshLoadingMoreStyle)loadingStyle;

@end
