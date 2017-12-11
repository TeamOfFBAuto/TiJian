//
//  UIViewController+NavigationBar.m
//  TestCustomNavigation
//
//  Created by 杜林 on 16/1/5.
//  Copyright (c) 2016年 杜林. All rights reserved.
//

#import "UIViewController+NavigationBar.h"
#import "UINavigationBar+Appearance.h"
#import <objc/runtime.h>
#import "DLConst.h"

static char customBar;
static char customItem;
static char showCustomBar;

@implementation UIViewController (NavigationBar)

- (void)hiddenNavigationBar:(BOOL)hidden animated:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:hidden animated:animated];
    if (hidden) {
        [self.view bringSubviewToFront:[self currentNavigationBar]];
    }
}

#pragma mark -
- (void)resetShowCustomNavigationBar:(BOOL)showBar
{

    //防止重复迁移item数据，首次迁移完，会置空前一个navigationbar的topitem上所有item数据
    if (self.showCustomBar == showBar) {
        return;
    }
    
    self.showCustomBar = showBar;
    
    if (showBar) {
        
        if (!self.customNavigationBar) {
            
            CGFloat barHeight = 64.f;
            if (iPhoneX) {
                barHeight = 64 + 20 + 4;
            }
            UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, DLScreenWidth, barHeight)];
            UIImage *image = [[UIImage alloc] init];
            [bar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
            [bar setShadowImage:image];
            [self.view addSubview:bar];
            self.customNavigationBar = bar;
            
            UINavigationItem *baritem = [[UINavigationItem alloc] initWithTitle:@""];
            [self.customNavigationBar pushNavigationItem:baritem animated:NO];
            self.customItem = baritem;
            
            
            UIView * maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DLScreenWidth +1, bar.height)];
            maskView.backgroundColor = [UIColor clearColor];
            [bar resetEffectContainerView:maskView];
        }
        
        [self transItemFrom:self.navigationItem To:self.customItem];
    }
    else{
        UINavigationItem *fromItem = self.customItem;
        
        [self transItemFrom:fromItem To:self.navigationItem];
        
        [self.customNavigationBar removeFromSuperview];
        self.customNavigationBar = nil;
        self.customItem = nil;
    }
    
    
    self.navigationController.navigationBarHidden = showBar;
    if (self.navigationController == nil) {
        [self.navigationController setNavigationBarHidden:showBar];
    }
    
}


- (void)transItemFrom:(UINavigationItem *)fromItem To:(UINavigationItem *)toItem
{
    NSString *title = fromItem.title;
    toItem.title = title;
    fromItem.title = nil;
    
    
    UIView *titleView = fromItem.titleView;
    fromItem.titleView = nil;
    toItem.titleView = titleView;
    
    NSString *backTitle = fromItem.backBarButtonItem.title;
    fromItem.backBarButtonItem.title = nil;
    toItem.backBarButtonItem.title = backTitle;
    
    
    NSArray *leftArray = fromItem.leftBarButtonItems;
    fromItem.leftBarButtonItems = nil;
    toItem.leftBarButtonItems = leftArray;
    
    UIBarButtonItem *leftItem = fromItem.leftBarButtonItem;
    fromItem.leftBarButtonItem = nil;
    toItem.leftBarButtonItem = leftItem;
    
    NSArray *rightArray = fromItem.rightBarButtonItems;
    fromItem.rightBarButtonItems = nil;
    toItem.rightBarButtonItems = rightArray;
    
    UIBarButtonItem *rightItem = fromItem.rightBarButtonItem;
    fromItem.rightBarButtonItem = nil;
    toItem.rightBarButtonItem = rightItem;
}


#pragma mark - getters & setters

- (UINavigationBar *)currentNavigationBar
{
    if (self.showCustomBar) {
        return self.customNavigationBar;
    }
    return self.navigationController.navigationBar;
}

- (UINavigationItem *)currentNavigationItem
{
    if (self.showCustomBar) {
        return self.customItem;
    }
    return self.navigationItem;
}

- (UINavigationBar *)customNavigationBar
{
    return objc_getAssociatedObject(self, &customBar);
}

- (void)setCustomNavigationBar:(UINavigationBar *)bar
{
    objc_setAssociatedObject(self, &customBar, bar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (UINavigationItem *)customItem
{
    return objc_getAssociatedObject(self, &customItem);
}

- (void)setCustomItem:(UINavigationItem *)item
{
    objc_setAssociatedObject(self, &customItem, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)showCustomBar
{
    return [objc_getAssociatedObject(self, &showCustomBar) boolValue];
}

- (void)setShowCustomBar:(BOOL)show
{
    objc_setAssociatedObject(self, &showCustomBar, @(show), OBJC_ASSOCIATION_ASSIGN);
}
@end
