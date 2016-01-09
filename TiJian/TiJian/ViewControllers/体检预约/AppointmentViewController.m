//
//  AppointmentViewController.m
//  TiJian
//
//  Created by lichaowei on 15/11/13.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "AppointmentViewController.h"

#import "PersonalCustomViewController.h"//个性化定制
#import "PhysicalTestResultController.h"//测试结果
#import "ChooseHopitalController.h"//选择分院和时间
#import "AppointDetailController.h"//预约详情
#import "GStoreHomeViewController.h"//商城
#import "GoneClassListViewController.h"

#import "ProductModel.h"
#import "AppointmentCell.h"
#import "AppointModel.h"
#define kTagButton 300
#define kTagTableView 200

@interface AppointmentViewController ()<RefreshDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    RefreshTableView *_table;
    NSArray *_company;
    NSArray *_personal;
    NSArray *_expired;//已过期
    NSArray *_no_expired;//未过期
    int _currentPage;//当前页面
}
@property(nonatomic,retain)UIScrollView *scroll;
@property(nonatomic,retain)UIView *noAppointView;//待预约view
@property(nonatomic,retain)UIView *appointedView;//已预约view
@property(nonatomic,retain)UIView *appointedOverView;//已预约过期view

@end

@implementation AppointmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"预约";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForAppointSuccess) name:NOTIFICATION_APPOINT_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForAppointSuccess) name:NOTIFICATION_APPOINT_CANCEL_SUCCESS object:nil];
    //更新预约
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForUpdateAppointSuccess) name:NOTIFICATION_APPOINT_UPDATE_SUCCESS object:nil];
    
    //创建视图
    [self prepareView];
    //请求数据
    [self tableViewWithIndex:0].isHaveLoaded = YES;
    [[self tableViewWithIndex:0] showRefreshHeader:YES];
    [self buttonWithIndex:0].selected = YES;
    _currentPage = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 通知处理

- (void)notificationForAppointSuccess
{
    //刷新预约情况
    [[self tableViewWithIndex:0]showRefreshHeader:YES];//全部
    [[self tableViewWithIndex:1]showRefreshHeader:YES];//已预约
    [[self tableViewWithIndex:2]showRefreshHeader:YES];//已预约
}

/**
 *  更新预约成功
 */
- (void)notificationForUpdateAppointSuccess
{
    //刷新预约情况
    [[self tableViewWithIndex:2]showRefreshHeader:YES];//已过期
    [[self tableViewWithIndex:3]showRefreshHeader:YES];//已预约
    [[self tableViewWithIndex:0]showRefreshHeader:YES];//全部

}

#pragma mark - 视图创建

/**
 *  待预约为空时
 *
 *  @return
 */
- (UIView *)noAppointView
{
    if (_noAppointView) {
        
        return _noAppointView;
    }
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    view.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    CGFloat width = FitScreen(96);
    width = iPhone4 ? width * 0.8 : width;
    
    _noAppointView = view;
    
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(38, 55, width, width)];
    icon.image = [UIImage imageNamed:@"hema"];
    [view addSubview:icon];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, icon.bottom - 5, DEVICE_WIDTH, 15) title:@"您还没有任何套餐可以预约" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"323232"]];
    [view addSubview:label];
    
    label = [[UILabel alloc]initWithFrame:CGRectMake(0, label.bottom + 5, DEVICE_WIDTH, 15) title:@"您可以先" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"323232"]];
    [view addSubview:label];
    
    width = DEVICE_WIDTH / 3.f;
    CGFloat aver = width / 5.f;
    for (int i = 0; i < 2; i ++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(aver * 2 + (width + aver) * i, label.bottom + 35, width, 35);
        [view addSubview:btn];
        [btn addCornerRadius:2.f];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        if (i == 0) {
            [btn setBorderWidth:0.5 borderColor:DEFAULT_TEXTCOLOR];
            [btn setTitle:@"购买套餐" forState:UIControlStateNormal];
            [btn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(clickToBuy) forControlEvents:UIControlEventTouchUpInside];
        }else
        {
            [btn setBorderWidth:0.5 borderColor:[UIColor colorWithHexString:@"ec7d24"]];
            [btn setTitle:@"定制专属套餐" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithHexString:@"ec7d24"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(clickToCustomization:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    return view;
}

/**
 *  已预约为空时
 *
 *  @return
 */
- (UIView *)appointedView
{
    if (_appointedView) {
        
        return _appointedView;
    }
    
    _appointedView = [self viewForResult];
        
    return _appointedView;
}

/**
 *  已预约过期
 *
 *  @return
 */
-(UIView *)appointedOverView
{
    if (_appointedOverView) {
        return _appointedOverView;
    }
    _appointedOverView = [self viewForResult];
    return _appointedOverView;
}

- (UIView *)viewForResult
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    CGFloat width = FitScreen(96);
    width = iPhone4 ? width * 0.8 : width;
    
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(38, 55, width, width)];
    icon.image = [UIImage imageNamed:@"hema"];
    [view addSubview:icon];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, icon.bottom - 5, DEVICE_WIDTH, 15) title:@"您还没有预约任何套餐" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"323232"]];
    [view addSubview:label];
    return view;
}

