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
#import "ConfirmOrderViewController.h"

typedef enum {
    STATETYPE_OPEN = 0,//打开
    STATETYPE_CLOSE //关闭
}STATETYPE; //日历类型

#define kTag_appointSuccess 200 //预约成功
#define kTag_appoint 201 //是否确定预约体检

@interface ChooseHopitalController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIView *_calendar_bgView;
    UITableView *_table;
    
    int _selectHospitalId;//选中得分院di
    NSString *_selectDate;//选中的时间
    NSString *_selectCenterName;//选中分院name
    
    NSString *_exam_center_id;//体检中心id
    NSString *_order_id;
    NSString *_company_id; //公司订单才有的
    NSString *_order_checkuper_id;//公司订单才有的
    NSString *_voucherId;//代金卷id
    id _userInfo;//代金卷绑定的体检人
    int _noAppointNum;//未预约数
    BOOL _isCompanyAppoint;//是否是公司预约
    BOOL _nopayAppoint;//不支付直接预约
    NSArray *_selectedHospitalArray;//已经选择过分院model,并包含对应人员
    
    CGFloat _lastOffsetY;
    
    NSArray *_dataArray;//数据源
}

@property (strong, nonatomic) NSCalendar *currentCalendar;
@property(nonatomic,retain)UIButton *closeButton;
@property(nonatomic,retain)UIImageView *closeImage;
@property(nonatomic,retain)UIView *calendarView;//日历背景view
@property(nonatomic,retain)ResultView *nodataView;
@property(nonatomic,retain)NSDate *beginDate;//开始时间

@end

@implementation ChooseHopitalController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:NSStringFromClass([self class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"选择时间、分院";
    self.rightString = @"确认";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack
                        WithRightButtonType:MyViewControllerRightbuttonTypeText];
    
    _currentCalendar = [NSCalendar currentCalendar];

    //日历
    [self.view addSubview:self.calendarView];
    
    //列表
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, self.calendarView.bottom, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - _calendarView.bottom) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    
    NSString *selectDate = [LTools timeDate:self.beginDate withFormat:@"yyyy-MM-dd"];
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
    
    self.calendarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_HEIGHT, 108 + 27)];
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
    
    //line
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, _closeButton.height - 0.5, _closeButton.width, 0.5)];
    line.backgroundColor = [UIColor whiteColor];
    [_closeButton addSubview:line];
    
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
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetValue:authey forKey:@"authcode"];
    [params safeSetValue:_order_id forKey:@"order_id"];
    [params safeSetValue:_productId forKey:@"product_id"];
    [params safeSetValue:_exam_center_id forKey:@"exam_center_id"];
    [params safeSetValue:_selectDate forKey:@"date"];
    [params safeSetValue:_company_id forKey:@"company_id"];
    [params safeSetValue:_order_checkuper_id forKey:@"order_checkuper_id"];
    
        __weak typeof(self)weakSelf = self;
//    __weak typeof(_table)weakTable = _table;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:MAKE_APPOINT parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
                
        [weakSelf appointSuccessWithResult:result];
        
    } failBlock:^(NSDictionary *result) {
        
        int erroCode = [result[RESULT_CODE]intValue];
        if (erroCode < 2000) {
            [LTools showMBProgressWithText:Alert_ServerErroInfo_Inner addToView:weakSelf.view];
        }
    }];
}

- (void)networkForCenter:(NSString *)date
{
//     套餐商品id、 省id、 城市id、 预约日期、longitude 经度（可不传）、latitude 纬度（可不传

    _selectDate = date;//记录选择的时间
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    /**
     *  仅选择时间分院,修改套餐,需要传参数 之前选择的分院id
     */
    NSString *longtitude = [UserInfo getLontitude];
    NSString *latitude = [UserInfo getLatitude];
    
    [params safeSetString:self.productId forKey:@"product_id"];
    [params safeSetString:[GMAPI getCurrentProvinceId] forKey:@"province_id"];
    [params safeSetString:[GMAPI getCurrentCityId] forKey:@"city_id"];
    [params safeSetString:date forKey:@"date"];
    [params safeSetString:_exam_center_id forKey:@"exam_center_id"];
    [params safeSetString:longtitude forKey:@"longitude"];
    [params safeSetString:latitude forKey:@"latitude"];

    NSString *api = GET_CENTER_PERCENT;
    __weak typeof(self)weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        DDLOG(@"success result %@",result);
        [weakSelf parseDataWithResult:result];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
    }];
}

