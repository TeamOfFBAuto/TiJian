//
//  AppDelegate.m
//  TiJian
//
//  Created by lichaowei on 15/9/29.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "BMapKit.h"
#import <AlipaySDK/AlipaySDK.h>//支付宝
#import "WXApi.h"//微信
#import "SimpleMessage.h"
#import "UMSocial.h"
#import "MobClick.h"
#import "JPUSHService.h"//version 2.1.5
#import "ReportDetailController.h"//报告详情
#import "OrderInfoViewController.h"//订单详情
#import "WebviewController.h"//web
#import "AppointDetailController.h"//预约
#import "LogView.h"
//#import <Bugtags/Bugtags.h>//bugtags
#import <JSPatch/JSPatch.h> //在线修复bug
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaSSOHandler.h"

#define kAlertViewTag_token 100 //融云token
#define kAlertViewTag_otherClient 101 //其他设备登陆
#define kAlertViewTag_active 102 //正在前台 推送消息

@interface AppDelegate ()<BMKGeneralDelegate,WXApiDelegate,GgetllocationDelegate,RCIMReceiveMessageDelegate,RCIMUserInfoDataSource,RCIMConnectionStatusDelegate>
{
    GMAPI *mapApi;
    LocationBlock _locationBlock;
    BMKMapManager* _mapManager;
    CLLocationManager *_locationManager;
    
    int _getRongTokenTime;//获取融云token次数
    NSTimer *_getRongTokenTimer;//获取融云token计时器
    NSDictionary *_remoteMessageDic;//远程推送消息
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    sleep(1);
    
//    [self testNetwork];
    
    NSString *version = [[NSString alloc] initWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    //友盟
    [self umengSocial];
    
    //JSPatch distribution
//    [JSPatch startWithAppKey:JSPatchAppKey];
//    [JSPatch sync];
    
    //JSPatch develope
    [JSPatch testScriptInBundle];
    
        
    //注册上传头像通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(uploadHeadImage) name:NOTIFICATION_UPDATEHEADIMAGE object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotification:) name:NOTIFICATION_LOGIN object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotification:) name:NOTIFICATION_UPDATEMSGNUM object:nil];
    
    RootViewController *root = [[RootViewController alloc]init];
    self.window.rootViewController = root;
    
    //微信支付
    NSString *name = [NSString stringWithFormat:@"海马医生%@",version];
    [WXApi registerApp:WXAPPID withDescription:name];
    
    //百度地图
    [self startBaiduService];
    
    //初始化融云SDK。
    [self startRongCloud];
    
    /**
     * 统计推送打开率1 融云
     */
    [[RCIMClient sharedRCIMClient] recordLaunchOptionsEvent:launchOptions];
    
    //检查版本
    [self checkVersion];
    
    //================================= JPUSH =========================================
    //JPush Required
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:JPushAppkey
                          channel:JPushChannel
                 apsForProduction:[NSStringFromInt(JPushIsProduction) boolValue]
            advertisingIdentifier:nil];
    
    //UIApplicationLaunchOptionsRemoteNotificationKey,判断是通过推送消息启动的
    
    NSDictionary *userInfo = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if (userInfo)
    {
        DDLOG(@"didFinishLaunch : userInfo %@",userInfo);
    }

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForDidSetupNotification:) name:kJPFNetworkDidSetupNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForDidCloseNotification:) name:kJPFNetworkDidCloseNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForDidRegisterNotification:) name:kJPFNetworkDidRegisterNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForDidLoginNotification:) name:kJPFNetworkDidLoginNotification object:nil];
    //非APNS消息
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForDidReceiveMessageNotification:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    //错误提示
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForErrorNotification:) name:kJPFServiceErrorNotification object:nil];

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    DDLOG_CURRENT_METHOD;
    [LTools updateTabbarUnreadMessageNumber];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    //获取未读消息num
    [self netWorkForMsgNum];
}