- (RefreshTableView *)tableViewWithIndex:(int)index
{
    return (RefreshTableView *)[self.view viewWithTag:kTagTableView + index];
}
- (UIButton *)buttonWithIndex:(int)index
{
    return (UIButton *)[self.view viewWithTag:kTagButton + index];
}

- (void)prepareView
{
    NSArray *arr = @[@"全部",@"未预约",@"已预约",@"已过期"];
    int sum = (int)arr.count;
    
    self.scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 45, DEVICE_WIDTH, DEVICE_HEIGHT - 45 - 64)];
    _scroll.pagingEnabled = YES;
    _scroll.delegate = self;
    [self.view addSubview:_scroll];
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.contentSize = CGSizeMake(DEVICE_WIDTH * sum, _scroll.height);
    
    //scrollView 和 系统手势冲突问题
    [_scroll.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    
    CGFloat width = DEVICE_WIDTH / sum;
    for (int i = 0; i < sum; i ++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(width * i, 0, width, 45);
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        [btn setTitleColor:DEFAULT_TEXTCOLOR_TITLE forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"f68326"] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        btn.backgroundColor = [UIColor whiteColor];
        [btn addTarget:self action:@selector(clickToSwap:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = kTagButton + i;
        [self.view addSubview:btn];
        
        RefreshTableView *table = [[RefreshTableView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH * i, 0, DEVICE_WIDTH, _scroll.height) style:UITableViewStylePlain];
        table.refreshDelegate = self;
        table.dataSource = self;
        [_scroll addSubview:table];
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        table.tag = kTagTableView + i;
    }

}

#pragma mark - 网络请求

- (void)netWorkForListWithTable:(RefreshTableView *)table
{
    int index = (int)table.tag - kTagTableView;
    NSDictionary *params;
    NSString *api;
    
    NSString *authkey = [UserInfo getAuthkey];
    
    //待预约
    if (table == [self tableViewWithIndex:0]) {
        
        api = GET_ALL_APPOINTS;
        params = @{@"authcode":authkey};
    }
    //待预约
    else if (table == [self tableViewWithIndex:1]) {
        
        api = GET_NO_APPOINTS;
        params = @{@"authcode":authkey};
    }
    //已预约
    else if (table == [self tableViewWithIndex:2])
    {
        api = GET_APPOINT;
        params = @{@"authcode":authkey,
                   @"expired":@"0",
                   @"page":NSStringFromInt(table.pageNum),
                   @"per_page":NSStringFromInt(PAGESIZE_MID)};
    }
    //已过期
    else if ([self tableViewWithIndex:3])
    {
        api = GET_APPOINT;
        params = @{@"authcode":authkey,
                   @"expired":@"1",
                   @"page":NSStringFromInt(table.pageNum),
                   @"per_page":NSStringFromInt(PAGESIZE_MID)};
    }
    __weak typeof(self)weakSelf = self;
    __weak typeof(table)weakTable = table;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [weakSelf parseDataWithResult:result withIndex:index];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [weakTable loadFail];
        
    }];
}

#pragma mark - 数据解析处理

