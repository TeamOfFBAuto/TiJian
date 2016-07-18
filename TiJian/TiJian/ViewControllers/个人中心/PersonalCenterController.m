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
#import "MyWalletViewController.h"//我的钱包
#import "MessageCenterController.h"//消息中心
#import "MessageViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "WebviewController.h"

@interface PersonalCenterController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate>
{
    UITableView *_table;
    NSArray *_dataArray;
    NSArray *_projectsArray;//推荐项目
    UserInfo *_userInfo;
    UIImageView *_headImageView;//头像
    
    UILabel *_nameLabel;
    UILabel *_sexLabel;
    UIImageView *_sexImage;
    UIView *_headview;//table headview
    UIImageView *_vipHat;//vip皇冠
    UIImageView *_vipImage;//vip
}

@property(nonatomic,retain)UIView *loginView;
@property(nonatomic,retain)UIView *unloginView;
@property (nonatomic,retain)UIView *redPoint;//未读消息

@end

@implementation PersonalCenterController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([LoginManager isLogin]) {
        [self updateUserInfo];
    }
    
    [LTools updateTabbarUnreadMessageNumber];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"个人中心";
    self.rightImageName = @"personal_message";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeNull WithRightButtonType:MyViewControllerRightbuttonTypeOther];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForLogoutNotify:) name:NOTIFICATION_LOGOUT object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForLoginNotify:) name:NOTIFICATION_LOGIN object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(netWorkForList) name:NOTIFICATION_PAY_SUCCESS object:nil];
    _userInfo = [UserInfo userInfoForCache];
    
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 49) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.backgroundColor = [UIColor clearColor];
    
    [self createTableHeadView];
    
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5.f)];
    _table.tableFooterView = footer;
    
    //同步网络数据
    if ([LoginManager isLogin]) {
        [self netWorkForList];
    }
    
    //监控未读消息num
    
    UITabBarController *root = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if ([root isKindOfClass:[UITabBarController class]]) {
        
        UINavigationController *unvc = [root.viewControllers objectAtIndex:2];
        [unvc.tabBarItem addObserver:self forKeyPath:@"badgeValue" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        
    }
}

/**
 *  控制右上角红点
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"observeValueForKeyPath %@",change);
    
    if ([keyPath isEqualToString:@"badgeValue"]) {
        
        id new = [change objectForKey:@"new"];
        
        int newNum = 0.f;
        if ([new isKindOfClass:[NSNull class]]) {
            
            newNum = 0;
        }else
        {
            newNum = [new intValue];
        }
        
        if (newNum > 0) {
            
            self.redPoint.hidden = NO;
        }else
        {
            self.redPoint.hidden = YES;
        }
        
        DDLOG(@"mine未读消息 %d",newNum);
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 通知

- (void)notificationForLogoutNotify:(NSNotification *)notify
{
    [self updateLoginState:NO];
    [LTools updateTabbarUnreadMessageNumber];
}

- (void)notificationForLoginNotify:(NSNotification *)notify
{
    [self updateLoginState:YES];
}

#pragma - mark 网络请求

- (void)netWorkForList
{
    NSString *authkey = [UserInfo getAuthkey];
    NSDictionary *params = @{@"authcode":authkey};;
    NSString *api = GET_USERINFO_WITHID;
    
     @WeakObj(self);
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:Weakself.view animated:YES];
        
        NSDictionary *user_info = result[@"user_info"];
        
        [Weakself updateUserInfoWithResult:user_info];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        
    }];
}

- (void)updateUserInfoWithResult:(NSDictionary *)result
{
    UserInfo *userInfo = [[UserInfo alloc]initWithDictionary:result];
    
    [userInfo cacheUserInfo];//存储

    [self updateUserInfo];
    
}

- (void)updateUserInfo
{
    UserInfo *userInfo = [UserInfo userInfoForCache];
    //设置头像
    BOOL updateState = [LTools boolForKey:USER_UPDATEHEADIMAGE_STATE];
    if (!updateState) { //不需要上传,则正常显示url
        
        UIImage *image = _headImageView.image ? : DEFAULT_HEADIMAGE;
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.avatar] placeholderImage:image options:SDWebImageRefreshCached];
    
    }else
    {
        UIImage *image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:USER_NEWHEADIMAGE];
        if (image) {
            _headImageView.image = image;
        }else
        {
            _headImageView.image = DEFAULT_HEADIMAGE;
        }
    }
    
    NSString *name = [NSString stringWithFormat:@"用户名:%@",userInfo.user_name];
    _nameLabel.text = name;
    
    int sex = [userInfo.gender intValue];
    _sexImage.image = sex == 1 ? [UIImage imageNamed:@"sex_nan"] : [UIImage imageNamed:@"sex_nv"];
    
    NSString *sexString = (sex == 1) ? @"男" : @"女";
    _sexLabel.text = sexString;
    
    [self updateVipState];//vip状态
}

#pragma - mark 创建视图

/**
 *  未读消息红点
 *
 *  @return
 */
