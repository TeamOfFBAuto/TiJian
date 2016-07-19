//
//  AppointDirectController.m
//  TiJian
//
//  Created by lichaowei on 16/7/18.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "AppointDirectController.h"
#import "PersonalCustomViewController.h"//个性化定制
#import "PhysicalTestResultController.h"//测试结果
#import "ChooseHopitalController.h"//选择分院和时间
#import "AppointDetailController.h"//预约详情
#import "GStoreHomeViewController.h"//商城
#import "GoneClassListViewController.h"
#import "AppointProgressDetailController.h"//已体检预约进度
#import "GoHealthProductDetailController.h" //go健康详情页或者服务详情页
#import "HospitalDetailViewController.h"//分院详情
#import "LocationChooseViewController.h"//选择位置

#import "ProductModel.h"
#import "AppointmentCell.h"
#import "AppointModel.h"
#import "HospitalModel.h"
#import "NewCenterCell.h"

@interface AppointDirectController ()<LocationChooseDelegate>
{
    NSArray *_company;
    NSArray *_personal;
    NSString *_companyName;//公司名字
    UIButton *_locationButton;//位置btn
}

@end

@implementation AppointDirectController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"体检预约";
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForAppointSuccess) name:NOTIFICATION_APPOINT_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForAppointSuccess) name:NOTIFICATION_APPOINT_CANCEL_SUCCESS object:nil];
    
    [self.tableView showRefreshHeader:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 通知处理

/**
 *  预约成功更新
 */
- (void)notificationForAppointSuccess
{
    [self.tableView showRefreshHeader:YES];
}

#pragma mark - 视图创建


#pragma mark - 网络请求

- (void)netWorkForListWithTable:(RefreshTableView *)table
{
    NSDictionary *params;
    NSString *api;
    
    NSString *authkey = [UserInfo getAuthkey];
    
    api = GET_NO_APPOINTS;
    params = @{@"authcode":authkey,
                   @"level":@"2",
               @"num":@"3"};
    
    __weak typeof(self)weakSelf = self;
    __weak typeof(_tableView)weakTable = self.tableView;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [weakSelf parseDataWithResult:result];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [weakTable loadFail];
        
    }];
}

/**
 *
 * 获取分院列表 带套餐
 */
- (void)netWorkForCenterList
{
//WithLong:(NSString *)lon
//lat:(NSString *)lat
    NSString *lon = [UserInfo getLontitude];
    NSString *lat = [UserInfo getLatitude];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetString:[GMAPI getCurrentProvinceId] forKey:@"province_id"];
    [params safeSetString:[GMAPI getCurrentCityId] forKey:@"city_id"];
//    [params safeSetString:self.brand_id forKey:@"brand_id"];//品牌
    [params safeSetString:lon forKey:@"longitude"];
    [params safeSetString:lat forKey:@"latitude"];
    [params safeSetInt:_tableView.pageNum forKey:@"page"];
    [params safeSetInt:10 forKey:@"per_page"];
    [params safeSetInt:2 forKey:@"num"];//数字代表几个套餐

    NSString *api = Get_hospital_list;
    
//    __weak typeof(self)weakSelf = self;
    __weak typeof(_tableView)weakTable = _tableView;
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        
        NSArray *temp = [HospitalModel modelsFromArray:result[@"list"]];
        [weakTable reloadData:temp pageSize:10 noDataView:[self resultViewWithType:PageResultType_nodata title:nil msg:@"没有找到附近的分院!" btnTitle:nil selector:@selector(refreshData)]];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [weakTable reloadData:nil pageSize:10 noDataView:[self resultViewWithType:PageResultType_nodata title:nil msg:@"没有找到附近的分院!" btnTitle:nil selector:@selector(refreshData)]];
        
    }];
}

#pragma mark - 数据解析处理

