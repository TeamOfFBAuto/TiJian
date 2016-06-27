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

//#define SERVER_URL @"http://www.hippodr.com" //海马医生域名

#define SERVER_URL @"http://182.92.106.193:88" //海马医生域名 测试服务器


//体检须知
#define URL_TIJIANXUZHI @"/data/checkup_notice.html"

//优惠券说明
#define URL_YOUHUIQUANSHUOMING @"/data/coupon_notice.html"

//代金券说明
#define URL_DAIJINQUANSHUOMING @"/data/voucher_notice.html"

//积分说明
#define URL_JIFENSHUOMING @"/data/score_rules.html"

//隐私说明
#define URL_YINSISHUOMING @"/data/privacy.html"

//体检报告查询账号密码说
#define URL_ReportAccount @"/data/report_account.html"


//商城首页轮播图
#define StoreCycleAdv @"/index.php?d=api&c=adver&m=adver_list"

//商城套餐分类
#define StoreProductClass @"/index.php?d=api&c=setmeal&m=setmeal_category_list"

//商城首页精品推荐
#define StoreJingpinTuijian @"/index.php?d=api&c=setmeal&m=index_setmeal_list"

//商品列表 get方式
#define StoreProductList @"/index.php?d=api&c=setmeal&m=setmeal_list"

//品牌店
#define StoreHomeDetail @"/index.php?d=api&c=setmeal&m=brand_shop"

//获取体检分院列表
#define GET_CENTER_LIST @"/index.php?d=api&c=appoint&m=get_center_list"

//搜索套餐
#define ProductSearch @"/index.php?d=api&c=setmeal&m=search"

//获取热门搜索
#define ProductHotSearch @"/index.php?d=api&c=setmeal&m=hot_search"

//获取筛选品牌列表
#define BrandList_oneClass @"/index.php?d=api&c=setmeal&m=brand_city_list"

//获取我的足迹
#define GetMyProductsFoot @"/index.php?d=api&c=track&m=get_tracks"

//添加足迹
#define AddMyProductFoot @"/index.php?d=api&c=track&m=add_track"

//套餐详情
#define StoreProductDetail @"/index.php?d=api&c=setmeal&m=setmeal_detail"

//商品浏览量+1
#define StoreProductLiulanNumAdd @"/index.php?d=api&c=statistic&m=add_product_view"

//店铺浏览量+1
#define BrandStoreLiulanliangNumAdd @"/index.php?d=api&c=setmeal&m=add_brand_view"

//套餐下体检项目列表
#define StoreProdectProjectList @"/index.php?d=api&c=setmeal&m=setmeal_project_list"

//领取优惠券
#define USER_GETCOUPON @"/index.php?d=api&c=order&m=receive_coupon"

//我的优惠券列表
#define USER_MYYOUHUIQUANLIST @"/index.php?d=api&c=order&m=my_coupon_list"

//我的代金券列表
#define USER_MYDAIJINQUANLIST @"/index.php?d=api&c=order&m=my_vouchers_list"

//进入我的钱包 显示优惠券和代金券数量
#define USER_WALLET_COUPON_NUM @"/index.php?d=api&c=order&m=my_wallet"

//下单时，可以使用的优惠券列表
#define ORDER_GETYOUHUIQUANLIST @"/index.php?d=api&c=order&m=use_coupon_list"

//下单时，可以使用的代金券列表
#define ORDER_GETDAIJIQUANLIST @"/index.php?d=api&c=order&m=use_vouchers_list"


/**********************个性化定制相关结果********************************/

#pragma mark - 个性化定制相关结果

//获取个性定制结果POST
#define GET_CUSTOMIZAITION_RESULT @"/index.php?d=api&c=customization&m=get_customization_result"

//2、获取最近的个性化测试结果
#define GET_LATEST_CUSTOMIZATION_RESULT @"/index.php?d=api&c=customization&m=get_latest_customization_result"

//3、保存个性化测试结果 result_id 结果id
#define UPDATE_CUSTOMIZATION_RESULT @"/index.php?d=api&c=customization&m=update_customization_result"

//添加商品评论
#define ADD_PRODUCT_PINGLUN @"/index.php?d=api&c=products&m=add_comment"

//接口的去掉域名、去掉参数部分

//根据id获取用户信息 (参数: uid authcode)
#define GET_USERINFO_WITHID @"/index.php?d=api&c=user&m=get_user_info"

