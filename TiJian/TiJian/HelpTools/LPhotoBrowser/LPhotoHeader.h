//
//  LPhotoHeader.h
//  TestPhotoBrowser
//
//  Created by lichaowei on 15/12/23.
//  Copyright © 2015年 lcw. All rights reserved.
//

#ifndef LPhotoHeader_h
#define LPhotoHeader_h


///屏幕宽度
#define DEVICE_WIDTH  [UIScreen mainScreen].bounds.size.width
///屏幕高度
#define DEVICE_HEIGHT [UIScreen mainScreen].bounds.size.height

//===================== weak 和 strong
#pragma mark - weak 和 strong
#define WeakObj(o) autoreleasepool{} __weak typeof(o) Weak##o = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

#import "UIImageView+Extensions.h"

//==============================打印类、方法
#pragma mark - Debug log macro
//start
#ifdef DEBUG

#define DDLOG( s , ...) NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define DDLOG_CURRENT_METHOD NSLog(@"%@-%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd))


#else

#define DDLOG(...) ;
#define DDLOG_CURRENT_METHOD ;

#endif
//===end

#endif /* LPhotoHeader_h */
