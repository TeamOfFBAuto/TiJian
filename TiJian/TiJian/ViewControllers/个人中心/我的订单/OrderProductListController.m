//
//  OrderProductListController.m
//  TiJian
//
//  Created by lichaowei on 15/11/26.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "OrderProductListController.h"
#import "ProductModel.h"
#import "AppointmentCell.h"
#import "ChooseHopitalController.h"

@interface OrderProductListController ()<RefreshDelegate,UITableViewDataSource>{
    
    RefreshTableView *_table;
}

@end

@implementation OrderProductListController

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
    self.myTitle = @"订单清单";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForAppointSuccess) name:NOTIFICATION_APPOINT_SUCCESS object:nil];

    [self prepareRefreshTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 通知处理

- (void)notificationForAppointSuccess
{
    //刷新预约情况
    [_table showRefreshHeader:YES];
}

#pragma mark - 视图创建

- (void)prepareRefreshTableView
{
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    [_table showRefreshHeader:YES];
}

#pragma mark - 网络请求

- (void)netWorkForList
{
    NSDictionary *params = @{@"authcode":[LTools objectForKey:USER_AUTHOD],
                             @"order_id":self.orderId};;
    NSString *api = GET_SETMEALS_BY_ORDER;
    
//    GoHealth_get_order_info
    
    if (self.platformType == PlatformType_goHealth) {
        api = GoHealth_get_order_info;
    }
    __weak typeof(self)weakSelf = self;
    __weak typeof(_table)weakTable = _table;
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        NSArray *temp = [ProductModel modelsFromArray:result[@"setmeals"]];
        [weakTable reloadData:temp isHaveMore:NO];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        [weakTable loadFail];
    }];
}

#pragma mark - 数据解析处理

#pragma mark - 事件处理

#pragma mark - 代理

#pragma - mark RefreshDelegate <NSObject>

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    [self netWorkForList];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    [self netWorkForList];
}
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    ProductModel *aModel = _table.dataArray[indexPath.row];
    
    if (!aModel.order_id) {
        [LTools showMBProgressWithText:@"订单无效！" addToView:self.view];
        [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];
        return;
    }
    
    if ([aModel.no_appointed_num intValue] == 0) {
        return;
    }
    
    aModel.order_id = self.orderId;
    
    ChooseHopitalController *choose = [[ChooseHopitalController alloc]init];
    choose.gender = [aModel.gender intValue];
    
    //公司
    if ([aModel.company_id intValue] > 0 && [aModel.order_checkuper_id intValue] > 0) {
        
        NSString *order_checkuper_id = [NSString stringWithFormat:@"%@",aModel.order_checkuper_id];
        [choose companyAppointWithOrderId:aModel.order_id
                               productId:aModel.product_id
                               companyId:[NSString stringWithFormat:@"%@",aModel.company_id]
                      order_checkuper_id:order_checkuper_id
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
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    ProductModel *aModel = _table.dataArray[indexPath.row];
    return [AppointmentCell heightForCellWithType:[aModel.type intValue]];
}

#pragma - mark UITableViewDataSource

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return tableView.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"AppointmentCell1";
    AppointmentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[AppointmentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier type:1];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setCellWithModel:_table.dataArray[indexPath.row]];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
