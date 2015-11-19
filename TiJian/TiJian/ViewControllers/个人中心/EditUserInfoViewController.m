//
//  EditUserInfoViewController.m
//  TiJian
//
//  Created by lichaowei on 15/11/6.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "EditUserInfoViewController.h"
#import "UpdateUserInfoController.h"
#import "LDatePicker.h"

#define kTagSex 300
#define kTagPhoto 301

@interface EditUserInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    UITableView *_table;
    NSArray *_titles;
    int _sex;
    int _age;
    UIView *_pickerBgView;//选择器背景view
    UIPickerView *_pickeView;
}

@property(nonatomic,retain)UIImageView *iconImageView;//头像
@property(nonatomic,retain)UserInfo *userInfo;

@property(nonatomic,retain)LDatePicker *datePicker;//时间选择器
@property(nonatomic,strong)UIView *backPickView;//地区选择pickerView后面的背景view


@end

@implementation EditUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (_isFullUserInfo) {
        
        self.myTitle = @"完善信息";
    }else
    {
        self.myTitle = @"我的账户";
        //需啊哟显示 收货地址
    }
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    [self netWorkForList];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建
/**
 *  时间选择器
 *
 *  @return
 */
-(LDatePicker *)datePicker
{
    if (_datePicker) {
        return _datePicker;
    }
    _datePicker = [[LDatePicker alloc] init];
    
    return _datePicker;
}

- (void)prepareRefreshTableViewWithResult:(NSDictionary *)result
{
    
    NSDictionary *user_info = result[@"user_info"];
    
    self.userInfo = [[UserInfo alloc]initWithDictionary:user_info];
    [self.userInfo cacheUserInfo];//存储
    
    _titles = @[@"姓       名",@"昵       称",@"性       别",@"年       龄",@"出生日期",@"身份证号"];
    //,@"手  机  号"
    
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.backgroundColor = [UIColor clearColor];
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 65)];
    _table.tableHeaderView = header;
    
    UIView *infoView = [[UIView alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 60)];
    infoView.backgroundColor = [UIColor whiteColor];
    [header addSubview:infoView];
    
    [infoView addTaget:self action:@selector(clickToChangeUserHeadImage) tag:0];
    
    //title
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 60, 60) title:@"头       像" font:15 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_THIRD];
    [infoView addSubview:title];
    
    //箭头
    UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 35, 0, 35, 60)];
    arrow.image = [UIImage imageNamed:@"personal_jiantou_r"];
    arrow.contentMode = UIViewContentModeCenter;
    [infoView addSubview:arrow];
    
    //头像
    self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(arrow.left - 40, 10, 40, 40)];
    [_iconImageView addRoundCorner];
    [infoView addSubview:_iconImageView];
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:_userInfo.avatar] placeholderImage:DEFAULT_HEADIMAGE];
    
    //line
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(10, infoView.height - 0.5, DEVICE_WIDTH - 10, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [infoView addSubview:line];
}

#pragma mark - 网络请求

- (void)netWorkForUpdateUserType:(UPDATEINFOTYPE)type
                           param:(NSString *)param
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
    NSDictionary *params;
    if (type == UPDATEINFOTYPE_AGE) {
        
        params = @{@"authcode":authKey,
                   @"age":param};
        
    }else if (type == UPDATEINFOTYPE_BIRTHDAY){
        
        params = @{@"authcode":authKey,
                   @"birthday":param};
    }else if (type == UPDATEINFOTYPE_GENDER){
        
        params = @{@"authcode":authKey,
                   @"gender":param};
    }
    
    NSString *api = USER_UPDATE_USEINFO;
    
    __weak typeof(self)weakSelf = self;
    __weak typeof(_table)weaktable = _table;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        if (type == UPDATEINFOTYPE_AGE) {
            
            [UserInfo updateUserAge:param];
            _userInfo.age = param;
            
        }else if (type == UPDATEINFOTYPE_BIRTHDAY){
            
            [UserInfo updateUserBirthday:param];
            _userInfo.birthday = [LTools timeDatelineWithString:param format:@"YYYY-MM-dd"];
            
        }else if (type == UPDATEINFOTYPE_GENDER){
            
            [UserInfo updateUserSex:param];
            _userInfo.gender = param;
        }
        
        [weaktable reloadData];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

