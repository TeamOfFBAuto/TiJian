//
//  ForgetPwdController.m
//  YiYiProject
//
//  Created by lichaowei on 14/12/13.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "ForgetPwdController.h"


static int seconds = 60;//计时60s
#define kSeconds 60

@interface ForgetPwdController ()<UITextFieldDelegate>
{
    NSTimer *timer;
    UIView *_bgView_one;
    UIView *_bgView_second;
    NSString *_encryptcode;//验证码
}

@end

@implementation ForgetPwdController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
    [self setNavigationStyle:NAVIGATIONSTYLE_BLUE title:@"找回密码"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:NSStringFromClass([self class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    [self createOneView];
    [self createSecondView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [timer invalidate];
    timer = nil;
}

#pragma mark - 视图创建

- (void)createOneView
{
    UIView *bgView_one = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    bgView_one.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgView_one];
    
    _bgView_one = bgView_one;
    
    UIView *oneView = [[UIView alloc]initWithFrame:CGRectMake(0, 30, DEVICE_WIDTH, 100)];
    oneView.backgroundColor = [UIColor whiteColor];
    [bgView_one addSubview:oneView];
    
    for (int i = 0; i < 2; i ++) {
        
        UITextField *pwd_tf = [[UITextField alloc]initWithFrame:CGRectMake(15, 50 * i, 200, 50)];
        pwd_tf.font = [UIFont systemFontOfSize:12];
//        pwd_tf.secureTextEntry = YES;
        [oneView addSubview:pwd_tf];
        pwd_tf.delegate = self;
        pwd_tf.backgroundColor = [UIColor whiteColor];
        pwd_tf.keyboardType = UIKeyboardTypeNumberPad;
        NSString *placeHolder;
        if (i == 0) {
            
            self.phoneTF = pwd_tf;
            placeHolder = @"请输入手机号";
            pwd_tf.returnKeyType = UIReturnKeyNext;
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(10, pwd_tf.bottom - 0.5, oneView.width - 20, 0.5)];
            line.backgroundColor = [UIColor colorWithHexString:@"e4e4e4"];
            [oneView addSubview:line];
            
            //显示验证码和获取验证码
            self.codeLabel = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 10 - 80, 12.5, 80, 25)];
            self.codeLabel.backgroundColor = [UIColor colorWithHexString:@"6caae5"];
            self.codeLabel.textColor = [UIColor whiteColor];
            [self.codeLabel setTextAlignment:NSTextAlignmentCenter];
            //    self.codeLabel.text = @"59s";
            self.codeLabel.userInteractionEnabled = NO;
            [oneView addSubview:self.codeLabel];
            //获取验证码
            self.codeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.codeButton.frame = self.codeLabel.frame;
            self.codeButton.backgroundColor = [UIColor colorWithHexString:@"6caae5"];
            [oneView addSubview:self.codeButton];
            [self.codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
            [self.codeButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
            [self.codeButton addTarget:self action:@selector(clickToSecurityCode:) forControlEvents:UIControlEventTouchUpInside];
            
        }else if(i == 1){
            
            self.securityTF = pwd_tf;
            placeHolder = @"请输入验证码";
            pwd_tf.returnKeyType = UIReturnKeyDone;
        }
        pwd_tf.placeholder = placeHolder;
        
    }
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureBtn setTitle:@"下一步" forState:UIControlStateNormal];
    sureBtn.frame = CGRectMake(30, oneView.bottom + 30, DEVICE_WIDTH - 60, 40);
    sureBtn.backgroundColor = DEFAULT_TEXTCOLOR;
    [sureBtn addCornerRadius:2.f];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [bgView_one addSubview:sureBtn];
    [sureBtn addTarget:self action:@selector(clickToNext) forControlEvents:UIControlEventTouchUpInside];

}

