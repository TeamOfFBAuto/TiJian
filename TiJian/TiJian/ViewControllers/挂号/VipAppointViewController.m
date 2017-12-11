//
//  VipAppointViewController.m
//  TiJian
//
//  Created by lichaowei on 16/4/28.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "VipAppointViewController.h"
#import "WebviewController.h"
#import "AddPeopleViewController.h"
#import "VipRegisteringController.h"//VIP专家号
#import "EditUserInfoViewController.h"
#import "GStoreHomeViewController.h"
#import "PropertyButton.h"
#import "FamilyCell.h"

#define TableViewWidth DEVICE_WIDTH * 3 / 5.f //右侧选择就诊人view宽度

@interface VipAppointViewController ()<RefreshDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
{
    BOOL _sliderOpen;
    //VIP标记
    UIButton *_vipBtn;
    UILabel *_useStateLaebl;//使用状态label
    int _availableNum;//可服务次数
    int _totalNum;//可服务次数
    UIButton *_guaHaoBtn;//开始挂号按钮
    int _selectUserFamilyid;//选择用户id
}

@property(nonatomic,retain)RefreshTableView *table;
@property(nonatomic,retain)UIView *sliderBgView;
@property(nonatomic,retain)UIView *footerView;
@property(nonatomic,retain)UIActivityIndicatorView *indicator;
@property(nonatomic,retain)UIImageView *vipAlert;//vip弹框

@end

@implementation VipAppointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"专家号";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - HMFitIphoneX_navcBarHeight)];
    imageView.backgroundColor = [UIColor orangeColor];
    
    if (iPhone4) {
       imageView.image = [UIImage imageNamed:@"vip_iphone4.jpg"];
    }
    else if(iPhone6PLUS)
    {
        imageView.image = [UIImage imageNamed:@"vip_iphone6p.jpg"];
    }else
    {
       imageView.image = [UIImage imageNamed:@"vip_iphone6.jpg"];// 5 6 公用一张
    }
    imageView.userInteractionEnabled = YES;
    [self.view addSubview:imageView];
    
    CGFloat senderWidth = DEVICE_WIDTH / 2.f + 10;//挂号按钮宽度
    CGFloat vipTop = 100;
    CGFloat senderTop = imageView.height - 80 - 40;
    if (iPhone4) {
        vipTop = 155;
        senderTop = imageView.height - 152;
    }else if (iPhone5)
    {
        vipTop = 205;
        senderTop = imageView.height - 172;
    }else if (iPhone6)
    {
        vipTop = 245;
        senderTop = imageView.height - 217;
    }else if (iPhone6PLUS)
    {
        vipTop = 285;
        senderTop = imageView.height - 237;
    }
    
    //VIP标记
    _vipBtn = [[UIButton alloc]initWithframe:CGRectMake(0, vipTop, 61, 64) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"vip_yes"] selectedImage:[UIImage imageNamed:@"vip_no"] target:self action:nil];
    [self.view addSubview:_vipBtn];
    _vipBtn.centerX = imageView.width / 2.f;
    _vipBtn.selected = ![UserInfo getVipState];
    
    //开始挂号
    UIButton *sender = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sender.frame = CGRectMake(0, senderTop, senderWidth, 50.f);
    [sender.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [sender setTitle:@"开始挂号" forState:UIControlStateNormal];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sender setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.1]];
    [sender addCornerRadius:25.f];
    [imageView addSubview:sender];
    sender.centerX = imageView.width / 2.f;
    [sender addTarget:self action:@selector(clickToSelectPeople:) forControlEvents:UIControlEventTouchUpInside];
    _guaHaoBtn = sender;
    
    //使用情况
    _useStateLaebl = [[UILabel alloc]initWithFrame:CGRectMake(0, sender.bottom + 10, DEVICE_WIDTH, 16) font:12 align:NSTextAlignmentCenter textColor:[UIColor whiteColor] title:nil];
    [_useStateLaebl setAttributedText:[self useStringWithUseNum:0 lastNum:0]];
    [self.view addSubview:_useStateLaebl];
    
    [self.view addSubview:self.sliderBgView];
    
    //初始化值
    _sliderOpen = NO;
    
    //获取vip状态
    [self netWorkForVipState];
    
    //支付成功更新vip状态
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(netWorkForVipState) name:NOTIFICATION_PAY_SUCCESS object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  使用次数AttributeString
 *
 *  @param useNum  已使用次数
 *  @param lastNum 剩余次数
 *
 *  @return
 */