//21_1、获取我的家人详情 get参数调取参数：authcode\family_uid
#define GET_Family_info @"/index.php?d=api&c=user&m=get_family_info"

//只根据用户id获取用户信息
#define GET_USERINFO_ONLY_USERID @"/index.php?d=api&c=user&m=get_user_by_uid"

//单品 - 添加收藏 (参数:product_id、authcode)
#define HOME_PRODUCT_COLLECT_ADD @"/?d=api&c=products&m=favor"

//品牌推荐 -- 加强包
#define Get_c_setmeal_product @"/index.php?d=api&c=customization&m=get_c_setmeal_product"

//专家解读 详细解读web页 result_id
#define Get_customization_detail @"/index.php?d=api&c=customization&m=view_customization"

/**************************登录注册相关用户接口**********************************/

#pragma mark - 登录注册相关用户接口
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

//获取用户积分
#define USER_GETJIFEN @"/index.php?d=api&c=user&m=get_my_score&authcode="

//我的积分明细
#define USER_SCORE_DETAIL @"/index.php?d=api&c=user&m=my_score_detail"

//20、融云获取token
#define USER_GET_TOKEN @"/index.php?d=api&c=chat&m=get_token"

//关于我们
#define ABOUT_US_URL @"http://www.baidu.com"

/******************消息中心相关接口*******************/

#pragma mark - 消息中心相关

//11、获取我的消息列表 参数：authcode get方式\page 页数\per_page 第几页
//sort: 包含以下两种值，默认notice
//notice: 包含type=2, 4, 5, 6
//ac：包含type=3
#define GET_MY_MSG @"/index.php?d=api&c=msg&m=get_my_msg"

//12、获取消息详情 get方式\参数：authcode\msg_id
#define GET_MSG_INFO @"/index.php?d=api&c=msg&m=get_msg_info"

//13、获取未读/已读消息数量 sort:默认notice(通知): 包含type=2, 4, 5, 6 ac(活动)：包含type=3
#define GET_MSG_NUM @"/index.php?d=api&c=msg&m=msg_num"

//14、删除消息 GET 参数：authcode\msg_ids 多个id用英文逗号隔开
#define DEL_MY_MSG @"/index.php?d=api&c=msg&m=del_my_msg"

//11-4、更新消息状态(未读变已读) get 参数：authcode\msg_id: 消息id, 整形
#define UPDATE_MSG_STATUE @"/index.php?d=api&c=msg&m=update_status"

/******************首页活动相关接口*******************/

//1、活动列表
#define Get_Activity_list @"/index.php?d=api&c=activity&m=activity_list"

//2、获取是否有最新活动
//show:判断是否需要显示活动入口
//num:标识未读消息个数，大于0时显示红点
//latest_activity_id：最新的活动id,用来判断是否需要自动弹出活动页
#define Get_Show_activity @"/index.php?d=api&c=activity&m=show_activity"

/******************商品相关接口*******************/

#pragma mark - 商品相关

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

//商品相关接口=====================

//25、获取商品列表
#define PRODUCT_LIST @"/index.php?d=api&c=products&m=get_product_list"

//32、商品收藏列表

#define PRODUCT_COLLECT_LIST @"/index.php?d=api&c=products&m=get_favor_list"

//收藏商品
#define SHOUCANGRODUCT @"/index.php?d=api&c=products&m=add_favor"

//取消收藏
#define QUXIAOSHOUCANG @"/index.php?d=api&c=products&m=cancel_favor"

//搜索
#define SEACHERPRODUCT @"/index.php?d=api&c=products&m=search_product"

//活动详情
#define HUODONGXIANGQING @"/index.php?d=api&c=activity&m=get_activity_detail"

//16.意见反馈 post方式 authcode\suggest 意见  10~200个字符
#define ADD_SUGGEST @"/index.php?d=api&c=user&m=add_suggest"


//====================================收货地址相关接口====================================
#pragma mark - 收货地址相关

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


//订单相关接口=====================
#pragma mark - 订单相关

//40、购物车添加商品
#define ORDER_ADD_TO_CART @"/index.php?d=api&c=order&m=add_to_cart"

//41、购物车增加/减少商品
#define ORDER_EDIT_CART_PRODUCT @"/index.php?d=api&c=order&m=edit_cart_product"

//42、删除购物车记录
#define ORDER_DEL_CART_PRODUCT @"/index.php?d=api&c=order&m=del_cart_product"

//43、获取购物车记录
#define ORDER_GET_CART_PRODCUTS @"/index.php?d=api&c=order&m=get_cart_products"