//app每次启动或者变活跃
- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    //上传头像
    [self uploadHeadImage];
    
    //获取未读消息num
    [self netWorkForMsgNum];
    
    //这里处理新浪微博SSO授权进入新浪微博客户端后进入后台，再返回原来应用
    [UMSocialSnsService  applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/**
 * 推送处理2
 */
//注册用户通知设置
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
    
    // register to receive notifications
    [application registerForRemoteNotifications];
}
/**
 * 推送处理3
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *token = [[[[deviceToken description]
                        stringByReplacingOccurrencesOfString:@"<"withString:@""]
                        stringByReplacingOccurrencesOfString:@">"withString:@""]
                        stringByReplacingOccurrencesOfString:@" "withString:@""];
    
    //融云
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
    
    //JPush Required
    
    [JPUSHService registerDeviceToken:deviceToken];
    
    //本地记录
    [LTools setObject:token forKey:USER_DEVICE_TOKEN];
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    DDLOG(@"本地通知%@",notification.userInfo);
    
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
    
    //在此获取rongcloud本地通知消息
    /**
     * 统计推送打开率3
     */
    [[RCIMClient sharedRCIMClient] recordLocalNotificationEvent:notification];
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive){
        //程序在后台运行 点击消息进入走此处,做相应处理
        [self pushToMessageDetailWithResult:notification.userInfo ignoreRongcloud:NO];
    }

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    DDLOG(@"hahah2");
    DDLOG_CURRENT_METHOD;
    
    [self actionForApplication:application notificationUserInfo:userInfo];
    
//    [[LogView logInstance]addLog:@"RemoteNotification_short"];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
//    [[LogView logInstance]addLog:@"RemoteNotification_long"];

    [self actionForApplication:application notificationUserInfo:userInfo];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

/**
 *  处理远程通知消息
 *
 *  @param application 用于判断程序状态
 *  @param userInfo    通知内容
 */
- (void)actionForApplication:(UIApplication *)application
        notificationUserInfo:(NSDictionary *)userInfo
{
    //JPush
    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    
    // update unread number
    [LTools updateTabbarUnreadMessageNumber];
    
    /**
     * 统计推送打开率2
     */
    [[RCIMClient sharedRCIMClient] recordRemoteNotificationEvent:userInfo];
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive){
        
        //程序在后台运行 点击消息进入走此处,做相应处理
        [self pushToMessageDetailWithResult:userInfo ignoreRongcloud:NO];
    }
    if (state == UIApplicationStateActive) {
        
        //程序就在前台
        _remoteMessageDic = userInfo;
        
        NSDictionary *aps = userInfo[@"aps"];
        NSString *alertMessage = aps[@"alert"];//消息内容
        
        //提示之后再查看
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"消息通知" message:alertMessage delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"查看", nil];
        alertView.tag = kAlertViewTag_active;
        [alertView show];
    }
    if (state == UIApplicationStateBackground)
    {
        DDLOG(@"UIApplicationStateBackground %@",userInfo);
    }
}

#pragma mark - 友盟相关

- (void)umengSocial
{
    //友盟统计
    UMConfigInstance.appKey = UmengAppkey;
    UMConfigInstance.channelId = @"";
    UMConfigInstance.eSType = E_UM_NORMAL; // 仅适用于游戏场景
    UMConfigInstance.ePolicy = BATCH;
    [MobClick startWithConfigure:UMConfigInstance];
    
#ifdef DEBUG
    [MobClick setLogEnabled:YES];
#endif
    [MobClick setLogEnabled:YES];
    //使用友盟统计
    
    [UMSocialData setAppKey:UmengAppkey];
    
    //打开调试log的开关
    [UMSocialData openLog:NO];
    
    //打开新浪微博的SSO开关，设置新浪微博回调地址，这里必须要和你在新浪微博后台设置的回调地址一致。需要 #import "UMSocialSinaSSOHandler.h"
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:SinaAppKey secret:SinaAppSecret RedirectURL:RedirectUrl];
    
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:QQAPPID appKey:QQAPPKEY url:AppDownloadUrl];
    
    //设置支持没有客户端情况下使用SSO授权
    [UMSocialQQHandler setSupportWebView:YES];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:WXAPPID appSecret:WXAPPSECRET url:AppDownloadUrl];
    
    NSArray *snsNames = @[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQzone,UMShareToQQ];
    //UMShareToSina
    [UMSocialConfig hiddenNotInstallPlatforms:snsNames];
    
}


