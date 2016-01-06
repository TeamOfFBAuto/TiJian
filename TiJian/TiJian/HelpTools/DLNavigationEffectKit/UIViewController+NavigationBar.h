//
//  UIViewController+NavigationBar.h
//  TestCustomNavigation
//
//  Created by 杜林 on 16/1/5.
//  Copyright (c) 2016年 杜林. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (NavigationBar)

- (void)setShowCustomBar:(BOOL)show;

- (UINavigationBar *)currentNavigationBar;
- (UINavigationItem *)currentNavigationItem;

- (void)hiddenNavigationBar:(BOOL)hidden animated:(BOOL)animated;
- (void)resetShowCustomNavigationBar:(BOOL)showBar;

@end
