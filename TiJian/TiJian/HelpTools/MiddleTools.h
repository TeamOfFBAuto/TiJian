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

+ (id)shareInstance;

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

/**
 *  内置浏览器
 *
 *  @param viewController
 *  @param weburl         访问地址url
 *  @param title          标题
 *  @param moreInfo       右侧是否显示两个按钮
 *  @param hiddenBottom   隐藏底部tabbar
 */
+ (void)pushToWebFromViewController:(UIViewController *)viewController
                             weburl:(NSString *)weburl
                              title:(NSString *)title
                           moreInfo:(BOOL)moreInfo
                       hiddenBottom:(BOOL)hiddenBottom;

/**
 *  内置浏览器
 *
 *  @param viewController
 *  @param weburl         访问地址url
 *  @param extensionParams  根据需要拓展参数
 *  @param moreInfo       右侧是否显示两个按钮
 *  @param hiddenBottom   隐藏底部tabbar
 *  @param updateParamsBlock   方便数据回调block
 *  @param
 */
+ (void)pushToWebFromViewController:(UIViewController *)viewController
                             weburl:(NSString *)weburl
                    extensionParams:(NSDictionary *)extensionParams
                           moreInfo:(BOOL)moreInfo
                       hiddenBottom:(BOOL)hiddenBottom
                  updateParamsBlock:(UpdateParamsBlock)updateParamsBlock;

/**
 *  跳转至单品详情
 *
 *  @param productId      id
 *  @param viewController
 *  @param extendParams 增加拓张性
 */
+ (void)pushToProductDetailWithProductId:(NSString *)productId
                          viewController:(UIViewController *)viewController
                                   extendParams:(NSDictionary *)extendParams;

#pragma mark - 分享

/**
 *  分享 图片链接url
 *
 *  @param controller
 *  @param shareImageUrl  分享图片链接url
 *  @param shareTitle   标题
 *  @param shareContent 摘要
 *  @param linkUrl      链接
 */

-(void)shareFromViewController:(UIViewController *)controller
                  withImageUrl:(NSString *)shareImageUrl
                    shareTitle:(NSString *)shareTitle
                  shareContent:(NSString *)shareContent
                       linkUrl:(NSString *)linkUrl;
/**
 *  分享 UIImage
 *
 *  @param controller
 *  @param shareImage   分享UIImage对象
 *  @param shareTitle   标题
 *  @param shareContent 摘要
 *  @param linkUrl      链接
 */
- (void)shareFromViewController:(UIViewController *)controller
                      withImage:(UIImage *)shareImage
                     shareTitle:(NSString *)shareTitle
                   shareContent:(NSString *)shareContent
                        linkUrl:(NSString *)linkUrl;


#pragma mark - 友盟统计
/**
 *  友盟统计
 *
 *  @param eventId
 *  @param attributes
 *  @param number
 */
-(void)umengEvent:(NSString *)eventId attributes:(NSDictionary *)attributes number:(NSNumber *)number;


#pragma mark - 对接Go健康
/**
 *  go健康对接签名
 *
 *  @param params 需要的参数
 *
 *  @return
 */
+ (NSString *)goHealthSignWithParams:(NSDictionary *)params;

@end
