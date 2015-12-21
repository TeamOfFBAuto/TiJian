//
//  ChooseHopitalController.m
//  TiJian
//
//  Created by lichaowei on 15/11/12.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "ChooseHopitalController.h"
#import "PeopleManageController.h"
#import "SSLunarDate.h"
#import "HospitalModel.h"
#import "NSDate+FSExtension.h"

typedef enum {
    STATETYPE_OPEN = 0,//打开
    STATETYPE_CLOSE //关闭
}STATETYPE; //日历类型

@interface ChooseHopitalController ()<UITableViewDataSource,RefreshDelegate>
{
    UIView *_calendar_bgView;
    RefreshTableView *_table;
    
    int _selectHospitalId;//选中得分院di
    NSString *_selectDate;//选中的时间
    NSString *_selectCenterName;//选中分院name
    
    NSString *_exam_center_id;//体检中心id
    NSString *_order_id;
    NSString *_company_id; //公司订单才有的
    NSString *_order_checkuper_id;//公司订单才有的
    int _noAppointNum;//未预约数
    BOOL _isCompanyAppoint;//是否是公司预约
    BOOL _isJustSelect;//是否仅为选择时间和分院
    
    CGFloat _lastOffsetY;
}

@property (strong, nonatomic) NSCalendar *currentCalendar;
@property(nonatomic,retain)UIButton *closeButton;
@property(nonatomic,retain)UIImageView *closeImage;
@property(nonatomic,retain)UIView *calendarView;//日历背景view
@property(nonatomic,retain)ResultView *nodataView;
@property(nonatomic,retain)NSDate *beginDate;//开始时间

@end