- (void)parseDataWithResult:(NSDictionary *)result
{
    NSDictionary *setmeal_list = result[@"setmeal_list"];
        
    if (![setmeal_list isKindOfClass:[NSDictionary class]]) {
        
        [self.tableView finishReloadingData];
        return;
    }
    
    _company = [ProductModel modelsFromArray:setmeal_list[@"company"]];
    _personal = [ProductModel modelsFromArray:setmeal_list[@"personal"]];
    
    if (_company.count == 0 && _personal.count == 0) {
        
        //没有待预约
        
    }
    [self.tableView finishReloadingData];
}

#pragma mark - 事件处理

- (void)refreshData
{
    [_tableView showRefreshHeader:YES];
}

/**
 *  预约go健康
 *
 *  @param aModel
 */
- (void)appointGoHealthWithProductId:(NSString *)p_id
                         productName:(NSString *)p_name
                             orderId:(NSString *)o_id
{
    NSString *product_id = p_id;
    NSString *product_name = p_name;
    NSString *orderId = o_id;
    
    GoHealthAppointViewController *goHealthAppoint = [[GoHealthAppointViewController alloc]init];
    goHealthAppoint.orderId = orderId;
    goHealthAppoint.productId = product_id;
    goHealthAppoint.productName = product_name;
    [self.navigationController pushViewController:goHealthAppoint animated:YES];
}

- (void)clickToCustomization:(PropertyButton *)sender
{
    //友盟统计
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic safeSetValue:@"体检预约页" forKey:@"fromPage"];
    [[MiddleTools shareInstance]umengEvent:@"Customization" attributes:dic number:[NSNumber numberWithInt:1]];
    
    ProductModel *aModel = [sender isKindOfClass:[PropertyButton class]] ? sender.aModel : nil;
    
    //先判断是否个性化定制过
    BOOL isOver = [UserInfo getCustomState];
    if (isOver) {
        //已经个性化定制过
        PhysicalTestResultController *physical = [[PhysicalTestResultController alloc]init];
        physical.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:physical animated:YES];
    }else
    {
        PersonalCustomViewController *custom = [[PersonalCustomViewController alloc]init];
        custom.vouchers_id = aModel.coupon_id;
        custom.lastViewController = self;
        [self.navigationController pushViewController:custom animated:YES];
    }
}

/**
 *  使用代金券购买
 */
- (void)clickToBugUseVoucher:(PropertyButton *)sender
{
    //    checkuper_info" =                 {
    //    age = 28;
    //    gender = 1;
    //    "id_card" = 371311199999999999;
    //    mobile = 18612389982;
    //    "order_checkuper_id" = 0;
    //    "user_name" = "\U674e\U671d\U4f1f";
    
    ProductModel *aModel = sender.aModel;
    UserInfo *user;
    NSDictionary *checkuper_info = aModel.checkuper_info;
    if ([checkuper_info isKindOfClass:[NSDictionary class]]) {
        
        NSString *idcard = [checkuper_info objectForKey:@"id_card"];
        NSString *name = checkuper_info[@"family_user_name"];
        if (idcard && name) {
            user = [[UserInfo alloc]init];
            user.id_card = idcard;
            user.appellation = @"本人";
            user.family_uid = @"0";
            user.family_user_name = name;
            user.gender = NSStringFromInt([checkuper_info[@"gender"] intValue]);
            user.mobile = checkuper_info[@"mobile"];
        }
    }
    
    GoneClassListViewController *cc = [[GoneClassListViewController alloc]init];
    cc.haveChooseGender = YES;
    cc.className = @"使用代金券";
    cc.vouchers_id = aModel.coupon_id;//代金券
    if (user) {
        cc.user_voucher = user;
    }
    cc.uc_id = aModel.uc_id;
    cc.brandId = aModel.brand_id;
    cc.brandName = aModel.brand_name;
    [self.navigationController pushViewController:cc animated:YES];
}

//跳转到定位区域选择vc
-(void)pushToChooseLocation
{
    LocationChooseViewController *cc = [[LocationChooseViewController alloc]init];
    cc.delegate = self;
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
}


#pragma mark - LocationChooseDelegate

