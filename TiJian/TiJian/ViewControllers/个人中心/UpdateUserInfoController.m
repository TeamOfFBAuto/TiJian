//
//  UpdateUserInfoController.m
//  TiJian
//
//  Created by lichaowei on 15/11/19.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "UpdateUserInfoController.h"

@interface UpdateUserInfoController ()<UITextFieldDelegate>

@property(nonatomic,retain)UITextField *textField;
@end

@implementation UpdateUserInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *title;
    NSString *placeHolder;
    if (_updateType == UPDATEINFOTYPE_REALNAME) {
        title = @"请填写与身份证一致姓名,方便预约使用";
        self.myTitle = @"修改姓名";
        placeHolder = @"请输入真实姓名";
    }else if (_updateType == UPDATEINFOTYPE_IDCARD){
        title = @"请填写与身份证一致身份证号,方便预约使用";
        self.myTitle = @"修改身份证号";
        placeHolder = @"请输入真实身份证号";
    }else if (_updateType == UPDATEINFOTYPE_USERNAME){
        title = @"请填写昵称";
        self.myTitle = @"修改昵称";
        placeHolder = @"请输入昵称";
    }
    
    self.rightString = @"保存";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, DEVICE_WIDTH - 30, 12) title:title font:11 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_THIRD];
    [self.view addSubview:label];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, label.bottom + 10, DEVICE_WIDTH, 50)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    self.textField = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, DEVICE_WIDTH - 30, 50)];
    self.textField.placeholder = placeHolder;
    self.textField.text = self.content;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.delegate = self;
    [view addSubview:_textField];
    
}

#pragma mark - 事件处理

-(void)rightButtonTap:(UIButton *)sender
{
    [self netWork];
}

- (void)actionForSuccess
{
    if (self.updateBlock) {
        _updateBlock(self.textField.text);
    }
    
    [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];
    
}

#pragma mark - 网络请求

- (void)netWork
{
    
//    post参数调取
//    参数：
//    user_name 昵称
//    real_name 真实姓名
//    birthday 1988-10-10
//    gender 型别 1男 2女
//    age 年龄
//    password 密码
//    id_card 身份证号
//    mobile 手机
    
    NSString *authKey = [LTools cacheForKey:USER_AUTHOD];
    NSDictionary *params = @{@"authcode":authKey};
    if (_updateType == UPDATEINFOTYPE_REALNAME) {
        
        NSString *text = self.textField.text;
        if ([LTools isEmpty:text]) {
            [LTools alertText:@"请填写与身份证一致姓名,以免影响体检预约" viewController:self];
            
            return;
        }
        
        params = @{@"authcode":authKey,
                   @"real_name":text};
        
    }else if (_updateType == UPDATEINFOTYPE_IDCARD){
        
        NSString *text = self.textField.text;
        if (![LTools isValidateIDCard:text]) {
            [LTools alertText:@"请填写与身份证一致身份证号,以免影响体检预约" viewController:self];
            return;
        }
        
        params = @{@"authcode":authKey,
                   @"id_card":text};
    }else if (_updateType == UPDATEINFOTYPE_USERNAME){
        
        NSString *text = self.textField.text;
        if ([LTools isEmpty:text]) {
            [LTools alertText:@"昵称不能为空" viewController:self];
            return;
        }
        
        params = @{@"authcode":authKey,
                   @"user_name":text};
    }
    
    NSString *api = USER_UPDATE_USEINFO;
    
    __weak typeof(self)weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        
        if (_updateType == UPDATEINFOTYPE_REALNAME) {
            
            [UserInfo updateUserRealName:weakSelf.textField.text];
            
        }else if (_updateType == UPDATEINFOTYPE_IDCARD)
        {
            [UserInfo updateUserIdCard:weakSelf.textField.text];
            
        }else if (_updateType == UPDATEINFOTYPE_USERNAME)
        {
            [UserInfo updateUserName:weakSelf.textField.text];
        }
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        [weakSelf actionForSuccess];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpdateBlock:(UPDATEUSERINFOBLOCK)updateBlock
{
    _updateBlock = updateBlock;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    [self netWork];
    
    return YES;
}


@end
