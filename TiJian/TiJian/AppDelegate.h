//
//  AppDelegate.h
//  TiJian
//
//  Created by lichaowei on 15/9/29.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LocationBlock)(NSDictionary *dic);//获取坐标block

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)startDingweiWithBlock:(LocationBlock)location;

@end

