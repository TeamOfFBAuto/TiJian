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
//#import "UMSocial.h"

@interface AppDelegate ()<BMKGeneralDelegate,WXApiDelegate,GgetllocationDelegate>
{
    
    GMAPI *mapApi;
    LocationBlock _locationBlock;
    BMKMapManager* _mapManager;
    CLLocationManager *_locationManager;

}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //注册上传头像通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(uploadHeadImage) name:NOTIFICATION_UPDATEHEADIMAGE object:nil];
    
    RootViewController *root = [[RootViewController alloc]init];
    self.window.rootViewController = root;
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0)
    {
        //设置定位权限 仅ios8有意义
        [_locationManager requestWhenInUseAuthorization];// 前台定位
        
        //  [locationManager requestAlwaysAuthorization];// 前后台同时定位
    }
    [_locationManager startUpdatingLocation];
    
    
    
    
    
    
    
    //微信支付
    NSString *version = [[NSString alloc] initWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    NSString *name = [NSString stringWithFormat:@"衣加衣%@",version];
    [WXApi registerApp:WXAPPID withDescription:name];
    
    
    
    
    
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
        NSLog(@"manager start failed!");
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
   
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

#pragma - mark 

#pragma - mark 上传更新头像


/**
 *  上传头像
 *
 *  @param aImage
 */
- (void)uploadHeadImage
{
    //不需要更新,return
    if (![LTools cacheBoolForKey:USER_UPDATEHEADIMAGE_STATE]) {
        
        NSLog(@"不需要更新头像");
        
        return;
    }else
    {
        NSLog(@"需要更新头像");
        
    }
    
    NSString *authcode = [LTools cacheForKey:USER_AUTHOD];
    
    //没有authcode return
    if (authcode.length == 0) {
        
        return;
    }
    
    UIImage *image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:USER_NEWHEADIMAGE];
    
    NSDictionary *params = @{@"authcode":authcode};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:USER_UPLOAD_HEADIMAGE parameters:params constructingBodyBlock:^(id<AFMultipartFormData> formData) {
        
        if (image != nil) {
            NSData *imageData =UIImageJPEGRepresentation(image, 1.f);
            [formData appendPartWithFileData:imageData name:@"pic" fileName:@"myhead.jpg" mimeType:@"image/jpg"];
        }
        
    } completion:^(NSDictionary *result) {
        
        NSLog(@"completion result %@",result[Erro_Info]);
        
        [LTools cacheBool:NO ForKey:USER_UPDATEHEADIMAGE_STATE];//不需要更新头像
        
        [[SDImageCache sharedImageCache] removeImageForKey:USER_NEWHEADIMAGE fromDisk:YES];
        
        NSString *avatar = result[@"avatar"];
        
        [UserInfo updateUserAvatar:avatar];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATEHEADIMAGE_SUCCESS object:nil];//更新头像成功
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"failBlock result %@",result[Erro_Info]);
        
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


/**
 这里处理新浪微博SSO授权之后跳转回来，和微信分享完成之后跳转回来
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    NSLog(@"openURL------ %@",url);
    
    //当支付宝客户端在操作时,商户 app 进程在后台被结束,只能通过这个 block 输出支付 结果。
    
#pragma mark - 支付宝支付回调
    
    //如果极简开发包不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给开 发包
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
                                                      
                                                      NSLog(@"ali result = %@",resultDic);
                                                      
                                                      
                                                  }]; }
    
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回 authCode
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            
            NSLog(@"ali result = %@",resultDic);
            
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


#pragma mark - 微信支付回调

- (void)onResp:(BaseResp *)resp {
    
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *response = (PayResp *)resp;
        
        BOOL result = NO;
        NSString *errInfo = nil;
        switch (response.errCode) {
            case WXSuccess:
            {
                //服务器端查询支付通知或查询API返回的结果再提示成功
                NSLog(@"支付成功");
                errInfo = @"支付成功";
                result = YES;
            }
                break;
            case WXErrCodeCommon:
            case WXErrCodeSentFail:
            {
                NSLog(@"1、可能的原因：签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等.\n2、发送失败");
                errInfo = @"微信支付异常";
            }
                break;
            case WXErrCodeUserCancel:
                NSLog(@"用户取消支付");
                errInfo = @"用户取消支付";
                
                break;
            case WXErrCodeAuthDeny:
                
                NSLog(@"授权失败");
                errInfo = @"微信支付授权失败";
                break;
            default:
                NSLog(@"支付失败， retcode=%d",resp.errCode);
                
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



#pragma mark - 定位Delegate

- (void)theLocationDictionary:(NSDictionary *)dic{
    
    NSLog(@"定位成功------>%@",dic);
    
    if (_locationBlock) {
        
        _locationBlock(dic);
    }
    
    [GMAPI sharedManager].theLocationDic = [dic copy];
}


-(void)theLocationFaild:(NSDictionary *)dic{
    
    NSLog(@"定位失败----->%@",dic);
    
    if (_locationBlock) {
        _locationBlock(dic);
    }
}




@end