- (void)parseDataWithResult:(NSDictionary *)result
                  withIndex:(int)index
{
    NSDictionary *setmeal_list = result[@"appoint_list"];

    //全部
    if (index == 0) {
        
        if (![setmeal_list isKindOfClass:[NSDictionary class]]) {
            
            [[self tableViewWithIndex:index]finishReloadingData];
            return;
        }
        
        _company = [ProductModel modelsFromArray:setmeal_list[@"company"]];
        _personal = [ProductModel modelsFromArray:setmeal_list[@"personal"]];
        _no_expired = [AppointModel modelsFromArray:setmeal_list[@"no_expired"]];
        _expired = [AppointModel modelsFromArray:setmeal_list[@"expired"]];
        
        if (_company.count == 0 &&
            _personal.count == 0 &&
            _no_expired.count == 0 &&
            _expired.count == 0) {
            
            //没有待预约
            
            UIView *view = self.noAppointView;
            [[self tableViewWithIndex:index] addSubview:view];
            
        }else
        {
            [self.noAppointView removeFromSuperview];
            self.noAppointView = nil;
        }
        
        [[self tableViewWithIndex:index] finishReloadingData];
        
    }
    //待预约
    if (index == 1) {
        
        if (![setmeal_list isKindOfClass:[NSDictionary class]]) {
            
            [[self tableViewWithIndex:index]finishReloadingData];
            return;
        }
        
        _company = [ProductModel modelsFromArray:setmeal_list[@"company"]];
        _personal = [ProductModel modelsFromArray:setmeal_list[@"personal"]];
        
        
        if (_company.count == 0 && _personal.count == 0) {
            
            //没有待预约
            
            UIView *view = self.noAppointView;
            [[self tableViewWithIndex:index] addSubview:view];
            
        }else
        {
            [self.noAppointView removeFromSuperview];
            self.noAppointView = nil;
        }
        
        [[self tableViewWithIndex:index] finishReloadingData];
        
        
    }else if (index == 2){
        
        NSArray *temp = [AppointModel modelsFromArray:result[@"appoint_list"]];
        if (temp.count == 0) {
            [[self tableViewWithIndex:index]addSubview:self.appointedView];
        }else
        {
            [self.appointedView removeFromSuperview];
            self.appointedView = nil;
        }
        [[self tableViewWithIndex:index] reloadData:temp pageSize:PAGESIZE_MID];
        
    }else if (index == 3){
        
        NSArray *temp = [AppointModel modelsFromArray:result[@"appoint_list"]];
        if (temp.count == 0) {
            [[self tableViewWithIndex:index]addSubview:self.appointedOverView];
        }else
        {
            [self.appointedOverView removeFromSuperview];
            self.appointedOverView = nil;
        }
        [[self tableViewWithIndex:index] reloadData:temp pageSize:PAGESIZE_MID];

    }
}

#pragma mark - 事件处理

/**
 *  更改button状态
 *
 *  @param index 选中index
 */
- (void)updateButtonStateWithSelectedIndex:(int)index
{
    if (index == _currentPage) {
        
        return;
    }else
    {
        _currentPage = index;
    }
    
    NSLog(@"%s",__FUNCTION__);
    for (int i = 0; i < 4; i ++) {
        [self buttonWithIndex:i].selected = (index == i);
    }
    
    if (![self tableViewWithIndex:index].isHaveLoaded) {
        NSLog(@"请求数据 %d",index);
        [[self tableViewWithIndex:index] showRefreshHeader:YES];
    }
}

- (void)clickToSwap:(UIButton *)sender
{
    int index = (int)sender.tag - kTagButton;
    [self updateButtonStateWithSelectedIndex:index];
    [_scroll setContentOffset:CGPointMake(DEVICE_WIDTH * index, 0) animated:NO];
}

- (void)clickToBuy
{
    GStoreHomeViewController *cc= [[GStoreHomeViewController alloc]init];
    [self.navigationController pushViewController:cc animated:YES];
}
- (void)clickToCustomization:(PropertyButton *)sender
{
    
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
    ProductModel *aModel = sender.aModel;
    GoneClassListViewController *cc = [[GoneClassListViewController alloc]init];
    cc.className = @"使用代金券";
    cc.vouchers_id = aModel.coupon_id;//代金券
    cc.uc_id = aModel.uc_id;
    cc.brandId = aModel.brand_id;
    cc.brandName = aModel.brand_name;
    [self.navigationController pushViewController:cc animated:YES];
}