@implementation ChooseHopitalController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"选择时间、分院";
    self.rightString = @"确认";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
    
    _currentCalendar = [NSCalendar currentCalendar];

    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - _closeButton.bottom) style:UITableViewStylePlain];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _table.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    
    _table.tableHeaderView = self.calendarView;
    
    
    NSString *selectDate = [LTools timeDate:self.beginDate withFormat:@"YYYY-MM-dd"];
    [self networkForCenter:selectDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([_table respondsToSelector:@selector(setSeparatorInset:)]) {
        [_table setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_table respondsToSelector:@selector(setLayoutMargins:)]) {
        [_table setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(NSDate *)beginDate
{
    if (_beginDate) {
        return _beginDate;
    }
    _beginDate = [[NSDate date]fs_dateByAddingDays:1];
    return _beginDate;
}

#pragma mark - 视图创建

/**
 *  请求结果 为空、等特殊情况
 */
-(ResultView *)resultViewWithType:(PageResultType)type
{
    NSString *content;
    if (type == PageResultType_nodata){
        
        content = @"没有找到对应的可预约分院";
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

- (UIView *)calendarView
{
    if (_calendarView) {
        return _calendarView;
    }
    
    self.calendarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_HEIGHT, 300 + 27)];
    _calendarView.backgroundColor = [UIColor whiteColor];
    
    [self.calendarView addSubview:self.calendar];
    [self.calendarView addSubview:self.closeButton];
    
    return _calendarView;
}

- (UIButton *)closeButton
{
    if (_closeButton) {
        return _closeButton;
    }
    //关闭按钮
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.frame = CGRectMake(0, _calendar.bottom, DEVICE_WIDTH, 27);
    _closeButton.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
    [_closeButton addTarget:self action:@selector(clickToCloseClendar:) forControlEvents:UIControlEventTouchUpInside];
    
    //图标
    self.closeImage = [[UIImageView alloc]initWithFrame:_closeButton.bounds];
    _closeImage.image = [UIImage imageNamed:@"yuyue_jiantou_down"];
    _closeImage.contentMode = UIViewContentModeCenter;
    [_closeButton addSubview:_closeImage];
    
    return _closeButton;
}

-(FSCalendar *)calendar
{
    if (_calendar) {
        return _calendar;
    }
    self.calendar = [[FSCalendar alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 300)];
    _calendar.delegate = self;
    _calendar.dataSource = self;
    _calendar.backgroundColor = [UIColor whiteColor];
    _calendar.clipsToBounds = YES;
    [_calendar setScope:FSCalendarScopeWeek];
    [_calendar setCurrentPage:self.beginDate animated:YES];
    [_calendar selectDate:self.beginDate];
    
    FSCalendarAppearance *apprearance = _calendar.appearance;
    apprearance.todayColor = [UIColor redColor];
    apprearance.selectionColor = [UIColor colorWithHexString:@"f88326"];
    apprearance.headerTitleColor = [UIColor colorWithHexString:@"323232"];
    apprearance.weekdayTextColor = [UIColor colorWithHexString:@"999999"];
    return _calendar;
}

- (void)updateCalendarState
{
    [UIView animateWithDuration:0.3 animations:^{
        self.calendarView.height = self.closeButton.bottom;
        _table.tableHeaderView = self.calendarView;

    }];
}

#pragma mark - 网络请求

/**
 *  提交预约信息
 */
- (void)networkForMakeAppoint
{
//    company_id 公司id（若是公司买单的 则要传）
//    order_checkuper_id 预约id（若是公司买单的 则要传）
    
    int index = _selectHospitalId;
    if (index <= 0) {
        
        [LTools alertText:@"请选择体检分院" viewController:self];
        
        return;
    }
    
    _exam_center_id = NSStringFromInt(_selectHospitalId);
    
    NSString *authey = [LTools objectForKey:USER_AUTHOD];
    NSDictionary *params = @{@"authcode":authey,
                             @"order_id":_order_id,
                             @"product_id":_productId,
                             @"exam_center_id":_exam_center_id,
                             @"date":_selectDate,
                             @"company_id":_company_id ? : @"", //公司订单才有的
                             @"order_checkuper_id":_order_checkuper_id ? : @"", //公司订单才有的
                             };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self)weakSelf = self;
//    __weak typeof(_table)weakTable = _table;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:MAKE_APPOINT parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        [LTools showMBProgressWithText:@"恭喜您预约成功！" addToView:weakSelf.view];
        [weakSelf performSelector:@selector(appointSuccess) withObject:nil afterDelay:0.5];
        NSLog(@"预约成功 result");
        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

- (void)networkForCenter:(NSString *)date
{
//     套餐商品id、 省id、 城市id、 预约日期、longitude 经度（可不传）、latitude 纬度（可不传

    _selectDate = date;//记录选择的时间
    NSDictionary *params;
    /**
     *  仅选择时间分院,修改套餐,需要传参数 之前选择的分院id
     */
    if (_isJustSelect) {
        params = @{@"product_id":self.productId,
                   @"province_id":[GMAPI getCurrentProvinceId],
                   @"city_id":[GMAPI getCurrentCityId],
                   @"date":date,
                   @"page":NSStringFromInt(_table.pageNum),
                   @"per_page":@"50",
                   @"exam_center_id":_exam_center_id};
        
    }else
    {
        params = @{@"product_id":self.productId,
                   @"province_id":[GMAPI getCurrentProvinceId],
                   @"city_id":[GMAPI getCurrentCityId],
                   @"date":date,
                   @"page":NSStringFromInt(_table.pageNum),
                   @"per_page":@"50"};
    }
    
    NSString *api = GET_CENTER_PERCENT;
    
    __weak typeof(self)weakSelf = self;
//    __weak typeof(_table)weakTable = _table;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [weakSelf parseDataWithResult:result];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
//        [weakTable loadFail];
        
    }];
}


#pragma mark - 事件处理

- (void)appointSuccess
{
    //预约成功通知
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_APPOINT_SUCCESS object:nil];
//    AppointResultController *result = [[AppointResultController alloc]init];
//    [self.navigationController pushViewController:result animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  公司预约参数
 *
 *  @param orderId
 *  @param productId
 *  @param companyId          公司id
 *  @param order_checkuper_id 公司订单特有
 *  @param noAppointNum
 */
- (void)setCompanyAppointOrderId:(NSString *)orderId
                       productId:(NSString *)productId
                       companyId:(NSString *)companyId
              order_checkuper_id:(NSString *)order_checkuper_id
                    noAppointNum:(int)noAppointNum
{
    //提交预约参数
    _order_id = orderId;//订单id
    _productId = productId;//单品id
    //    _exam_center_id = examCenterId;
    _company_id = companyId;
    _order_checkuper_id = order_checkuper_id;
    _noAppointNum = noAppointNum;
    
    _isCompanyAppoint = YES;
}


/**
 *  仅选择时间和分院,不做其他操作
 *
 *  @param productId
 *  @param examCenterId 分院id
 */
- (void)setSelectParamWithProductId:(NSString *)productId
                       examCenterId:(NSString *)examCenterId
{
    _isJustSelect = YES;
    _productId = productId;
    _exam_center_id = examCenterId;
    _selectHospitalId = [examCenterId intValue];
}

/**
 *  仅选择时间和分院,不做其他操作
 *
 *  @param productId
 *  @param examCenterId 分院id
 */
- (void)setSelectParamWithProductId:(NSString *)productId
                       examCenterId:(NSString *)examCenterId
                     examCenterName:(NSString *)examCenterName
{
    _isJustSelect = YES;
    _productId = productId;
    _exam_center_id = examCenterId;
    _selectHospitalId = [examCenterId intValue];
    _selectCenterName = examCenterName;
}

- (void)parseDataWithResult:(NSDictionary *)result
{
    NSArray *temp = [HospitalModel modelsFromArray:result[@"center_list"]];
    
    [_table reloadData:temp pageSize:50 noDataView:[self resultViewWithType:PageResultType_nodata]];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

}

- (void)clickToCloseClendar:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        _closeImage.image = [UIImage imageNamed:@"yuyue_jiantou_up"];
    }else
    {
        _closeImage.image = [UIImage imageNamed:@"yuyue_jiantou_down"];
    }
    
    FSCalendarScope selectedScope = sender.selected ? FSCalendarScopeMonth : FSCalendarScopeWeek;

    [_calendar setScope:selectedScope animated:YES];
    
}