-(UIView *)redPoint
{
    if (!_redPoint) {
        
        CGFloat width = 10.f;
        UIView *point = [[UIView alloc]initWithFrame:CGRectMake(self.right_button.width - width/2.f, -width/2.f, width, width)];
        [self.right_button addSubview:point];
        _redPoint = point;
        point.backgroundColor = [UIColor colorWithHexString:@"ec2120"];
        [point setBorderWidth:1.5f borderColor:[UIColor whiteColor]];
        [point addRoundCorner];
    }
    return _redPoint;
}

/**
 *  创建tableView headView
 */
- (void)createTableHeadView
{
    _headview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 80)];
    _headview.backgroundColor = [UIColor whiteColor];
    
    
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 60, 60)];
    [logo addRoundCorner];
    [_headview addSubview:logo];
    logo.backgroundColor = [UIColor colorWithHexString:@"e6e6e6"];
    [logo addTaget:self action:@selector(clickToChangeUserHeadImage) tag:0];
    _headImageView = logo;
    
    //头像加vip
    UIImageView *vipHat = [[UIImageView alloc]initWithFrame:CGRectMake(logo.right - 18, logo.bottom - 18, 18, 18)];
    vipHat.image = [UIImage imageNamed:@"personal_vip"];
    [_headview addSubview:vipHat];
    vipHat.hidden = YES;
    _vipHat = vipHat;
    
    //设置头像
    BOOL updateState = [LTools boolForKey:USER_UPDATEHEADIMAGE_STATE];
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
    CGFloat width = [LTools widthForText:name font:14];
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 22.5, width + 5, 15) title:name font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [_loginView addSubview:_nameLabel];
    
    //VIP标识
    UIImageView *vipImage = [[UIImageView alloc]initWithFrame:CGRectMake(_nameLabel.right + 5, 0, 15.5, 15.5)];
    vipImage.image = [UIImage imageNamed:@"personal_vipyes"];
    [_loginView addSubview:vipImage];
    vipImage.centerY = _nameLabel.centerY;
    _vipImage = vipImage;
    
    UILabel *sexLabel = [[UILabel alloc]initWithFrame:CGRectMake(_nameLabel.left, _nameLabel.bottom + 7, 35, 15) title:@"性别:" font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [_loginView addSubview:sexLabel];
    
    int sex = [_userInfo.gender intValue];
    UIImageView *sexImage = [[UIImageView alloc]initWithFrame:CGRectMake(sexLabel.right + 5, sexLabel.top + 1, 12, 12)];
    sexImage.image = sex == 1 ? [UIImage imageNamed:@"sex_nan"] : [UIImage imageNamed:@"sex_nv"];
    [_loginView addSubview:sexImage];
    _sexImage = sexImage;
    
    NSString *sexString = (sex == 1) ? @"男" : @"女";
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(sexImage.right + 6, sexLabel.top, 15, 15) title:sexString font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [_loginView addSubview:label];
    _sexLabel = label;
    
    //箭头
    UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(_loginView.width - 15 - 3.5, 0, 5.5, 11)];
    arrow.image = [UIImage imageNamed:@"personal_jiantou_small"];
    [_loginView addSubview:arrow];
    
    label = [[UILabel alloc]initWithFrame:CGRectMake(_loginView.width - arrow.width - 100 - 20, _loginView.height - 20 - 12 + 2, 100, 30) title:@"账户管理、收货地址" font:11 align:NSTextAlignmentRight textColor:DEFAULT_TEXTCOLOR_TITLE];
    [_loginView addSubview:label];
    label.font = [UIFont boldSystemFontOfSize:11];
    arrow.centerY = label.centerY;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = _loginView.bounds;
    [btn addTarget:self action:@selector(clickToEditUserInfo) forControlEvents:UIControlEventTouchUpInside];
    [_loginView addSubview:btn];
    
    return _loginView;
}

