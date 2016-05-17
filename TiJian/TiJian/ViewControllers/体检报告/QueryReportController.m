//
//  QueryReportController.m
//  TiJian
//
//  Created by lichaowei on 16/5/16.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "QueryReportController.h"
#import "LPickerView.h"

@interface QueryReportController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    LPickerView *_pickerView;
    NSArray *_itemsArray;
    NSString *_brandId;//选择的品牌id
    MBProgressHUD *_loading;
}
//@property(nonatomic,strong)UIView *backPickView;//地区选择pickerView后面的背景view

@end

@implementation QueryReportController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"查找报告";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    [self.view addTapGestureTaget:self action:@selector(hiddenKeyboard) imageViewTag:0];
    
    [self netWorkForBrandList];//请求品牌列表
    
    NSArray *items = @[@"品牌",@"账号",@"密码"];
    NSArray *placeHolders = @[@"请选择体检品牌",@"请输入体检中心提供的账号",@"请输入体检中心提供的密码"];
    CGFloat top = 0.f;
    for (int i = 0; i < items.count; i ++) {
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(23, 30 + (50 + 20) * i, DEVICE_WIDTH - 23 * 2, 50)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bgView];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 50) font:15 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE title:items[i]];
        [bgView addSubview:titleLabel];
        
        UITextField *tf = [[UITextField alloc]initWithFrame:CGRectMake(titleLabel.right, 2, bgView.width - titleLabel.width, bgView.height - 2)];
        tf.delegate = self;
        tf.font = [UIFont systemFontOfSize:14];
        [bgView addSubview:tf];
        tf.placeholder = placeHolders[i];
        tf.tag = 100 + i;
        if (i == 2) {
            tf.secureTextEntry = YES;
        }
        //账号
        if (i == 1) {
            tf.returnKeyType = UIReturnKeyNext;
            tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
        //密码
        else if (i == 2)
        {
            tf.returnKeyType = UIReturnKeyDone;
            tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
        
        top = bgView.bottom;
    }
    
    //提交信息按钮
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.backgroundColor = DEFAULT_TEXTCOLOR;
    loginBtn.frame = CGRectMake((DEVICE_WIDTH - 200)/2.f, top + 60, 200, 40);
    [self.view addSubview:loginBtn];
    [loginBtn setTitle:@"提交信息" forState:UIControlStateNormal];
    [loginBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [loginBtn addTarget:self action:@selector(clickToSubmit:) forControlEvents:UIControlEventTouchUpInside];
    [loginBtn addCornerRadius:5.f];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(loginBtn.left, loginBtn.bottom + 13, loginBtn.width, 14) font:13 align:NSTextAlignmentRight textColor:DEFAULT_TEXTCOLOR title:@"不清楚账号、密码？"];
    [label addTaget:self action:@selector(clickToConfused:) tag:0];
    [self.view addSubview:label];
    
    _loading = [LTools MBProgressWithText:@"努力加载中..." addToView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 网络请求

- (void)netWorkForBrandList
{
    NSString *api = Report_center;
//    __weak typeof(self)weakSelf = self;
    
     @WeakObj(_pickerView);
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        NSArray *list = result[@"list"];
        _itemsArray = [NSArray arrayWithArray:list];
        
        if (Weak_pickerView) {
            [Weak_pickerView reloadAllComponents];
        }
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        
    }];
}

/**
 *  查询报告
 *
 *  @param brandId   品牌id
 *  @param accountNo 账号
 *  @param password  密码
 */
-(void)queryReportWithBrandId:(NSString *)brandId
                    accountNo:(NSString *)accountNo
                     password:(NSString *)password{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetString:[UserInfo getAuthkey] forKey:@"authcode"];
    [params safeSetString:brandId forKey:@"brand_id"];
    [params safeSetString:accountNo forKey:@"account_no"];
    [params safeSetString:password forKey:@"password"];
    [params safeSetString:@"2" forKey:@"type"];// 2 表示输入账号密码查询（上传）

     @WeakObj(self);
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_loading show:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:REPORT_ADD parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [_loading hide:YES];
        NSLog(@"success %@",result);
        
        if ([result[RESULT_CODE] intValue] == 0) {
            
            NSString *url = result[@"url"];
            [MiddleTools pushToWebFromViewController:Weakself weburl:url title:@"体检报告" moreInfo:NO hiddenBottom:NO];
        }
        
        
    } failBlock:^(NSDictionary *result) {
        [_loading hide:YES];
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSString *msg = result[Erro_Info];
        [LTools showMBProgressWithText:msg addToView:Weakself.view];
        
    }];
}

