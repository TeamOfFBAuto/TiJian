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
@property(nonatomic,retain)NSArray *list;
@property(nonatomic,retain)NSArray *shop_products;//单品列表(不同地方不同叫法)
@property(nonatomic,retain)NSString *order_note;//备注

@property(nonatomic,retain)NSString *is_comment;//是否评论
@property(nonatomic,retain)NSNumber *is_appoint;//是否可以预约 1可以预约
//订单详情
@property(nonatomic,retain)NSString *total_price;//现价
@property(nonatomic,retain)NSString *total_fee;//最终的价格(优惠后加邮费)
@property(nonatomic,retain)NSString *product_total_price;//商品总价 不包含运费的
@property(nonatomic,retain)NSString *address_id;
@property(nonatomic,retain)NSString *merchant_phone;//客服电话

@property(nonatomic,retain)NSString *yy_uid;//联系人id
@property(nonatomic,retain)NSString *yy_username;//联系人name

@property(nonatomic,retain)NSString *receiver_username;
@property(nonatomic,retain)NSString *receiver_mobile;

@property(nonatomic,retain)NSString *real_price;//实际付款
@property(nonatomic,retain)NSString *coupon_offset_money;  //优惠券优惠金额
@property(nonatomic,retain)NSString *vouchers_offset_money;//代金券优惠金额
@property(nonatomic,retain)NSString *score_offset_money;// 积分优惠金额
@property(nonatomic,retain)NSString *express_fee; //运费

@property(nonatomic,retain)NSString *add_time; //订单创建时间

@property(nonatomic,retain)NSString *pay_type;//1 支付宝 2 微信

//订单状态 1=》待付款 2=》待预约 3=》已预约 4=》已完成 5=》已取消 6=》已删除
//1=》待付款      新版本没有2、3状态       4=》已完成 5=》已取消 6=》已删除 7=>已付款
@property(nonatomic,retain)NSString *status;

//退单状态 0=>未申请退款 1=》用户已提交申请退款 2=》同意退款（已提交微信/支付宝）3=》同意退款（退款成功） 4=》同意退款（退款失败） 5=》拒绝退款
@property(nonatomic,retain)NSString *refund_status;

@property(nonatomic,retain)NSString *real_product_total_price;//实际可以退的

@property(nonatomic,retain)id couponModel;//记录该订单是否用首单减免

@property(nonatomic,retain)NSDictionary *newer_coupons;//首单减免

@property(nonatomic,retain)NSString *enable_refund;//是否可以退款 等于1 就可以退款 0 不可以退款

//{
//    "title": "北京衣加衣",
//    "desc": "体检费",
//    "use_time": "1452690911"
//}
@property(nonatomic,retain)NSDictionary *invoice_info;//发票信息
@property(nonatomic,retain)NSString *require_post;//快递方式 0电子体检码 1快递体检凭证

@property(nonatomic,retain)NSString *info_url;//详情web链接
@property(nonatomic,retain)NSNumber *type;//type参数为1的 咱海马的订单 为2是go健康的订单

-(instancetype)initWithDictionary:(NSDictionary *)dic;

@end
