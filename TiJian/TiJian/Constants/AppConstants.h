//
//  AppConstants.h
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  存放整个系统会用到的一些常量
 */

#ifndef WJXC_AppConstants_h
#define WJXC_AppConstants_h

///屏幕宽度
#define DEVICE_WIDTH  [UIScreen mainScreen].bounds.size.width
///屏幕高度
#define DEVICE_HEIGHT [UIScreen mainScreen].bounds.size.height

//BunleIdentifier
#define AppBunleIdentifier [[NSBundle mainBundle] bundleIdentifier]
//系统9.0之后
#define IOS9_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"9.0"] != NSOrderedAscending )
//系统8.0之后
#define IOS8_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending )
//系统7.0之后
#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )

#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6PLUS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

//==============================打印类、方法
#pragma mark - Debug log macro
//start
#ifdef DEBUG

#define DDLOG( s , ...) NSLog( @"%@(%d):<%@> %@",[[NSString stringWithUTF8String:__FILE__] lastPathComponent],__LINE__,NSStringFromSelector(_cmd),[NSString stringWithFormat:(s), ##__VA_ARGS__] )
//#define DDLOG( s , ...) NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define DDLOG_CURRENT_METHOD NSLog(@"%@-%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd))


#else

#define DDLOG(...) ;
#define DDLOG_CURRENT_METHOD ;

#endif


//==============================end

//适配6 PLUS 放大1.2倍
#define FitScreen(a) (iPhone6PLUS ? a * 1.2 : a)

//根视图
#define ROOTVIEWCONTROLLER (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController

//图片比例
#define W_H_RATIO 200.f/320
//计算BMI
#define BMI(weight,height) (weight / powf(height * 0.01, 2))

//int 转 string
#define NSStringFromFloat(float) [NSString stringWithFormat:@"%f",(float)]
#define NSStringFromInt(int) [NSString stringWithFormat:@"%d",(int)]

//=====================weak 和 strong
#pragma mark - weak 和 strong
#define WeakObj(o) autoreleasepool{} __weak typeof(o) Weak##o = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

//错误提示信息 

#define ALERT_ERRO_PHONE @"请输入有效手机号"
#define ALERT_ERRO_PASSWORD @"密码格式有误,请输入6~12位英文字母或数字"
#define ALERT_ERRO_SECURITYCODE @"请输入有效验证码"
#define ALERT_ERRO_FINDPWD @"两次密码不一致"

#define Alert_AppointSucess @"预约提交成功,查看请前往”个人中心>体检预约"

//秒杀相关描述语
#define MIAOSHAO_END_TEXT @"秒杀已结束"
#define MIAOSHAO_PRE_TEXT @"秒杀结束倒计时:"

//分页网络请求
#define G_PER_PAGE 10
#define PAGESIZE_BIG 50 //根据需求选择不同页size
#define PAGESIZE_MID 20
#define PAGESIZE_SMALL 10

//保存用户信息设备信息相关

#define USER_INFO @"userInfo"//用户信息
#define USER_FACE @"userface"
#define USER_NAME @"username"
#define USER_PWD @"userPw"
#define USER_UID @"useruid"
#define USERINFO_MODEL @"USERINFO_MODEL" //存储在本地用户model

#define USERLocation @"locationInfo"

#define USER_MSG_NUM @"msgNum" //通知总数通知消息个数
#define USER_Notice_Num @"noticeNum" //通知消息个数
#define USER_Ac_Num @"acNum" //未读活动消息个数

#define USER_READED_NEWESTMSGID @"readedNewestMsgId"//存储上次最新的活动id,用于判断是否需要自动打开活动轮播页

