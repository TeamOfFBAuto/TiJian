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

#define kAlertViewTag_token 100 //融云token
#define kAlertViewTag_otherClient 101 //其他设备登陆

@interface AppDelegate ()<BMKGeneralDelegate,WXApiDelegate,GgetllocationDelegate,RCIMReceiveMessageDelegate,RCIMUserInfoDataSource,RCIMConnectionStatusDelegate>
{
    GMAPI *mapApi;
    LocationBlock _locationBlock;
    BMKMapManager* _mapManager;
    CLLocationManager *_locationManager;
    
    int _getRongTokenTime;//获取融云token次数
    NSTimer *_getRongTokenTimer;//获取融云token计时器
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //注册上传头像通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(uploadHeadImage) name:NOTIFICATION_UPDATEHEADIMAGE object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startRongCloud) name:NOTIFICATION_LOGIN object:nil];
    
    RootViewController *root = [[RootViewController alloc]init];
    self.window.rootViewController = root;
    
    //微信支付
    NSString *version = [[NSString alloc] initWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    NSString *name = [NSString stringWithFormat:@"河马%@",version];
    [WXApi registerApp:WXAPPID withDescription:name];
    
    //百度地图
    [self startBaiduService];
    
    //注册远程通知
    [self startRemoteNotificationWithAppilication:application];
    
    //初始化融云SDK。
    [self startRongCloud];
    
    //友盟统计
    [MobClick startWithAppkey:UmengAppkey];
    
    //检查版本
    [self checkVersion];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [LTools updateTabbarUnreadMessageNumber];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

//app每次启动或者变活跃
- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    //上传头像
    [self uploadHeadImage];
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
    
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [LTools updateTabbarUnreadMessageNumber];
    
    DDLOG(@"JPush2 remote %@",userInfo);
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive){
        DDLOG(@"UIApplicationStateInactive %@",userInfo);
        //程序在后台运行 点击消息进入走此处,做相应处理
    }
    if (state == UIApplicationStateActive) {
        DDLOG(@"UIApplicationStateActive %@",userInfo);
        //程序就在前台

    }
    if (state == UIApplicationStateBackground)
    {
        DDLOG(@"UIApplicationStateBackground %@",userInfo);
    }
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    DDLOG(@"%@",notification.userInfo);
    //在此获取rongcloud本地通知消息
}

#pragma  mark

#pragma - mark 注册通知

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
#pragma - mark  百度地图

- (void)startBaiduService
{
    //使用百度地图相关
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0)
    {
        //设置定位权限 仅ios8有意义
        [_locationManager requestWhenInUseAuthorization];// 前台定位
        
        //  [locationManager requestAlwaysAuthorization];// 前后台同时定位
    }
    [_locationManager startUpdatingLocation];
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:BAIDUMAP_APPKEY  generalDelegate:self];
    if (!ret) {
        DDLOG(@"manager start failed!");
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

#pragma mark - BMKGeneralDelegate <NSObject>

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


#pragma mark - 支付宝支付回调

/**
 这里处理新浪微博SSO授权之后跳转回来，和微信分享完成之后跳转回来
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    DDLOG(@"openURL------ %@",url);
    
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
    
//    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
    
    return YES;
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




#pragma mark - 获取坐标

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
    //客服就不需要了
    if ([userId isEqualToString:SERVICE_ID]) {
        
        return;
    }
    
    if ([userId isEqualToString:[UserInfo userInfoForCache].uid]) {
        
        UserInfo *user = [UserInfo userInfoForCache];
        if (user) {
            
            RCUserInfo *userInfo = [[RCUserInfo alloc]initWithUserId:user.uid name:user.user_name portrait:user.avatar];
            return completion(userInfo);
        }
    }
    
    
    
//    NSString *userName = [LTools rongCloudUserNameWithUid:userId];
//    NSString *userIcon = [LTools rongCloudUserIconWithUid:userId];
//    
//    DDLOG(@"userId %@ userIcon %@",userId,userIcon);
//    
//    DDLOG(@"----->|%@|",userName);
//    
//    //没有保存用户名 或者 更新时间超过一个小时
//    if ([LTools isEmpty:userName] || [LTools isEmpty:userIcon]  || [LTools rongCloudNeedRefreshUserId:userId]) {
//        
//        NSDictionary *params = @{@"uid":userId};
//        [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_USERINFO_ONLY_USERID parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
//            
//            NSDictionary *dic = result[@"user_info"];
//            if ([dic isKindOfClass:[NSDictionary class]]) {
//                
//                NSString *name = dic[@"user_name"];
//                NSString *icon = dic[@"avatar"];
//                
//                //不为空
//                if (![LTools isEmpty:name]) {
//                    
//                    [LTools cacheRongCloudUserName:name forUserId:userId];
//                }
//                
//                [LTools cacheRongCloudUserIcon:icon forUserId:userId];
//                
//                RCUserInfo *userInfo = [[RCUserInfo alloc]initWithUserId:userId name:name portrait:icon];
//                
//                return completion(userInfo);
//            }
//            
//        } failBlock:^(NSDictionary *result) {
//            
//        }];
//    }
//    
//    DDLOG(@"userId %@ %@",userId,userName);
//    
//    RCUserInfo *userInfo = [[RCUserInfo alloc]initWithUserId:userId name:userName portrait:userIcon];
//    
//    return completion(userInfo);
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
            DDLOG(@"RCConnectErrorCode %ld",status);
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

@end