-(void)afterChooseCity:(NSString *)theCity province:(NSString *)theProvince
{    
    [_locationButton setTitle:theCity forState:UIControlStateNormal];
    
    NSString *pStr = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:theProvince]];
    NSString *cStr = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:theCity]];
    
    if ([pStr isEqualToString:cStr]) {
        cStr = @"0";
    }
    
    NSDictionary *dic = @{
                          @"province":pStr,
                          @"city":cStr
                          };
    [GMAPI cache:dic ForKey:USERLocation];
    
    //请求分院列表
    [self netWorkForCenterList];
}

#pragma - mark RefreshDelegate <NSObject>

- (void)loadNewDataForTableView:(RefreshTableView *)tableView
{
    [self netWorkForListWithTable:tableView];
    [self netWorkForCenterList];
}
- (void)loadMoreDataForTableView:(RefreshTableView *)tableView
{
    [self netWorkForCenterList];
}
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(RefreshTableView *)tableView
{
    if (indexPath.section == 2) {
        
        HospitalModel *aModel = tableView.dataArray[indexPath.row];
        HospitalDetailViewController *hospital = [[HospitalDetailViewController alloc]init];
        hospital.centerId = aModel.exam_center_id;
        [self.navigationController pushViewController:hospital animated:YES];
        
        return;
    }
    
    //未预约
        ProductModel *aModel;
        int index_row = (int)indexPath.row;
        if (indexPath.section == 0) {
            if (index_row < _company.count) {
                aModel = _company[index_row];
            }
        }else if (indexPath.section == 1){
            if (index_row < _personal.count) {
                aModel = _personal[index_row];
            }
        }
        
        int type = [aModel.type intValue];//1 公司购买套餐 2 公司代金券 3 普通套餐
        int c_type = [aModel.c_type intValue];//c_type=1 1为海马医生预约 2为go健康预约
        
        if ([aModel isKindOfClass:[ProductModel class]] &&
            type == 2) { //代金券
            return;
        }
        
        //公司、个人套餐 预约操作
        if (indexPath.section == 0 ||
            indexPath.section == 1) {
            
            if (c_type == 2) { //go健康
                
                int no_appointed_num = [aModel.no_appointed_num intValue];
                if (no_appointed_num > 0) {
                    [self appointGoHealthWithProductId:aModel.product_id productName:aModel.product_name orderId:aModel.order_id];
                }else
                {
                    [LTools showMBProgressWithText:@"此套餐已预约完成!" addToView:self.view];
                }
            }else
            {
                ChooseHopitalController *choose = [[ChooseHopitalController alloc]init];
                choose.gender = [aModel.gender intValue];
                //公司
                if (type == 1) {
                    
                    NSString *order_checkuper_id = aModel.checkuper_info[@"order_checkuper_id"];
                    NSString *companyId = aModel.company_info[@"company_id"];
                    
                    [choose companyAppointWithOrderId:aModel.order_id
                                            productId:aModel.product_id
                                            companyId:companyId order_checkuper_id:order_checkuper_id
                                         noAppointNum:[aModel.no_appointed_num intValue]
                                               gender:[aModel.gender intValue]];
                }else
                {
                    [choose appointWithProductId:aModel.product_id
                                         orderId:aModel.order_id
                                    noAppointNum:[aModel.no_appointed_num intValue]];
                    choose.lastViewController = self;//需要选择体检人的时候需要传
                }
                
                [self.navigationController pushViewController:choose animated:YES];
            }
            
        }
}

- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    if (indexPath.section == 2)
    {
        return 112.f;
    }
        
    ProductModel *aModel;
    if (indexPath.section == 0) {
        if (indexPath.row < _company.count) {
            aModel = _company[indexPath.row];
        }
        
    }else
    {
        if (indexPath.row < _personal.count) {
            aModel = _personal[indexPath.row];
        }
    }
    
    return [AppointmentCell heightForCellWithType:[aModel.type intValue]];
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView
{
    UIView *head = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40.f)];
    head.backgroundColor = [UIColor whiteColor];
    
    //line
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [head addSubview:line];
    
    if (_companyName== nil) {
        _companyName = @"公司购买套餐";
    }
    
    NSString *title = @"套餐";
    if (section == 0) {
        title = _companyName;
    }else if (section == 1){
        title = @"个人购买套餐";
    }else if (section == 2){
        title = @"附近体检分院";
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0.5, DEVICE_WIDTH - 30, 39) title:title font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE];
    [head addSubview:label];
    
    if (section == 2) {
        CGFloat width = 100.f;
        
        UIButton *chatBtn = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - width - 12, 0.5, width, 39) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil target:self action:nil];
        [head addSubview:chatBtn];
        [chatBtn setTitleColor:DEFAULT_TEXTCOLOR_TITLE forState:UIControlStateNormal];
        [chatBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        chatBtn.backgroundColor = [UIColor clearColor];
        [chatBtn setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
        [chatBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        NSString *cityName = [GMAPI getCurrentCityName];
        [chatBtn setTitle:cityName forState:UIControlStateNormal];
        [chatBtn addTarget:self action:@selector(pushToChooseLocation) forControlEvents:UIControlEventTouchUpInside];
        
        _locationButton = chatBtn;
    }
    
    //line
    line = [[UIImageView alloc]initWithFrame:CGRectMake(0, label.bottom, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [head addSubview:line];
    
    return head;
}
- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView
{
    if (section == 0) {
        
        if (_company.count == 0) {
            return 0.f;
        }else
        {
            return 40.f;
        }
    }
    if (section == 1) {
        if (_personal.count == 0) {
            return 0.f;
        }else
        {
            return 40.f;
        }
    }
    
    if (_tableView.isHaveLoaded == NO) {
        return 0.f;
    }
    return 40.f;
}

-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(RefreshTableView *)tableView
{
    
    if (section == 0) {
        
        if (_company.count == 0) {
            return 0.f;
        }else
        {
            return 5.f;
        }
    }
    if (section == 1) {
        if (_personal.count == 0) {
            return 0.f;
        }else
        {
            return 5.f;
        }
    }
    return 0.f;
}
-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(RefreshTableView *)tableView
{
    if (section == 0 || section == 1)
    {
        UIView *head = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40.f)];
        head.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
        return head;
    }

    return nil;
}

#pragma - mark UITableViewDataSource

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section == 0) {
        return _company.count;
    }else if (section == 1){
        return _personal.count;
    }
    return tableView.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    //未预约 以及 （全部里面第一部分公司套餐、第二部分个人套餐）
    if (indexPath.section == 0 || indexPath.section == 1)
    {
        AppointmentCell *cell = nil;
        ProductModel *aModel = nil;
        if (indexPath.section == 0) {
            if (indexPath.row < _company.count) {
                aModel = _company[indexPath.row];
            }
        }else
        {
            if (indexPath.row < _personal.count) {
                
                aModel = _personal[indexPath.row];
            }
        }
        if ([aModel.type intValue] == 2) { //代金券
            
            static NSString *identifier = @"AppointmentCell2";
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[AppointmentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier type:2];
            }
            
            cell.buyButton.aModel = aModel;
            [cell.buyButton addTarget:self action:@selector(clickToBugUseVoucher:) forControlEvents:UIControlEventTouchUpInside];
            cell.customButton.aModel = aModel;
            [cell.customButton addTarget:self action:@selector(clickToCustomization:) forControlEvents:UIControlEventTouchUpInside];
            
        }else
        {
            static NSString *identifier = @"AppointmentCell1";
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[AppointmentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier type:1];
            }
        }
        
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell setCellWithModel:aModel];
        
        return cell;
    }
    
    static NSString *identifier = @"NewCenterCell";
    NewCenterCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = (NewCenterCell *)[LTools cellForIdentify:identifier cellName:identifier forTable:tableView];
        
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 112 - 0.5, DEVICE_WIDTH, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [cell.contentView addSubview:line];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setCenterModel:_tableView.dataArray[indexPath.row]];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(RefreshTableView *)tableView
{
    return 3;
}

@end
