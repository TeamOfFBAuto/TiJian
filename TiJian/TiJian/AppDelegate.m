//
//  AppDelegate.m
//  TiJian
//
//  Created by lichaowei on 15/9/29.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //注册上传头像通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(uploadHeadImage) name:NOTIFICATION_UPDATEHEADIMAGE object:nil];
    
    RootViewController *root = [[RootViewController alloc]init];
    self.window.rootViewController = root;
    
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

@end