#pragma mark - 通知处理

- (void)actionForNotification:(NSNotification *)notification
{
    //登录通知
    if ([notification.name isEqualToString:NOTIFICATION_LOGIN]) {
        [self startRongCloud];//启动融云
        [self netWorkForMsgNum];//获取未读消息条数
    }else if ([notification.name isEqualToString:NOTIFICATION_UPDATEHEADIMAGE]){
        [self uploadHeadImage];//上传头像
    }else if ([notification.name isEqualToString:NOTIFICATION_UPDATEMSGNUM]){
        [self netWorkForMsgNum];
    }
}

#pragma  mark

#pragma - mark 注册远程通知

- (void)startRemoteNotificationWithAppilication:(UIApplication *)application
{
    /**
     * 推送处理1
     */
    if ([application
         respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:(UIUserNotificationTypeBadge |
                                                                  UIUserNotificationTypeSound |
                                                                  UIUserNotificationTypeAlert)
                                                categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeAlert |
        UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
}

#pragma mark - 版本检查

- (void)checkVersion
{
    //版本更新
    [[LTools shareInstance]versionForAppid:AppStore_Appid Block:^(BOOL isNewVersion, NSString *updateUrl, NSString *updateContent) {
                
    }];
}
#pragma mark - 上传更新头像

/**
 *  上传头像
 *
 *  @param aImage
 */
- (void)uploadHeadImage
{
    //不需要更新,return
    if (![LTools boolForKey:USER_UPDATEHEADIMAGE_STATE]) {
        
        DDLOG(@"不需要更新头像");
        return;
    }else
    {
        DDLOG(@"需要更新头像");
    }
    
    NSString *authkey = [UserInfo getAuthkey];
    
    //没有authcode return
    if (authkey.length == 0) {
        
        return;
    }
    
    UIImage *image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:USER_NEWHEADIMAGE];
    
    NSDictionary *params = @{@"authcode":authkey};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:USER_UPLOAD_HEADIMAGE parameters:params constructingBodyBlock:^(id<AFMultipartFormData> formData) {
        
        if (image != nil) {
            NSData *imageData =UIImageJPEGRepresentation(image, 1.f);
            [formData appendPartWithFileData:imageData name:@"pic" fileName:@"myhead.jpg" mimeType:@"image/jpg"];
        }
        
    } completion:^(NSDictionary *result) {
        
        DDLOG(@"completion result %@",result[Erro_Info]);
        
        [LTools setBool:NO forKey:USER_UPDATEHEADIMAGE_STATE];//不需要更新头像
        
        [[SDImageCache sharedImageCache] removeImageForKey:USER_NEWHEADIMAGE fromDisk:YES];
        
        NSString *avatar = result[@"avatar"];
        
        [UserInfo updateUserAvatar:avatar];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATEHEADIMAGE_SUCCESS object:nil];//更新头像成功
        
    } failBlock:^(NSDictionary *result) {
        
        DDLOG(@"failBlock result %@",result[Erro_Info]);
        
    }];
}

#pragma mark - 支付相关

#pragma - mark 支付宝支付回调

