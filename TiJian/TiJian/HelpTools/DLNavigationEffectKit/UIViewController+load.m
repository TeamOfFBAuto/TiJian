//
//  UIViewController+load.m
//  TestCustomNavigation
//
//  Created by 杜林 on 16/1/5.
//  Copyright (c) 2016年 杜林. All rights reserved.
//

#import "UIViewController+load.h"
#import "UIViewController+NavigationBar.h"
#import <objc/runtime.h>

@implementation UIViewController (load)

+ (void)load
{
    [self swizzlebyRepelaceSelector:@selector(viewDidLoad) withSelector:@selector(replaceViewDidLoad)];
}

+ (void)swizzlebyRepelaceSelector:(SEL)origSEL withSelector:(SEL)replaceSelector
{
    Method originalMethod = class_getInstanceMethod(self, origSEL);
    Method newMethod = class_getInstanceMethod(self, replaceSelector);
    
    BOOL methodAdded = class_addMethod([self class],
                                       origSEL,
                                       method_getImplementation(newMethod),
                                       method_getTypeEncoding(newMethod));
    
    if (methodAdded) {
        class_replaceMethod([self class],
                            replaceSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}


- (void)replaceViewDidLoad
{
    [self replaceViewDidLoad];
    
    self.showCustomBar = NO;
}

@end
