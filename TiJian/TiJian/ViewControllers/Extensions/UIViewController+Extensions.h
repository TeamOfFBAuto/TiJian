//
//  UIViewController+Extensions.h
//  TiJian
//
//  Created by gaomeng on 2017/12/8.
//  Copyright © 2017年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Extensions)

#pragma mark - 适配iPhone X
/**
 适配iOS 11 scrollView偏移20像素问题
 */
- (void)adjustsScrollViewForIOS11;

@end