//44、用户登录后同步购物车数据
#define ORDER_SYNC_CART_INFO @"/index.php?d=api&c=order&m=sync_cart_info"

//47、提交订单,后台生成订单号
#define ORDER_SUBMIT @"/index.php?d=api&c=order&m=submit_order"

//获取我最近使用的发票列表
#define FAPIAO_MYNEAR @"/index.php?d=api&c=user&m=get_user_invoice"

//45、获取用户默认地址
#define ORDER_GET_DEFAULT_ADDRESS @"/index.php?d=api&c=user&m=get_default_address"

//46、获取运费

#define ORDER_GET_EXPRESS_FEE @"/index.php?d=api&c=order&m=get_express_fee"

//获取可用优惠劵
#define ORDER_GET_USECOUPONLIST @"/index.php?d=api&c=order&m=use_coupon_list"

//48、获取支付宝签名或者微信生成预订单
#define ORDER_GET_SIGN @"/index.php?d=api&c=order&m=get_sign"

//49、获取订单详情
#define ORDER_GET_ORDER_INFO @"/index.php?d=api&c=order&m=get_order_info"

//50、获取我的订单列表
//authcode、status 订单状态（no_pay待付款，no_appointment待预约，no_comment待评价，complete已完成）、page 当前页、per_page 每页显示数量

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

//获取订单中的套餐列表 authcode\order_id
#define GET_SETMEALS_BY_ORDER @"/index.php?d=api&c=order&m=get_setmeals_by_order"

//***************家人管理****************//
#pragma mark - 家人管理相关接口

//21、获取我的家人列表
#define GET_FAMILY @"/index.php?d=api&c=user&m=get_family"

//22、添加我的家人信息
#define ADD_FAMILY @"/index.php?d=api&c=user&m=add_family"
//post:参数authcode、family_user_name 姓名、appellation 称谓、id_card 身份证号、gender 性别（1=》男 2=》女）、age 年龄、mobile 手机号

//23、编辑我的家人信息
#define EDIT_FAMILY @"/index.php?d=api&c=user&m=edit_family"
//post:参数authcode、family_user_name 姓名、appellation 称谓、id_card 身份证号、gender 性别（1=》男 2=》女）、age 年龄、mobile 手机号

//24、删除我的家人信息
#define DEL_FAMILY @"/index.php?d=api&c=user&m=del_family"
//post参数调取参数:authcode、family_uids 列表中的id 可传多个 用英文逗号隔开


//=======================================================

#pragma - mark 健康资讯相关接口
//    category_id 分类id  选填 1、健康资讯 2、体检常识
//1. 资讯列表 (GET get方式 page 当前页 per_page 每页显示数目)
#define HEALTH_ACTICAL_LIST @"/index.php?d=api&c=article&m=article_list"

//=======================================================

#pragma - mark 体检预约相关接口

//1、获取未预约
#define GET_NO_APPOINTS @"/index.php?d=api&c=appoint&m=get_no_appoints"

//2、获取预约体检分院

//(get:product_id 套餐商品id、province_id 省id、city_id 城市id、date 预约日期、longitude 经度（可不传）、latitude 纬度（可不传）)
#define GET_CENTER_PERCENT @"/index.php?d=api&c=appoint&m=get_center_percent"

//3、提交预约信息
//post 方式 authcode、order_id 订单id、product_id 套餐商品id、exam_center_id 预约体检机构id、date 预约体检日期（如：2015-11-13）、company_id 公司id（若是公司买单的 则要传）、order_checkuper_id 预约id（若是公司买单的 则要传）、family_uid 家人id 多个用英文逗号隔开（若是个人买单，则要传）、myself 是否包括本人 1是 0不是（若是个人买单，则要传）
#define MAKE_APPOINT @"/index.php?d=api&c=appoint&m=make_appoint"

//4、获取已预约/过期列表
//get 方式 authcode、expired 是否过期的 0=》未过期 1=》已过期、page、per_page
#define GET_APPOINT @"/index.php?d=api&c=appoint&m=get_appoints"

//获取已体检的预约列表
#define GET_FINISHED_APPOINT @"/index.php?d=api&c=appoint&m=get_finished_appoints"

//获取已体检进度详情
#define GET_AppointProgressDetail @"/index.php?d=api&c=appoint&m=view_finished_appoint"

