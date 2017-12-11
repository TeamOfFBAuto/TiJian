//
//  UIViewController+Extensions.m
//  TiJian
//
//  Created by gaomeng on 2017/12/8.
//  Copyright © 2017年 lcw. All rights reserved.
//

#import "UIViewController+Extensions.h"

#define  adjustsScrollViewInsets(scrollView)\
do {\
_Pragma("clang diagnostic push")\
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")\
if ([scrollView respondsToSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:")]) {\
NSMethodSignature *signature = [UIScrollView instanceMethodSignatureForSelector:@selector(setContentInsetAdjustmentBehavior:)];\
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];\
NSInteger argument = 2;\
invocation.target = scrollView;\
invocation.selector = @selector(setContentInsetAdjustmentBehavior:);\
[invocation setArgument:&argument atIndex:2];\
[invocation retainArguments];\
[invocation invoke];\
}\
_Pragma("clang diagnostic pop")\
} while (0)


@implementation UIViewController (Extensions)

#pragma mark - 适配iPhone X
/**
 适配iOS 11 scrollView偏移20像素问题
 */
- (void)adjustsScrollViewForIOS11
{
    //适配
    __block UIScrollView *scrollView = nil;
    if ([self isKindOfClass:[UITableViewController class]]) {
        scrollView = ((UITableViewController *)self).tableView;
    }else
    {
        if ([self.view isKindOfClass:[UIScrollView class]]) {
            scrollView = (UIScrollView *)self.view;
        }else
        {
            [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[UIScrollView class]]) {
                    scrollView = (UIScrollView *)obj;
                }else if ([obj isKindOfClass:[UIWebView class]]){
                    scrollView = ((UIWebView *)obj).scrollView;
                }
            }];
        }
    }
    adjustsScrollViewInsets(scrollView);
    
    
    //#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
    //    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    //
    //#endif
    //
    //
    //#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_11_0)
    //#else
    //    self.automaticallyAdjustsScrollViewInsets = NO;
    //
    //#endif
}


@end