- (NSAttributedString *)useStringWithUseNum:(int)useNum
                                    lastNum:(int)lastNum
{
    _availableNum = lastNum;//默认0次
    NSString *usedkey1 = NSStringFromInt(useNum);
    NSString *lastkey2 = NSStringFromInt(lastNum);
    NSString *content = [NSString stringWithFormat:@"您已经使用 %@ 次   还有 %@ 次服务",usedkey1,lastkey2];
    
    NSAttributedString *temp = [LTools attributedString:content keyword:usedkey1 color:DEFAULT_TEXTCOLOR_ORANGE];
    NSMutableAttributedString *m_string = [[NSMutableAttributedString alloc]initWithAttributedString:temp];
    return [LTools attributedString:m_string originalString:content AddKeyword:lastkey2 color:DEFAULT_TEXTCOLOR_ORANGE];
}

#pragma mark - getter

/**
 *  非vip提醒
 *
 *  @return
 */
-(UIImageView *)vipAlert
{
    if (!_vipAlert) {
        
        UIImage *alertImage = [UIImage imageNamed:@"vip_alert"];
        CGSize imageSize = alertImage.size;
        CGFloat width = imageSize.width;
        CGFloat height = imageSize.height;
        
        CGFloat realWidth = DEVICE_WIDTH * height / width;//实际要显示宽
        CGFloat realHeight = realWidth * height / width;//实际显示高度
        _vipAlert = [[UIImageView alloc]initWithFrame:CGRectMake((DEVICE_WIDTH - realWidth)/2.f - 3, _guaHaoBtn.top - 10 - realHeight, realWidth, realHeight)];
        _vipAlert.image = alertImage;
        _vipAlert.userInteractionEnabled = YES;

        
        UIButton *closeBtn = [[UIButton alloc]initWithframe:CGRectMake(_vipAlert.width - 50, 0, 50, 50) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil target:self action:@selector(hiddenVipAlert)];
        [_vipAlert addSubview:closeBtn];
//        closeBtn.backgroundColor = [UIColor redColor];
        
        UIButton *buyBtn = [[UIButton alloc]initWithframe:CGRectMake(0, closeBtn.bottom + 10, _vipAlert.width, _vipAlert.height - closeBtn.bottom - 80) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil target:self action:@selector(clickToBuy)];
        [_vipAlert addSubview:buyBtn];
//        buyBtn.backgroundColor = [[UIColor orangeColor]colorWithAlphaComponent:0.3];
        
    }
    return _vipAlert;
}

#pragma mark - 视图创建

-(UIView *)footerView
{
    if (!_footerView) {

        CGFloat width = TableViewWidth;
        _footerView = [[UIView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH, self.sliderBgView.height - 150, width,150)];
        _footerView.backgroundColor = [UIColor whiteColor];
        
        UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
        [add setTitle:@"  添加就诊人" forState:UIControlStateNormal];
        add.frame = CGRectMake(20, _footerView.height - 80 - 30 - 30 - 5, width - 60, 30);
        [add addCornerRadius:15];
        add.backgroundColor = DEFAULT_TEXTCOLOR;
        [add.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [add addTarget:self action:@selector(clickToAddPeople) forControlEvents:UIControlEventTouchUpInside];
        [add setImage:[UIImage imageNamed:@"vip_+"] forState:UIControlStateNormal];
        [_footerView addSubview:add];
        add.centerX = _footerView.width / 2.f;
        
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancel setTitle:@"取消" forState:UIControlStateNormal];
        cancel.frame = CGRectMake(20, add.bottom + 15 + 10, width - 60, 30);
        [cancel addCornerRadius:15];
        cancel.backgroundColor = [UIColor colorWithHexString:@"bfbfbf"];
        [cancel.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(hiddeSliderView) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:cancel];
        cancel.centerX = _footerView.width / 2.f;
    }
    return _footerView;
}