- (void)netWorkForList
{
    NSString *authkey = [LTools cacheForKey:USER_AUTHOD];
    NSDictionary *params = @{@"authcode":authkey};;
    NSString *api = GET_USERINFO_WITHID;
    
    __weak typeof(self)weakSelf = self;
    __weak typeof(_table)weakTable = _table;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        [weakSelf prepareRefreshTableViewWithResult:result];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

#pragma mark - 数据解析处理

#pragma mark - 事件处理

/**
 *  收货地址
 */
- (void)clickToAddress
{
    NSLog(@"我的收货地址");
}

- (void)clickToUpdateType:(UPDATEINFOTYPE)type
{
    __weak typeof(_table)weakTable = _table;
    UpdateUserInfoController *edit = [[UpdateUserInfoController alloc]init];
    edit.updateType = type;
    
    if (type == UPDATEINFOTYPE_REALNAME) {
        edit.content = _userInfo.real_name;
        
    }else if (type == UPDATEINFOTYPE_IDCARD){
        edit.content = _userInfo.id_card;
    }else if (type == UPDATEINFOTYPE_USERNAME){
        edit.content = _userInfo.user_name;
    }
    
    edit.updateBlock = ^(NSString *text){
        
        if (type == UPDATEINFOTYPE_REALNAME) {
            
            _userInfo.real_name = text;
            
        }else if (type == UPDATEINFOTYPE_IDCARD){
            
            _userInfo.id_card = text;
            
        }else if (type == UPDATEINFOTYPE_USERNAME){
            _userInfo.user_name = text;
        }
        [weakTable reloadData];
        
        NSLog(@"text:%@",text);
    };
    [self.navigationController pushViewController:edit animated:YES];
}

- (void)clickToUpdateBirthday
{
    __weak typeof(self)weakSelf = self;
    [self.datePicker showDateBlock:^(ACTIONTYPE type, NSString *dateString) {
        
        if (type == ACTIONTYPE_SURE) {
            
            [weakSelf netWorkForUpdateUserType:UPDATEINFOTYPE_BIRTHDAY param:dateString];
        }
        
        NSLog(@"dateBlock %@",dateString);
        
    }];
}

/**
 *  修改头像
 */
- (void)clickToChangeUserHeadImage
{
    NSLog(@"修改个人头像");
    
    if (![LoginViewController isLogin]) {
        NSLog(@"未登录修改毛线");
        return;
    }
    
    UIActionSheet* alert = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"相机",@"从相机选择",nil];
    alert.tag = kTagPhoto;
    [alert showInView:self.view];
}

-(void)choseImageWithTypeCameraTypePhotoLibrary:(UIImagePickerControllerSourceType)type{
    
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate =self;
    imagePicker.sourceType = type;
    imagePicker.allowsEditing = YES;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicker.allowsEditing =YES;
    [self presentViewController:imagePicker animated:YES completion:^{
        
    }];
}

#pragma mark - 代理

