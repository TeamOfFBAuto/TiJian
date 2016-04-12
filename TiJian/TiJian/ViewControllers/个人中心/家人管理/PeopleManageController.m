//
//  PeopleManageController.m
//  TiJian
//
//  Created by lichaowei on 15/11/6.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "PeopleManageController.h"
#import "AddPeopleViewController.h"
#import "EditUserInfoViewController.h"
#import "AppointModel.h"
#import "ConfirmOrderViewController.h"
#import "ProductModel.h"
#import "HospitalModel.h"

#define kTag_Appoint 200 //预约
#define kTag_Delete 201 //去删除
#define KTag_EditUserInfo 202 //去编辑个人信息

@interface PeopleManageController ()<UITableViewDataSource,RefreshDelegate>
{
    RefreshTableView *_table;
    UIButton *_arrowBtn;
    BOOL _isOpen;//是否展开
    UIView *_view_tableHeader;
    BOOL _isEdit;//是否在编辑
    UILabel *_numLabel;//位数
    int _deleteIndex;//待删除下标
    NSMutableArray *_selectedArray;//选中
    NSArray *_tempSelectedArray;//选中

    NSMutableArray *_selectedUserArray;//选中model
    NSArray *_tempSelectedUserArray;//选中model
    
    NSArray *_selectedHospitalArray;//已经选择过的体检分院及体检人

    //此套餐可以预约个数
    int _noAppointNum;//未预约个数
    //提交预约参数
    NSString *_order_id;//订单id
    NSString *_product_id;//单品id
    NSString *_exam_center_id;//体检机构id
    NSString *_exam_center_name;//体检机构name
    NSString *_date;// 预约体检日期（如：2015-11-13）
    
    //个人特有
    UIImageView *_selectedIcon;//选择本人的icon
    BOOL _isMyselfSelected;//是否选择自己

}

@property(nonatomic,retain)ResultView *nodataView;

@end

@implementation PeopleManageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (_actionType == PEOPLEACTIONTYPE_NORMAL) {
        self.myTitle = @"家人管理";
    }else if (_actionType == PEOPLEACTIONTYPE_SELECT_Single){
        self.myTitle = @"重新选择体检人";
    }else if (_actionType == PEOPLEACTIONTYPE_SELECT_APPOINT ||
              _actionType == PEOPLEACTIONTYPE_NOPAYAPPOINT ||
              _actionType == PEOPLEACTIONTYPE_SELECT_Mul){
        self.myTitle = @"选择体检人";
    }
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.view.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [self createNavigationbarTools];
    
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH,DEVICE_HEIGHT - 64)];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];
    
    _selectedArray = [NSMutableArray array];
    if (_tempSelectedArray) {
        [_selectedArray addObjectsFromArray:_tempSelectedArray];
    }
    _selectedUserArray = [NSMutableArray array];
    if (_tempSelectedUserArray) {
        [_selectedUserArray addObjectsFromArray:_tempSelectedUserArray];
    }
    _isOpen = YES;//默认打开
    _isEdit = NO;//默认非编辑
    _table.tableHeaderView = [self tableHeadView];
    
    if (_actionType == PEOPLEACTIONTYPE_SELECT_APPOINT ||
        _actionType == PEOPLEACTIONTYPE_NOPAYAPPOINT ||
        _actionType == PEOPLEACTIONTYPE_SELECT_Mul) {
        UIView *view = [self tableFooterView];
        [self.view addSubview:view];
        view.top = DEVICE_HEIGHT - view.height - 64;
        _table.height = DEVICE_HEIGHT - 64 - view.height;
    }
    
    [_table showRefreshHeader:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 网络请求

- (void)getFamily
{
    NSString *authkey = [UserInfo getAuthkey];
    __weak typeof(self)weakSelf = self;
    __weak typeof(_table)weakTable = _table;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:GET_FAMILY parameters:@{@"authcode":authkey} constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *temp = [UserInfo modelsFromArray:result[@"family_list"]];
        [weakTable reloadData:temp pageSize:1000 noDataView:[weakSelf resultViewWithType:PageResultType_nodata]];
        _numLabel.text = [NSString stringWithFormat:@"%d位",(int)weakTable.dataArray.count];
        
    } failBlock:^(NSDictionary *result) {
        
        [weakTable loadFail];
    }];
}

