//
//  AddPeopleViewController.m
//  TiJian
//
//  Created by lichaowei on 15/11/6.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "AddPeopleViewController.h"
#import "RightTextFieldCell.h"

@interface AddPeopleViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    UITableView *_table;
    NSArray *_items;
    NSMutableArray *_contentArray;//内容
    int _sex;//性别 1男2女
    int _age;//年龄
    
    UIPickerView *_pickeView;
    UIView *_pickerBgView;//选择器背景view
}
@property(nonatomic,strong)UIView *backPickView;//地区选择pickerView后面的背景view

@end

@implementation AddPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"添加家人";
    _items = @[@"姓名:",@"称谓:",@"身份证号:",@"性别:",@"年龄:",@"手机号:"];

    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
    
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resetState)];
    [_table addGestureRecognizer:tap];
    
    if (self.actionStyle == ACTIONSTYLE_ADD) {
        
        _contentArray = [NSMutableArray arrayWithArray:@[@"请填写与身份证一致的姓名",@"请填写",@"请认真填写",@"请选择",@"请选择",@"请填写"]];
        self.rightString = @"完成";

    }else if (self.actionStyle == ACTIONSTYLE_DETTAILT){
        
        NSString *gender = [self.userModel.gender intValue] == 1 ? @"男" : @"女";
        _sex = [self.userModel.gender intValue];//性别 1男2女
        _age = [self.userModel.age intValue];//年龄
        _contentArray = [NSMutableArray arrayWithArray:@[self.userModel.family_user_name ? : @"请填写与身份证一致的姓名",self.userModel.appellation ? : @"请填写",self.userModel.id_card ? : @"请认真填写",gender,self.userModel.age ? : @"请选择",self.userModel.mobile ? : @"请填写"]];
        
        self.rightString = @"提交";
        
    }else if (self.actionStyle == ACTIONSTYLE_DetailByFamily_uid){
        self.rightString = @"提交";
        [self networkForFamilyUserInfo];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 数据处理

- (void)parseFamilyInfoWithResult:(NSDictionary *)result
{
    UserInfo *userInfo = [[UserInfo alloc]initWithDictionary:result[@"family_info"]];
    NSString *gender = [userInfo.gender intValue] == 1 ? @"男" : @"女";
    _sex = [userInfo.gender intValue];//性别 1男2女
    _age = [userInfo.age intValue];//年龄
    _contentArray = [NSMutableArray arrayWithArray:@[userInfo.family_user_name ? : @"请填写与身份证一致的姓名",userInfo.appellation ? : @"请填写",userInfo.id_card ? : @"请认真填写",gender,userInfo.age ? : @"请选择",userInfo.mobile ? : @"请填写"]];
    [_table reloadData];
}

#pragma - mark 网络请求

/**
 *  获取家人详情
 */
- (void)networkForFamilyUserInfo
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    NSString *authcode = [UserInfo getAuthkey];
    [param safeSetString:authcode forKey:@"authcode"];
    [param safeSetString:self.family_uid forKey:@"family_uid"];
     @WeakObj(self);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_Family_info parameters:param constructingBodyBlock:nil completion:^(NSDictionary *result) {
        DDLOG(@"result %@",result);
        [Weakself parseFamilyInfoWithResult:result];
        [MBProgressHUD hideHUDForView:Weakself.view animated:YES];
    } failBlock:^(NSDictionary *result) {
        DDLOG(@"result %@",result);
        [MBProgressHUD hideHUDForView:Weakself.view animated:YES];

    }];
}

