//
//  GRegisterViewController.m
//  WJXC
//
//  Created by gaomeng on 15/7/7.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GRegisterViewController.h"

static int seconds = 60;//计时60s
#define kSeconds 60

@interface GRegisterViewController ()<UITextFieldDelegate>
{
    NSMutableArray *_yuanViewArray;
    NSMutableArray *_downYuanTitleLabelArray;
    NSMutableArray *_numLabelArray;
    
    UIScrollView *_downScrollView;
    NSTimer *timer;
    UIButton *getYanzhengmaBtn;
    NSString *_encryptcode;//验证码
}

@property(nonatomic,retain)UILabel *codeLabel;//验证码显示
@property(nonatomic,retain)UIButton *codeButton;//点击获取验证码

@end

@implementation GRegisterViewController

- (void)dealloc
{
    self.registerBlock = nil;
    [timer invalidate];
    timer = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNavigationStyle:NAVIGATIONSTYLE_BLUE title:@"注册"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.myTitle = @"注册";
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"6da0cf"];

    [self creatUpView];
    
    [self creatDownInfoView];
    
    [self changeTheUpViewStateWithNum:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - MyMeThod

-(void)creatUpView{
    
    CGFloat jianju = (DEVICE_WIDTH - (32*3)) /4.0;
    _yuanViewArray = [NSMutableArray arrayWithCapacity:1];
    _downYuanTitleLabelArray = [NSMutableArray arrayWithCapacity:1];
    _numLabelArray = [NSMutableArray arrayWithCapacity:1];
    
    self.upThreeStepView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, DEVICE_WIDTH, 90)];
    [self.view addSubview:self.upThreeStepView];
    
    UIControl *control = [[UIControl alloc]initWithFrame:self.upThreeStepView.bounds];
    [control addTarget:self action:@selector(gShou) forControlEvents:UIControlEventTouchUpInside];
    [self.upThreeStepView addSubview:control];
    
    
    NSArray *titleArray = @[@"输入手机号",@"输入验证码",@"设置密码"];
    for (int i = 0; i<3; i++) {
        
        UIView *oneView = [[UIView alloc]initWithFrame:CGRectMake(jianju + i*(jianju+32), 20, 32, 32)];
        if (i == 0) {
            [oneView setFrame:CGRectMake(jianju - 10 + i*(jianju+32), 20, 32, 32)];
            
            
            UIImageView *fenge = [[UIImageView alloc]initWithFrame:CGRectMake(oneView.right, oneView.center.y, jianju + 10, 20)];
//            fenge.backgroundColor = [UIColor redColor];
            fenge.image = [UIImage imageNamed:@"user_xuxian"];
            [self.upThreeStepView addSubview:fenge];
            
//            UIView *fenge = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(oneView.frame)+15, oneView.center.y, jianju - 20, 0.5f)];
//            fenge.backgroundColor = [UIColor whiteColor];
//            [self.upThreeStepView addSubview:fenge];
        }else if (i == 2){
            [oneView setFrame:CGRectMake(jianju + 10 + i*(jianju+32), 20, 32, 32)];
            
        }else if (i == 1){
//            UIView *fenge = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(oneView.frame)+15, oneView.center.y, jianju - 20, 0.5f)];
//            fenge.backgroundColor = [UIColor whiteColor];
//            [self.upThreeStepView addSubview:fenge];
            
            UIImageView *fenge = [[UIImageView alloc]initWithFrame:CGRectMake(oneView.right, oneView.center.y, jianju + 10, 20)];
//            fenge.backgroundColor = [UIColor lightGrayColor];
            fenge.image = [UIImage imageNamed:@"user_xuxian"];
            [self.upThreeStepView addSubview:fenge];

        }
        oneView.layer.cornerRadius = 16;
        oneView.layer.borderWidth = 1;
        oneView.layer.borderColor = [[UIColor whiteColor]CGColor];
        oneView.layer.masksToBounds = YES;
        oneView.backgroundColor = [UIColor clearColor];
        [self.upThreeStepView addSubview:oneView];
        [_yuanViewArray addObject:oneView];
        
        
        UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.textColor = [UIColor colorWithHexString:@"6da0cf"];
        numLabel.text = [NSString stringWithFormat:@"%d",i+1];
        numLabel.center = oneView.center;
        [self.upThreeStepView addSubview:numLabel];
        [_numLabelArray addObject:numLabel];
        
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 15)];
        tLabel.text = titleArray[i];
        CGPoint ccter = oneView.center;
        tLabel.font = [UIFont systemFontOfSize:12];
        tLabel.textAlignment = NSTextAlignmentCenter;
        ccter.y = CGRectGetMaxY(oneView.frame)+15;
        tLabel.center = ccter;
        [self.upThreeStepView addSubview:tLabel];
        [_downYuanTitleLabelArray addObject:tLabel];
    }
    
}