#pragma mark - 代理

#pragma - mark UIScrollDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _scroll) {
        
        int page = floor((scrollView.contentOffset.x - DEVICE_WIDTH / 2) / DEVICE_WIDTH) + 1;//只要大于半页就算下一页
        [self updateButtonStateWithSelectedIndex:page];
        
    }
    
}

#pragma - mark RefreshDelegate <NSObject>

- (void)loadNewDataForTableView:(RefreshTableView *)tableView
{
    [self netWorkForListWithTable:tableView];
}
- (void)loadMoreDataForTableView:(RefreshTableView *)tableView
{
    [self netWorkForListWithTable:tableView];
}
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(RefreshTableView *)tableView
{
    int index = (int)tableView.tag - kTagTableView;
    if (index == 0 || index == 1) {
        
        ProductModel *aModel;
        if (indexPath.section == 0) {
            aModel = _company[indexPath.row];
        }else if (indexPath.section == 1){
            aModel = _personal[indexPath.row];
        }else if (indexPath.section == 2){
            aModel = _no_expired[indexPath.row];
        }else if (indexPath.section == 3){
            aModel = _expired[indexPath.row];
        }
        
        if ([aModel isKindOfClass:[ProductModel class]] &&
            [aModel.type intValue] == 2) { //代金券
            return;
        }
        
        if (indexPath.section == 0 ||
            indexPath.section == 1) {
            
            ChooseHopitalController *choose = [[ChooseHopitalController alloc]init];
            choose.gender = [aModel.gender intValue];
            //公司
            if ([aModel.type intValue] == 1) {
                
                NSString *order_checkuper_id = aModel.checkuper_info[@"order_checkuper_id"];
                [choose setCompanyAppointOrderId:aModel.order_id productId:aModel.product_id companyId:aModel.company_info[@"company_id"] order_checkuper_id:order_checkuper_id noAppointNum:[aModel.no_appointed_num intValue]];
            }else
            {
                choose.productId = aModel.product_id;
                choose.order_id = aModel.order_id;
                choose.noAppointNum = [aModel.no_appointed_num intValue];//未预约个数
                
                choose.lastViewController = self;//需要选择体检人的时候需要传
            }
            
            [self.navigationController pushViewController:choose animated:YES];
        }else
        {
            AppointModel *aModel;
            if (indexPath.section == 2){
                aModel = _no_expired[indexPath.row];
            }else if (indexPath.section == 3){
                aModel = _expired[indexPath.row];
            }
            AppointDetailController *detail = [[AppointDetailController alloc]init];
            detail.appoint_id = aModel.appoint_id;
            [self.navigationController pushViewController:detail animated:YES];
        }
        
    }else
    {
        AppointModel *aModel = tableView.dataArray[indexPath.row];
        AppointDetailController *detail = [[AppointDetailController alloc]init];
        detail.appoint_id = aModel.appoint_id;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    int index = (int)tableView.tag - kTagTableView;
    if (index == 0 || index == 1) {
        
        if (indexPath.section == 2 ||
            indexPath.section == 3)
        {
            return 60.f;
        }
        
        ProductModel *aModel = indexPath.section == 0 ? _company[indexPath.row] : _personal[indexPath.row];
        return [AppointmentCell heightForCellWithType:[aModel.type intValue]];
    }
    
    return 60.f;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView
{
    int index = (int)tableView.tag - kTagTableView;
    if (index == 0 || index == 1) {
        
        UIView *head = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40.f)];
        head.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
        NSString *title = section == 0 ? @"公司购买套餐" : @"个人购买套餐";
        if (section == 0) {
            title = @"公司购买套餐";
        }else if (section == 1){
            title = @"个人购买套餐";
        }else if (section == 2){
            title = @"已预约";
        }else if (section == 3){
            title = @"已过期";
        }
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 120, 40) title:title font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"989898"]];
        [head addSubview:label];
        return head;
    }
    return nil;
}
- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView
{
    int index = (int)tableView.tag - kTagTableView;
    if (index == 0 || index == 1) {
        
        if (section == 0) {
            
            if (_company.count == 0) {
                return 0.f;
            }
        }
        if (section == 1) {
            if (_personal.count == 0) {
                return 0.f;
            }
        }
        
        if (section == 2) {
            if (_no_expired.count == 0) {
                return 0.f;
            }
        }
        
        if (section == 3) {
            if (_expired.count == 0) {
                return 0.f;
            }
        }
        
        
        return 40.f;
    }
    return 0.f;
}