- (void)deleteFamily:(int)index
{
    UserInfo *aModel = _table.dataArray[index];

    NSString *authkey = [UserInfo getAuthkey];
    NSDictionary *params = @{@"authcode":authkey,
                             @"family_uids":aModel.family_uid};
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self)weakSelf = self;
    __weak typeof(_table)weakTable = _table;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:DEL_FAMILY parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        [weakTable.dataArray removeObjectAtIndex:index];
        [weakTable reloadData];
        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

/**
 *  预约参数传值
 *
 *  @param orderId
 *  @param productId
 *  @param examCenterId     体检机构id
 *  @param date             预约的时间 格式如：2015-11-13
 *  @param noAppointNum     套餐未预约个数
 */
- (void)setAppointOrderId:(NSString *)orderId
                productId:(NSString *)productId
             examCenterId:(NSString *)examCenterId
                     date:(NSString *)date
             noAppointNum:(int)noAppointNum
{
    //提交预约参数
    _order_id = orderId;//订单id
    _product_id = productId;//单品id
    _exam_center_id = examCenterId;//体检机构id
    _date = date;// 预约体检日期（如：2015-11-13）
    _noAppointNum = noAppointNum;
}


/**
 *  选择多个体检人信息 回调
 *  @param examCenterName   体检机构name
 *  @param examCenterId     体检机构id
 *  @param date             预约的时间 格式如：2015-11-13
 *  @param noAppointNum     套餐未预约个数
 */
- (void)selectMulPeopleWithExamCenterId:(NSString *)examCenterId
                         examCenterName:(NSString *)examName
                               examDate:(NSString *)date
                           noAppointNum:(int)noAppointNum
                            updateBlock:(UpdateParamsBlock)updateBlock
{
    self.updateParamsBlock = updateBlock;
    //提交预约参数
    _exam_center_id = examCenterId;//体检机构id
    _exam_center_name = examName;
    _date = date;// 预约体检日期（如：2015-11-13）
    _noAppointNum = noAppointNum;
}

/**
 *  选择多个体检人信息 回调
 *  @param examCenterName   体检机构name
 *  @param examCenterId     体检机构id
 *  @param date             预约的时间 格式如：2015-11-13
 *  @param noAppointNum     套餐未预约个数
 */
- (void)selectMulPeopleWithHospitalArray:(NSArray *)hospitalArray
                            examCenterId:(NSString *)examCenterId
                         examCenterName:(NSString *)examName
                               examDate:(NSString *)date
                           noAppointNum:(int)noAppointNum
                            updateBlock:(UpdateParamsBlock)updateBlock
{
    self.updateParamsBlock = updateBlock;
    //提交预约参数
    _exam_center_id = examCenterId;//体检机构id
    _exam_center_name = examName;
    _date = date;// 预约体检日期（如：2015-11-13）
    _noAppointNum = noAppointNum;
    _selectedHospitalArray = hospitalArray;

    NSArray *userArray;
    for (HospitalModel *hospital in hospitalArray) {
        //分院和时间都满足
        if ([hospital.exam_center_id integerValue] == [examCenterId integerValue] &&
            [hospital.date isEqualToString:date]) {
            userArray = hospital.usersArray;
        }
    }
    if (userArray.count) {
        [self replaceUserArray:userArray noAppointNum:noAppointNum updateBlock:updateBlock];
    }
}

/**
 *  更新体检人
 *
 *  @param userArray    体检人数组
 *  @param noAppointNum
 *  @param updateBlock
 */