-(UIActivityIndicatorView *)indicator
{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicator.color = [UIColor grayColor];
        _indicator.frame = _table.bounds;
    }
    return _indicator;
}

/**
 *  右侧选择就诊人View
 *
 *  @return
 */
-(UIView *)sliderBgView
{
    if (!_sliderBgView)
    {
        _sliderBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - HMFitIphoneX_navcBarHeight)];
        _sliderBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _sliderBgView.alpha = 0.f;
        [self.view addSubview:_sliderBgView];
        
        [_sliderBgView addSubview:self.table];
        [_sliderBgView addSubview:self.footerView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddeSliderView)];
        tap.delegate = self;
        [_sliderBgView addGestureRecognizer:tap];
    }
    return _sliderBgView;
}

-(RefreshTableView *)table
{
    if (!_table) {
        CGFloat width = TableViewWidth;
        _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH, 0, width, self.sliderBgView.height - 150) style:UITableViewStylePlain refreshHeaderHidden:YES];
        _table.refreshDelegate = self;
        _table.backgroundColor = [UIColor whiteColor];
        _table.dataSource = self;
        [self.sliderBgView addSubview:_table];
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        
        UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 66)];
        _table.tableHeaderView = header;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, width, 33) font:14 align:NSTextAlignmentCenter textColor:[UIColor whiteColor] title:@"选择就诊人"];
        label.backgroundColor = DEFAULT_TEXTCOLOR;
        [header addSubview:label];
    }
    
    [_table addSubview:self.indicator];
    return _table;
}

/**
 *  请求结果 为空、等特殊情况
 */
-(ResultView *)resultView
{
    if (!_resultView) {
        _resultView = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"]
                                                        title:@"温馨提示"
                                                      content:@"您还没有添加家人"];
    }
    
    return (ResultView *)_resultView;
}

#pragma mark - 事件处理

/**
 *  去购买套餐
 */
- (void)clickToBuy
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic safeSetValue:@"HomeViewController" forKey:@"style"];
    [[MiddleTools shareInstance]umengEvent:@"Store_home" attributes:dic number:[NSNumber numberWithInt:1]];
    
    GStoreHomeViewController *cc= [[GStoreHomeViewController alloc]init];
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
    
    [self hiddenVipAlert];
}

/**
 *  编辑用户信息
 *
 *  @param sender
 */
- (void)clickToEditUserInfo:(PropertyButton *)sender
{
    UserInfo *aModel = sender.aModel;
    NSString *familyUid = aModel.family_uid;
    if (familyUid && [familyUid intValue] > 0)
    {
        [self editFamilyUserInfoFamilyUid:familyUid];
    }else
    {
        [self editLoginUserInfo];
    }
}

/**
 *  编辑本人信息
 */
- (void)editLoginUserInfo
{
    EditUserInfoViewController *edit = [[EditUserInfoViewController alloc]init];
    edit.isFullUserInfo = YES;
     @WeakObj(self);
    [edit setUpdateParamsBlock:^(NSDictionary *params){
        [Weakself updateLoginUser];
        NSLog(@"params %@",params);
    }];
    [self.navigationController pushViewController:edit animated:YES];
}

/**
 *  同步当前登录用户
 */
- (void)updateLoginUser
{
    for (UserInfo *userInfo in _table.dataArray)
    {
        if ([userInfo.uid intValue] == [[UserInfo getUserId]intValue] &&
            ([LTools isEmpty:userInfo.family_uid] || [userInfo.family_uid intValue] == 0))//判断是自己
        {
            UserInfo *loginUser = [UserInfo userInfoForCache];
            userInfo.family_user_name = loginUser.real_name;
            [_table reloadData];
        }
    }
}

/**
 *  编辑家人信息
 */
