//
//  MIddleTools.h
//  TiJian
//
//  Created by lichaowei on 15/12/7.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <Foundation/Foundation.h>

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


/**
 *  查看产品详情(海马、go健康)
 *
 *  @param productId
 *  @param platType          区分海马、go健康
 *  @param viewController
 *  @param extendParams
 *  @param updateParamsBlock
 */
+ (void)pushToProductDetailWithProductId:(NSString *)productId
                                platType:(PlatformType)platType
                          viewController:(UIViewController *)viewController
                            extendParams:(NSDictionary *)extendParams
                       updateParamsBlock:(UpdateParamsBlock)updateParamsBlock;

#pragma mark - 订单

/**
 *  订单再次购买
 *
 *  @param platformType   区分海马、go健康
 *  @param products       产品数组(ProductModel或者NSDictionary)
 *  @param viewController
 *  @param extendParams
 */
+ (void)pushToAgainBuyOrderType:(PlatformType)platformType
                       products:(NSArray *)products
                 viewController:(UIViewController *)viewController
                   extendParams:(NSDictionary *)extendParams;

/**
 *  订单支付
 *
 *  @param orderId        订单id
 *  @param orderNum       订单num 201600010
 *  @param sumPrice       总实付价格
 *  @param payStyle       //1 支付宝 2 微信
 *  @param platformType  平台区分 海马、go健康
 *  @param viewController
 *  @param extendParams
 */
+ (void)pushToPayOrderId:(NSString *)orderId
                orderNum:(NSString *)orderNum
                sumPrice:(CGFloat)sumPrice
                payStyle:(int)payStyle
            platformType:(PlatformType)platformType
          viewController:(UIViewController *)viewController
            extendParams:(NSDictionary *)extendParams;


/**
 *  前去预约(海马、go健康)
 *
 *  @param platformType   区分海马、go健康
 *  @param orderid        订单id
 *  @param products       产品
 *  @param viewController
 *  @param extendParams
 */
+ (void)pushToAppointPlatformType:(PlatformType)platformType
                          orderId:(NSString *)orderid
                         products:(NSArray *)products
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

/**
 *  跳转至go健康服务详情
 *
 *  @param serviceId       服务id
 *  @param productId       套餐产品id
 *  @param orderNum        订单id
 *  @param controller
 *  @param extensionParams 拓展参数备用
 */
+ (void)pushToGoHealthServiceId:(NSString *)serviceId
                      productId:(NSString *)productId
                       orderNum:(NSString *)orderNum
             fromViewController:(UIViewController *)controller
                extensionParams:(NSDictionary *)extensionParam;

@end