- (void)replaceUserArray:(NSArray *)userArray
            noAppointNum:(int)noAppointNum
             updateBlock:(UpdateParamsBlock)updateBlock
{
    NSMutableArray *tempUsers = [NSMutableArray array];
    NSMutableArray *tempIds = [NSMutableArray arrayWithCapacity:userArray.count];
    self.updateParamsBlock = updateBlock;
    for (UserInfo *user in userArray) {
        
        if ([user.family_uid integerValue] == 0 ||
            user.mySelf == YES) {
            _isMyselfSelected = YES;
        }else
        {
            NSString *uid = NSStringFromInt([user.family_uid intValue]);
            [tempIds addObject:uid];
            [tempUsers addObject:user];
        }
    }
    //
    _tempSelectedArray = [NSArray arrayWithArray:tempIds];
    _tempSelectedUserArray = [NSArray arrayWithArray:tempUsers];
    _noAppointNum = noAppointNum + (int)userArray.count;

    [_table reloadData];
}

/**
 *  提交预约信息
 */
- (void)networkForMakeAppoint
{
    //个人
    //家人id 多个用英文逗号隔开（若是个人买单，则要传）
    
    NSString *family_uid = [_selectedArray componentsJoinedByString:@","];
    //myself 是否包括本人 1是 0不是（若是个人买单，则要传）
//    NSString *myself = _isMyselfSelected ? @"1" : @"0";
    
    NSString *authkey = [UserInfo getAuthkey];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetValue:authkey forKey:@"authcode"];
    [params safeSetValue:_order_id forKey:@"order_id"];
    [params safeSetValue:_product_id forKey:@"product_id"];
    [params safeSetValue:_exam_center_id forKey:@"exam_center_id"];
    [params safeSetValue:_date forKey:@"date"];
    [params safeSetBool:_isMyselfSelected forKey:@"myself"];

    [params safeSetValue:family_uid forKey:@"family_uid"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:MAKE_APPOINT parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        [LTools showMBProgressWithText:@"恭喜您预约成功！" addToView:weakSelf.view];
        [weakSelf performSelector:@selector(appointSuccess) withObject:nil afterDelay:0.5];
        NSLog(@"预约成功 result");
        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

#pragma - mark 事件处理

- (void)appointSuccess
{
    //预约成功通知
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_APPOINT_SUCCESS object:nil];

    if (self.lastViewController) {
        [self.navigationController popToViewController:self.lastViewController animated:YES];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  去预约
 */
- (void)clickToAppoint
{
    int num = (int)_selectedArray.count;
    //选择自己或者选择了至少一个其他人
    if (_isMyselfSelected || num > 0) {
        
        if (_actionType == PEOPLEACTIONTYPE_NORMAL)
        {
            return;
            
        }else if (_actionType == PEOPLEACTIONTYPE_SELECT_Single)
        {
            //仅选择人并自动返回
            return;
            
        }else if (_actionType == PEOPLEACTIONTYPE_SELECT_Mul)//选择多个体检人
        {
            //选择的体检人
            NSMutableArray *temp = [NSMutableArray arrayWithArray:_selectedUserArray];
            
            //是否包含自己
            if (_isMyselfSelected) {
                
                UserInfo *loginUser = [UserInfo userInfoForCache];
                UserInfo *userInfo = [[UserInfo alloc]init];
                userInfo.family_uid = 0;
                userInfo.appellation = @"本人";
                userInfo.family_user_name = loginUser.real_name;
                userInfo.id_card = loginUser.id_card;
                userInfo.mySelf = YES;
                [temp addObject:userInfo];
            }
            
            HospitalModel *tempHospital;
            NSMutableArray *hospitalsArray;
            if (_selectedHospitalArray.count) {
                hospitalsArray = [NSMutableArray arrayWithArray:_selectedHospitalArray];
            }else
            {
                hospitalsArray = [NSMutableArray array];
            }
            
            for (HospitalModel *hospital in _selectedHospitalArray) {
                //分院和时间都满足
                if ([hospital.exam_center_id integerValue] == [_exam_center_id integerValue] &&
                    [hospital.date isEqualToString:_date]) {
                    
                    tempHospital = hospital;
                }
            }
            
            if (tempHospital) {
                tempHospital.usersArray = [NSMutableArray arrayWithArray:temp];//体检人信息
            }else
            {
                HospitalModel *hospital = [[HospitalModel alloc]init];
                hospital.date = _date;
                hospital.exam_center_id = _exam_center_id;
                hospital.center_name = _exam_center_name;
                hospital.usersArray = [NSMutableArray arrayWithArray:temp];//体检人信息
                [hospitalsArray addObject:hospital];
            }
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params safeSetValue:hospitalsArray forKey:@"hospital"];//分院数组
            [params safeSetValue:temp forKey:@"userInfo"];//体检人数组

            
            //回调值
            if (self.updateParamsBlock) {
                self.updateParamsBlock(params);
            }
            if (self.lastViewController) {
                [self.navigationController popToViewController:self.lastViewController animated:YES];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }else if (_actionType == PEOPLEACTIONTYPE_SELECT_APPOINT) //选择直接预约
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"是否确定预约体检" delegate:self cancelButtonTitle:@"稍等" otherButtonTitles:@"确定", nil];
            alert.tag = kTag_Appoint;
            [alert show];
            
        }else if (_actionType == PEOPLEACTIONTYPE_NOPAYAPPOINT)
        {
            //选择的体检人
            NSMutableArray *temp = [NSMutableArray arrayWithArray:_selectedUserArray];
            //是否包含自己
            if (_isMyselfSelected) {
                
                UserInfo *loginUser = [UserInfo userInfoForCache];
                UserInfo *userInfo = [[UserInfo alloc]init];
                userInfo.family_uid = 0;
                userInfo.appellation = @"本人";
                userInfo.family_user_name = loginUser.real_name;
                userInfo.id_card = loginUser.id_card;
                userInfo.mySelf = YES;
                [temp addObject:userInfo];
                
                num += 1;
            }
            
            //aModel.current_price\product_num、brand_name、cover_pic
            ProductModel *productModel = (ProductModel *)self.productModel;
            productModel.product_num = NSStringFromInt(num);
            productModel.current_price = productModel.setmeal_price;
            productModel.product_name = productModel.setmeal_name;
            
            HospitalModel *hospital = [[HospitalModel alloc]init];
            hospital.date = _date;
            hospital.exam_center_id = _exam_center_id;
            hospital.center_name = _exam_center_name;
            
            ConfirmOrderViewController *cc = [[ConfirmOrderViewController alloc]init];
            cc.lastViewController = self;
            [cc appointWithProductModel:productModel hospital:hospital userArray:temp];
            [self.navigationController pushViewController:cc animated:YES];
        }
        
    }else{
        
        [LTools showMBProgressWithText:@"请选择体检人" addToView:self.view];
        
    }
}