- (void)editFamilyUserInfoFamilyUid:(NSString *)familyUid
{
    AddPeopleViewController *add = [[AddPeopleViewController alloc]init];
    add.actionStyle = ACTIONSTYLE_EditDetailByFamily_uid;
    add.family_uid = familyUid;
     @WeakObj(self);
    [add setUpdateParamsBlock:^(NSDictionary *params){
        
        NSLog(@"params %@",params);
        [Weakself.table refreshNewData];
    }];
    [self.navigationController pushViewController:add animated:YES];
}

/**
 *  隐藏vipalert
 */
- (void)hiddenVipAlert
{
    [self.vipAlert removeFromSuperview];
    _vipAlert = nil;
}

- (void)hiddeSliderView
{
    [self selectPeople:NO];
}

/**
 *  控制 右侧选择就诊人view移动动画
 *
 *  @param selected
 */
- (void)selectPeople:(BOOL)selected
{
    _sliderOpen = selected;

     @WeakObj(self);
    [UIView animateWithDuration:0.3 animations:^{
        
        if (selected) {
            Weakself.table.left = DEVICE_WIDTH * 2 / 5.f;
            Weakself.footerView.left = DEVICE_WIDTH * 2 / 5.f;
            Weakself.sliderBgView.alpha = 1;
        }else
        {
            Weakself.table.left = DEVICE_WIDTH;
            Weakself.footerView.left = DEVICE_WIDTH;
            Weakself.sliderBgView.alpha = 0;
        }
    }];
}

/**
 *  开始挂号
 *
 *  @param sender
 */
- (void)clickToSelectPeople:(UIButton *)sender
{
    if (_availableNum <= 0) { //没有可用服务次数
        
        if(_totalNum == 1) //总数为1 而且使用完了
        {
            self.vipAlert.transform = CGAffineTransformScale(self.vipAlert.transform,0.5,0.5);
            [UIView animateWithDuration:0.2 animations:^{
                [self.view addSubview:self.vipAlert];
                self.vipAlert.transform = CGAffineTransformIdentity;
                self.vipAlert.transform = CGAffineTransformScale(self.vipAlert.transform,1.1,1.1);
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.1 animations:^{
                    self.vipAlert.transform = CGAffineTransformIdentity;
                }];
            }];
            
        }else
        {
            [LTools showMBProgressWithText:@"您的服务次数已用完！" addToView:self.view];
        }
        
    }else
    {
        [self selectPeople:YES];
        
        if (self.table.dataArray.count == 0) {
            
            [self getFamily];
        }
    }
}

/**
 *  点击跳转至挂号网对接
 *
 *  @param btn
 */
- (void)pushToGuaHaoType:(int)type
               familyuid:(NSString *)familyuid
{
    WebviewController *web = [[WebviewController alloc]init];
    web.guaHao = YES;
    web.type = type;
    web.familyuid = familyuid;
    web.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];
}

/**
 *  点击跳转至native挂号
 *
 *  @param btn
 */
- (void)pushToNativeGuaHaoWithUserInfo:(UserInfo *)userInfo
{
    //预约结果通知
    VipRegisteringController *vipRegister = [[VipRegisteringController alloc]init];
    vipRegister.userInfo = userInfo;
     @WeakObj(self);
    [vipRegister setUpdateParamsBlock:^(NSDictionary *params) {
       
        BOOL result = [params[@"result"]boolValue];
        if (result) {
            
            [Weakself actionForRefferalSucess];
        }
        
    }];
    [self.navigationController pushViewController:vipRegister animated:YES];
}

/**
 *  vip挂号预约成功
 */
- (void)actionForRefferalSucess
{
    //
    _availableNum -= 1;//剩余次数
    if (_availableNum < 0) {
        _availableNum = 0;
    }
    [_useStateLaebl setAttributedText:[self useStringWithUseNum:_totalNum - _availableNum lastNum:_availableNum]];
    
}