//5、查看预约详情
//get 方式、authcode、appoint_id 预约id
#define GET_APPOINT_DETAIL @"/index.php?d=api&c=appoint&m=view_appoint"

//6、取消预约
//post 方式、authcode、appoint_id 预约id
#define CANCEL_APPOINT @"/index.php?d=api&c=appoint&m=cancel_appoint"

//7、重新/编辑预约
//post、authcode、appoint_id 预约id、exam_center_id 预约体检分院id、date 预约日期
#define UPDATE_APPOINT @"/index.php?d=api&c=appoint&m=update_appoint"

//8、获取全部预约列表
//1.如果含有order_id=0的字段，则是公司代金券，详见未预约列表接口
//2.其它情况
//appoint_status：预约状态  1：未预约  2：已预约未过期  3：已预约已过期
#define GET_ALL_APPOINTS @"/index.php?d=api&c=appoint&m=get_all_appoints"

//9、获取分院列表 province_id  省份id  必填
//city_id  城市id  必填
//brand_id  品牌id  选填
//latitude  纬度  选填
//longitude 经度  选填
//page
//per_page
#define Get_hospital_list @"/index.php?d=api&c=appoint&m=get_center_list"

//10、分院详情
#define Get_hospital_detail @"/index.php?d=api&c=appoint&m=get_center_detail"

//=======================================================

#pragma - mark 体检报告

//1.报告列表 authcode\page\per_page
#define REPORT_LIST @"/index.php?d=api&c=report&m=report_list"

//2.报告详情 authcode\report_id\page\per_page
#define REPORT_DETAIL @"/index.php?d=api&c=report&m=report_detail"

//3.添加报告
//post 方式
//参数：authcode type 1表示普通上传 2表示输入账号密码查询（上传）
//1、 family_uid和myself任意传一个 或另一个传0  myself权重高
//checkup_time  体检时间(如：2015-12-05)
//图片
//2、brand_id、account_no、password成功返回url
#define REPORT_ADD @"/index.php?d=api&c=report&m=add_report"

//4.删除报告 get 方式 authcode\report_id
#define REPORT_DEL @"/index.php?d=api&c=report&m=del_report"

//报告支持的品牌
#define Report_center @"/index.php?d=api&c=report&m=get_report_center"

//========================================================

#pragma - mark 挂号网对接

//挂号网相关接口
//1、预约 get
//target配置：
//1     预约挂号
//2     转诊预约
//3     健康顾问团
//4     公立医院主治医生
//5     公立医院权威专家
//6     我的问诊
//7     我的预约
//8     我的转诊
//9     我的关注
//10    家庭联系人
//11    家庭病例
//12    我的申请
//13    医生随访
//14    购药订单

//1、参数:authcode 必传 target 用户动作标号 必传  例:预约挂号传递 1
#define Guahao_Appoint @"/index.php?d=api&c=register&m=appoint"

//2、专家问诊医生列表
#define Guahao_doctorlist @"/index.php?d=api&c=register&m=doctor_list"

//3、医生跳转链接 //get 方式authcode 必填、detail_url医生列表中的detail_url

#define Guahao_doctorDetail @"/index.php?d=api&c=register&m=doctor_url"


#pragma - mark Go健康对接

//1、提交订单
#define GoHealth_submit_order @"/index.php?d=api&c=go_order&m=submit_order"

//2、获取支付宝或者微信签名 authcode:\order_id: 订单id\sign_type: ali或者weixin
#define GoHealth_get_sign @"/index.php?d=api&c=go_order&m=get_sign"

//3、验证订单支付状态 get 参数:authcode\order_id  订单id
#define GoHealth_get_order_pay @"/index.php?d=api&c=go_order&m=get_order_pay"

//4、提交预约人信息
#define GoHealth_upAppointUserInfo @"/index.php?d=api&c=go_order&m=make_appoint"

//6、获取订单详情
#define GoHealth_get_order_info @"/index.php?d=api&c=go_order&m=get_order_info"

//7、获取订单详情产品清单
#define GoHealth_get_setmeals_by_order @"/index.php?d=api&c=go_order&m=get_setmeals_by_order"

//8、go健康订单 用户申请退款
#define GoHealth_apply_refund @"/index.php?d=api&c=go_order&m=apply_refund"

//9、用户取消/删除订单
#define GoHealth_handle_order @"/index.php?d=api&c=go_order&m=handle_order"

//go健康产品已销售数量
#define GoHealth_product_sale @"/index.php?d=api&c=go_order&m=get_product_sale"

#endif