/**
 *  选择体检人并返回
 *
 *  @param user UserInfo model
 *  @param myself 是否是本人
 */
- (void)selectPeople:(UserInfo *)user
              myself:(BOOL)myself
{
    if (self.updateParamsBlock) {
        
        NSDictionary *params = @{@"result":user,
                                 @"myself":[NSNumber numberWithBool:myself]};
        self.updateParamsBlock(params);
    }
    
    [self leftButtonTap:nil];
}

/**
 *  查看本人信息
 */
- (void)clickToMe
{
    //大于0表示需要判断性别
    //男或者女时判断选择人的性别
    if (self.gender == Gender_Boy || self.gender == Gender_Girl) {
        
        Gender gender_select = [[UserInfo userInfoForCache].gender intValue];
        
        if (gender_select != self.gender) {
            
            NSString *title = self.gender == Gender_Girl ? @"本套餐仅适用于\"女\"性" : @"本套餐仅适用于\"男\"性";
            [LTools showMBProgressWithText:title addToView:self.view];
            return;
        }
    }
    
    //普通
    if (_actionType == PEOPLEACTIONTYPE_NORMAL) {
        
        [self clickToEditUserInfoIsFull:NO];

    }
    //选择人
    else if (_actionType == PEOPLEACTIONTYPE_SELECT_Single){
        
        if ([self enableSelectNewPeople]) {
            
            //需要判断信息是否完整
            if ([self isUserInfoWell]) {
                
                _selectedIcon.hidden = NO;
                _isMyselfSelected = YES;
                
                //选择成功回调
                NSLog(@"选择体检人成功");
                
                UserInfo *user = [UserInfo userInfoForCache];
                
                [self selectPeople:user myself:YES];
                
                
            }else
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"用户信息不完整,去完善？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去完善", nil];
                alert.tag = KTag_EditUserInfo;
                [alert show];
            }
        }
        
    }
    //选择并预约
    else if (_actionType == PEOPLEACTIONTYPE_SELECT_APPOINT ||
             _actionType == PEOPLEACTIONTYPE_NOPAYAPPOINT ||
             _actionType == PEOPLEACTIONTYPE_SELECT_Mul){
        
        if (_isMyselfSelected) {
            
            _selectedIcon.hidden = YES;
            _isMyselfSelected = NO;
            
        }else
        {
            if ([self enableSelectNewPeople]) {
                
                //需要判断信息是否完整
                if ([self isUserInfoWell]) {
                    
                    _selectedIcon.hidden = NO;
                    _isMyselfSelected = YES;
                    
                }else
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"用户信息不完整,去完善？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去完善", nil];
                    alert.tag = KTag_EditUserInfo;
                    [alert show];
                }
            }
        }
    }
}