- (void)clickToAddPeople
{
    AddPeopleViewController *add = [[AddPeopleViewController alloc]init];

     @WeakObj(self);
     @WeakObj(_table);
    [add setUpdateParamsBlock:^(NSDictionary *params){
        
        NSLog(@"params %@",params);
        Weak_table.isReloadData = YES;
        [Weakself getFamily];
    }];
    
    [self.navigationController pushViewController:add animated:YES];
}


/**
 *  根据结果控制vip状态
 *
 *  @param result
 */
- (void)updateVipStateWithResult:(NSDictionary *)result
{
    int register_referral_counts = [result[@"register_referral_counts"] intValue];//使用的次数
    int register_referral_total_counts = [result[@"register_referral_total_counts"] intValue];//一共可使用的次数
    _availableNum = register_referral_total_counts - register_referral_counts;//剩余次数
    _totalNum = register_referral_total_counts;
    
    [_useStateLaebl setAttributedText:[self useStringWithUseNum:register_referral_counts lastNum:_availableNum]];
    
    BOOL is_vip = [result[@"is_vip"]boolValue];
    _vipBtn.selected = !is_vip;
}

#pragma mark - 网络请求

/**
 *  获取vip状态信息
 */
- (void)netWorkForVipState
{
    NSString *authkey = [UserInfo getAuthkey];
    NSDictionary *params = @{@"authcode":authkey};
    NSString *api = get_register_referral_counts;
    
    __weak typeof(self)weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf updateVipStateWithResult:result];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
}

- (void)getFamily
{
    [self.indicator startAnimating];
    
    NSString *authkey = [UserInfo getAuthkey];
    __weak typeof(self)weakSelf = self;
//    __weak typeof(_table)weakTable = _table;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_FAMILY parameters:@{@"authcode":authkey} constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *temp = [UserInfo modelsFromArray:result[@"family_list"]];
        UserInfo *selfUser = [UserInfo userInfoForCache];
        selfUser.appellation = @"本人";
        
        NSString *name = @"本人";
        if ([LTools isEmpty:selfUser.real_name]) {
            name = selfUser.user_name;
        }else
        {
            name = selfUser.real_name;
        }
        selfUser.mySelf = YES;
        selfUser.family_user_name = name;
        
        NSMutableArray *arr = [NSMutableArray arrayWithObject:selfUser];
        [arr addObjectsFromArray:temp];
        
        [weakSelf.table reloadData:arr pageSize:1000 noDataView:weakSelf.resultView];
        
        [weakSelf.indicator stopAnimating];
        
    } failBlock:^(NSDictionary *result) {
        
        [weakSelf.table loadFailWithView:weakSelf.resultView pageSize:1000];
        [weakSelf.indicator stopAnimating];
    }];
}


#pragma mark - 数据解析处理

#pragma mark - 代理

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"];
}

#pragma - mark RefreshDelegate <NSObject>

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    [self getFamily];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    
}
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    UserInfo *user = _table.dataArray[indexPath.row];
//    [self pushToGuaHaoType:2 familyuid:user.family_uid];
    
    if ([LTools isEmpty:user.family_uid]
        && user.mySelf) { //判断是否是自己
        
        if (![UserInfo isLoginUserInfoWell]) { //信心不完善
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"用户信息不完整,去完善？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去完善", nil];
            [alert show];
            
            return;
        }
    }
    
    [self pushToNativeGuaHaoWithUserInfo:user];
    
    [self hiddeSliderView];
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    return 44.f;
}

#pragma - mark UITableViewDataSource

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return tableView.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"FamilyCell";
    FamilyCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        
        cell = [[FamilyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UserInfo *aModel = _table.dataArray[indexPath.row];
    
    [cell.editButton addTarget:self action:@selector(clickToEditUserInfo:) forControlEvents:UIControlEventTouchUpInside];
    cell.editButton.aModel = aModel;
    cell.nameLabel.width = TableViewWidth - 50 * 2;
    cell.selectButton.left = TableViewWidth - 50;

    NSString *name = aModel.family_user_name;
    cell.nameLabel.text = name;
        
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma - mark UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        [self editLoginUserInfo];
    }
}

@end