-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(RefreshTableView *)tableView
{
    int index = (int)tableView.tag - kTagTableView;
    if (index == 0 || index == 1)
    {
        return 5.f;
    }
    return 0.f;
}
-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(RefreshTableView *)tableView
{
    int index = (int)tableView.tag - kTagTableView;
    if (index == 0 || index) {
        
        UIView *head = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40.f)];
        head.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
        return head;
    }
    return nil;
}

#pragma - mark UITableViewDataSource

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    int index = (int)tableView.tag - kTagTableView;
    if (index == 0 || index == 1) {
        
        if (section == 0) {
            return _company.count;
        }else if (section == 1){
            return _personal.count;
        }else if (section == 2){
            return _no_expired.count;
        }else if (section == 3){
            return _expired.count;
        }
    }
    return tableView.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    int index = (int)tableView.tag - kTagTableView;
    
    if (index == 1 || (index == 0 && (indexPath.section == 0 || indexPath.section == 1)) ){
        
        AppointmentCell *cell;
        ProductModel *aModel = indexPath.section == 0 ? _company[indexPath.row] : _personal[indexPath.row];
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
        if (indexPath.section == 0) {
            
            [cell setCellWithModel:_company[indexPath.row]];
        }else
        {
            [cell setCellWithModel:_personal[indexPath.row]];
        }
        
        return cell;
    }
    
    static NSString *identifier = @"identify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 55)];
        view.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:view];
        
        CGFloat nameWidth = 120;
        CGFloat timeWidth = 70;
        CGFloat centerWidth = DEVICE_WIDTH - nameWidth - timeWidth - 20;
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, nameWidth, 55) title:nil font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE];
        [view addSubview:nameLabel];
        nameLabel.tag = 100;
        
        UILabel *centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.right, 0, centerWidth, 55) title:nil font:14 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE];
        [view addSubview:centerLabel];
        centerLabel.tag = 101;
        
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 10 - timeWidth, 0, timeWidth, 55) title:nil font:13 align:NSTextAlignmentRight textColor:DEFAULT_TEXTCOLOR_TITLE];
        [view addSubview:timeLabel];
//        timeLabel.backgroundColor = [UIColor redColor];
        timeLabel.tag = 102;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *nameLabel = [cell.contentView viewWithTag:100];
    UILabel *centerLabel = [cell.contentView viewWithTag:101];
    UILabel *timeLabel = [cell.contentView viewWithTag:102];
    RefreshTableView *table = (RefreshTableView *)tableView;
    AppointModel *aModel;
    
    if (index == 0) {
        //全部里面 未过期、已过期
        if (indexPath.section == 2) {
            aModel = _no_expired[indexPath.row];
        }else if (indexPath.section == 3){
            aModel = _expired[indexPath.row];
        }
    }else
    {
        aModel = table.dataArray[indexPath.row];
    }
    NSString *name = aModel.user_name;
    NSString *text = [NSString stringWithFormat:@"%@ (%@)",aModel.user_relation,aModel.user_name];
    [nameLabel setAttributedText:[LTools attributedString:text keyword:name color:DEFAULT_TEXTCOLOR_TITLE_THIRD]];
    centerLabel.text = aModel.center_name;
    
    //未过期
    if (index == 2 || (index == 0 && indexPath.section == 2)) {
        
        timeLabel.text = [LTools timeString:aModel.appointment_exam_time withFormat:@"yyyy.MM.dd"];

    }
    //已过期
    else if (index == 3 || (index == 0 && indexPath.section == 3)){
        
        NSString *days = NSStringFromInt([aModel.days intValue]);
        NSString *text = [NSString stringWithFormat:@"过期%@天",days];
        [timeLabel setAttributedText:[LTools attributedString:text keyword:days color:[UIColor colorWithHexString:@"f88326"]]];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(RefreshTableView *)tableView
{
    int index = (int)tableView.tag - kTagTableView;
    if (index == 0) {
        return 4;
    }else if (index == 1){
        return 2;
    }
    return 1;
}

@end
