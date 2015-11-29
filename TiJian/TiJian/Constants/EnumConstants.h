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
    Gender_Girl = 1,
    Gender_Boy
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
    ORDERTYPE_DaiFu = 1, //待付款
    ORDERTYPE_NoAppoint,//待预约
    ORDERTYPE_Appointed,//已预约
    ORDERTYPE_WanCheng, //完成
    ORDERTYPE_TuiHuan //退换
}ORDERTYPE;

typedef enum{
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


#endif