- (void)addFamily
{
    [self resetState];
        
    //post:参数authcode、 姓名、 称谓、 身份证号、gender 性别（1=》男 2=》女）、age 年龄、mobile 手机号
    NSString *authcode = [UserInfo getAuthkey];
    NSString *family_user_name = [self textFieldWithTag:100].text;
    NSString *appellation = [self textFieldWithTag:101].text;
    NSString *id_card = [self textFieldWithTag:102].text;
    NSString *genderString = [self textFieldWithTag:103].text;//性别
    NSString *ageString = [self textFieldWithTag:104].text;//年龄

    int gender = _sex;
    int age = _age;
    NSString *mobile =  [self textFieldWithTag:105].text;
    
    if ([LTools isEmpty:family_user_name]) {
        
        [LTools alertText:@"请填写与身份证一致姓名,以免影响体检预约" viewController:self];
        
        return;
    }
    if ([LTools isEmpty:appellation]) {
        
        [LTools alertText:@"请填写合适的称谓" viewController:self];
        return;
    }
    
    if (![LTools isValidateIDCard:id_card]) {
        
        [LTools alertText:@"请填写正确身份证号码,以免影响体检预约" viewController:self];
        return;
    }
    
    if ([LTools isEmpty:genderString]) {
        
        [LTools alertText:@"请选择性别" viewController:self];
        return;
    }
    
    if ([LTools isEmpty:ageString]) {
        
        [LTools alertText:@"请认真选择年龄" viewController:self];
        return;
    }
    
    
    NSDictionary *params;
    
    if (self.actionStyle == ACTIONSTYLE_ADD) {
        
        params = @{@"authcode":authcode,
                   @"family_user_name":family_user_name,
                   @"appellation":appellation,
                   @"id_card":id_card,
                   @"gender":NSStringFromInt(gender),
                   @"age":NSStringFromInt(age),
                   @"mobile":mobile};
        
    }else if (self.actionStyle == ACTIONSTYLE_DETTAILT){
        
        params = @{@"authcode":authcode,
                   @"family_user_name":family_user_name,
                   @"appellation":appellation,
                   @"id_card":id_card,
                   @"gender":NSStringFromInt(gender),
                   @"age":NSStringFromInt(age),
                   @"mobile":mobile,
                   @"family_uid": self.userModel.family_uid};
    }
    
    NSString *api = self.actionStyle == ACTIONSTYLE_ADD ? ADD_FAMILY : EDIT_FAMILY;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        [LTools showMBProgressWithText:result[RESULT_INFO] addToView:weakSelf.view];
        [weakSelf updatePeople];
        [weakSelf performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:1.f];
        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

- (void)updatePeople
{
    if (self.updateParamsBlock) {
        self.updateParamsBlock(@{@"result":@"addSuccess"});
    }
}

#pragma - mark 创建视图

-(void)createAreaPickView{
    
    //地区选择
    self.backPickView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    self.backPickView .backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    [[UIApplication sharedApplication].keyWindow addSubview:_backPickView];
    self.backPickView.alpha = 0.f;//默认初始
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToCancel:)];
    [self.backPickView addGestureRecognizer:tap];
    
    //初始为
    _pickerBgView = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 216 + 40)];
    _pickerBgView.backgroundColor = [UIColor whiteColor];
    [self.backPickView addSubview:_pickerBgView];
    
    //上线
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [_pickerBgView addSubview:line];
    
    //下线
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 40, DEVICE_WIDTH, 0.5f)];
    line2.backgroundColor = DEFAULT_LINECOLOR;
    [_pickerBgView addSubview:line2];

    //地区pickview
    _pickeView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 40, DEVICE_WIDTH, 216)];
    _pickeView.delegate = self;
    _pickeView.dataSource = self;
    [_pickerBgView addSubview:_pickeView];
    