-(void)rightButtonTap:(UIButton *)sender
{
    //仅是选择时间和分院,不做其他操作
    if (_isJustSelect) {
        
        if (self.updateParamsBlock) {
            
            if (_selectCenterName.length > 0 && _selectDate.length > 0) {
                NSDictionary *params = @{@"date":_selectDate,
                                         @"centerName":_selectCenterName,
                                         @"centerId":NSStringFromInt(_selectHospitalId)};
                self.updateParamsBlock(params);
            }
            [self leftButtonTap:nil];
        }
        
        return;
    }
    
    
    int index = _selectHospitalId;
    if (index <= 0) {
        
        [LTools alertText:@"请选择体检分院" viewController:self];
        
        return;
    }
    
    //公司预约提交预约信息
    if (_isCompanyAppoint) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"是否确定预约体检" delegate:self cancelButtonTitle:@"稍等" otherButtonTitles:@"确定", nil];
        [alert show];
        
        return;
    }
    
    //确认 分院、时间
    
    //选择人 预约
    PeopleManageController *people = [[PeopleManageController alloc]init];
    people.actionType = PEOPLEACTIONTYPE_SELECT_APPOINT;
    [people setAppointOrderId:self.order_id productId:self.productId examCenterId:NSStringFromInt(_selectHospitalId) date:_selectDate noAppointNum:self.noAppointNum];
    
    people.lastViewController = self.lastViewController;
    people.gender = self.gender;
    [self.navigationController pushViewController:people animated:YES];
    
}

#pragma - mark UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        
        [self networkForMakeAppoint];//提交预约
    }
}

#pragma mark - FSCalendarDelegate

