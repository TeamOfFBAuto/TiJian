//
//  PersonalCenterController.m
//  TiJian
//
//  Created by lichaowei on 15/11/5.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "PersonalCenterController.h"
#import "SettingsViewController.h"
#import "PeopleManageController.h"
#import "EditUserInfoViewController.h"
#import "AppointmentViewController.h"
#import "GShopCarViewController.h"
#import "ProductListViewController.h"
#import "OrderViewController.h"
#import "GMyOrderViewController.h"

@interface PersonalCenterController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UITableView *_table;
    NSArray *_dataArray;
    NSArray *_projectsArray;//推荐项目
    UserInfo *_userInfo;
    UIImageView *_headImageView;//头像
    
    UILabel *_nameLabel;
    UIView *_headview;//table headview
}

@property(nonatomic,retain)UIView *loginView;
@property(nonatomic,retain)UIView *unloginView;

@end

@implementation PersonalCenterController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_loginView removeFromSuperview];
    _loginView = nil;
    [self updateLoginState:[LoginViewController isLogin]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitleLabel.text = @"个人中心";
    self.rightImageName = @"personal_message";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeNull WithRightButtonType:MyViewControllerRightbuttonTypeOther];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForLogoutNotify:) name:NOTIFICATION_LOGOUT object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForLoginNotify:) name:NOTIFICATION_LOGIN object:nil];
    
    _userInfo = [UserInfo userInfoForCache];
    
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 49) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.backgroundColor = [UIColor clearColor];
    
    [self createTableHeadView];
    
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5.f)];
    _table.tableFooterView = footer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 通知

- (void)notificationForLogoutNotify:(NSNotification *)notify
{
    [self updateLoginState:NO];
}

- (void)notificationForLoginNotify:(NSNotification *)notify
{
    [self updateLoginState:YES];
}

#pragma - mark 网络请求

#pragma - mark 创建视图
/**
 *  创建tableView headView
 */
- (void)createTableHeadView
{
    _headview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 80)];
    _headview.backgroundColor = [UIColor whiteColor];
    
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 60, 60)];
    [logo addRoundCorner];
    [_headview addSubview:logo];
    logo.backgroundColor = [UIColor colorWithHexString:@"e6e6e6"];
    [logo addTaget:self action:@selector(clickToChangeUserHeadImage) tag:0];
    _headImageView = logo;
    
    //设置头像
    BOOL updateState = [LTools cacheBoolForKey:USER_UPDATEHEADIMAGE_STATE];
    if (!updateState) { //不需要上传,则正常显示url
        [logo sd_setImageWithURL:[NSURL URLWithString:_userInfo.avatar] placeholderImage:DEFAULT_HEADIMAGE];
    }else
    {
        UIImage *image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:USER_NEWHEADIMAGE];
        if (image) {
            logo.image = image;
        }else
        {
            logo.image = DEFAULT_HEADIMAGE;
        }
    }
    
    if ([LoginViewController isLogin]) {
        
        [_headview addSubview:self.loginView];
        
    }else
    {
        [_headview addSubview:self.unloginView];
    }
    
    _table.tableHeaderView = _headview;
    
}

-(UIView *)unloginView
{
    if (_unloginView) {
        return _unloginView;
    }
    _unloginView = [[UIView alloc]initWithFrame:CGRectMake(15 + 60 + 10, 0, DEVICE_WIDTH - (15 + 60 + 10), 80)];
    _unloginView.backgroundColor = [UIColor whiteColor];
    
    NSString *name = [NSString stringWithFormat:@"登录/注册"];
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 15) title:name font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [_unloginView addSubview:_nameLabel];
    _nameLabel.centerY = _unloginView.height/2.f;
    
    
    UIImageView *editImage = [[UIImageView alloc]initWithFrame:CGRectMake(_unloginView.width - 15 - 7, (80-14)/2.f, 7, 14)];
    editImage.image = [UIImage imageNamed:@"personal_jiantou_r"];
    [_unloginView addSubview:editImage];
    [_unloginView addTaget:self action:@selector(clickToEditUserInfo) tag:0];
    
    return _unloginView;
}

-(UIView *)loginView{
    
    if (_loginView) {
        
        return _loginView;
    }
    
    _loginView = [[UIView alloc]initWithFrame:CGRectMake(15 + 60 + 10, 0, DEVICE_WIDTH - (15 + 60 + 10), 80)];
    _loginView.backgroundColor = [UIColor whiteColor];
    
    NSString *name = [NSString stringWithFormat:@"用户名:%@",_userInfo.user_name];
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 22.5, 200, 15) title:name font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [_loginView addSubview:_nameLabel];
    
    UILabel *sexLabel = [[UILabel alloc]initWithFrame:CGRectMake(_nameLabel.left, _nameLabel.bottom + 7, 35, 15) title:@"性别:" font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [_loginView addSubview:sexLabel];
    
    int sex = [_userInfo.gender intValue];
    
    UIImageView *sexImage = [[UIImageView alloc]initWithFrame:CGRectMake(sexLabel.right + 5, sexLabel.top + 1, 12, 12)];
    sexImage.image = sex == 1 ? [UIImage imageNamed:@"sex_nan"] : [UIImage imageNamed:@"sex_nv"];
    [_loginView addSubview:sexImage];
    
    NSString *sexString = (sex == 1) ? @"男" : @"女";
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(sexImage.right + 6, sexLabel.top, 15, 15) title:sexString font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [_loginView addSubview:label];
    
//    UIImageView *editImage = [[UIImageView alloc]initWithFrame:CGRectMake(_loginView.width - 15 - 23, (80-23)/2.f, 23, 23)];
//    editImage.image = [UIImage imageNamed:@"bianji"];
//    [_loginView addSubview:editImage];
//    [_loginView addTaget:self action:@selector(clickToEditUserInfo) tag:0];
    
    //箭头
    UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(_loginView.width - 15 - 3.5, 0, 5.5, 11)];
    arrow.image = [UIImage imageNamed:@"personal_jiantou_small"];
    [_loginView addSubview:arrow];
    
    label = [[UILabel alloc]initWithFrame:CGRectMake(_loginView.width - arrow.width - 100 - 20, _loginView.height - 20 - 12 + 2, 100, 11) title:@"账户管理、收货地址" font:11 align:NSTextAlignmentRight textColor:DEFAULT_TEXTCOLOR_TITLE];
    [_loginView addSubview:label];
    label.font = [UIFont boldSystemFontOfSize:11];
    [label addTaget:self action:@selector(clickToEditUserInfo) tag:0];
    
    arrow.centerY = label.centerY;
    
    return _loginView;
}

