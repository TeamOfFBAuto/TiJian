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
    RootViewController *root = [[RootViewController alloc]init];
    self.window.rootViewController = root;

    NSString *test = @"110100";
    NSLog(@"%@",[AppDelegate toDecimalSystemWithBinarySystem:test]);
    
    
//  str 为要转换的字符串，endstr 为第一个不能转换的字符的指针，base 为字符串 str 所采用的进制。
    NSLog(@"%lu",  strtoul([test UTF8String], NULL, 2));//二进制转长整形无符号
    
    return YES;
}

//  二进制转十进制

+ (NSString *)toDecimalSystemWithBinarySystem:(NSString *)binary

{
    
    int ll = 0 ;
    
    int  temp = 0 ;
    
    for (int i = 0; i < binary.length; i ++)
        
    {
        
        temp = [[binary substringWithRange:NSMakeRange(i, 1)] intValue];
        
        temp = temp * powf(2, binary.length - i - 1);
        
        ll += temp;
        
    }
    
    
    
    NSString * result = [NSString stringWithFormat:@"%d",ll];
    
    
    
    return result;
    
}

//  十进制转二进制

+ (NSString *)toBinarySystemWithDecimalSystem:(NSString *)decimal

{
    int num = [decimal intValue];
    int remainder = 0;      //余数
    int divisor = 0;        //除数
    
    NSString * prepare = @"";
    while (true)
        
    {
        remainder = num%2;
        
        divisor = num/2;
        
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%d",remainder];
        if (divisor == 0)
        {
            break;
        }
    }
    
    
    NSString * result = @"";
    
    for (int i = (int)prepare.length - 1; i >= 0; i --)
        
    {
        
        result = [result stringByAppendingFormat:@"%@",
                  
                  [prepare substringWithRange:NSMakeRange(i , 1)]];
        
    }
    
    
    
    return result;
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
