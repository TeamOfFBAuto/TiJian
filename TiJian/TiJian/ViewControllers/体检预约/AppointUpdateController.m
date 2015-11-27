//
//  AppointUpdateController.m
//  TiJian
//
//  Created by lichaowei on 15/11/17.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "AppointUpdateController.h"
#import "ChooseHopitalController.h"
#import "PeopleManageController.h"
#import "AppointModel.h"

@interface AppointUpdateController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL _isAppointAgain;//是否是再次预约
    AppointModel *_appointModel;
    UITableView *_table;
    NSArray *_titles;
    BOOL _isUpdated;//是否被更新过
    BOOL _isMyself;//是否是自己
    NSString *_updateFamilyUid;//更新的familyUid
}

@end

@implementation AppointUpdateController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.rightString = @"完成";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
    self.view.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  设置参数
 *
 *  @param aModel         预约详情model
 *  @param isAppointAgain 是否是重新预约
 */
- (void)setParamsWithModel:(AppointModel *)aModel
            isAppointAgain:(BOOL)isAppointAgain

{
    if (isAppointAgain) {
        self.myTitle = @"重新预约";
    }else{
        self.myTitle = @"预约修改";
    }
    _appointModel = aModel;
    
    [self prepareRefreshTableView];
}

#pragma mark - 视图创建

- (void)prepareRefreshTableView
{
    _titles = @[@"姓       名:",@"性       别:",@"年       龄:",@"身份证号:",@"手  机  号:"];

    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.backgroundColor = [UIColor clearColor];
}

#pragma mark - 网络请求
/**
 *  预约修改
 */
- (void)netWorkForUpdateAppoint
{
//    myself 1 表示本人
    NSString *authcode = [LTools cacheForKey:USER_AUTHOD];
    NSDictionary *params;
    
    if (_isMyself) {
        
        params = @{@"authcode":authcode,
                   @"appoint_id":_appointModel.appoint_id,
                   @"exam_center_id":_appointModel.exam_center_id,
                   @"date":[LTools timeString:_appointModel.appointment_exam_time withFormat:@"YYYY-MM-dd"],
                   @"myself":@"1"};
    }else
    {
        params = @{@"authcode":authcode,
                   @"appoint_id":_appointModel.appoint_id,
                   @"exam_center_id":_appointModel.exam_center_id,
                   @"date":[LTools timeString:_appointModel.appointment_exam_time withFormat:@"YYYY-MM-dd"],
                   @"family_uid":_updateFamilyUid ? _updateFamilyUid : @""};
    }
    
    NSString *api = UPDATE_APPOINT;
    
    __weak typeof(self)weakSelf = self;
    //    __weak typeof(RefreshTableView *)weakTable = _table;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_APPOINT_UPDATE_SUCCESS object:nil];
        [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

#pragma mark - 数据解析处理

#pragma mark - 事件处理

-(void)rightButtonTap:(UIButton *)sender
{
    
    if (_isUpdated) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"是否确定重新预约？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }else
    {
        [self leftButtonTap:nil];
    }
}

/**
 *  去选择体检人
 */
- (void)clickToSelectUserInfo
{
    NSLog(@"选择体检人");
    
    _isUpdated = YES;
    
    PeopleManageController *people = [[PeopleManageController alloc]init];
    people.actionType = PEOPLEACTIONTYPE_SELECT;
    people.noAppointNum = 1;
    [self.navigationController pushViewController:people animated:YES];
    
    __weak typeof(self)weakSelf = self;
    people.updateParamsBlock = ^(NSDictionary *params){
      
        UserInfo *user = params[@"result"];
        BOOL myself = [params[@"myself"]boolValue];
        [weakSelf updatePeople:user myself:myself];
    };
}

- (void)updatePeople:(UserInfo *)userInfo
              myself:(BOOL)myself
{
    _isMyself = myself;
    _updateFamilyUid = userInfo.family_uid;
    _appointModel.user_name = myself ? userInfo.real_name : userInfo.family_user_name;
    _appointModel.gender = userInfo.gender;
    _appointModel.age = userInfo.age;
    _appointModel.id_card = userInfo.id_card;
    _appointModel.mobile = userInfo.mobile;
    
    [_table reloadData];
}

/**
 *  去选择体检分院
 */
- (void)clickToTimeAndCenter
{
    NSLog(@"选择时间分院");
    
    _isUpdated = YES;
    
    ChooseHopitalController *choose = [[ChooseHopitalController alloc]init];
    [choose setSelectParamWithProductId:_appointModel.product_id examCenterId:_appointModel.exam_center_id];
    [self.navigationController pushViewController:choose animated:YES];
    
    __weak typeof(self)weakSelf = self;
    choose.updateParamsBlock = ^(NSDictionary *params){
        
        [weakSelf updateCenterWithParams:params];
    };
}

- (void)updateCenterWithParams:(NSDictionary *)params
{
    NSString *date = params[@"date"];
    NSString *centerName = params[@"centerName"];
    NSString *centerId = params[@"centerId"];
    
    _appointModel.center_name = centerName;
    _appointModel.exam_center_id = centerId;
    NSString *time = [LTools timeDatelineWithString:date format:@"YYYY-MM-dd"];
    _appointModel.appointment_exam_time = time;
    [_table reloadData];
}

#pragma mark - 代理

#pragma mark - UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        [self netWorkForUpdateAppoint];
    }
}

