//
//  GTranslucentSideBar.h
//  TiJian
//
//  Created by gaomeng on 15/11/4.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GTranslucentSideBar;
@protocol GTranslucentSideBarDelegate <NSObject>
@optional
- (void)sideBar:(GTranslucentSideBar *)sideBar didAppear:(BOOL)animated;
- (void)sideBar:(GTranslucentSideBar *)sideBar willAppear:(BOOL)animated;
- (void)sideBar:(GTranslucentSideBar *)sideBar didDisappear:(BOOL)animated;
- (void)sideBar:(GTranslucentSideBar *)sideBar willDisappear:(BOOL)animated;
@end
@interface GTranslucentSideBar : UIViewController<UIGestureRecognizerDelegate>
@property (nonatomic, assign) CGFloat sideBarWidth;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic) BOOL translucent;
@property (nonatomic) UIBarStyle translucentStyle;
@property (nonatomic) CGFloat translucentAlpha;
@property (nonatomic, strong) UIColor *translucentTintColor;
@property (readonly) BOOL hasShown;
@property (readonly) BOOL showFromRight;
@property BOOL isCurrentPanGestureTarget;
@property NSInteger tag;

@property (nonatomic, weak) id<GTranslucentSideBarDelegate> delegate;

- (id)init;
- (id)initWithDirection:(BOOL)showFromRight;

- (void)show;
- (void)showAnimated:(BOOL)animated;
- (void)showInViewController:(UIViewController *)controller animated:(BOOL)animated;

- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;

- (void)handlePanGestureToShow:(UIPanGestureRecognizer *)recognizer inView:(UIView *)parentView;

- (void)setContentViewInSideBar:(UIView *)contentView;
@end
