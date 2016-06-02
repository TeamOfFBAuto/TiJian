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
    [MobClick beginLogPageView:NSStringFromClass([self class])];
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:NSStringFromClass([self class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"修改密码";
    self.rightString = @"完成";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
    
    _maiScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    _maiScrollView.delegate = self;
    _maiScrollView.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT+215-64);
    _maiScrollView.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
    [self.view addSubview:_maiScrollView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenKeyboard)];
    [_maiScrollView addGestureRecognizer:tap];
    
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
        
        if (i == 2) {
            tf.returnKeyType = UIReturnKeyDone;
        }
        
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        
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

#pragma mark - 事件处理

/**
 *  隐藏键盘
 */
- (void)hiddenKeyboard
{
    [_maiScrollView setContentOffset:CGPointMake(0, 0) animated:YES];

    for (int i = 0; i < 3; i ++) {
        UITextField *tf = [self textFieldForTag:100 + i];
        if ([tf isFirstResponder]) {
            [tf resignFirstResponder];
        }
    }
}

- (UITextField *)textFieldForTag:(int)tag
{
    return (UITextField *)[self.view viewWithTag:tag];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if (!iPhone4) {
        return;
    }
    int tag = (int)textField.tag;

    if (tag == 100) {//当前密码
        
    }else if (tag == 101 || tag == 102){//确认新密码
        
        [_maiScrollView setContentOffset:CGPointMake(0, 80) animated:YES];
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    int tag = (int)textField.tag;
    if (tag == 100) {//当前密码
        
        [[self textFieldForTag:101]becomeFirstResponder];
        
    }else if (tag == 101){//新密码
        
        [[self textFieldForTag:102]becomeFirstResponder];
        
    }else if (tag == 102){//确认新密码
        
        NSLog(@"done");
        [self hiddenKeyboard];
        [self rightButtonTap:nil];
    }
    
    return YES;
}


#pragma - mark 事件处理

-(void)rightButtonTap:(UIButton *)sender
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
    NSString *authcode = [UserInfo getAuthkey];
    if (!authcode || authcode.length == 0) {
        
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *params = @{@"authcode":authcode,
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
            
//            [weakSelf cleanUserInfo];
            
            [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];


        }
        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];

        NSLog(@"result %@",result[Erro_Info]);
        
    }];
}


/**
 *  退出登录清空用户信息
 */
- (void)cleanUserInfo
{
    /**
     *  归档的方式保存userInfo
     */
    
    [UserInfo cleanUserInfo];

    
    //保存登录状态 yes
    
    [LTools setBool:NO forKey:LOGIN_SERVER_STATE];
    
    /**
     *  退出登录通知
     */
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_LOGOUT object:nil];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"---%f",scrollView.contentOffset.y);
}


@end