- (void)calendarCurrentScopeWillChange:(FSCalendar *)calendar animated:(BOOL)animated
{
    CGSize size = [calendar sizeThatFits:calendar.frame.size];
    

    _calendar.height = size.height;
    _closeButton.top = _calendar.bottom;
    
//    _table.top = _closeButton.bottom;
//    _table.height = DEVICE_HEIGHT - 64 - _closeButton.bottom;
    
    [self updateCalendarState];
    
    NSLog(@"size %f",size.height);
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date
{
    if ([date fs_isEqualToDateForDay:[NSDate date]]) {
        
        if ([date fs_isEqualToDateForDay:[NSDate date]]) {
            
            [LTools showMBProgressWithText:@"只能预约今天以后分院!" addToView:self.view];
        }
        
        return NO;
    }
    return YES;
}
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSString *selectDate = [LTools timeDate:date withFormat:@"YYYY-MM-dd"];
    NSLog(@"did select date %@",selectDate);
    
    _selectDate = selectDate;//important
    
    [_table refreshNewData];
}

#pragma mark - FSCalendarDataSource
- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date
{
   SSLunarDate * _lunarDate = [[SSLunarDate alloc] initWithDate:date calendar:_currentCalendar];
    return _lunarDate.dayString;
}

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    return [NSDate date];
}
//- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar;


#pragma - mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    HospitalModel *h_model = _table.dataArray[indexPath.row];
    
    _selectHospitalId = [h_model.exam_center_id intValue];
    _selectCenterName = h_model.center_name;
    
    [tableView reloadData];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    //按照作者最后的意思还要加上下面这一段
    
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        
        [cell setPreservesSuperviewLayoutMargins:NO];
        
    }
    
}

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _table.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    static NSString *identifier = @"PreViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 100 - 10, 0, 100, 50)];
        label.textColor = [UIColor colorWithHexString:@"323232"];
        label.font = [UIFont systemFontOfSize:13];
        label.textAlignment = NSTextAlignmentRight;
//        label.backgroundColor = [UIColor redColor];
        [cell.contentView addSubview:label];
        label.tag = 100;
        
        //图标 对号
        UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15 - 14.5, 0, 14.5, 50)];
        icon.image = [UIImage imageNamed:@"duihao"];
        icon.contentMode = UIViewContentModeCenter;
        [cell.contentView addSubview:icon];
        icon.tag = 101;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];

    cell.textLabel.textColor = [UIColor colorWithHexString:@"646464"];
    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"323232"];
    
    UILabel *label = [cell.contentView viewWithTag:100];
    UIImageView *icon = [cell.contentView viewWithTag:101];

    HospitalModel *h_model = _table.dataArray[indexPath.row];
    
    if (h_model) {
        NSString *brand = h_model.brand_name;
        NSString *name = h_model.center_name;
        NSString *text = [NSString stringWithFormat:@"%@  %@",brand ? : @"",name ? : @""];
        [cell.textLabel setAttributedText:[LTools attributedString:text keyword:name color:[UIColor colorWithHexString:@"323232"]]];
        
        NSString *numString = [NSString stringWithFormat:@"%d%%",[h_model.appoint_percent intValue]];
        NSString *d_text = [NSString stringWithFormat:@"已预约%@",numString];
        [label setAttributedText:[LTools attributedString:d_text keyword:numString color:[UIColor colorWithHexString:@"f88323"]]];
    }
    
    
    
    if ([h_model.exam_center_id intValue] == _selectHospitalId) {
        
        label.left = DEVICE_WIDTH - 100 - 10 - 35;
        icon.hidden = NO;
    }else
    {
        label.left = DEVICE_WIDTH - 100 - 10;
        icon.hidden = YES;
    }
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

#pragma mark - 代理

#pragma - mark RefreshDelegate <NSObject>

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    [self networkForCenter:_selectDate];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    [self networkForCenter:_selectDate];
}
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    HospitalModel *h_model = _table.dataArray[indexPath.row];
    _selectHospitalId = [h_model.exam_center_id intValue];
    _selectCenterName = h_model.center_name;
    [tableView reloadData];
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    return 50.f;
}

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (_lastOffsetY > offsetY) {
        
        if (self.closeButton.selected) {
            
            [self clickToCloseClendar:self.closeButton];

        }
    }
    _lastOffsetY = offsetY;
}

@end