#pragma - mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
       
        NSLog(@"更新名字");
        [self clickToUpdateType:UPDATEINFOTYPE_REALNAME];
        
    }if (indexPath.row == 1) {
        
        NSLog(@"更新昵称");
        [self clickToUpdateType:UPDATEINFOTYPE_USERNAME];
        
    }else if (indexPath.row == 2){
        
        NSLog(@"选择性别");
        UIActionSheet* alert = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                  cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"男",@"女",nil];
        alert.tag = kTagSex;
        [alert showInView:self.view];
        
    }else if (indexPath.row == 3){
        
        NSLog(@"更改年龄");
        [self pickerViewShow:YES];
        
    }else if (indexPath.row == 4){
        
        NSLog(@"出生日期");
        [self clickToUpdateBirthday];
        
    }else if (indexPath.row == 5){
        
        NSLog(@"身份证号");
        [self clickToUpdateType:UPDATEINFOTYPE_IDCARD];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (!_isFullUserInfo) {
        return 55;
    }
    
    return 0.01f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if (!_isFullUserInfo) {
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 55)];
        view.backgroundColor = [UIColor clearColor];
        
        UIView *infoView = [[UIView alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 50)];
        infoView.backgroundColor = [UIColor whiteColor];
        [view addSubview:infoView];
        
        [infoView addTaget:self action:@selector(clickToChangeUserHeadImage) tag:0];
        
        //title
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 60, 50) title:@"收货地址" font:15 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_THIRD];
        [infoView addSubview:title];
        
        //箭头
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 35, 0, 35, 50)];
        arrow.image = [UIImage imageNamed:@"personal_jiantou_r"];
        arrow.contentMode = UIViewContentModeCenter;
        [infoView addSubview:arrow];
        
        [view addTaget:self action:@selector(clickToAddress) tag:0];
        
        return view;
    }
    
    return [UIView new];
}

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"identify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        
        //箭头
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 35, 0, 35, 50)];
        arrow.image = [UIImage imageNamed:@"personal_jiantou_r"];
        arrow.contentMode = UIViewContentModeCenter;
        [cell.contentView addSubview:arrow];
        
        //detail
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 200 - 35, 0, 200, 50) title:nil font:15 align:NSTextAlignmentRight textColor:DEFAULT_TEXTCOLOR_TITLE];
        [cell.contentView addSubview:label];
        label.tag = 100;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.textColor = DEFAULT_TEXTCOLOR_TITLE_THIRD;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.text = _titles[indexPath.row];
    
    NSString *detail = @"";
    if (indexPath.row == 0) {
        
        detail = _userInfo.real_name;
        
    }else if (indexPath.row == 1) {
        
        detail = _userInfo.user_name;
    }
    
    else if (indexPath.row == 2){
        
        int sex = [_userInfo.gender intValue];
        if (sex > 0) {
            detail = [_userInfo.gender intValue] == 1 ? @"男" : @"女";
        }else
        {
            detail = @"未选择";
        }
        
    }else if (indexPath.row == 3){
        
        detail = [_userInfo.age intValue] > 0 ? _userInfo.age : @"未选择";
        
    }else if (indexPath.row == 4){
        
        detail = [_userInfo.birthday intValue] > 0 ? [LTools timeString:_userInfo.birthday withFormat:@"YYYY.MM.dd"] : @"未填写";
    }else if (indexPath.row == 5){
        
        if ([LTools isValidateIDCard:_userInfo.id_card]) {
            detail = _userInfo.id_card;
        }else
        {
            detail = @"未填写";
        }
        
    }else if (indexPath.row == 6){
        if ([LTools isValidateMobile:_userInfo.mobile]) {
            
            detail = _userInfo.mobile;
        }else
        {
            detail = @"未填写";
        }
        
    }
    
    UILabel *detailLabel = [cell.contentView viewWithTag:100];
    detailLabel.text = detail;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark UIACtionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag == kTagSex) {
        
        if(buttonIndex ==0){
            //男
            _sex = 1;
            
            [self netWorkForUpdateUserType:UPDATEINFOTYPE_GENDER param:@"1"];
            
        }else if(buttonIndex == 1){
            //女
            _sex = 2;
            [self netWorkForUpdateUserType:UPDATEINFOTYPE_GENDER param:@"2"];
            
        }
        [_table reloadData];
    }else if (actionSheet.tag == kTagPhoto){
        
        if(buttonIndex ==0){
            [self choseImageWithTypeCameraTypePhotoLibrary:UIImagePickerControllerSourceTypeCamera];
        }else if(buttonIndex == 1){
            [self choseImageWithTypeCameraTypePhotoLibrary:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }
}

#pragma - mark UIPickerViewControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    //    NSData * imageData = UIImageJPEGRepresentation(image,0.6);
    
    image = [LTools scaleToSizeWithImage:image size:CGSizeMake(200, 200)];
    //TODO：将图片发给服务器
    
    [LTools cacheBool:YES ForKey:USER_UPDATEHEADIMAGE_STATE];//需要更新头像
    
    //存储更新头像image
    
    [[SDImageCache sharedImageCache]storeImage:image forKey:USER_NEWHEADIMAGE toDisk:YES];
    
    //上传头像通知
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATEHEADIMAGE object:image];
    
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        weakSelf.iconImageView.image = image;
    });
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - 年龄选择器

-(void)createAreaPickView{
    
    //地区选择
    self.backPickView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    self.backPickView .backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    [[UIApplication sharedApplication].keyWindow addSubview:_backPickView];
    self.backPickView.alpha = 0.f;//默认初始
    
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
    
    [self netWorkForUpdateUserType:UPDATEINFOTYPE_AGE param:NSStringFromInt(_age)];
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

@end