//    - (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated
    NSString *age = [self textFieldWithTag:104].text;
    if (![LTools isEmpty:age]) {
        [_pickeView selectRow:[age intValue] - 1 inComponent:0 animated:NO];
    }else
    {
        [_pickeView selectRow:26 - 1 inComponent:0 animated:NO];
    }
    
    //取消按钮
    UIButton *quxiaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    quxiaoBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [quxiaoBtn setTitle:@"取消" forState:UIControlStateNormal];
    [quxiaoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    quxiaoBtn.frame = CGRectMake(10, 5, 60, 30);
    [quxiaoBtn addTarget:self action:@selector(clickToCancel:) forControlEvents:UIControlEventTouchUpInside];
    [quxiaoBtn setBorderWidth:1 borderColor:DEFAULT_TEXTCOLOR];
    [quxiaoBtn addCornerRadius:3.f];
    
    //确定按钮
    UIButton *quedingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    quedingBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [quedingBtn setTitle:@"确定" forState:UIControlStateNormal];
    [quedingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    quedingBtn.frame = CGRectMake(DEVICE_WIDTH - 70, 5, 60, 30);
    [quedingBtn setBorderWidth:1 borderColor:DEFAULT_TEXTCOLOR];
    [quedingBtn addCornerRadius:3.f];
    [quedingBtn addTarget:self action:@selector(clickToSure:) forControlEvents:UIControlEventTouchUpInside];
    
    [_pickerBgView addSubview:quedingBtn];
    [_pickerBgView addSubview:quxiaoBtn];
}

- (UITextField *)textFieldWithTag:(int)tag
{
    return (UITextField *)[_table viewWithTag:tag];
}

#pragma - mark 事件处理

-(void)rightButtonTap:(UIButton *)sender
{
    if (self.actionStyle == ACTIONSTYLE_DETTAILT ||
        self.actionStyle == ACTIONSTYLE_DetailByFamily_uid) {
        //提交修改结果
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"是否确定提交修改信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        
    }else if (self.actionStyle == ACTIONSTYLE_ADD){
        
        [self addFamily];
    }
}
/**
 *  重置状态,隐藏键盘，_table滚动CGRectZero
 */
- (void)resetState
{
    [self resignViewFirstResponder];
    [_table setContentOffset:CGPointMake(0, 0) animated:YES];
}

/**
 *  隐藏键盘
 */
- (void)resignViewFirstResponder
{
    for (int i = 0; i < _items.count; i ++) {
        
        UITextField *tf = [_table viewWithTag:100 + i];
        if ([tf isFirstResponder]) {
            [tf resignFirstResponder];
        }
    }
}

/**
 *  滚动tableView
 *
 *  @param textField
 */
- (void)scrollTableViewWithTextField:(UITextField *)textField
{
    if (iPhone6PLUS) { // 6plus 不需要滚动
        
        return;
    }
    
    CGPoint origin = textField.frame.origin;
    CGPoint point = [textField.superview convertPoint:origin toView:_table];

    float navBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGPoint offset = _table.contentOffset;
    
    if (iPhone6) {
        
        if (point.y >= 305) {
            
            offset.y = (point.y - navBarHeight) - 25 - 200;
            [_table setContentOffset:offset animated:YES];
            
        }else
        {
            offset.y = 0;
            [_table setContentOffset:offset animated:YES];
        }
        
        return;

    }
    
    if (point.y > 5) {
        
        // Adjust the below value as you need
        offset.y = (point.y - navBarHeight) - 25;
        [_table setContentOffset:offset animated:YES];
    }
}

#pragma mark - 年龄选择器
//地区出现
-(void)pickerViewShow:(BOOL)show
{
    if (!_backPickView) {
        [self createAreaPickView];
    }
    __weak typeof (self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        
        weakSelf.backPickView.alpha = show ? 1 : 0;
        _pickerBgView.top = show ? (DEVICE_HEIGHT - _pickerBgView.height) : DEVICE_HEIGHT;
        
    }];
}

- (void)clickToCancel:(UIButton *)sender
{
    [self pickerViewShow:NO];
}

- (void)clickToSure:(UIButton *)sender
{
    [self pickerViewShow:NO];
    int age = (int)[_pickeView selectedRowInComponent:0] + 1;
    _age = age;
    [_contentArray replaceObjectAtIndex:4 withObject:NSStringFromInt(age)];
    [self textFieldWithTag:104].text = NSStringFromInt(age);
    [_table reloadData];
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return 150;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)componen{
    
    return [NSString stringWithFormat:@"%d",(int)row + 1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSLog(@"年龄%d",(int)row + 1);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        [self addFamily];
    }
}

