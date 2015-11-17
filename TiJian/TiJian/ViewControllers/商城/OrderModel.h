//
//  OrderModel.h
//  WJXC
//
//  Created by lichaowei on 15/7/30.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  我的订单 订单model
 */
#import "BaseModel.h"
#import "ProductModel.h"
@interface OrderModel : BaseModel

@property(nonatomic,retain)NSString *order_id;
@property(nonatomic,retain)NSString *order_no;
@property(nonatomic,retain)NSString *address;
@property(nonatomic,retain)NSArray *products;//单品列表
@property(nonatomic,retain)NSArray *shop_products;//单品列表(不同地方不同叫法)

//订单详情
@property(nonatomic,retain)NSString *total_price;//现价
@property(nonatomic,retain)NSString *total_fee;//最终的价格(优惠后加邮费)
@property(nonatomic,retain)NSString *product_total_price;//商品总价 不包含运费的
@property(nonatomic,retain)NSString *address_id;
@property(nonatomic,retain)NSString *express_fee;//运费
@property(nonatomic,retain)NSString *merchant_phone;//客服电话

@property(nonatomic,retain)NSString *yy_uid;//联系人id
@property(nonatomic,retain)NSString *yy_username;//联系人name

@property(nonatomic,retain)NSString *receiver_username;
@property(nonatomic,retain)NSString *receiver_mobile;

@property(nonatomic,retain)NSString *pay_type;//1 支付宝 2 微信

//订单状态 1=》待付款 2=》已付款 3=》已发货 4=》已送达（已收货） 5=》已取消 6=》已删除
@property(nonatomic,retain)NSString *status;

//退单状态 0=>未申请退款 1=》用户已提交申请退款 2=》同意退款（已提交微信/支付宝）3=》同意退款（退款成功） 4=》同意退款（退款失败） 5=》拒绝退款
@property(nonatomic,retain)NSString *refund_status;

@property(nonatomic,retain)NSString *is_comment;//是否已评论

@property(nonatomic,retain)NSString *real_product_total_price;//实际可以退的

@property(nonatomic,retain)id couponModel;//记录该订单是否用首单减免

@property(nonatomic,retain)NSDictionary *newer_coupons;//首单减免

-(instancetype)initWithDictionary:(NSDictionary *)dic;

@end