//修改上方状态
-(void)changeTheUpViewStateWithNum:(int)theNum{
    
    
    //修改顶部
    
    for (UILabel *lable in _numLabelArray) {
        lable.textColor = [UIColor whiteColor];
    }
    
    for (UIView *oneView in _yuanViewArray) {
        oneView.backgroundColor = [UIColor clearColor];
        oneView.layer.cornerRadius = 16;
        oneView.layer.borderWidth = 1;
        oneView.layer.borderColor = [[UIColor whiteColor]CGColor];
        oneView.layer.masksToBounds = YES;
    }
    
    for (UILabel *titleLabel in _downYuanTitleLabelArray) {
        titleLabel.textColor = [UIColor colorWithHexString:@"d4eeff"];
    }
    
    
    UIView *oneView = _yuanViewArray[theNum - 1];
    oneView.backgroundColor = [UIColor whiteColor];
    oneView.layer.borderWidth = 0;
    UILabel *numlabel = _numLabelArray[theNum - 1];
    numlabel.textColor = DEFAULT_TEXTCOLOR;
    UILabel *ttLabel = _downYuanTitleLabelArray[theNum - 1];
    ttLabel.textColor = [UIColor whiteColor];
    
}


//创建下方信息填写view
-(void)creatDownInfoView{

    _downScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.upThreeStepView.frame), DEVICE_WIDTH, DEVICE_HEIGHT-64-self.upThreeStepView.frame.size.height)];
    _downScrollView.userInteractionEnabled = YES;
    [_downScrollView setContentSize:CGSizeMake(DEVICE_WIDTH*3, self.downInfoView.frame.size.height)];
    [self.view addSubview:_downScrollView];
    
    UIControl *tt = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH*3, _downScrollView.frame.size.height)];
    [tt addTarget:self action:@selector(gShou) forControlEvents:UIControlEventTouchUpInside];
    [_downScrollView addSubview:tt];
    _downScrollView.scrollEnabled = NO;
    
    CGFloat top = 20.f;
    
    //输入手机号
    UIView *phoneNumView = [[UIView alloc]initWithFrame:CGRectMake(28, top, DEVICE_WIDTH - 28 * 2, 40)];
    phoneNumView.backgroundColor = [UIColor colorWithHexString:@"5a8cbd"];
    phoneNumView.layer.cornerRadius = 2;
    [_downScrollView addSubview:phoneNumView];
    
    UIImageView *phoneIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    phoneIcon.image = [UIImage imageNamed:@"user_shoujihao"];
    phoneIcon.contentMode = UIViewContentModeCenter;
    [phoneNumView addSubview:phoneIcon];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(phoneIcon.right, 0, 0.5, 40)];
    line.backgroundColor = DEFAULT_TEXTCOLOR;
    [phoneNumView addSubview:line];
    
    self.phoneTF = [[UITextField alloc]initWithFrame:CGRectMake(phoneIcon.right + 10, 0, phoneNumView.frame.size.width - 20 - 40 - 10, 40)];
    [phoneNumView addSubview:self.phoneTF];
    self.phoneTF.tag = 100;
    self.phoneTF.font = [UIFont systemFontOfSize:15];
    self.phoneTF.placeholder = @"输入手机号";
    self.phoneTF.delegate = self;
    self.phoneTF.returnKeyType = UIReturnKeyNext;
    self.phoneTF.textColor = [UIColor whiteColor];
    self.phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    
    NSAttributedString *string = [LTools attributedString:@"请输入手机号" keyword:@"请输入手机号" color:[UIColor whiteColor]];
    [self.phoneTF setAttributedPlaceholder:string];
    
    
    getYanzhengmaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [getYanzhengmaBtn setFrame:CGRectMake(50, CGRectGetMaxY(phoneNumView.frame)+30, DEVICE_WIDTH-50 * 2, 40)];
    [getYanzhengmaBtn setBackgroundColor:[UIColor whiteColor]];
    [getYanzhengmaBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getYanzhengmaBtn addTarget:self action:@selector(getYanzhengmaBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [getYanzhengmaBtn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    getYanzhengmaBtn.layer.cornerRadius = 4;
    getYanzhengmaBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_downScrollView addSubview:getYanzhengmaBtn];
    getYanzhengmaBtn.userInteractionEnabled = NO;
    getYanzhengmaBtn.alpha = 0.5f;
    
    //输入验证码
    UIView *yanzhengmaView = [[UIView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH + 28, top, DEVICE_WIDTH-28 * 2, 40)];
    yanzhengmaView.backgroundColor = [UIColor colorWithHexString:@"5a8cbd"];
    yanzhengmaView.layer.cornerRadius = 2;
    yanzhengmaView.tag = 101;
    [_downScrollView addSubview:yanzhengmaView];
    
    CGFloat a_width = yanzhengmaView.width / 4.f;
    
    self.yanzhengmaTf = [[UITextField alloc]initWithFrame:CGRectMake(20, 0, a_width * 3 - 20, 40)];
    self.yanzhengmaTf.font = [UIFont systemFontOfSize:15];
    self.yanzhengmaTf.returnKeyType = UIReturnKeyNext;//下一步
    self.yanzhengmaTf.delegate = self;
    self.yanzhengmaTf.textColor = [UIColor whiteColor];
    self.yanzhengmaTf.keyboardType = UIKeyboardTypeNumberPad;

    [yanzhengmaView addSubview:self.yanzhengmaTf];
    NSString *y_text = @"请输入验证码";
    [self.yanzhengmaTf setAttributedPlaceholder:[LTools attributedString:y_text keyword:y_text color:[UIColor whiteColor]]];
    
    //显示验证码和获取验证码
    self.codeLabel = [[UILabel alloc]initWithFrame:CGRectMake(_yanzhengmaTf.right, 0, a_width, 40)];
    self.codeLabel.backgroundColor = [UIColor colorWithHexString:@"6caae5"];
    self.codeLabel.textColor = [UIColor whiteColor];
    [self.codeLabel setTextAlignment:NSTextAlignmentCenter];
//    self.codeLabel.text = @"59s";
    self.codeLabel.userInteractionEnabled = NO;
    [yanzhengmaView addSubview:self.codeLabel];
    //获取验证码
    self.codeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.codeButton.frame = self.codeLabel.frame;
    self.codeButton.backgroundColor = [UIColor colorWithHexString:@"6caae5"];
    [yanzhengmaView addSubview:self.codeButton];
    [self.codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.codeButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
    [self.codeButton addTarget:self action:@selector(getYanzhengmaBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(DEVICE_WIDTH + 50, yanzhengmaView.bottom + 30, DEVICE_WIDTH - 100, 40)];
    btn.backgroundColor = [UIColor whiteColor];
    [btn setTitle:@"下一步" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickToNext) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn.layer.cornerRadius = 2;
    [btn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    [_downScrollView addSubview:btn];
    
    
    //设置密码
    
    UIView *mimaView = [[UIView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH * 2, top, DEVICE_WIDTH-20, 100)];
    mimaView.backgroundColor = [UIColor clearColor];
    
//    UIView *fenge = [[UIView alloc]initWithFrame:CGRectMake(0, 49, mimaView.frame.size.width, 0.5)];
//    fenge.backgroundColor = [UIColor whiteColor];
//    [mimaView addSubview:fenge];
    [_downScrollView addSubview:mimaView];
    
    for (int i = 0; i < 2; i++) {
        
        
        UIView *mimaTf_view = [[UIView alloc]initWithFrame:CGRectMake(28, (40 + 20) * i, DEVICE_WIDTH - 28 * 2, 40)];
        mimaTf_view.backgroundColor = [UIColor colorWithHexString:@"5a8cbd"];
        [mimaView addSubview:mimaTf_view];
        
        UIImageView *mimaTf_icon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        mimaTf_icon.image = [UIImage imageNamed:@"user_mima2"];
        mimaTf_icon.contentMode = UIViewContentModeCenter;
        [mimaTf_view addSubview:mimaTf_icon];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(mimaTf_icon.right, 0, 0.5, 40)];
        line.backgroundColor = DEFAULT_TEXTCOLOR;
        [mimaTf_view addSubview:line];
        
        UITextField *pwd_tf = [[UITextField alloc]initWithFrame:CGRectMake(mimaTf_icon.right + 10, 0, mimaTf_view.width - 40 - 10, 40)];
        pwd_tf.font = [UIFont systemFontOfSize:12];
        pwd_tf.secureTextEntry = YES;
        [mimaTf_view addSubview:pwd_tf];
        pwd_tf.delegate = self;
        pwd_tf.textColor = [UIColor whiteColor];
        
        NSString *placeHolder;
        if (i == 0) {
            
            self.mimaTf = pwd_tf;
            placeHolder = @"请输入密码";
            pwd_tf.returnKeyType = UIReturnKeyNext;
            
        }else if(i == 1){
            
            self.mima2Tf = pwd_tf;
            placeHolder = @"请再次输入密码";
            pwd_tf.returnKeyType = UIReturnKeyDone;

        }
        [pwd_tf setAttributedPlaceholder:[LTools attributedString:placeHolder keyword:placeHolder color:[UIColor whiteColor]]];
    }
    
    UIButton *querenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [querenBtn setFrame:CGRectMake(2 * DEVICE_WIDTH + 50, CGRectGetMaxY(mimaView.frame) + 30, DEVICE_WIDTH - 50 * 2, 40)];
    [querenBtn setTitle:@"开启健康之旅" forState:UIControlStateNormal];
    [querenBtn addTarget:self action:@selector(querenBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    querenBtn.layer.cornerRadius = 2;
    querenBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [querenBtn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    [querenBtn setBackgroundColor:[UIColor whiteColor]];
    [_downScrollView addSubview:querenBtn];
    
}

//收键盘
-(void)gShou{
    [self.phoneTF resignFirstResponder];
    [self.yanzhengmaTf resignFirstResponder];
    [self.mimaTf resignFirstResponder];
    [self.mima2Tf resignFirstResponder];
    
    
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT-64);
    } completion:^(BOOL finished) {
        
    }];
}


//获取验证码
-(void)getYanzhengmaBtnClicked{
    
    [self gShou];//收键盘
    
    SecurityCode_Type type;//默认注册
    type = 1;
    
    NSString *mobile = self.phoneTF.text;
    
    if (![LTools isValidateMobile:mobile]) {
        
        [LTools alertText:ALERT_ERRO_PHONE viewController:self];
        return;
    }
    
    __weak typeof(self)weakSelf = self;
       
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *param = @{
                            @"mobile":mobile,
                            @"type":@"1",
                            @"encryptcode":[LTools md5Phone:mobile]
                            };
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:USER_GET_SECURITY_CODE parameters:param constructingBodyBlock:nil completion:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog(@"result %@",result);
        _encryptcode = result[@"code"];//记录验证码
        
        //获取验证码成功之后切换界面
        [weakSelf changeTheUpViewStateWithNum:2];
        [_downScrollView setContentOffset:CGPointMake(DEVICE_WIDTH, 0) animated:YES];
        
        //开始计时
        [weakSelf startTimer];
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        NSLog(@"failDic %@",result);
        [weakSelf renewTimer];
    }];
    
}

//输入完验证码
-(void)clickToNext{
    
    int code = [self.yanzhengmaTf.text intValue];//填写的验证码
    //下一步
    if (code == [_encryptcode intValue]) {
        
        [self changeTheUpViewStateWithNum:3];
        [_downScrollView setContentOffset:CGPointMake(2 * DEVICE_WIDTH, 0) animated:YES];
        
    }else{
        
        [LTools showMBProgressWithText:ALERT_ERRO_SECURITYCODE addToView:self.view];
    }
}

//提交注册
-(void)querenBtnClicked{
    //    get方式调取
    //    参数解释依次为:
    //    username(昵称,可不填，系统自动分配一个) string
    //    password（密码，必须大于等于6位，不能有中文）string
    //    gender(性别，1=》男 2=》女，可不填，默认为女) int
    //    type(注册类型，1=》手机注册 2=》邮箱注册，默认为手机注册) int
    //    code(验证码 6位数字) int
    //    mobile(手机号) string
    
    [self gShou];
    
    
    if (![self.mimaTf.text isEqualToString:self.mima2Tf.text]) {
        
        [LTools showMBProgressWithText:@"两次输入密码不一致" addToView:self.view];
        return;
    }
    
//    NSString *userName = @"";
    NSString *password = self.mimaTf.text;
//    Gender sex = Gender_Girl;//默认女
//    Register_Type type = Register_Phone;//默认手机号方式
    int code = [self.yanzhengmaTf.text intValue];
    NSString *mobile = self.phoneTF.text;
    
    if (![LTools isValidateMobile:mobile]) {
        
        [LTools alertText:ALERT_ERRO_PHONE viewController:self];
        return;
    }
    
    if (![LTools isValidatePwd:password]) {
        
        [LTools alertText:ALERT_ERRO_PASSWORD viewController:self];
        return;
    }
    
    NSString *codestr = [NSString stringWithFormat:@"%d",code];
    NSDictionary *params = @{@"mobile":mobile,
                             @"code":codestr,
                             @"password":password
                             };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:USER_REGISTER_ACTION parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [LTools showMBProgressWithText:@"注册成功" addToView:self.view];
        
        [self performSelector:@selector(clickToClose) withObject:nil afterDelay:1.5];
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog(@"failDic %@",result);
    }];
}