/**
 这里处理新浪微博SSO授权之后跳转回来，和微信分享完成之后跳转回来
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    DDLOG(@"openURL------ %@",url);
    
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
        //调用其他SDK，例如支付宝SDK等
        
        //当支付宝客户端在操作时,商户 app 进程在后台被结束,只能通过这个 block 输出支付 结果。
        
        //如果极简开发包不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给开 发包
        if ([url.host isEqualToString:@"safepay"]) {
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                      standbyCallback:^(NSDictionary *resultDic) {
                                                          
                                                          DDLOG(@"ali result = %@",resultDic);
                                                          
                                                          
                                                      }]; }
        
        if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回 authCode
            [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
                
                DDLOG(@"ali result = %@",resultDic);
                
            }];
        }
        
        //来自微信
        if ([url.host isEqualToString:@"pay"]) {
            
            return  [WXApi handleOpenURL:url delegate:self];
        }
    }
    return result;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:self];
}

#pragma - mark 微信支付回调

- (void)onResp:(BaseResp *)resp {
    
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *response = (PayResp *)resp;
        
        BOOL result = NO;
        NSString *errInfo = nil;
        switch (response.errCode) {
            case WXSuccess:
            {
                //服务器端查询支付通知或查询API返回的结果再提示成功
                DDLOG(@"支付成功");
                errInfo = @"支付成功";
                result = YES;
            }
                break;
            case WXErrCodeCommon:
            case WXErrCodeSentFail:
            {
                DDLOG(@"1、可能的原因：签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等.\n2、发送失败");
                errInfo = @"微信支付异常";
            }
                break;
            case WXErrCodeUserCancel:
                DDLOG(@"用户取消支付");
                errInfo = @"用户取消支付";
                
                break;
            case WXErrCodeAuthDeny:
                
                DDLOG(@"授权失败");
                errInfo = @"微信支付授权失败";
                break;
            default:
                DDLOG(@"支付失败， retcode=%d",resp.errCode);
                errInfo = @"微信支付失败";
                break;
        }
        //微信支付通知
        NSDictionary *params = @{@"result":[NSNumber numberWithBool:result],@"erroInfo":errInfo};
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_PAY_WEIXIN_RESULT object:nil userInfo:params];
    }
}

#pragma mark - 百度地图启动、获取坐标

#pragma - mark  百度地图

- (void)startBaiduService
{
    //使用百度地图相关
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0)
    {
        //设置定位权限 仅ios8有意义
        [_locationManager requestWhenInUseAuthorization];// 前台定位
    }
    [_locationManager startUpdatingLocation];
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    
    
    NSString *BD_Appkey = BAIDUMAP_APPKEY;
    if ([LTools isEnterprise]) {
        BD_Appkey = BAIDUMAP_APPKEY_Enterprise;
    }
    // 如果要关注网络及授权验证事件，请设定  generalDelegate参数
    BOOL ret = [_mapManager start:BD_Appkey  generalDelegate:self];
    if (!ret) {
        DDLOG(@"manager start failed!");
    }
}

#pragma - mark 获取坐标

- (void)startDingweiWithBlock:(LocationBlock)location
{
    _locationBlock = location;
    
    //定位获取坐标
    mapApi = [GMAPI sharedManager];
    mapApi.delegate = self;
    
    [mapApi startDingwei];
    
}

#pragma - mark 定位Delegate

- (void)theLocationDictionary:(NSDictionary *)dic{
    
    DDLOG(@"定位成功------>%@",dic);
    
    if (_locationBlock) {
        
        _locationBlock(dic);
    }
    
    [GMAPI sharedManager].theLocationDic = [dic copy];
}


-(void)theLocationFaild:(NSDictionary *)dic{
    
    DDLOG(@"定位失败----->%@",dic);
    
    if (_locationBlock) {
        _locationBlock(dic);
    }
}


#pragma - mark BMKGeneralDelegate <NSObject>

/**
 *返回网络错误
 *@param iError 错误号
 */
- (void)onGetNetworkState:(int)iError
{
    
}

/**
 *返回授权验证错误
 *@param iError 错误号 : 为0时验证通过，具体参加BMKPermissionCheckResultCode
 */
- (void)onGetPermissionState:(int)iError
{
    
}


#pragma mark - RongCloud