/**
 *  跳转至用户详情页
 *
 *  @param aModel
 */
- (void)clickToUserInfo:(UserInfo *)aModel
{
    AddPeopleViewController *add = [[AddPeopleViewController alloc]init];
    add.actionStyle = ACTIONSTYLE_DETTAILT;
    add.userModel = aModel;
    __weak typeof(_table)weakTable = _table;
    
    [add setUpdateParamsBlock:^(NSDictionary *params){
        
        NSLog(@"params %@",params);
        [weakTable showRefreshHeader:YES];
    }];
    
    [self.navigationController pushViewController:add animated:YES];
}

/**
 *  点击打开或者关闭
 *
 *  @param sender
 */
- (void)clickToAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _arrowBtn.selected = sender.selected;
    
    _isOpen = !sender.selected;
    
    [_table reloadData];
    
}

/**
 *  添加新人
 */
- (void)clickToAdd:(UIButton *)sender
{
    AddPeopleViewController *add = [[AddPeopleViewController alloc]init];
    __weak typeof(_table)weakTable = _table;
    
    [add setUpdateParamsBlock:^(NSDictionary *params){
        
        NSLog(@"params %@",params);
        [weakTable showRefreshHeader:YES];
    }];
    
    [self.navigationController pushViewController:add animated:YES];
}

/**
 *  编辑状态、可删除人
 *
 *  @param sender
 */
- (void)clickToEdit:(UIButton *)sender
{
    _isEdit = !_isEdit;
    [_table reloadData];
}

/**
 *  编辑本人信息
 */
- (void)clickToEditUserInfoIsFull:(BOOL)isFull
{
    EditUserInfoViewController *edit = [[EditUserInfoViewController alloc]init];
    edit.isFullUserInfo = isFull;
    [self.navigationController pushViewController:edit animated:YES];
}

/**
 *  判断本人信息是否完整
 *
 *  @return
 */
- (BOOL)isUserInfoWell
{
    UserInfo *userInfo = [UserInfo userInfoForCache];
    NSString *name = userInfo.real_name;
    NSString *id_card = userInfo.id_card;
    int sex = [userInfo.gender intValue];
    int age = [userInfo.age intValue];
    NSString *phone = userInfo.mobile;
    
    if (name.length > 0 &&
        [LTools isValidateIDCard:id_card] &&
        sex > 0 &&
        age > 0 &&
        [LTools isValidateMobile:phone]) {
        
        return YES;
    }
    
    return NO;
}

/**
 *  判断是否可以选择更多人
 *
 *  @return 是否
 */