- (void)clickToClose {
    
    [self.navigationController popViewControllerAnimated:YES];
    
    //注册成功block
    if (self.registerBlock) {
        
        self.registerBlock(self.phoneTF.text,self.mimaTf.text);
    }
}


#pragma - mark 60s计时

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

#pragma - mark UITextFileDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
    if (textField == self.phoneTF) {
        
        [self getYanzhengmaBtnClicked];
    }
    
    //下一步
    if (textField == self.yanzhengmaTf) {
        
        [self clickToNext];
    }
    
    //新密码跳转至确认密码
    if (textField == self.mimaTf) {
        
        [self.mima2Tf becomeFirstResponder];
    }
    
    if (textField == self.mima2Tf) {
        
        //完成
        
        [self querenBtnClicked];
    }
    
    return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"%s",__FUNCTION__);
    
    if (!iPhone4) {
        return YES;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = CGRectMake(0,-10, DEVICE_WIDTH, DEVICE_HEIGHT);
    } completion:^(BOOL finished) {
        
    }];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /**
     *  根据手机号填写,控制获取验证码按钮是否可以点击
     */
    
    NSString *temp = textField.text;
    if (string.length) {
        temp = [NSString stringWithFormat:@"%@%@",temp,string];
    }else
    {
        if (temp.length > 1) {
            
            temp = [temp substringWithRange:NSMakeRange(0, temp.length - 2)];
        }
    }
    
    if (textField == self.phoneTF) {
        
        if ([LTools isValidateMobile:temp]) {
            
            getYanzhengmaBtn.userInteractionEnabled = YES;
            getYanzhengmaBtn.alpha = 1.f;
        }else
        {
            getYanzhengmaBtn.userInteractionEnabled = NO;
            getYanzhengmaBtn.alpha = 0.5f;
        }
    }
    
    return YES;
}


@end
