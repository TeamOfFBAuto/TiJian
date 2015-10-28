//
//  GwebViewController.h
//  fblifebbs
//
//  Created by gaomeng on 14/10/17.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShenQingDianPuViewController;

@interface GwebViewController : MyViewController<UIWebViewDelegate>
{
    UIWebView *awebview;
    UIButton *button_comment;
    UILabel *titleview;
    
    NSMutableArray *my_array;
    NSString *string_title;
}
@property(nonatomic,strong) NSString * urlstring;
@property(nonatomic,retain)NSString *targetTitle;

@property(nonatomic,assign)BOOL ismianzeshengming;//免责声明

@property(nonatomic,assign)ShenQingDianPuViewController *shenqingdianpuvc;//申请店铺vc


@property(nonatomic,assign)BOOL isSaoyisao;//是否为扫一扫


@end
