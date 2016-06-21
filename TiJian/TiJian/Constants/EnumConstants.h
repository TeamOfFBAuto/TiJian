//
//  EnumConstants.h
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  常用的一些枚举
 */
#ifndef WJXC_EnumConstants_h
#define WJXC_EnumConstants_h

//登录类型 normal为正常手机登陆，sweibo、qq、weixin分别代表新浪微博、qq、微信登陆
typedef enum{
    Login_Normal = 0,
    Login_Sweibo,
    Login_QQ,
    Login_Weixin
}Login_Type;

//性别
typedef enum{
    Gender_NO = 0,//未知
    Gender_Boy = 1, //1 男
    Gender_Girl = 2, //2  女
    Gender_Other // 通用
}Gender;

//个人定制 问题的类型
typedef enum{
    QUESTIONTYPE_SEX = 1,//性别问题
    QUESTIONTYPE_AGE ,//年龄问题
    QUESTIONTYPE_HEIHGT ,//身高问题
    QUESTIONTYPE_WEIGHT ,//体重问题
    QUESTIONTYPE_OTHER //其他问题
}QUESTIONTYPE;

//个人定制 问题的选项类型 单选、多选、其他
//选项类型默认1  1=》多选一 2=》除特殊选项可多选，选特殊选项则其他都不能选 3=》除特殊选项单选，分别可以和特殊选项同时选中 4=》任意选择
typedef enum{
    QUESTIONOPTIONTYPE_SINGLE = 1,//单选
    QUESTIONOPTIONTYPE_MULTI_NOSPECIAL = 2,//除了特殊选项可多选，选特殊选项则其他都不能选
    QUESTIONOPTIONTYPE_SINGLE_NOSPECIAL = 3,//正常的选项单选,但是可以分别和特殊选项组合
    QUESTIONOPTIONTYPE_MULTI = 4,//多选
    QUESTIONOPTIONTYPE_OTHER //其他
}QUESTIONOPTIONTYPE;


//注册类型，1=》手机注册 2=》邮箱注册，默认为手机注册
typedef enum{
    Register_Phone = 1,
    Register_Email
}Register_Type;

//验证码用途 1=》注册 2=》商店短信验证 3=》找回密码 4⇒申请成为搭配师获取验证码 默认为1) int
typedef enum{
    SecurityCode_Register = 1,
    SecurityCode_FindPWD,
    SecurityCode_Match
}SecurityCode_Type;

typedef enum{
    ORDERTYPE_All = 1,//全部
    ORDERTYPE_DaiFu , //待付款
    ORDERTYPE_NoAppoint,//待预约
    ORDERTYPE_Appointed,//已预约
    ORDERTYPE_WanCheng, //完成
    ORDERTYPE_TuiHuan, //退换
    ORDERTYPE_Payed//已付款
}ORDERTYPE;

typedef enum{
    ORDERACTIONTYPE_Default = 0, //不做任何操作
    ORDERACTIONTYPE_Pay = 1, //去支付
    ORDERACTIONTYPE_Appoint,//去预约
    ORDERACTIONTYPE_Comment, //评价晒单
    ORDERACTIONTYPE_BuyAgain, //再次购买
    ORDERACTIONTYPE_Refund  //申请退款
}ORDERACTIONTYPE; // 订单列表 操作类型


typedef enum {
    
    PAY_RESULT_TYPE_Success = 1,//成功
    PAY_RESULT_TYPE_Waiting = 2,//处理中
    PAY_RESULT_TYPE_Fail = 3 //失败
    
}PAY_RESULT_TYPE;//支付结果


typedef enum {
    GCouponType_youhuiquan,//优惠券
    GCouponType_daijinquan,//代金券
    GCouponType_use_youhuiquan,//使用优惠券
    GCouponType_use_daijinquan,//使用代金券
    GCouponType_disUse_youhuiquan,//不可用的优惠券
    GCouponType_disUse_daijinquan//不可用代金券
}GCouponType;


typedef enum {
    PageResultType_nologin = 1,//未登录
    PageResultType_nodata = 2,//数据为空
    PageResultType_requestFail = 3 //请求异常
}PageResultType;//页面结果类型

//消息通知类型
//PhysicalExamination (PE)
typedef enum{
    /**
     *  客服消息 1
     */
    MsgType_Service = 1 ,//客服消息
    /**
     *  体检提醒消息 2
     */
    MsgType_PEAlert = 2,//2、体检提醒消息（提前一天通知） theme_id: 预约详情id
    /**
     *  活动消息 3
     */
    MsgType_Activity = 3,//3、活动消息
    /**
     *  体检报告进度 4
     */
    MsgType_PEProgress = 4, //4、体检报告进度
    /**
     *  体检报告解读完成消息 5
     */
    MsgType_PEReportReadFinish = 5,//5、体检报告报告解读完成消息   theme_id: 体检报告id
    /**
     *  订单退款状态 6
     */
    MsgType_OrderRefundState = 6 //6、订单的退款状态    theme_id: 订单id

}MsgType;
//pic: 封面图(可能为空)

//typedef enum {
//    PayActionType_default = 0,//默认 0 海马体检商城支付
//    PayActionType_goHealth// go健康相关支付
//}PayActionType;

/**
 *  开启客服来源类型
 */
typedef enum{
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
    SourceType_Order,
    /**
     *  来源自单品详情
     */
    SourceType_ProductDetail_goHealth,
    /**
     *  来源自订单详情
     */
    SourceType_Order_goHealth
}SourceType;

typedef enum {
    PlatformType_default = 0,//默认 0 海马相关
    PlatformType_goHealth// go健康相关
}PlatformType; //平台信息

typedef enum {
    ACTIONTYPE_NORMAL = 0,//滚动
    ACTIONTYPE_SURE, //确定
    ACTIONTYPE_Refresh, //刷新数据
    ACTIONTYPE_CANCEL, //取消
    ACTIONTYPE_SURE_AllC //确定
}ACTIONTYPE;

////挂号网相关接口
////1、预约 get
////target配置：
//typedef enum {
//    /**
//     *  1、预约挂号
//     */
//    GuhaoActionType_guaHao = 1,//1     预约挂号
//    /**
//     *  2、转诊预约
//     */
//    GuhaoActionType_zhuanZhen = 2,//2     转诊预约
//    /**
//     *  3、健康顾问团
//     */
//    GuhaoActionType_ = 3,//3     健康顾问团
//    GuhaoActionType_appoint = 4,//4     公立医院主治医生
//    GuhaoActionType_appoint = 5,//5     公立医院权威专家
//    GuhaoActionType_appoint = 6,//6     我的问诊
//    GuhaoActionType_appoint = 7,//7     我的预约
//    GuhaoActionType_appoint = 8,//8     我的转诊
//    GuhaoActionType_appoint = 9,//9     我的关注
//    GuhaoActionType_appoint = 10,//10    家庭联系人
//    GuhaoActionType_appoint = 11,//11    家庭病例
//    GuhaoActionType_appoint = 12,//12    我的申请
//    GuhaoActionType_appoint = 13,//13    医生随访
//    GuhaoActionType_appoint = 14,//14    购药订单
//
//}GuhaoActionType;



#endif
