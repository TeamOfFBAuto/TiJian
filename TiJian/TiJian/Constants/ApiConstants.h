//
//  ApiConstants.h
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  存放请求接口
 */
#ifndef WJXC_ApiConstants_h
#define WJXC_ApiConstants_h

#define SERVER_URL @"http://123.57.51.27:85" //域名地址 正式
//#define SERVER_URL @"http://182.92.106.193:85" //域名地址 测试

//添加商品评论
#define ADD_PRODUCT_PINGLUN @"/index.php?d=api&c=products&m=add_comment"

//接口的去掉域名、去掉参数部分

//根据id获取用户信息 (参数: uid authcode)
#define GET_USERINFO_WITHID @"/index.php?d=api&c=user&m=get_user_info"

//只根据用户id获取用户信息
#define GET_USERINFO_ONLY_USERID @"/index.php?d=api&c=user&m=get_user_info_by_uid"

//单品 - 添加收藏 (参数:product_id、authcode)
#define HOME_PRODUCT_COLLECT_ADD @"/?d=api&c=products&m=favor"

//登录
#define USER_LOGIN_ACTION @"/index.php?d=api&c=user&m=login"

//退出登录
#define USER_LOGOUT_ACTION @"/index.php?d=api&c=user&m=login_out"

//注册
#define USER_REGISTER_ACTION @"/index.php?d=api&c=user&m=register"
//获取验证码
#define USER_GET_SECURITY_CODE @"/index.php?d=api&c=user&m=get_code"
//找回密码
#define USER_GETBACK_PASSWORD @"/index.php?d=api&c=user&m=get_back_password"
//修改密码
#define USER_UPDATE_PASSWORD @"/index.php?d=api&c=user&m=change_password"

//修改用户头像
#define USER_UPLOAD_HEADIMAGE @"/index.php?d=api&c=user&m=update_user_photo"

//修改用户信息
#define USER_UPDATE_USEINFO @"/index.php?d=api&c=user&m=update_user_info"

//关于我们
#define ABOUT_US_URL @"http://www.baidu.com"


//获取商品详情
#define GET_PRODUCTDETAIL @"/index.php?d=api&c=products&m=get_product_detail"

//添加商品浏览量
#define GET_PRODUCT_ADDVIEW @"/index.php?d=api&c=statistic&m=add_product_view"

//获取商品列表
#define GET_PRODUCTlIST @"/index.php?d=api&c=products&m=get_product_list"


//获取首页轮播列表
#define GET_HOMESCROLLVIEWDATA @"/index.php?d=api&c=adver&m=get_adver_list"

//获取商品评论(参数product_id=1  商品id 必填 comment_level=1 选填 评论级别 1差评 2中评 3好评  0或不传将获取所有级别评论 page=1 当前评论页perpage=1 评论每页显示数目 order=comment_id   排序字段 direction=  排序顺序  [desc:降序   asc：升序])
#define GET_PRODUCT_COMMENT @"/index.php?d=api&c=products&m=get_product_comment"



//获取商品分类
#define GET_PRODUCT_CLASS @"/index.php?d=api&c=products&m=get_product_category"

//获取热门城市
#define GET_HOTCITY @"/index.php?d=api&c=products&m=hot_city"

//收藏商品
#define SHOUCANGRODUCT @"/index.php?d=api&c=products&m=add_favor"

//取消收藏
#define QUXIAOSHOUCANG @"/index.php?d=api&c=products&m=cancel_favor"

//搜索
#define SEACHERPRODUCT @"/index.php?d=api&c=products&m=search_product"

//活动详情
#define HUODONGXIANGQING @"/index.php?d=api&c=activity&m=get_activity_detail"

//收货地址相关接口==================

//获取用户的收货地址列表
#define USER_ADDRESS_LIST @"/index.php?d=api&c=user&m=get_user_address"

//16、添加用户的收货地址
#define USER_ADDRESS_ADD @"/index.php?d=api&c=user&m=add_user_address"

//17、编辑用户的收货地址
#define USER_ADDRESS_EDIT @"/index.php?d=api&c=user&m=edit_user_address"

//设置默认地址
#define USER_ADDRESS_SETDEFAULT @"/index.php?d=api&c=user&m=set_default_address"

//删除地址
#define USER_ADDRESS_DELETE @"/index.php?d=api&c=user&m=del_user_address"

//20、融云获取tokend
#define USER_GET_TOKEN @"/index.php?d=api&c=chat&m=get_token"

//商品相关接口=====================

//25、获取商品列表
#define PRODUCT_LIST @"/index.php?d=api&c=products&m=get_product_list"

//32、商品收藏列表

#define PRODUCT_COLLECT_LIST @"/index.php?d=api&c=products&m=get_favor_list"

//订单相关接口=====================

//40、购物车添加商品
#define ORDER_ADD_TO_CART @"/index.php?d=api&c=order&m=add_to_cart"

//41、购物车增加/减少商品
#define ORDER_EDIT_CART_PRODUCT @"/index.php?d=api&c=order&m=edit_cart_product"

//42、删除某条购物车记录
#define ORDER_DEL_CART_PRODUCT @"/index.php?d=api&c=order&m=del_cart_product"

//43、获取购物车记录
#define ORDER_GET_CART_PRODCUTS @"/index.php?d=api&c=order&m=get_cart_products"

//44、用户登录后同步购物车数据
#define ORDER_SYNC_CART_INFO @"/index.php?d=api&c=order&m=sync_cart_info"

//47、提交订单,后台生成订单号
#define ORDER_SUBMIT @"/index.php?d=api&c=order&m=submit_order"

//45、获取用户默认地址及运费
#define ORDER_GET_DEFAULT_ADDRESS @"/index.php?d=api&c=order&m=get_default_address"

//46、获取运费

#define ORDER_GET_EXPRESS_FEE @"/index.php?d=api&c=order&m=get_express_fee"

//获取可用优惠劵
#define ORDER_GET_USECOUPONLIST @"/index.php?d=api&c=order&m=use_coupon_list"

//48、获取支付宝签名或者微信生成预订单
#define ORDER_GET_SIGN @"/index.php?d=api&c=order&m=get_sign"

//49、获取订单详情
#define ORDER_GET_ORDER_INFO @"/index.php?d=api&c=order&m=get_order_info"

//50、获取我的订单列表
#define ORDER_GET_MY_ORDERS @"/index.php?d=api&c=order&m=get_my_orders"

//51、查看订单支付状态
#define ORDER_GET_ORDER_PAY @"/index.php?d=api&c=order&m=get_order_pay"

//52、用户确认收货
#define ORDER_RECEIVING_CONFIRM @"/index.php?d=api&c=order&m=receiving_confirm"

//52、延长收货
#define ORDER_RECEIVING_Delay @"/index.php?d=api&c=order&m=delay_receive"

//53、用户取消或删除订单
#define ORDER_HANDLE_ORDER @"/index.php?d=api&c=order&m=handle_order"

//退款
#define ORDER_REFUND @"/index.php?d=api&c=order&m=apply_refund"

//获取购物车数量

#define GET_SHOPPINGCAR_NUM @"/index.php?d=api&c=order&m=get_cart_pro_num"


#endif
