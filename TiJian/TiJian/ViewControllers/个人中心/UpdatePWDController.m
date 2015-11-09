//
//  UpdatePWDController.m
//  WJXC
//
//  Created by lichaowei on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "UpdatePWDController.h"

@interface UpdatePWDController ()<UITextFieldDelegate,UIScrollViewDelegate>
{
    UIScrollView *_maiScrollView;
}


@end

@implementation UpdatePWDController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"修改密码";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    _maiScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    _maiScrollView.delegate = self;
    _maiScrollView.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT+215-64);
    _maiScrollView.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
    [self.view addSubview:_maiScrollView];
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 25, DEVICE_WIDTH - 20, 15) title:@"修改密码后,您可以用手机号和新密码登录" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"646464"]];
    [_maiScrollView addSubview:label];
    
    NSString *text = [NSString stringWithFormat:@"现手机号:%@",[UserInfo userInfoForCache].mobile];
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(10, label.bottom + 7, DEVICE_WIDTH - 20, 15) title:text font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"646464"]];
    [_maiScrollView addSubview:label2];
    
    NSArray *titles = @[@"原密码",@"新密码",@"确认新密码"];
    CGFloat top = 0.f;
    
    
    for (int i = 0; i < titles.count; i ++) {
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, label2.bottom + 25 + 50 * i, DEVICE_WIDTH, 50)];
        view.backgroundColor = [UIColor whiteColor];
        [_maiScrollView addSubview:view];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, view.height)];
        titleLabel.text = titles[i];
        titleLabel.font = [UIFont systemFontOfSize:14.f];
        titleLabel.textColor = [UIColor colorWithHexString:@"323232"];
        [view addSubview:titleLabel];
        
        UITextField *tf = [[UITextField alloc]initWithFrame:CGRectMake(titleLabel.right, 0, DEVICE_WIDTH - 20 - titleLabel.right, view.height)];
        [view addSubview:tf];
        tf.secureTextEntry = YES;
        tf.tag = 100 + i;
        tf.delegate = self;
        
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(10, view.height - 0.5, DEVICE_WIDTH - 10, 0.5)];
        [view addSubview:line];
        line.backgroundColor = DEFAULT_LINECOLOR;
        
        top = view.bottom;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (UITextField *)textFieldForTag:(int)tag
{
    return (UITextField *)[self.view viewWithTag:tag];
}



- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.tag == 100) {//当前密码
        
    }else if (textField.tag == 101){//新密码
        [_maiScrollView setContentOffset:CGPointMake(0, 100) animated:YES];
        
        
    }else if (textField.tag == 102){//确认新密码
        
        [_maiScrollView setContentOffset:CGPointMake(0, 100) animated:YES];
        
        
    }
}








#pragma - mark 事件处理

- (void)clickToSure:(UIButton *)sender
{
    NSString *password = [self textFieldForTag:100].text;//老密码
    NSString *newPWD = [self textFieldForTag:101].text;//新密码
    NSString *newPWD_second = [self textFieldForTag:102].text;//新密码确认


    if (![LTools isValidatePwd:password]) {
        
        [LTools alertText:ALERT_ERRO_PASSWORD viewController:self];
        return;
    }
    
    if (newPWD.length == 0) {

        [LTools alertText:@"新密码不能为空" viewController:self];
        return;
    }
    
    if (![LTools isValidatePwd:newPWD]) {
        
        [LTools alertText:@"新密码格式有误,请输入6~32位英文字母或数字" viewController:self];
        return;
    }
    
    if ([password isEqualToString:newPWD]) {
        
        [LTools alertText:@"新密码不能与旧密码一致" viewController:self];
        return;
    }
    
    if (![newPWD isEqualToString:newPWD_second]) {
        
        [LTools alertText:@"请确认新密码两次输入一致" viewController:self];
        
        return;
    }
    
    //同步服务器
    [self updatePassWord:newPWD confirmPassword:newPWD_second oldPwd:password];
}

/**
 *  更新密码
 *
 *  @param password        新密码
 *  @param passwordConfirm 新密码确认
 *  @param oldPwd          老密码
 */
- (void)updatePassWord:(NSString *)password
       confirmPassword:(NSString *)passwordConfirm
                oldPwd:(NSString *)oldPwd
{
    NSString *authcode = [LTools cacheForKey:USER_AUTHOD];
    if (!authcode || authcode.length == 0) {
        
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *params = @{@"authcode":[LTools cacheForKey:USER_AUTHOD],
                             @"new_password":password,
                             @"confirm_password":passwordConfirm,
                             @"old_password":oldPwd};
    
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:USER_UPDATE_PASSWORD parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"result %@ %@",result[Erro_Info],result);
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        int errorcode = [result[Erro_Code]intValue];
        if (errorcode == 0) {
            
            //修改成功
            
            [LTools showMBProgressWithText:result[Erro_Info] addToView:weakSelf.view];
            
            [weakSelf cleanUserInfo];

        }
        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];

        NSLog(@"result %@",result[Erro_Info]);
        
    }];
}

//-(void)leftButtonTap:(UIButton *)sender
//{
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}

/**
 *  退出登录清空用户信息
 */
- (void)cleanUserInfo
{
    /**
     *  归档的方式保存userInfo
     */
    
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"userInfo"];
    
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
    [LTools cache:nil ForKey:USER_NAME];
    [LTools cache:nil ForKey:USER_UID];
    [LTools cache:nil ForKey:USER_AUTHOD];
    [LTools cache:nil ForKey:USER_HEAD_IMAGEURL];
    
    //保存登录状态 yes
    
    [LTools cacheBool:NO ForKey:LOGIN_SERVER_STATE];
    
    /**
     *  退出登录通知
     */
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_LOGOUT object:nil];
    
    [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];
}
@end