#define USERCOMMONLYUSEDADDRESS @"USERCOMMONLYUSEDADDRESS"//用户最近访问
#define USERCOMMONLYUSEDADDRESS_P @"USERCOMMONLYUSEDADDRESS_P"//预约挂号用户最近访问
#define USERCOMMONLYUSEDSEARCHWORD @"USERCOMMONLYUSEDSEARCHWORD"//用户常用搜索
#define USERHistorySearch_hospital @"USERHistorySearch_hospital"//医院历史搜索
#define CitiesCacheOfHospital @"CitiesOfHospital_provinceId="//医院缓存key拼接provinceid
#define HospitalCacheOfHospital @"HospitalOfHospital_provinceId="//医院缓存key拼接provinceid
//分享相关
#define Share_title @"shareTitle" //分享标题
#define Share_imageUrl @"shareImageUrl" //分享图片地址
#define Share_content @"shareContent" //分享摘要


//两个登陆标识
#define LOGIN_SERVER_STATE @"user_login_state" //服务器 no是未登陆  yes是已登陆
#define LOGIN_RONGCLOUD_STATE @"rongcloudLoginState"//融云登陆状态

#define USER_AUTHOD @"user_authod"
#define USER_CHECKUSER @"checkfbuser"
#define USER_HEAD_IMAGEURL @"userHeadImageUrl"//头像url
#define USER_NoPwd @"USER_NoPwd" //用户是否有密码

#define USER_AUTHKEY_OHTER @"otherKey"//第三方key
#define USRR_AUTHKEY @"authkey"
#define USER_DEVICE_TOKEN @"DEVICE_TOKEN"
#define USER_RONGCLOUD_TOKEN @"RongCloudToken" //融云token

#define USER_UPDATEHEADIMAGE_STATE @"updateHeadImage"//更新用户头像
#define USER_NEWHEADIMAGE @"newHeadImage"//新头像

#define HomePage_cus_img @"HomePage_cus_img" //首页个性化定制顶部banner

//***************************** 三方平台appkey **********************************

#define AppStore_Appid @"1065404194"//appStore 海马医生

#define AppDownloadUrl @"http://a.app.qq.com/o/simple.jsp?pkgname=com.medical.app"//应用宝下载地址,可自动跳转至appStore

//友盟
#define UmengAppkey @"562455d167e58ede5000b699"//正式 umeng后 mobile@jiruijia.com


//百度地图
#define BAIDUMAP_APPKEY @"vEwczkv6IbBHcAjrkOswLmF3" //com.medical.hema
//百度地图 企业版
#define BAIDUMAP_APPKEY_Enterprise @"s0BroqlD9hCgwm67lOwrzy3K" //com.medical.hemaEnterprise

//融云
//1、开发环境
//#define RONGCLOUD_IM_APPKEY    @"p5tvi9dst1qn4" //融云账号 18600912932
//#define RONGCLOUD_IM_APPSECRET @"qCqG93VU6WBz"

//1、发布环境
#define RONGCLOUD_IM_APPKEY    @"n19jmcy59o089"
#define RONGCLOUD_IM_APPSECRET @"aeVAMwLAZF"

//融云客服 1.0
#define SERVICE_ID @"KEFU1448965696367"
//正式
#define SERVICE_ID_2 @"KEFU145261606391628"

//是否开启所有日志
#define EnableErroLogCode 2000  //n代表显示大于n的所有错误信息 发布时改为2000

//JPush环境配置
#define JPushIsProduction 1 //是否是生成环境 1为是 0为否
#define JPushAppkey @"d191338077d6b2157afe2bf7"
#define JPushChannel @"AppStore" //发布渠道

//========================== 海马医生

//sina SZK
#define SinaAppKey @"2127298190"
#define SinaAppSecret @"0c0ba054bfabec2b2cb3dc0cef811eb6"

//QQ 吉瑞嘉
#define QQAPPID @"1105131459" //tencent1105131459 十六进制:QQ41def7c3; 生成方法:NSString *str = [ [NSString alloc] initWithFormat:@"%x",1105131459];
#define QQAPPKEY @"9bXYfymSVFxpSKgp"

//微信 吉瑞嘉
#define WXAPPID @"wx47f54e431de32846" //衣加衣改为海马医生 商家检查 吉瑞嘉
#define WXAPPSECRET @"a71699732e3bef01aefdaf324e2f522c"
#define RedirectUrl @"http://sns.whalecloud.com/sina2/callback" //回调地址

//海马客服电话
#define HaiMa_service @"4006279589"



#endif