#pragma - mark 挂号对接处理
/**
 *  点击跳转至挂号网对接
 *
 *  @param btn
 */
- (void)clickToGuaHaoType:(int)type
{
    WebviewController *web = [[WebviewController alloc]init];
    web.guaHao = YES;
    web.type = type;
    web.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];
    
}

#pragma - mark 事件处理

/**
 *  更新Vip状态
 */
- (void)updateVipState
{
    _userInfo = [UserInfo userInfoForCache];
    BOOL isVip = [_userInfo.is_vip boolValue];
    _vipImage.hidden = !isVip;
    _vipHat.hidden = !isVip;
}

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
    
    [self updateVipState];
}

- (void)clickToEditUserInfo
{
    if ([LoginManager isLogin:self]) {
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
    
    if (![LoginViewController isLogin:self]) {
        NSLog(@"未登录修改毛线");
        return;
    }
    
    UIActionSheet* alert = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"拍照",@"从相册选择",nil];
    [alert showInView:self.view];
}

-(void)choseImageWithTypeCameraTypePhotoLibrary:(UIImagePickerControllerSourceType)type{
    
    if (type == UIImagePickerControllerSourceTypeCamera) { //相机
        if (![UIImagePickerController isSourceTypeAvailable:type]) {
            //不支持相机
            return;
        }
        
        //相机
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == kCLAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
        {
            //无权限
            NSString *title = @"此应用没有权限访问您的相机";
            NSString *errorMessage = @"您可以在\"隐私设置\"中启用访问。";
            
            //iOS8 之后可以打开系统设置界面
            if (IOS8_OR_LATER) {
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title
                                                                   message:errorMessage
                                                                  delegate:self
                                                         cancelButtonTitle:@"取消"
                                                         otherButtonTitles:@"设置", nil];
                [alertView show];
            }else
            {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title
                                                                   message:errorMessage
                                                                  delegate:nil
                                                         cancelButtonTitle:@"确定"
                                                         otherButtonTitles:nil, nil];
                [alertView show];
            }
            return;
        }
    }
    
    
    
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate =self;
    imagePicker.sourceType = type;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicker.allowsEditing =YES;
    [self presentViewController:imagePicker animated:YES completion:^{
        
    }];
}

//NSString *title = [NSString stringWithFormat:@"打开\"定位服务\"来允许\"%@\"确定您的位置",[LTools getAppName]];
//NSString *mes = @"以便获取附近分院信息";
//UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:mes delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
//[alert show];

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
    }else if (buttonIndex == 1){
        
        if (IOS8_OR_LATER) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: UIApplicationOpenSettingsURLString]];
        }
    }
}