- (void)startRongCloud
{
    if (![LoginViewController isLogin]) {
        
        DDLOG(@"未登录不需要start rongcloud");
        return;
    }
    
    //融云
    [[RCIM sharedRCIM] initWithAppKey:RONGCLOUD_IM_APPKEY];
    
    [[RCIM sharedRCIM]setReceiveMessageDelegate:self];
    
    [[RCIM sharedRCIM]setConnectionStatusDelegate:self];
    
    [[RCIM sharedRCIM]setUserInfoDataSource:self];//用户信息提供者
    
    [RCIM sharedRCIM].enableMessageAttachUserInfo = YES;

    UserInfo *user = [UserInfo userInfoForCache];
    
    if (user) {
        
        RCUserInfo *userInfo = [[RCUserInfo alloc]initWithUserId:user.uid name:user.user_name portrait:user.avatar];
        [RCIM sharedRCIM].currentUserInfo = userInfo;
    }
    
    //头像样式
    [[RCIM sharedRCIM] setGlobalMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
    
    //SDK 初始化方法 initWithAppKey 之后后注册消息类型
    [[RCIMClient sharedRCIMClient]registerMessageType:SimpleMessage.class];
    
    //开始融云登录
    [self startLoginRongTimer];
}

#pragma - mark  RCIMConnectionStatusDelegate <NSObject>

/**
 *  网络状态变化。
 *
 *  @param status 网络状态。
 */
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status
{
    //其他设备登陆
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"提示"
                              message:@"您的帐号在别的设备上登录，您被迫下线！"
                              delegate:self
                              cancelButtonTitle:@"知道了"
                              otherButtonTitles:@"重新登录", nil];
        alert.tag = kAlertViewTag_otherClient;
        [alert show];
        
    }
    //token不对
    else if (status == ConnectionStatus_TOKEN_INCORRECT) {
        DDLOG(@"Token已过期，请重新登录");
        [LTools setObject:nil forKey:USER_RONGCLOUD_TOKEN];
        [self startLoginRongTimer];
    }
}

#pragma - mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertViewTag_otherClient) {
        
        if (buttonIndex == 1) {
            
            [self startLoginRongTimer];
        }
    }else if (alertView.tag == kAlertViewTag_active) {
        
        if (buttonIndex == 1) {
            //查看消息
            NSDictionary *userInfo = _remoteMessageDic;
            //直接查看
            [self pushToMessageDetailWithResult:userInfo ignoreRongcloud:YES];
        }
    }
}


#pragma - mark RCIMReceiveMessageDelegate <NSObject>
/**
 接收消息到消息后执行。
 
 @param message 接收到的消息。
 @param left    剩余消息数.
 */
- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left
{
//    DDLOG(@"RCIMReceiveMessageDelegate 剩余 %d",left);
    //接受到消息 更新未读消息
    
    if (0 == left) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
            DDLOG_CURRENT_METHOD;
            [LTools updateTabbarUnreadMessageNumber];
            
        });
    }
}

#pragma - mark RCIMUserInfoDataSource <NSObject>

/**
 *  获取用户信息。
 *
 *  @param userId     用户 Id。
 *  @param completion 用户信息
 */
- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *userInfo))completion
{
    DDLOG(@"getUserInfoWithUserId %@",userId);
    
    if ([userId isEqualToString:SERVICE_ID_2]) {
        
        RCUserInfo *userInfo = [[RCUserInfo alloc]initWithUserId:userId name:@"海马医生" portrait:@""];
        return completion(userInfo);        
    }
    
    if ([userId isEqualToString:SERVICE_ID]) {
        
        RCUserInfo *userInfo = [[RCUserInfo alloc]initWithUserId:userId name:@"海马医生" portrait:@""];
        return completion(userInfo);
    }

    
    if ([userId isEqualToString:[UserInfo userInfoForCache].uid]) {
        
        UserInfo *user = [UserInfo userInfoForCache];
        if (user) {
            
            RCUserInfo *userInfo = [[RCUserInfo alloc]initWithUserId:user.uid name:user.user_name portrait:user.avatar];
            return completion(userInfo);
        }
    }
}


#pragma - mark 获取融云token

