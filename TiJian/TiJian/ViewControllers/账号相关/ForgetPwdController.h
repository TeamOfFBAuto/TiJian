//
//  ForgetPwdController.h
//  YiYiProject
//
//  Created by lichaowei on 14/12/13.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  忘记密码、无密码登录
 */

#import "MyViewController.h"

typedef enum {
    ForgetType_default = 0,//忘记密码
    ForgetType_loginWithoutPwd, //无密码登录
    ForgetType_setPwd //设置密码
}ForgetType;

@interface ForgetPwdController : MyViewController
@property (strong, nonatomic) IBOutlet UITextField *phoneTF;
@property (strong, nonatomic) IBOutlet UITextField *securityTF;
@property (strong, nonatomic) IBOutlet UITextField *passwordTF;
@property (strong, nonatomic) IBOutlet UITextField *secondPassword;
@property (strong, nonatomic) IBOutlet UIButton *codeButton;
@property (strong, nonatomic) IBOutlet UILabel *codeLabel;

@property (nonatomic,assign)ForgetType forgetType;//功能描述

- (IBAction)clickToCommit:(id)sender;

@end