- (UITextField *)textFieldWithTag:(int)tag
{
    return [self.view viewWithTag:tag];
}

#pragma mark - 视图创建

#pragma mark - 年龄选择器

- (void)selectBrand
{
    if (!_pickerView) {
        
         @WeakObj(self);
        _pickerView = [[LPickerView alloc]initWithDelegate:self delegate:self pickerBlock:^(ACTIONTYPE type, int row, int component) {
            if (type == ACTIONTYPE_SURE) {
                [Weakself selectBrandWithRow:row];
            }
        }];
    }
    
    [_pickerView pickerViewShow:YES];
}

- (void)selectBrandWithRow:(int)row
{
    NSString *title = _itemsArray[row][@"brand_name"];
    [self textFieldWithTag:100].text = title;
    _brandId = _itemsArray[row][@"brand_id"];//选中的品牌id

}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return _itemsArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)componen{
    
    return [NSString stringWithFormat:@"%d",(int)row + 1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSLog(@"年龄%d",(int)row + 1);
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 45.f;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view __TVOS_PROHIBITED
{
    UIView *pickerCell = view;
    if (!pickerCell) {
        pickerCell = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, [UIScreen mainScreen].bounds.size.width, 45.0f}];
        UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(50, 10, 25, 25)];
        icon.backgroundColor = [UIColor orangeColor];
        [pickerCell addSubview:icon];
        icon.tag = 100;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(icon.right + 10, 10, 200, 25) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@""];
        [pickerCell addSubview:label];
        label.tag = 101;
    }
    
    UIImageView *icon = [pickerCell viewWithTag:100];
    UILabel *label = [pickerCell viewWithTag:101];
    NSString *iconUrl = _itemsArray[row][@"brand_logo"];
    NSString *title = _itemsArray[row][@"brand_name"];
    [icon l_setImageWithURL:[NSURL URLWithString:iconUrl] placeholderImage:DEFAULT_HEADIMAGE];
    label.text = title;
    
    return pickerCell;
}

#pragma mark - 事件处理

- (void)clickToSubmit:(UIButton *)sender
{
    [self hiddenKeyboard];
    
    NSString *brandName = [self textFieldWithTag:100].text;//品牌名
    NSString *account = [self textFieldWithTag:101].text;//账号
    NSString *password = [self textFieldWithTag:102].text;//密码
    
    if ([LTools isEmpty:brandName]) {
        
        [LTools showMBProgressWithText:@"请选择体检品牌" addToView:self.view];
        return;
    }
    
    if ([LTools isEmpty:account]) {
        
        [LTools showMBProgressWithText:@"请输入有效的体检账号" addToView:self.view];
        return;
    }
    
    if ([LTools isEmpty:password]) {
        
        [LTools showMBProgressWithText:@"请输入有效的密码" addToView:self.view];
        return;
    }
    
    [self queryReportWithBrandId:_brandId accountNo:account password:password];
}

/**
 *  不清楚账号、密码
 *
 *  @param sender
 */
- (void)clickToConfused:(UIButton *)sender
{
    NSString *urlstring = [NSString stringWithFormat:@"%@%@",SERVER_URL,URL_ReportAccount];
//    urlstring = @"http://www.hippodr.com/docs/center/curl_ciming.php";
    [MiddleTools pushToWebFromViewController:self weburl:urlstring title:@"体检账号说明" moreInfo:NO hiddenBottom:NO];
}

- (void)hiddenKeyboard
{
    for (int i = 0; i < 3; i ++) {
        
        UITextField *tf = [self.view viewWithTag:100 + i];
        if ([tf isFirstResponder]) {
            [tf resignFirstResponder];
        }
    }
}

#pragma mark - UITextFieldDelegate <NSObject>

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //性别选择
    if (textField.tag == 100) {

    for (int i = 0; i < 3; i ++) {

        UITextField *tf = [self.view viewWithTag:100 + i];
        if ([tf isFirstResponder]) {
            [tf resignFirstResponder];
        }
    }

        [self selectBrand];
        
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 101) {
        [[self textFieldWithTag:102] becomeFirstResponder];
    }else if (textField.tag == 102)
    {
        [textField resignFirstResponder];
        [self clickToSubmit:nil];//提交
    }
    return YES;
}

@end
