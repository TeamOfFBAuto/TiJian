//
//  MIddleTools.h
//  TiJian
//
//  Created by lichaowei on 15/12/7.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  开启客服来源类型
 */
typedef NS_ENUM(NSInteger ,SourceType) {
    /**
     *  来源自普通进入方式
     */
    SourceType_Normal = 0,
    /**
     *  来源自单品详情
     */
    SourceType_ProductDetail = 1,
    /**
     *  来源自订单详情
     */
    SourceType_Order
};

@interface MiddleTools : NSObject

/**
 *  开启客服聊天
 *
 *  @param type           区分来源自单品详情、订单详情
 *  @param viewController tagerViewController
 *  @param model          单品model、或者订单model
 */
+ (void)pushToChatWithSourceType:(SourceType)type
              fromViewController:(UIViewController *)viewController
                           model:(id)model;

/**
 *  开启客服聊天
 *
 *  @param type           区分来源自单品详情、订单详情
 *  @param viewController tagerViewController
 *  @param model          单品model、或者订单model
 *  @param hiddenBottom   是否隐藏底部
 */
+ (void)pushToChatWithSourceType:(SourceType)type
              fromViewController:(UIViewController *)viewController
                           model:(id)model
                    hiddenBottom:(BOOL)hiddenBottom;

@end