#pragma - mark 事件处理
/**
 *  更新登录状态
 *
 *  @param isLogin 是否登录
 */
- (void)updateLoginState:(BOOL)isLogin
{
    if (isLogin) {
        
        if (self.unloginView) {
            self.unloginView.hidden = YES;
            [_unloginView removeFromSuperview];
            _unloginView = nil;
        }
        _userInfo = [UserInfo userInfoForCache];
        [_headview addSubview:self.loginView];
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:_userInfo.avatar] placeholderImage:DEFAULT_HEADIMAGE];
        
    }else
    {
        if (self.loginView) {
            [_loginView removeFromSuperview];
            _loginView = nil;
        }
        _headImageView.image = DEFAULT_HEADIMAGE;
        [_headview addSubview:self.unloginView];
    }
}

- (void)clickToEditUserInfo
{
    __weak typeof(self)weakSelf = self;
    if ([LoginViewController isLogin:self loginBlock:^(BOOL success) {
        
        if (success) {
            
            //登录成功更新界面
            [weakSelf updateLoginState:YES];
        }
    }])
    {
        //已登录
        NSLog(@"编辑个人信息");
        EditUserInfoViewController *edit = [[EditUserInfoViewController alloc]init];
        edit.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:edit animated:YES];
    }
}

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

-(void)rightButtonTap:(UIButton *)sender
{
    NSLog(@"消息中心");
}

#pragma mark UIACtionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex ==0){
        [self choseImageWithTypeCameraTypePhotoLibrary:UIImagePickerControllerSourceTypeCamera];
    }else if(buttonIndex == 1){
        [self choseImageWithTypeCameraTypePhotoLibrary:UIImagePickerControllerSourceTypePhotoLibrary];
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _headImageView.image = image;
    });
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma - mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![LoginViewController isLogin:self]) {
        return;
    }
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            //@"我的订单";
            OrderViewController *order = [[OrderViewController alloc]init];
            order.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:order animated:YES];
            
            GMyOrderViewController *cc = [[GMyOrderViewController alloc]init];
            cc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:cc animated:YES];
            
            
        }else if (indexPath.row == 1){
            
            //@"我的购物车";
            GShopCarViewController *shop = [[GShopCarViewController alloc]init];
            shop.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:shop animated:YES];
            
        }else if (indexPath.row == 2){
            
            //@"我的预约";
            AppointmentViewController *m_order = [[AppointmentViewController alloc]init];
            m_order.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:m_order animated:YES];
        }
    }else if (indexPath.section == 1){
        
        if (indexPath.row == 0) {
            
            //@"我的钱包";
            
        }else if (indexPath.row == 1){
            
            //@"我的收藏";
            ProductListViewController *list = [[ProductListViewController alloc]init];
            list.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:list animated:YES];
        }
    }else if (indexPath.section == 2){
        
        if (indexPath.row == 0) {
            
            //@"家人管理";
            PeopleManageController *p_manage = [[PeopleManageController alloc]init];
            p_manage.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:p_manage animated:YES];
        }
    }else if (indexPath.section == 3){
        
        if (indexPath.row == 0) {
            
            //@"设置";
            SettingsViewController *settings = [[SettingsViewController alloc]init];
            settings.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:settings animated:YES];
        }
    }
}

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    
    if (section == 0) {
        
        return 3;
    }else if (section == 1){
        
        return 2;
    }else if (section == 2){
        
        return 1;
    }else if (section == 3){
        
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"GProductCellTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15 - 7, (55-7-15)/2.f, 7, 14)];
        arrow.image = [UIImage imageNamed:@"personal_jiantou_r"];
        [cell.contentView addSubview:arrow];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"我的订单";
            cell.imageView.image = [UIImage imageNamed:@"personal_dingdan"];
            
        }else if (indexPath.row == 1){
            
            cell.textLabel.text = @"我的购物车";
            cell.imageView.image = [UIImage imageNamed:@"personal_gouwuche"];
            
        }else if (indexPath.row == 2){
            
            cell.textLabel.text = @"我的预约";
            cell.imageView.image = [UIImage imageNamed:@"personal_yuyue"];
        }
    }else if (indexPath.section == 1){
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"我的钱包";
            cell.imageView.image = [UIImage imageNamed:@"personal_qianbao"];
            
        }else if (indexPath.row == 1){
            
            cell.textLabel.text = @"我的收藏";
            cell.imageView.image = [UIImage imageNamed:@"personal_shoucang"];
        }
    }else if (indexPath.section == 2){
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"家人管理";
            cell.imageView.image = [UIImage imageNamed:@"personal_jiaren"];
        }
    }else if (indexPath.section == 3){
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"设置";
            cell.imageView.image = [UIImage imageNamed:@"personal_shezhi"];
        }
    }
    
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
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

@end