- (BOOL)enableSelectNewPeople
{
    int selectNum = (int)_selectedArray.count;//可选
    if (_isMyselfSelected) { //是否选择本人
        
        selectNum += 1;
    }
    
    //已选择小于剩余总数
    if (selectNum < _noAppointNum) {
        
        return YES;
    }
    
    NSString *text = [NSString stringWithFormat:@"共可约%d人,已选%d人",_noAppointNum,selectNum];
    
    [LTools alertText:text viewController:self];
    
    return NO;
}

#pragma - mark 创建视图

/**
 *  请求结果 为空、等特殊情况
 */
-(ResultView *)resultViewWithType:(PageResultType)type
{
    NSString *content;
    if (type == PageResultType_nodata){
        
        content = @"您还没有添加家人";
    }
    
    if (_nodataView) {
        
        [_nodataView setContent:content];
        return _nodataView;
    }
    
    ResultView *result = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"]
                                                    title:@"温馨提示"
                                                  content:content];
    
    self.nodataView = result;
    
    return result;
}

- (void)createNavigationbarTools
{
    
    if (_actionType == PEOPLEACTIONTYPE_NORMAL) {
        
        UIButton *rightView=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 88, 44)];
        rightView.backgroundColor=[UIColor clearColor];
        
        //添加
        UIButton *heartButton = [[UIButton alloc]initWithframe:CGRectMake(0, 0, 44, 44) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"personal_jiaren_tianjia"] selectedImage:nil target:self action:@selector(clickToAdd:)];
        [heartButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        
        
        //删除
        UIButton *collectButton = [[UIButton alloc]initWithframe:CGRectMake(44, 0, 44, 44) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"personal_jiaren_shanchu"] selectedImage:nil target:self action:@selector(clickToEdit:)];
        [collectButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        
        
        [rightView addSubview:heartButton];
        [rightView addSubview:collectButton];
        
        UIBarButtonItem *comment_item=[[UIBarButtonItem alloc]initWithCustomView:rightView];
        
        self.navigationItem.rightBarButtonItem = comment_item;
    }else
    {
        //添加
        UIButton *heartButton = [[UIButton alloc]initWithframe:CGRectMake(0, 0, 44, 44) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"personal_jiaren_tianjia"] selectedImage:nil target:self action:@selector(clickToAdd:)];
        [heartButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        UIBarButtonItem *comment_item=[[UIBarButtonItem alloc]initWithCustomView:heartButton];
        self.navigationItem.rightBarButtonItem = comment_item;
        return;
    }
    
}

- (UIView *)tableFooterView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 30 + 45)];
    view.backgroundColor = [UIColor clearColor];
    
    //确认预约按钮
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self.actionType == PEOPLEACTIONTYPE_NOPAYAPPOINT ||
        self.actionType == PEOPLEACTIONTYPE_SELECT_Mul) {
        [sureBtn setTitle:@"确认选择体检人" forState:UIControlStateNormal];
    }else
    {
        [sureBtn setTitle:@"确认预约" forState:UIControlStateNormal];
    }
    sureBtn.backgroundColor = DEFAULT_TEXTCOLOR;
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [sureBtn addCornerRadius:2.f];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [view addSubview:sureBtn];
    sureBtn.frame = CGRectMake(27, 15, DEVICE_WIDTH - 27 * 2, 45);
    [sureBtn addTarget:self action:@selector(clickToAppoint) forControlEvents:UIControlEventTouchUpInside];
    
    return view;
}

- (UIView *)tableHeadView
{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 67)];
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 6, DEVICE_WIDTH, 56)];
    bgView.backgroundColor = [UIColor whiteColor];
    [headView addSubview:bgView];
    //本人
    UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 35, bgView.height) title:@"本人" font:16 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
    [bgView addSubview:titleLable];
    
    NSString *name = [UserInfo userInfoForCache].user_name;
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleLable.right + 60, 0, 200, bgView.height) title:name font:15 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"313131"]];
    [bgView addSubview:nameLabel];
    
    if (_actionType == PEOPLEACTIONTYPE_NORMAL) {
        
        UIImageView *editImage = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15 - 7, (67-14)/2.f, 7, 14)];
        editImage.image = [UIImage imageNamed:@"personal_jiantou_r"];
        [bgView addSubview:editImage];
    }else
    {
        //图标 对号
        UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15 - 14.5, 0, 14.5, 50)];
        icon.image = [UIImage imageNamed:@"duihao"];
        icon.contentMode = UIViewContentModeCenter;
        [bgView addSubview:icon];
        icon.hidden = YES;
        _selectedIcon = icon;
    }
    
    if (_isMyselfSelected) {
        _selectedIcon.hidden = NO;
    }else
    {
        _selectedIcon.hidden = YES;
    }
    
    [bgView addTaget:self action:@selector(clickToMe) tag:0];
    
    return headView;
}