#pragma mark - 参数传递

/**
 *  公司预约参数
 *
 *  @param orderId
 *  @param productId
 *  @param companyId          公司id
 *  @param order_checkuper_id 公司订单特有
 *  @param gender 套餐对应性别
 *  @param noAppointNum
 */
- (void)companyAppointWithOrderId:(NSString *)orderId
                        productId:(NSString *)productId
                        companyId:(NSString *)companyId
               order_checkuper_id:(NSString *)order_checkuper_id
                     noAppointNum:(int)noAppointNum
                           gender:(Gender)gender
{
    _chooseType = ChooseType_appoint;//选择时间、分院之后进行预约
    //提交预约参数
    _order_id = orderId;//订单id
    _productId = productId;//单品id
    _company_id = companyId;
    _order_checkuper_id = order_checkuper_id;
    _noAppointNum = noAppointNum;
    _gender = gender;
    _isCompanyAppoint = YES;
}

/**
 *  代金卷直接预约
 *
 *  @param voucherId    代金卷id
 *  @param userInfo    代金卷绑定体检人
 *  @param productModel
 */
- (void)appointWithVoucherId:(NSString *)voucherId
                   userInfo:(id)userInfo
                        productModel:(ProductModel *)productModel
{
    _chooseType = ChooseType_centerAndConfirmOrder;//选择时间、分院之后进行预约
    //提交预约参数
    _voucherId = voucherId;
    _productId = productModel.product_id;//单品id
    self.productModel = productModel;
    _gender = [productModel.gender_id intValue];
    _userInfo = userInfo;
}


/**
 *  普通预约 选择时间、分院直接预约
 */
- (void)appointWithProductId:(NSString *)productId
                     orderId:(NSString *)orderid
                noAppointNum:(int)noAppointNum
{
    _chooseType = ChooseType_appoint;//直接预约
    _productId = productId;
    _order_id = orderid;
    _noAppointNum = noAppointNum;
}

/**
 *  直接预约,未支付
 *
 *  @param productId
 *  @param gender       套餐适用性别
 *  @param noAppointNum 剩余可预约数
 */
- (void)apppointNoPayWithProductModel:(ProductModel *)productModel
                               gender:(Gender)gender
                         noAppointNum:(int)noAppointNum
{
    _chooseType = ChooseType_nopayAppoint;
    _productId = productModel.product_id;
    self.productModel = productModel;
    _gender = gender;
    _noAppointNum = noAppointNum;
    _nopayAppoint = YES;
}

/**
 *  仅选择时间和分院,不做其他操作
 *
 *  @param productId
 *  @param examCenterId 分院id
 */
- (void)selectCenterWithProductId:(NSString *)productId
                     examCenterId:(NSString *)examCenterId
                   examCenterName:(NSString *)examCenterName
                      updateBlock:(UpdateParamsBlock)updateBlock
{
    _chooseType = ChooseType_center;//仅选择时间和分院,不预约
    self.updateParamsBlock = updateBlock;
    _productId = productId;
    _exam_center_id = examCenterId;
    _selectHospitalId = [examCenterId intValue];
    _selectCenterName = examCenterName;
}

/**
 *  仅选择时间和分院,不做其他操作
 *
 *  @param productId
 *  @param examCenterId 分院id
 */