-(void)rightButtonTap:(UIButton *)sender
{
    if ([LoginManager isLogin:self]) {
        NSLog(@"消息中心");
        MessageCenterController *message = [[MessageCenterController alloc]init];
        message.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:message animated:YES];
    }
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
    
    [LTools setBool:YES forKey:USER_UPDATEHEADIMAGE_STATE];//需要更新头像
    
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
    self.redPoint.hidden = YES;
    
    if (![LoginViewController isLogin:self]) {
        return;
    }
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            //@"体检预约";
            AppointmentViewController *m_order = [[AppointmentViewController alloc]init];
            m_order.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:m_order animated:YES];
            
        }else if (indexPath.row == 1){
            
           //@"体检订单";
            OrderViewController *order = [[OrderViewController alloc]init];
            order.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:order animated:YES];

            
        }else if (indexPath.row == 2){
            
            //@"体检钱包";
            MyWalletViewController *cc = [[MyWalletViewController alloc]init];
            cc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:cc animated:YES];
            
        }else if (indexPath.row == 3){
            
            //@"体检购物车";
            GShopCarViewController *shop = [[GShopCarViewController alloc]init];
            shop.isPersonalCenterPush = YES;
            shop.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:shop animated:YES];
            
        }else if (indexPath.row == 4){
            
            //@"体检套餐收藏";
            ProductListViewController *list = [[ProductListViewController alloc]init];
            list.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:list animated:YES];
        }
        
    }else if (indexPath.section == 1){
        
        //target配置：
        //1     预约挂号
        //2     转诊预约
        //3     健康顾问团
        //4     公立医院主治医生
        //5     公立医院权威专家
        //6     我的问诊
        //7     我的预约
        //8     我的转诊
        //9     我的关注
        //10    家庭联系人
        //11    家庭病例
        //12    我的申请
        //13    医生随访
        //14    购药订单
        
        if (indexPath.row == 0) {
            
            //@"挂号问诊";
            [self clickToGuaHaoType:6];
            
        }else if (indexPath.row == 1){
            
            //@"挂号转诊";
            [self clickToGuaHaoType:8];
            
        }else if (indexPath.row == 2){
            
            //@"挂号预约";
            [self clickToGuaHaoType:7];

        }else if (indexPath.row == 3){
            
            //@"挂号申请"12; 修改为我的关注 target:9
            [self clickToGuaHaoType:9];

        }else if (indexPath.row == 4){
            
            //@"医生随访"; 修改为 健康顾问团 target:3
            [self clickToGuaHaoType:3];
        }
        
    }else if (indexPath.section == 2){
        
        if (indexPath.row == 0) {
            
            //@"家人管理";
            PeopleManageController *p_manage = [[PeopleManageController alloc]init];
            p_manage.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:p_manage animated:YES];
            
        }else if (indexPath.row == 1) {
            
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
        
        return 5;
    }else if (section == 1){
        
        return 5;
    }else if (section == 2){
        
        return 2;
    }
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"personCenterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15 - 7, (55-7-15)/2.f, 7, 14)];
        arrow.image = [UIImage imageNamed:@"personal_jiantou_r"];
        [cell.contentView addSubview:arrow];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14];

    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"体检预约";
            cell.imageView.image = [UIImage imageNamed:@"personal_tijianyuyue"];

        }else if (indexPath.row == 1){
            
            cell.textLabel.text = @"体检订单";
            cell.imageView.image = [UIImage imageNamed:@"personal_tijiandingdan"];
            
            
        }else if (indexPath.row == 2){
            
            cell.textLabel.text = @"体检钱包";
            cell.imageView.image = [UIImage imageNamed:@"personal_tijianqianbao"];
            
        }else if (indexPath.row == 3){
            
            cell.textLabel.text = @"体检购物车";
            cell.imageView.image = [UIImage imageNamed:@"personal_tijiangouwuche"];
        }else if (indexPath.row == 4){
            
            cell.textLabel.text = @"体检套餐收藏";
            cell.imageView.image = [UIImage imageNamed:@"personal_tijianshoucang"];
        }
        
    }else if (indexPath.section == 1){
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"挂号问诊";
            cell.imageView.image = [UIImage imageNamed:@"personal_guahaowenzhen"];
            
        }else if (indexPath.row == 1){
            
            cell.textLabel.text = @"挂号转诊";
            cell.imageView.image = [UIImage imageNamed:@"personal_guanhaozhuanzhen"];
            
            
        }else if (indexPath.row == 2){
            
            cell.textLabel.text = @"挂号预约";
            cell.imageView.image = [UIImage imageNamed:@"personal_guahaoyuyue"];
            
        }else if (indexPath.row == 3){
            
            cell.textLabel.text = @"我的关注";
            cell.imageView.image = [UIImage imageNamed:@"personal_guanhaoshengqing"];
            
        }else if (indexPath.row == 4){
            
            cell.textLabel.text = @"家庭医生";
            cell.imageView.image = [UIImage imageNamed:@"personal_suifang"];
        }
        
    }else if (indexPath.section == 2){
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"家人管理";
            cell.imageView.image = [UIImage imageNamed:@"personal_jiarenguanli"];
        }else if (indexPath.row == 1) {
            
            cell.textLabel.text = @"设置";
            cell.imageView.image = [UIImage imageNamed:@"personal_settings"];
        }

    }
    
    return cell;
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