- (void)getRongCloudToken
{
    if (_getRongTokenTime == 0) {
        
        [self stopRongTimer];
        
        return;
    }
    
    _getRongTokenTime --;
    
    NSString *userToken = [LTools objectForKey:USER_RONGCLOUD_TOKEN];
    
    if (userToken.length) {
        
        [self loginRongCloudWithToken:userToken];
        
        return;
    }
    
    UserInfo *userInfo = [UserInfo userInfoForCache];
    NSString *user_id = userInfo.uid;
    
    if (!user_id || user_id.length == 0
        || [user_id isEqualToString:@"(null)"]
        || [user_id isKindOfClass:[NSNull class]]) {
        [self stopRongTimer];
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    NSString *user_name = userInfo.user_name;
    NSString *icon = userInfo.avatar;
    if ([LTools isEmpty:icon]) {
        icon = @"default";
    }
    NSDictionary *params = @{@"user_id":user_id,
                             @"name":user_name,
                             @"portrait_uri":icon};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:USER_GET_TOKEN parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSString *token = result[@"token"];
        
        [LTools setObject:token forKey:USER_RONGCLOUD_TOKEN];
        
        [weakSelf loginRongCloudWithToken:token];
        
    } failBlock:^(NSDictionary *result) {
        
        
    }];
}

- (void)loginRongCloudWithToken:(NSString *)userToken
{
    
    if (userToken.length) {
        
        __weak typeof(self)weakSelf = self;
        
        [[RCIM sharedRCIM]connectWithToken:userToken success:^(NSString *userId) {
            DDLOG(@"登录成功融云 userId %@",userId);
            [weakSelf stopRongTimer];//停止计时
        } error:^(RCConnectErrorCode status) {
            DDLOG(@"RCConnectErrorCode %ld",(long)status);
        } tokenIncorrect:^{
            DDLOG(@"token不对");
            
            [LTools setObject:nil forKey:USER_RONGCLOUD_TOKEN];
        }];
    }else
    {
        [self getRongCloudToken];
    }
    
}

- (void)startLoginRongTimer
{
    _getRongTokenTime = 5;
    [self getRongCloudToken];//先登录一次
    _getRongTokenTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(getRongCloudToken) userInfo:nil repeats:YES];
}

- (void)stopRongTimer
{
    [_getRongTokenTimer invalidate];
    _getRongTokenTimer = nil;
}


#pragma mark - 极光推送

//建立连接
- (void)notificationForDidSetupNotification:(NSNotification *)notify
{
    DDLOG(@"建立连接 JPush %@ %@",notify.userInfo,notify.object);
}

//关闭连接
- (void)notificationForDidCloseNotification:(NSNotification *)notify
{
    DDLOG(@"关闭连接 JPush %@ %@",notify.userInfo,notify.object);
}

//注册成功
- (void)notificationForDidRegisterNotification:(NSNotification *)notify
{
    DDLOG(@"注册成功 JPush %@ %@",notify.userInfo,notify.object);
}

//登录成功
- (void)notificationForDidLoginNotification:(NSNotification *)notify
{
    DDLOG(@"登录成功 JPush %@ %@",notify.userInfo,notify.object);
    [self uploadJPushRegisterId];
}

//收到消息(非APNS)
- (void)notificationForDidReceiveMessageNotification:(NSNotification *)notify
{
    DDLOG(@"收到消息(非APNS) JPush %@ %@",notify.userInfo,notify.object);
}

//错误提示
- (void)notificationForErrorNotification:(NSNotification *)notify
{
    DDLOG(@"错误提示 JPush %@ %@",notify.userInfo,notify.object);
}

/**
 *  上传JPush registerId
 */
- (void)uploadJPushRegisterId
{
    NSString *authkey = [UserInfo getAuthkey];
    if (authkey.length == 0) {
        return;
    }
    NSString *registration_id = [JPUSHService registrationID];
    if (!registration_id || registration_id.length == 0) {
        registration_id = @"JPush";
    }
    
    NSDictionary *params = @{@"authcode":authkey,
                             @"registration_id":registration_id};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:USER_UPDATE_USEINFO parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        DDLOG(@"更新register_id%@",result);
    } failBlock:^(NSDictionary *result) {
        DDLOG(@"失败register_id%@",result);
    }];
}