- (void)selectCenterUserInfo:(UserInfo *)userInfo
                productModel:(ProductModel *)productModel
                updateBlock:(UpdateParamsBlock)updateBlock
{
    _chooseType = ChooseType_center;//仅选择时间和分院,不预约
    self.updateParamsBlock = updateBlock;
    _productId = productModel.product_id;
    _userInfo = userInfo;
    self.productModel = productModel;
}

/**
 *  选择时间、分院以及人
 *
 *  @param productId
 *  @param gender       套餐对应性别
 *  @param noAppointNum 可预约个数
 *  @param updateBlcok
 */
- (void)selectCenterAndPeopleWithProductId:(NSString *)productId
                                    gender:(Gender)gender
                              noAppointNum:(int)noAppointNum
                               updateBlock:(UpdateParamsBlock)updateBlcok
{
    self.updateParamsBlock = updateBlcok;
    _productId = productId;
    _gender = gender;
    _noAppointNum = noAppointNum;
    _chooseType = ChooseType_centerAndPeople;
}

/**
 *  选择时间、分院以及人(可选择传入已选择分院)
 * 
 *  @parsm hospitalArray 分院数组,包含分院对应的体检人
 *  @param productId
 *  @param gender       套餐对应性别
 *  @param noAppointNum 可预约个数
 *  @param updateBlcok
 */
- (void)selectCenterAndPeopleWithHospitalArray:(NSArray *)hospitalArray
                                     productId:(NSString *)productId
                                        gender:(Gender)gender
                                  noAppointNum:(int)noAppointNum
                                   updateBlock:(UpdateParamsBlock)updateBlcok
{
    self.updateParamsBlock = updateBlcok;
    _productId = productId;
    _gender = gender;
    _noAppointNum = noAppointNum;
    _chooseType = ChooseType_centerAndPeople;
    _selectedHospitalArray = hospitalArray;
}

#pragma mark - 事件处理

/**
 *  预约成功
 *
 *  @param result
 */
- (void)appointSuccessWithResult:(NSDictionary *)result
{
    //预约成功通知
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_APPOINT_SUCCESS object:nil];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:Alert_AppointSucess delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alert.tag = kTag_appointSuccess;
    [alert show];
}

- (void)parseDataWithResult:(NSDictionary *)result
{
    NSArray *temp = [HospitalModel modelsFromArray:result[@"center_list"]];
    _dataArray = [NSArray arrayWithArray:temp];
    UIView *view = [self resultViewWithType:PageResultType_nodata];
    if (temp.count == 0) {
        [_table addSubview:view];
        view.center = CGPointMake(_table.width/2.f, _table.height/2.f);
    }else
    {
        [view removeFromSuperview];
    }
    
    [_table reloadData];
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
    
    NSDate *currentDate = [NSDate fs_dateFromString:_selectDate format:@"yyyy-MM-dd"];
    [_calendar setCurrentPage:currentDate animated:YES];
}