#pragma - mark UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        
        
        if (alertView.tag == kTag_Appoint) {
            
            [self networkForMakeAppoint];//提交预约

        }else if (alertView.tag == KTag_EditUserInfo){
            
            //去编辑个人信息
            
            [self clickToEditUserInfoIsFull:YES];
        }
            
        if (alertView.tag == kTag_Delete) {
            
            [self deleteFamily:_deleteIndex];
        }
    }
}


#pragma - mark RefreshDelegate

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    [self getFamily];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    
}
//新加
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    UserInfo *aModel = _table.dataArray[indexPath.row];
    
    //大于0表示需要判断性别
    //男或者女时判断选择人的性别
    if (self.gender == Gender_Boy || self.gender == Gender_Girl) {
        
        Gender gender_select = [aModel.gender intValue];
        
        if (gender_select != self.gender) {
            
            NSString *title = self.gender == Gender_Girl ? @"本套餐仅适用于\"女\"性" : @"本套餐仅适用于\"男\"性";
            [LTools showMBProgressWithText:title addToView:self.view];
            return;
        }
    }

    if (_isEdit) {//在编辑
        NSLog(@"删除");
        _deleteIndex = (int)indexPath.row;
        NSString *text = [NSString stringWithFormat:@"是否删除\"%@\"\"%@\"?",aModel.appellation,aModel.family_user_name];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:text delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = kTag_Delete;
        [alert show];
    }else
    {
        NSString *uid = aModel.family_uid;
        
        if (_actionType == PEOPLEACTIONTYPE_NORMAL) {
            
            [self clickToUserInfo:aModel];

        }else if (_actionType == PEOPLEACTIONTYPE_SELECT_Single){
            
            if ([self enableSelectNewPeople]) {
                [_selectedArray addObject:uid];
                [_selectedUserArray addObject:aModel];//记录model
            }
            [tableView reloadData];
            
            //选择成功回调
            NSLog(@"选择体检人成功");
            
            [self selectPeople:aModel myself:NO];
            
        }else if (_actionType == PEOPLEACTIONTYPE_SELECT_APPOINT ||
                  _actionType == PEOPLEACTIONTYPE_NOPAYAPPOINT ||
                  _actionType == PEOPLEACTIONTYPE_SELECT_Mul){
            
            if ([_selectedArray containsObject:uid]) {
                [_selectedArray removeObject:uid];
                UserInfo *temp;
                for (UserInfo *user in _selectedUserArray) {
                    if ([user.family_uid integerValue] == [uid integerValue]) {
                        temp = user;
                    }
                }
                if (temp) {
                    [_selectedUserArray removeObject:temp];
                }
                
            }else
            {
                
                if ([self enableSelectNewPeople]) {
                    
                    [_selectedArray addObject:uid];
                    [_selectedUserArray addObject:aModel];
                    
                }else
                {
                    return;
                }
            }
            
            [tableView reloadData];
        }
    }
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    return 56.f;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView
{
    if (!_view_tableHeader) {
        _view_tableHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 56)];
        _view_tableHeader.backgroundColor = [UIColor whiteColor];
        //本人
        UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 35, _view_tableHeader.height) title:@"家人" font:16 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
        [_view_tableHeader addSubview:titleLable];
        
        NSString *name = [NSString stringWithFormat:@"%d位",(int)_table.dataArray.count];
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleLable.right + 60, 0, 200, _view_tableHeader.height) title:name font:15 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"313131"]];
        [_view_tableHeader addSubview:nameLabel];
        _numLabel = nameLabel;
        
        _arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _arrowBtn.frame = CGRectMake(DEVICE_WIDTH - 15 - 13, (67-7)/2.f, 13, 7);
        [_view_tableHeader addSubview:_arrowBtn];
        [_arrowBtn setImage:[UIImage imageNamed:@"personal_jiaren_jiantou_b"] forState:UIControlStateNormal];
        [_arrowBtn setImage:[UIImage imageNamed:@"personal_jiaren_jiantou_t"] forState:UIControlStateSelected];
        [_view_tableHeader addTaget:self action:@selector(clickToAction:) tag:0];
        
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, _view_tableHeader.height - 0.5, DEVICE_WIDTH, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [_view_tableHeader addSubview:line];
    }
    
    return _view_tableHeader;
}
- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView
{
    return 56.f;
}

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (!_isOpen) {
        return 0.f;
    }
    return _table.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"peopleManagerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 56)];
        bgView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:bgView];
        
        if (_actionType == PEOPLEACTIONTYPE_NORMAL) {
            
            UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15 - 7, (56-7-15)/2.f, 7, 14)];
            arrow.image = [UIImage imageNamed:@"personal_jiantou_r"];
            [bgView addSubview:arrow];
            arrow.tag = 104;
        }else
        {
            //图标 对号
            UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15 - 14.5, 0, 14.5, 50)];
            icon.image = [UIImage imageNamed:@"duihao"];
            icon.contentMode = UIViewContentModeCenter;
            [cell.contentView addSubview:icon];
            icon.tag = 103;
        }
        
        UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(15 * 2, 0, 100, bgView.height) title:nil font:16 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
        [bgView addSubview:titleLable];
        titleLable.tag = 100;
        
        NSString *name = nil;
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleLable.right, 0, DEVICE_WIDTH - titleLable.right - 10, bgView.height) title:name font:15 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"313131"]];
        [bgView addSubview:nameLabel];
        nameLabel.tag = 101;
        
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 56 - 0.5, DEVICE_WIDTH, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [cell.contentView addSubview:line];
        
        //删除按钮
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        deleteBtn.backgroundColor = [UIColor colorWithHexString:@"ed1f1f"];
        deleteBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        deleteBtn.frame = CGRectMake(DEVICE_WIDTH, 0, 70, 56);
        [bgView addSubview:deleteBtn];
        deleteBtn.tag = 102;
        deleteBtn.userInteractionEnabled = NO;

    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    UILabel *title = [cell.contentView viewWithTag:100];
    UILabel *nameLabel = [cell.contentView viewWithTag:101];
    UIButton *deleteBtn = (UIButton *)[cell.contentView viewWithTag:102];
    
    UIImageView *icon = [cell.contentView viewWithTag:103];
    UIImageView *arrow = [cell.contentView viewWithTag:104];
    
    [UIView animateWithDuration:0.3 animations:^{
        deleteBtn.left = _isEdit ? DEVICE_WIDTH - 70 : DEVICE_WIDTH;
        arrow.hidden = _isEdit;
        title.left = _isEdit ? 5 : 30;
        nameLabel.left = title.right;
    }];
    
    UserInfo *aModel = _table.dataArray[indexPath.row];
    title.text = aModel.appellation;
    
    NSString *name = @"";
    NSString *alia = @"";
    Gender gender = [aModel.gender intValue];
    if (gender != Gender_NO && gender != Gender_Other) {
        
        alia = [NSString stringWithFormat:@"(%@)",gender == Gender_Boy ? @"男" : @"女" ];
        name = [NSString stringWithFormat:@"%@%@",aModel.family_user_name,alia];
    }else
    {
        name = aModel.family_user_name;
    }
    [nameLabel setAttributedText:[LTools attributedString:name keyword:alia color:[UIColor orangeColor]]];
    
    NSString *uid = aModel.family_uid;
    if ([_selectedArray containsObject:uid]) {
        icon.hidden = NO;
    }else
    {
        icon.hidden = YES;
    }
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


@end