#pragma mark - 获取未读消息number

- (void)netWorkForMsgNum
{
    if (![LoginManager isLogin]) {
        return;
    }
    NSDictionary *params = @{@"authcode":[UserInfo getAuthkey]};
    NSString *api = GET_MSG_NUM;
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        
        int count = [[result objectForKey:@"count"]intValue];
        
        [LTools setObject:[NSNumber numberWithInt:count] forKey:USER_MSG_NUM];//未读消息个数
        [LTools updateTabbarUnreadMessageNumber];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
    }];
}

/**
 *  处理活动推送和抢购推送
 *
 *  @param type     判断消息类型
 *  @param detailId 消息id
 */

/**
 *  处理推送消息
 *
 *  @param userInfo 通知消息
 *  @param ignoreRongcloud 是否忽略融云消息
 */
- (void)pushToMessageDetailWithResult:(NSDictionary *)userInfo
                             ignoreRongcloud:(BOOL)ignoreRongcloud
{
    //非融云
    UITabBarController *root = (UITabBarController *)self.window.rootViewController;
    int selectIndex = (int)root.selectedIndex;
    UINavigationController *unVc = [root.viewControllers objectAtIndex:selectIndex];
    int viewsCount = (int)unVc.viewControllers.count;
    
    /**
     * 获取融云融云推送消息
     */
    
    NSDictionary *rc = userInfo[@"rc"];//融云的信息
    if (!ignoreRongcloud && [rc isKindOfClass:[NSDictionary class]]) {
        
        NSString *userId = rc[@"fId"];
        if (userId) {
            
            NSLog(@"该远程推送来自融云的推送服务");
            
            BOOL hidden = false;
            if (viewsCount == 1) {
                hidden = YES;
            }
            
            if ([unVc isKindOfClass:[UINavigationController class]]){
                
                UIViewController *viewController = unVc.visibleViewController;
                if ([NSStringFromClass(viewController.class) isEqualToString:@"RCDChatViewController"]) {
                    
                    return;
                }
            }

            [MiddleTools pushToChatWithSourceType:SourceType_Normal fromViewController:unVc model:nil hiddenBottom:hidden];
            return;
        }

    }

//    NSDictionary *aps = userInfo[@"aps"];//包含 alert和sound
//    NSString *alertMessage = aps[@"alert"];//消息内容
    //直接查看
    NSString *msg_type = userInfo[@"type"];
    NSString *theme_id = userInfo[@"theme_id"];//对应活动、报告、订单等id
    NSString *msg_id = userInfo[@"msg_id"];//信息id
    NSString *url = userInfo[@"url"];//活动url

    MsgType type = [msg_type intValue];
    
    UIViewController *targetViewController;
    if (type == MsgType_PEReportReadFinish) //报告解读完成
    {
        if (![LoginManager isLogin]) {
            
            return;
        }
        //报告详情页
        ReportDetailController *detail = [[ReportDetailController alloc]init];
        detail.msg_id = msg_id;
        detail.reportId = theme_id;
        targetViewController = detail;
        
    }else if (type == MsgType_OrderRefundState){ //订单申请退款
        
        if (![LoginManager isLogin]) {
            
            return;
        }
        OrderInfoViewController *orderInfo = [[OrderInfoViewController alloc]init];
        orderInfo.order_id = theme_id;
        orderInfo.msg_id = msg_id;
        targetViewController = orderInfo;
        
    }else if (type == MsgType_PEAlert){ //体检提醒
        
        if (![LoginManager isLogin]) {
            
            return;
        }
        AppointDetailController *detail = [[AppointDetailController alloc]init];
        detail.appoint_id = theme_id;
        detail.msg_id = msg_id;
        targetViewController = detail;
        
    }else if (type == MsgType_Activity){ //活动
        
        WebviewController *web = [[WebviewController alloc]init];
        web.webUrl = url;
        web.navigationTitle = @"活动详情";
        targetViewController = web;
        
    }else if (type == MsgType_PEProgress){ //体检报告进度
        
        DDLOG(@"体检进度报告");
        
    }
    
    if (viewsCount == 1) {
        targetViewController.hidesBottomBarWhenPushed = YES;
    }
    [unVc pushViewController:targetViewController animated:YES];
}



