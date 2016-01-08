//
//  UINavigationBar+Appearance.m
//  TestCustomNavigation
//
//  Created by 杜林 on 16/1/5.
//  Copyright (c) 2016年 杜林. All rights reserved.
//

#import "UINavigationBar+Appearance.h"
#import <objc/runtime.h>

static char keyEffectContainerView;

@implementation UINavigationBar (Appearance)

- (void)resetEffectContainerView:(UIView *)view
{
    [self.effectContainerView removeFromSuperview];
    
    if (!view) {
        return;
    }
    
    
    BOOL added = NO;
    for (UIView * subView in self.subviews) {
        if ([subView isMemberOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
            [subView addSubview:view];
            added = YES;
            break;
        }
    }
    
    if (!added) {
        [self insertSubview:view atIndex:0];
    }
    
    self.effectContainerView = view;
}

#pragma mark - setters & getters

- (UIView *)effectContainerView
{
    return objc_getAssociatedObject(self, &keyEffectContainerView);
}

- (void)setEffectContainerView:(UIView *)view
{
    objc_setAssociatedObject(self, &keyEffectContainerView, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
