//
//  LoginViewController.h
//  OneTheBike
//
//  Created by lichaowei on 14/10/26.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyViewController.h"

typedef void(^LoginBlock)(BOOL success);

@interface LoginViewController : MyViewController
{
    LoginBlock _aLoginBlock;
}
@property (strong, nonatomic) IBOutlet UITextField *phoneTF;
@property (strong, nonatomic) IBOutlet UITextField *pwdTF;

@property(nonatomic,assign)BOOL isSpecial;//是否是特殊(特殊情况不是present,所以不能dismiss)

@property (strong, nonatomic) IBOutlet UIButton *qqButton;
@property (strong, nonatomic) IBOutlet UIButton *weixinButton;
@property (strong, nonatomic) IBOutlet UIButton *sianButton;
@property (strong, nonatomic) IBOutlet UIView *thirdLoginView;
@property (strong, nonatomic) IBOutlet UIView *thirdLoginView2;

@property (strong, nonatomic) IBOutlet UILabel *zhuceLabel;


- (void)setLoginBlock:(LoginBlock)aBlock;

- (IBAction)clickToSina:(id)sender;
- (IBAction)clickToQQ:(id)sender;
- (IBAction)tapToHiddenKeyboard:(id)sender;

+ (BOOL)isLogin;
+ (BOOL)isLogin:(UIViewController *)viewController;
+ (BOOL)isLogin:(UIViewController *)viewController
     loginBlock:(LoginBlock)aBlock;

@end