#pragma mark - go健康接口测试

//- (void)testNetwork
//{
////    http://121.40.167.147:3005/v1/productions?appId=gjk001061?&nonceStr=09DS2LSDKFSF6CQ2502SI8ZNMTM67VS&sign=D1A831FA8945B84C15D041AC3EA556C9
//    
//    NSString *server = @"http://121.40.167.147:3005/v1/productions?appId=gjk001061";
//    
//    //①对参数按照key=value的格式,并按照参数名ASCII字典序排序如下
//    NSString *stringA = @"appId=gjk001061&nonceStr=09DS2LSDKAAA6CQ2502SI8ZNMTM99VS";
//    
//    //②拼接API密钥(appSecret)
//    NSString *stringSignTemp = [NSString stringWithFormat:@"%@&key=3b3f2a13cc7b59830ca819c38e7f294897b3978465d38a8b675b6a2a9474d50e",stringA];
//    
//    //③进行MD5运算,再将得到的字符串所有字符转换为大写,得到sign值signValue
//    stringSignTemp = [LTools md5:stringSignTemp];
//    
//    NSString *sign = [stringSignTemp uppercaseString];//转大写
//    
//    NSString *api = [NSString stringWithFormat:@"%@",server];
//    
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:api]];
//    
//    NSDictionary *params = @{@"nonceStr":@"09DS2LSDKAAA6CQ2502SI8ZNMTM99VS",
//                             @"sign":sign};
//    
//    __weak typeof(self)weakSelf = self;
//    
//    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
//        NSLog(@"success result %@",result);
//        
//        NSArray *temp = [BaseModel modelsFromArray:result[@"data"]];
//        //        [weakTable reloadData:temp pageSize:10];
//        
//    } failBlock:^(NSDictionary *result) {
//        
//        NSLog(@"fail result %@",result);
//        NSLog(@"%@",result[@"msg"]);
//        
//    }];
//}


- (void)testNetwork
{
    //    http://121.40.167.147:3005/v1/productions?appId=gjk001061?&nonceStr=09DS2LSDKFSF6CQ2502SI8ZNMTM67VS&sign=D1A831FA8945B84C15D041AC3EA556C9
    
    NSString *nonceStr = @"";
    NSString *appid = @"gjk001061";
    NSString *appSecret = @"3b3f2a13cc7b59830ca819c38e7f294897b3978465d38a8b675b6a2a9474d50e";
    
    //①对参数按照key=value的格式,并按照参数名ASCII字典序排序如下
    NSString *stringA = @"appId=gjk001061&nonceStr=09DS2LSDKAAA6CQ2502SI8ZNMTM99VS";
    
    //②拼接API密钥(appSecret)
    NSString *stringSignTemp = [NSString stringWithFormat:@"%@&key=3b3f2a13cc7b59830ca819c38e7f294897b3978465d38a8b675b6a2a9474d50e",stringA];
    
    //③进行MD5运算,再将得到的字符串所有字符转换为大写,得到sign值signValue
    stringSignTemp = [LTools md5:stringSignTemp];
    
    NSString *sign = [stringSignTemp uppercaseString];//转大写
    
    NSString *server = @"http://121.40.167.147:3005/v1/productions";
    NSString *api = [NSString stringWithFormat:@"%@?appId=%@&nonceStr=%@&sign=%@",server,@"gjk001061",@"09DS2LSDKAAA6CQ2502SI8ZNMTM99VS",sign];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:api]];
    
    NSDictionary *params = @{CUSTOM_REQUEST:request};
    
    __weak typeof(self)weakSelf = self;
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodCustom api:nil parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        
        NSArray *temp = [BaseModel modelsFromArray:result[@"data"]];
        //        [weakTable reloadData:temp pageSize:10];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        NSLog(@"%@",result[@"msg"]);
        
    }];
}



@end