- (void)createSecondView
{
    UIView *bgView_one = [[UIView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    bgView_one.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:bgView_one];
    
    _bgView_second = bgView_one;
    
    UIView *oneView = [[UIView alloc]initWithFrame:CGRectMake(0, 30, DEVICE_WIDTH, 100)];
    oneView.backgroundColor = [UIColor whiteColor];
    [bgView_one addSubview:oneView];
    
    for (int i = 0; i < 2; i ++) {
        
        UITextField *pwd_tf = [[UITextField alloc]initWithFrame:CGRectMake(15, 50 * i, 200, 50)];
        pwd_tf.font = [UIFont systemFontOfSize:12];
        pwd_tf.secureTextEntry = YES;
        [oneView addSubview:pwd_tf];
        pwd_tf.delegate = self;
        pwd_tf.backgroundColor = [UIColor whiteColor];
        NSString *placeHolder;
        if (i == 0) {
            
            self.passwordTF = pwd_tf;
            placeHolder = @"请输入新密码";
            pwd_tf.returnKeyType = UIReturnKeyNext;
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(10, pwd_tf.bottom - 0.5, oneView.width - 20, 0.5)];
            line.backgroundColor = [UIColor colorWithHexString:@"e4e4e4"];
            [oneView addSubview:line];
            
        }else if(i == 1){
            
            self.secondPassword = pwd_tf;
            placeHolder = @"请再次输入密码";
            pwd_tf.returnKeyType = UIReturnKeyDone;
        }
        pwd_tf.placeholder = placeHolder;
        
    }
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureBtn setTitle:@"提交" forState:UIControlStateNormal];
    sureBtn.frame = CGRectMake(30, oneView.bottom + 30, DEVICE_WIDTH - 60, 40);
    sureBtn.backgroundColor = DEFAULT_TEXTCOLOR;
    [sureBtn addCornerRadius:2.f];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [bgView_one addSubview:sureBtn];
    [sureBtn addTarget:self action:@selector(clickToCommit:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 事件处理

/**
 *  下一步
 */
- (void)clickToNext
{
    if (![LTools isValidateMobile:self.phoneTF.text]) {
        
        [LTools alertText:ALERT_ERRO_PHONE viewController:self];
        return;
    }
    NSString *text = self.securityTF.text;

    if ([text intValue] != [_encryptcode intValue]) {
        
        [LTools alertText:ALERT_ERRO_SECURITYCODE viewController:self];
        
        return;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
       
        _bgView_second.left = 0.f;
    }];
}

#pragma mark - 倒计时
- (void)startTimer
{
    self.codeButton.hidden = YES;
    self.codeLabel.hidden = NO;
    
    seconds = kSeconds;
    [self calculateTime];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(calculateTime) userInfo:Nil repeats:YES];
}

//计算时间
- (void)calculateTime
{
    NSString *title;
    if (seconds > 9) {
        title = [NSString stringWithFormat:@"%ds",seconds];
    }else
    {
        title = [NSString stringWithFormat:@"%ds",seconds];
    }
    self.codeLabel.text = title;
    
    if (seconds != 0) {
        seconds --;
    }else
    {
        [self renewTimer];
    }
}
//计时器归零
- (void)renewTimer
{
    [timer invalidate];//计时器停止
    _codeButton.hidden = NO;
    _codeLabel.hidden = YES;
    seconds = kSeconds;
}


#pragma mark - 网络请求

- (IBAction)tapToHiddenKeyboard:(id)sender {
    
    [self.passwordTF resignFirstResponder];
    [self.securityTF resignFirstResponder];
    [self.phoneTF resignFirstResponder];
    [self.secondPassword resignFirstResponder];
}


/**
 *  获取验证码
 */
- (IBAction)clickToSecurityCode:(id)sender {
    
//    SecurityCode_Type type = SecurityCode_FindPWD;//找回密码
    [self tapToHiddenKeyboard:nil];
    NSString *mobile = self.phoneTF.text;
    
    if (![LTools isValidateMobile:mobile]) {
        
        [LTools alertText:ALERT_ERRO_PHONE viewController:self];
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    
    
    NSDictionary *dic = @{
                          @"mobile":mobile,
                          @"type":@"2",
                          @"encryptcode":[LTools md5Phone:mobile]
                          };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:USER_GET_SECURITY_CODE parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        //获取成功才开始计时
        _encryptcode = result[@"code"];
        [weakSelf startTimer];
        [LTools showMBProgressWithText:@"验证码已发送" addToView:self.view];
        
    } failBlock:^(NSDictionary *result) {
         [weakSelf renewTimer];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

    }];
}


- (IBAction)clickToCommit:(id)sender {
    
    
//    get方式调取
//    参数解释依次为:
//    mobile(手机号) string
//    code（验证码）int
//    new_password(新密码) str
    
    
    NSString *password = self.passwordTF.text;
//    NSString *secondPassword = self.secondPassword.text;
//    int code = [self.securityTF.text intValue];
    NSString *mobile = self.phoneTF.text;
    
    if (![LTools isValidateMobile:mobile]) {
        
        [LTools alertText:ALERT_ERRO_PHONE viewController:self];
        return;
    }
    
    if (![LTools isValidatePwd:password]) {
        
        [LTools alertText:ALERT_ERRO_PASSWORD viewController:self];
        return;
    }
    
    if (![self.passwordTF.text isEqualToString:self.secondPassword.text]) {
        
        [LTools alertText:ALERT_ERRO_FINDPWD viewController:self];
        
        return;
    }
    
    if (self.securityTF.text.length != 6) {
        
        [LTools alertText:ALERT_ERRO_SECURITYCODE];
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    NSDictionary *dic = @{
                          @"mobile":mobile,
                          @"code":self.securityTF.text,
                          @"new_password":password,
                          @"confirm_password":self.secondPassword.text
                          };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:USER_GETBACK_PASSWORD parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

        [LTools showMBProgressWithText:@"找回密码成功" addToView:self.view];
        
        [self performSelector:@selector(clickToClose:) withObject:nil afterDelay:2];
        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

    }];
    
}

- (void)clickToClose:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma - mark UITextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTF) {
        
        [self.secondPassword becomeFirstResponder];
    }
    if (textField == self.secondPassword) {
        [self clickToCommit:nil];
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.phoneTF) {
        NSString *text = textField.text;
        text = [LTools stringByRemoveUnavailableWithPhone:text];
        textField.text = text;
    }
}

@end
