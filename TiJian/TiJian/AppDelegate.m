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

#define BAIDU_APPKEY @"xVfbtQq4cB5OLkTk8hmxlyLd" //appStore com.yijiayi.yijiayi

@interface AppDelegate ()<BMKGeneralDelegate>
{
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
    
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定   BMKGeneralDelegate协议
    
    BOOL ret = [_mapManager start:BAIDU_APPKEY  generalDelegate:self];
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

@end