#pragma mark - UIACtionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex ==0){
        //男
        _sex = 1;
        
        [_contentArray replaceObjectAtIndex:3 withObject:@"男"];
        [self textFieldWithTag:103].text = @"男";
        
    }else if(buttonIndex == 1){
        //女
        _sex = 2;
        [_contentArray replaceObjectAtIndex:3 withObject:@"女"];
        [self textFieldWithTag:103].text = @"女";

    }
    [_table reloadData];
}


#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -  UITableViewDataSource<NSObject>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"peopleCell";
    RightTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[RightTextFieldCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier textFieldDelegate:self];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    //注意section
    cell.textLabel.text = _items[indexPath.section];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"323232"];
    
    
    NSString *text = _contentArray[indexPath.section];
    
    if (self.actionStyle == ACTIONSTYLE_ADD) {
        
        
        NSArray *placeholderArr = @[@"请填写与身份证一致的姓名",@"请填写",@"请认真填写",@"请选择",@"请选择",@"请填写"];
        text = placeholderArr[indexPath.section];
        [cell.tf_right setAttributedPlaceholder:[LTools attributedString:text keyword:text color:[UIColor colorWithHexString:@"b0b0b0"]]];

    }else
    {
        cell.tf_right.text = text;
    }
    cell.tf_right.tag = 100 + indexPath.section;
    cell.tf_right.returnKeyType = UIReturnKeyNext;
    if (indexPath.section == _items.count - 1) {
        
        cell.tf_right.returnKeyType = UIReturnKeyDone;
        cell.tf_right.keyboardType = UIKeyboardTypeNumberPad;//数字键
    }else
    {
        cell.tf_right.keyboardType = UIKeyboardTypeDefault;
    }
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _items.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *head = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5.f)];
    head.backgroundColor = [UIColor clearColor];
    return head;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"---offset y %f",scrollView.contentOffset.y);
    
}

#pragma - mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self scrollTableViewWithTextField:textField];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    int index = (int)textField.tag - 100;
    
    if (textField.text.length > 0) {
        [_contentArray replaceObjectAtIndex:index withObject:textField.text];
        //102 身份证
        DDLOG(@"--idcard:%@",textField.text);
        if (textField.tag == 102) {
            NSString *idCard = textField.text;
            Gender gender = [LTools getIdCardSex:idCard];
            NSString *age = [LTools getIdCardAge:idCard];
            
            NSString *genderString = [self textFieldWithTag:103].text;//性别
            NSString *ageString = [self textFieldWithTag:104].text;//年龄
            
            if ([LTools isEmpty:genderString]) {
                NSString *sex = gender == Gender_Girl ? @"女":@"男";
                [self textFieldWithTag:103].text = sex;
                [_contentArray replaceObjectAtIndex:3 withObject:sex];
                _sex = gender == Gender_Girl ? 2 : 1; //1男 2女
            }
            
            if ([LTools isEmpty:ageString]) {
                [self textFieldWithTag:104].text = age;
                [_contentArray replaceObjectAtIndex:4 withObject:age];
                _age = [age intValue];
            }
        }
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    int tag = (int)textField.tag;
    //性别选择
    if (tag == 103 || tag == 104) {
        
        for (int i = 0; i < _items.count; i ++) {
            
            UITextField *tf = [_table viewWithTag:100 + i];
            if ([tf isFirstResponder]) {
                [tf resignFirstResponder];
            }
        }
        
        [self scrollTableViewWithTextField:textField];
        
        //年龄选择
        if (tag == 104) {
            
            [self pickerViewShow:YES];
            
        }else
        {
            UIActionSheet* alert = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                      cancelButtonTitle:@"取消"
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:@"男",@"女",nil];
            [alert showInView:self.view];
        }
        
        return NO;
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    int tag = (int)textField.tag + 1;
    
    UITextField *tf = [_table viewWithTag:tag];
    if (tf) {
        [tf becomeFirstResponder];
    }else
    {
        [self addFamily];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string   // return NO to not change text
{
    //身份证号
//    if (textField.tag == 102) {
//        <#statements#>
//    }
    
    return YES;
}


@end