-(void)rightButtonTap:(UIButton *)sender
{
    
    int index = _selectHospitalId;
    if (index <= 0) {
        
        [LTools alertText:@"请选择体检分院" viewController:self];
        return;
    }
    
    _exam_center_id = NSStringFromInt(_selectHospitalId);
    //仅是选择时间和分院,不做其他操作
    if (_chooseType == ChooseType_center) {
        
        if (self.updateParamsBlock) {
            
            if (_selectCenterName.length > 0 && _selectDate.length > 0) {
                
                HospitalModel *aModel = [[HospitalModel alloc]init];
                aModel.exam_center_id = NSStringFromInt(_selectHospitalId);
                aModel.center_name = _selectCenterName;
                aModel.date = _selectDate;
                
                NSMutableDictionary *temp = [NSMutableDictionary dictionary];
                [temp safeSetString:_selectDate forKey:@"date"];
                [temp safeSetString:_selectCenterName forKey:@"centerName"];
                [temp safeSetValue:NSStringFromInt(_selectHospitalId) forKey:@"centerId"];
                [temp safeSetValue:aModel forKey:@"hospital"];
                
                if (_userInfo) {
                    
                    aModel.usersArray = [NSMutableArray arrayWithObject:_userInfo];
                    self.productModel.hospitalArray = [NSMutableArray arrayWithObject:aModel];
                    [temp safeSetValue:self.productModel forKey:@"productModel"];

                }
                
                self.updateParamsBlock(temp);
            }
            [self leftButtonTap:nil];
        }
        
        return;
    }
    
    //选择完分院跳转至确认订单
    if (_chooseType == ChooseType_centerAndConfirmOrder) {
        
        HospitalModel *aModel = [[HospitalModel alloc]init];
        aModel.exam_center_id = NSStringFromInt(_selectHospitalId);
        aModel.center_name = _selectCenterName;
        aModel.date = _selectDate;
        aModel.usersArray = [NSMutableArray arrayWithObject:_userInfo];

        
        ConfirmOrderViewController *cc = [[ConfirmOrderViewController alloc]init];
        cc.lastViewController = self;
        cc.voucherId = _voucherId;
        self.productModel.product_num = @"1";
        self.productModel.current_price = _productModel.setmeal_price;
        self.productModel.product_name = _productModel.setmeal_name;
        self.productModel.hospitalArray = [NSMutableArray arrayWithObject:aModel];//分院
        cc.dataArray = [NSArray arrayWithObject:self.productModel];
        [self.navigationController pushViewController:cc animated:YES];
        
        return;
    }
    
    
    //公司预约提交预约信息
    if (_isCompanyAppoint) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"是否确定预约体检" delegate:self cancelButtonTitle:@"稍等" otherButtonTitles:@"确定", nil];
        alert.tag = kTag_appoint;
        [alert show];
        
        return;
    }
    
//    ChooseType_appoint = 0,//选择时间、分院之后进行预约
//    ChooseType_center,//仅选择时间和分院,不预约
//    ChooseType_centerAndPeople,//选择时间分院和人，不预约
//    ChooseType_nopayAppoint // 未支付预约,跳转至确认订单
    
    //确认 分院、时间
    
    //选择人 预约
    PeopleManageController *people = [[PeopleManageController alloc]init];
    
    [people setAppointOrderId:self.order_id productId:self.productId examCenterId:NSStringFromInt(_selectHospitalId) date:_selectDate noAppointNum:self.noAppointNum];
    
    if (_chooseType == ChooseType_appoint)
    {
        people.actionType = PEOPLEACTIONTYPE_SELECT_APPOINT;//选择并预约
    }
    else if (_chooseType == ChooseType_nopayAppoint)
    {
        people.actionType = PEOPLEACTIONTYPE_NOPAYAPPOINT;//未支付预约
        [people selectMulPeopleWithExamCenterId:_exam_center_id examCenterName:_selectCenterName examDate:_selectDate noAppointNum:_noAppointNum updateBlock:nil];
    }
    else if (_chooseType == ChooseType_centerAndPeople)
    {
        people.actionType = PEOPLEACTIONTYPE_SELECT_Mul;//仅选择人
        
        [people selectMulPeopleWithHospitalArray:_selectedHospitalArray examCenterId:_exam_center_id examCenterName:_selectCenterName examDate:_selectDate noAppointNum:_noAppointNum updateBlock:self.updateParamsBlock];
    }
    
    people.lastViewController = self.lastViewController;
    people.gender = self.gender;
    people.productModel = self.productModel;
    [self.navigationController pushViewController:people animated:YES];
    
}

#pragma - mark UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        
        if (alertView.tag == kTag_appoint) {
            [self networkForMakeAppoint];//提交预约
        }
        
    }else if (buttonIndex == 0)
    {
        if (alertView.tag == kTag_appointSuccess) {
            //返回
            [self leftButtonTap:nil];
        }
    }
}

#pragma mark - FSCalendarDelegate