#pragma - mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        
        if ([_appointModel.company_id intValue] > 0) {
            
            if (indexPath.row == 0) {
                return 40.f;
            }
        }
        
        return 60.f;
    }
    
    return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50 + 5.f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 55)];
    view.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    UIView *brandView = [[UIView alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 50)];
    brandView.backgroundColor = [UIColor whiteColor];
    [view addSubview:brandView];
    //logo
    UIImageView *brandIcon = [[UIImageView alloc]initWithFrame:CGRectMake(17, 12.5, 12, 12)];
    brandIcon.contentMode = UIViewContentModeCenter;
    [brandView addSubview:brandIcon];
    brandIcon.centerY = brandView.height /2.f;
    
    //name
    UILabel *brandName = [[UILabel alloc]initWithFrame:CGRectMake(brandIcon.right + 10, 0, brandView.width - brandIcon.right - 10 - 15, 50) title:nil font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [brandView addSubview:brandName];
    
    if (section == 0) {
        brandIcon.image = [UIImage imageNamed:@"tijianren_duo"];
        brandName.text = @"体检人信息";
        
        //大于0 是公司套餐
        if ([_appointModel.company_id intValue] > 0) {
            [view addTaget:self action:@selector(clickToSelectUserInfo) tag:0];

        }
        
    }else if (section == 1){
        brandIcon.image = [UIImage imageNamed:@"fenyuan"];
        brandName.text = @"体检时间、分院";
        [view addTaget:self action:@selector(clickToTimeAndCenter) tag:0];

    }else if (section == 2){
        brandIcon.image = [UIImage imageNamed:@"gouwudai"];
        brandName.text = @"体检套餐";
    }
    
    //线
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, brandView.height - 0.5, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [brandView addSubview:line];
    
    if (section != 2 && [_appointModel.company_id intValue] == 0) {
        //箭头
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(view.width - 6 - 20, (50-12)/2.f, 6, 12)];
        arrow.image = [UIImage imageNamed:@"jiantou"];
        [brandView addSubview:arrow];
        
    }
    
    
    return view;
}

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section == 0) {
        return 5;
    }else if (section == 1){
        return 2;
    }else if (section == 2){
        
        if ([_appointModel.company_id intValue] == 0) {
            return 1;
        }
        
        return 2;//公司套餐
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"identify";
    static NSString *identifier2 = @"identify2";
    UITableViewCell *cell;
    if (indexPath.section == 2) {
        
        //公司
        if ([_appointModel.company_id intValue] > 0 && indexPath.row == 0) {
            
            if (indexPath.row == 0) {
                
                cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier2];
                }
                
            }
        }else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 64, 40)];
                [cell.contentView addSubview:imageView];
                imageView.tag = 100;
                CGFloat left = imageView.right + 20;
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(left, 0, DEVICE_WIDTH - left - 15, 60) title:nil font:14 align:NSTextAlignmentRight textColor:DEFAULT_TEXTCOLOR_TITLE];
                label.tag = 101;
                label.numberOfLines = 2;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                [cell.contentView addSubview:label];
            }
        }
    
    }else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier2];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14.f];
    cell.textLabel.textColor = DEFAULT_TEXTCOLOR_TITLE_THIRD;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.f];
    cell.detailTextLabel.textColor = DEFAULT_TEXTCOLOR_TITLE;
    if (indexPath.section == 0) {
        
        cell.textLabel.text = _titles[indexPath.row];
        NSString *detail = @"";
        if (indexPath.row == 0) {
            
            detail = _appointModel.user_name;
        }else if (indexPath.row == 1){
            
            detail = [_appointModel.gender intValue] == 1 ? @"男" : @"女";
        }else if (indexPath.row == 2){
            
            detail = _appointModel.age;
        }else if (indexPath.row == 3){
            
            detail = _appointModel.id_card;
        }else if (indexPath.row == 4){
            
            detail = _appointModel.mobile;
            
        }
        cell.detailTextLabel.text = detail;
        
    }else if (indexPath.section == 1){
        
        cell.textLabel.text = indexPath.row == 0 ? @"时       间:" : @"分       院:";
        
        NSString *detail = @"";
        if (indexPath.row == 0) {
            
            detail = [LTools timeString:_appointModel.appointment_exam_time withFormat:@"YYYY.MM.dd"];
        }else if (indexPath.row == 1){
            
            detail = _appointModel.center_name;
        }
        cell.detailTextLabel.text = detail;
        
    }else if (indexPath.section == 2){
        
        //公司
        if ([_appointModel.company_id intValue] > 0 && indexPath.row == 0) {
            
            cell.textLabel.text = @"公司名称:";
            cell.detailTextLabel.text = _appointModel.company_name;
        }else
        {
            UIImageView *imageView = [cell.contentView viewWithTag:100];
            [imageView sd_setImageWithURL:[NSURL URLWithString:_appointModel.cover_pic] placeholderImage:DEFAULT_HEADIMAGE];
            
            UILabel *label = [cell.contentView viewWithTag:101];
            label.text = _appointModel.setmeal_name;

        }
        
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


@end