- (void)calendarCurrentScopeWillChange:(FSCalendar *)calendar animated:(BOOL)animated
{
    CGSize size = [calendar sizeThatFits:calendar.frame.size];
    
    _calendar.height = size.height;
    _closeButton.top = _calendar.bottom;
    
     @WeakObj(self);
     @WeakObj(_table);
    [UIView animateWithDuration:0.3 animations:^{
        Weakself.calendarView.height = Weakself.closeButton.height + size.height;
        Weak_table.height = DEVICE_HEIGHT - 64 - Weakself.calendarView.height;
        Weak_table.top = _calendarView.bottom;
        [Weakself updateResultView];
    }];
}

/**
 *  更新结果页frame
 */
- (void)updateResultView
{
    UIView *view = [self resultViewWithType:PageResultType_nodata];
    if (view) {
        view.center = CGPointMake(_table.width/2.f, _table.height/2.f);
    }
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
    NSString *selectDate = [LTools timeDate:date withFormat:@"yyyy-MM-dd"];
    NSLog(@"did select date %@",selectDate);
    
    _selectDate = selectDate;//important
    
    [self networkForCenter:selectDate];
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    NSLog(@"offsety %f",offsetY);
    
    if (offsetY < -40) {
        if (!self.closeButton.selected) {
            [self clickToCloseClendar:_closeButton];
        }
    }else if (offsetY > 10){
        if (self.closeButton.selected) {
            [self clickToCloseClendar:_closeButton];
        }
    }

//    if (_lastOffsetY > offsetY) {
//        
//        if (self.closeButton.selected) {
//            
//            [self clickToCloseClendar:self.closeButton];
//            
//        }
//    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    CGFloat offsetY = scrollView.contentOffset.y;

    
//    if (_lastOffsetY > offsetY) {
//        
//        if (self.closeButton.selected) {
//            
//            [self clickToCloseClendar:self.closeButton];
//            
//        }
//    }else
//    {
//        if (scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height - 40))
//        {
//            if (!self.closeButton.selected) {
//                
//                [self clickToCloseClendar:self.closeButton];
//                
//            }
//        }
//    }
//    _lastOffsetY = offsetY;
}

#pragma - mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    HospitalModel *h_model = _dataArray[indexPath.row];
    if ([h_model.appoint_percent intValue] == 100){
        return;
    }
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
    return _dataArray.count;
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
        
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50 - 0.5, DEVICE_WIDTH, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [cell.contentView addSubview:line];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];

    cell.textLabel.textColor = [UIColor colorWithHexString:@"646464"];
    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"323232"];
    
    UILabel *label = [cell.contentView viewWithTag:100];
    UIImageView *icon = [cell.contentView viewWithTag:101];

    HospitalModel *h_model = _dataArray[indexPath.row];
    
    if (h_model) {
        NSString *brand = h_model.brand_name;
        NSString *name = h_model.center_name;
        NSString *text = [NSString stringWithFormat:@"%@  %@",brand ? : @"",name ? : @""];
        
        NSString *distance = [LTools distanceString:h_model.distance];
        if (distance) {
            text = [NSString stringWithFormat:@"%@ %@",text,distance];
        }
        
        [cell.textLabel setAttributedText:[LTools attributedString:text keyword:name color:[UIColor colorWithHexString:@"323232"]]];
        
        NSString *numString = [NSString stringWithFormat:@"%d%%",[h_model.appoint_percent intValue]];
        NSString *d_text = [NSString stringWithFormat:@"已预约%@",numString];

        if ([h_model.appoint_percent intValue] == 100) {
            
            cell.backgroundColor = [UIColor colorWithHexString:@"fafafa"];
            label.text = d_text;
        }else
        {
            cell.backgroundColor = [UIColor whiteColor];
            [label setAttributedText:[LTools attributedString:d_text keyword:numString color:[UIColor colorWithHexString:@"f88323"]]];
        }
        
    }
    
    if ([h_model.exam_center_id intValue] == _selectHospitalId && [h_model.appoint_percent intValue] != 100) {
        
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
    HospitalModel *h_model = _dataArray[indexPath.row];

    if ([h_model.appoint_percent intValue] == 100){
        return;
    }
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
