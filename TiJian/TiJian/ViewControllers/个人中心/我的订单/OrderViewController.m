//
//  OrderViewController.m
//  WJXC
//
//  Created by lichaowei on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "OrderViewController.h"
#import "OrderCell.h"
#import "OrderModel.h"
#import "PayActionViewController.h"//支付页面
#import "OrderInfoViewController.h"//订单详情
#import "RefreshTableView.h"
#import "TuiKuanViewController.h"//退款页面
#import "OrderProductListController.h"//订单的套餐列表
#import "AddCommentViewController.h"
#import "ConfirmOrderViewController.h"//确认订单

#define kPadding_Pay 1000 //去支付
#define kPadding_Refund 2000 //退款
#define kPadding_Confirm 3000 //确认收货
#define kPadding_BuyAgain  4000 //再次购买
#define kPadding_Appoint 5000 //前去预约

//no_pay待付款，no_appointment待预约，no_comment待评价，complete已完成

//获取对应tableView
#define TABLEVIEW_TAG_All 0 //全部
#define TABLEVIEW_TAG_DaiFu 1 //待付款
#define TABLEVIEW_TAG_NoAppoint 2 //待预约
#define TABLEVIEW_TAG_Appointed 3 //已预约
#define TABLEVIEW_TAG_WanCheng 4 //完成
#define TABLEVIEW_TAG_TuiHuan 5 //退换

//NSArray *titles = @[@"全部",@"待付款",@"已付款",@"已完成",@"退换"];

#define TableView_title_All @"全部" //全部
#define TableView_title_DaiFu @"待付款" //待付款
#define TableView_title_Payed @"已付款" //已付款
#define TableView_title_WanCheng @"已完成" //完成
#define TableView_title_TuiHuan @"退换" //退换

#define Title_array @[@"全部",@"待付款",@"已付款",@"已完成",@"退换"]

@interface CustomeAlertView : UIAlertView

@property(nonatomic,retain)id object;//参数

@end

@implementation CustomeAlertView


@end

@interface OrderViewController ()<RefreshDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    int _buttonNum;//button个数
    UIView *_indicator;//指示器
    UIScrollView *_scroll;
}

@end

@implementation OrderViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:NSStringFromClass([self class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"我的订单";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
//    NSArray *titles = @[@"全部",@"待付款",@"待预约",@"已预约",@"已完成",@"退换"];
    NSArray *titles = Title_array;

    int count = (int)titles.count;
    CGFloat width = DEVICE_WIDTH / count;
    _buttonNum = count;
    
    _scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 40, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 40)];
    _scroll.delegate = self;
    _scroll.contentSize = CGSizeMake(DEVICE_WIDTH * count, _scroll.height);
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.pagingEnabled = YES;
    [self.view addSubview:_scroll];
    
    //scrollView 和 系统手势冲突问题
    [_scroll.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    
    for (int i = 0; i < count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        btn.tag = 100 + i;
        btn.frame = CGRectMake(width * i, 0, width, 40);
        [btn setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
        [btn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateSelected];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn addTarget:self action:@selector(clickToSelect:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor whiteColor];
        btn.selected = YES;
        
        RefreshTableView *_table = [[RefreshTableView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH * i, 0, DEVICE_WIDTH,_scroll.height)];
        _table.refreshDelegate = self;
        _table.dataSource = self;
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_scroll addSubview:_table];
        _table.tableTitle = titles[i];
        _table.tag = 200 + i;
    }
    
    _indicator = [[UIView alloc]initWithFrame:CGRectMake(0, 38, width, 2)];
    _indicator.backgroundColor = DEFAULT_TEXTCOLOR;
    [self.view addSubview:_indicator];
    
    //默认选中第一个
    [self controlSelectedButtonTag:100];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotify:) name:NOTIFICATION_PAY_SUCCESS object:nil];//支付成功
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotify:) name:NOTIFICATION_ORDER_CANCEL object:nil];//取消订单
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotify:) name:NOTIFICATION_ORDER_DEL object:nil];//删除订单
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotify:) name:NOTIFICATION_TUIKUAN_SUCCESS object:nil];//退款
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotify:) name:NOTIFICATION_ORDER_COMMIT object:nil];//提交订单
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotify:) name:NOTIFICATION_COMMENTSUCCESS object:nil];//评论
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotify:) name:NOTIFICATION_APPOINT_SUCCESS object:nil];//预约成功
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 通知处理

/**
 *  处理通知
 *
 *  @param notify
 */
- (void)actionForNotify:(NSNotification *)notify
{
    DDLOG(@"%@ %@",notify.name,notify.userInfo);
    NSString *notifyName = notify.name;
    
    if ([notifyName isEqualToString:NOTIFICATION_PAY_SUCCESS])//支付成功
    {
        //支付成功 更新
        [[self refreshTableForTitle:TableView_title_DaiFu]showRefreshHeader:YES];
        [[self refreshTableForTitle:TableView_title_Payed]showRefreshHeader:YES];
        
    }else if ([notifyName isEqualToString:NOTIFICATION_RECIEVE_CONFIRM]){//确认收货
        DDLOG(@"确认收货通知");
    }else if ([notifyName isEqualToString:NOTIFICATION_ORDER_CANCEL])//取消订单
    {
        //取消订单通知 只有待付款可以取消订单
        [[self refreshTableForTitle:TableView_title_DaiFu]showRefreshHeader:YES];
        
    }else if ([notifyName isEqualToString:NOTIFICATION_ORDER_DEL])//删除订单
    {
        //删除订单通知 完成的可以删除
        [[self refreshTableForTitle:TableView_title_WanCheng]showRefreshHeader:YES];
        
    }else if ([notifyName isEqualToString:NOTIFICATION_TUIKUAN_SUCCESS])//退款成功
    {
        [[self refreshTableForTitle:TableView_title_Payed]showRefreshHeader:YES];
        [[self refreshTableForTitle:TableView_title_TuiHuan]showRefreshHeader:YES];
        
    }else if ([notifyName isEqualToString:NOTIFICATION_ORDER_COMMIT])//提交订单
    {
        [[self refreshTableForTitle:TableView_title_DaiFu]showRefreshHeader:YES];
        
    }else if ([notifyName isEqualToString:NOTIFICATION_COMMENTSUCCESS])//评价晒单
    {
        [[self refreshTableForTitle:TableView_title_WanCheng]showRefreshHeader:YES];
        
    }else if ([notifyName isEqualToString:NOTIFICATION_APPOINT_SUCCESS])//体检预约成功
    {
        [[self refreshTableForTitle:TableView_title_DaiFu]showRefreshHeader:YES];
        [[self refreshTableForTitle:TableView_title_Payed]showRefreshHeader:YES];
    }
    
    [[self refreshTableForIndex:TABLEVIEW_TAG_All]showRefreshHeader:YES];//全部
}

///**
// *  处理通知
// *
// *  @param notify
// */
//- (void)actionForNotify:(NSNotification *)notify
//{
//    DDLOG(@"%@ %@",notify.name,notify.userInfo);
//    NSString *notifyName = notify.name;
//    
//    
//    int indexOne = -1;
//    int indexTwo = -1;
//    if ([notifyName isEqualToString:NOTIFICATION_PAY_SUCCESS]) {//支付成功
//        //支付成功 更新
//        indexOne = TABLEVIEW_TAG_DaiFu;//待付款
//        indexTwo = TABLEVIEW_TAG_NoAppoint;//待预约
//        
//    }else if ([notifyName isEqualToString:NOTIFICATION_RECIEVE_CONFIRM]){//确认收货
//        DDLOG(@"确认收货通知");
//    }else if ([notifyName isEqualToString:NOTIFICATION_ORDER_CANCEL]){//取消订单
//        //取消订单通知 只有待付款可以取消订单
//        indexOne = TABLEVIEW_TAG_DaiFu;//待付款
//        
//    }else if ([notifyName isEqualToString:NOTIFICATION_ORDER_DEL]){//删除订单
//        
//        //删除订单通知 完成的可以删除
//        indexOne = TABLEVIEW_TAG_WanCheng;
//        
//    }else if ([notifyName isEqualToString:NOTIFICATION_TUIKUAN_SUCCESS]){//退款成功
//        
//        indexOne = TABLEVIEW_TAG_NoAppoint;//待付款
//        indexTwo = TABLEVIEW_TAG_TuiHuan;//退货列表
//        
//    }else if ([notifyName isEqualToString:NOTIFICATION_ORDER_COMMIT]){//提交订单
//        indexOne = TABLEVIEW_TAG_DaiFu;//待付款
//        
//    }else if ([notifyName isEqualToString:NOTIFICATION_COMMENTSUCCESS]){//评价晒单
//        
//        indexOne = TABLEVIEW_TAG_WanCheng;//完成
//        
//    }else if ([notifyName isEqualToString:NOTIFICATION_APPOINT_SUCCESS]){//体检预约成功
//        
//        indexOne = TABLEVIEW_TAG_NoAppoint;//待预约
//        indexTwo = TABLEVIEW_TAG_Appointed;//已预约
//    }
//    
//    if (indexOne >= 0) {
//        [[self refreshTableForIndex:indexOne]showRefreshHeader:YES];
//    }
//    if (indexTwo >= 0) {
//        [[self refreshTableForIndex:indexTwo]showRefreshHeader:YES];
//    }
//    
//    [[self refreshTableForIndex:TABLEVIEW_TAG_All]showRefreshHeader:YES];//全部
//}

#pragma - mark 网络请求

/**
 *  获取订单列表
 *
 *  @param orderType 不同的订单状态
 */
- (void)getOrderListWithRefreshTable:(RefreshTableView *)table
{
    NSString *authey = [UserInfo getAuthkey];
    if (authey.length == 0) {
        return;
    }
    
    NSString *status = nil;
    NSString *title = table.tableTitle;
    if ([title isEqualToString:TableView_title_All]) { //全部
        status = @"all";
    }
    else if ([title isEqualToString:TableView_title_DaiFu])//待付款
    {
        status = @"no_pay";
        
    }else if ([title isEqualToString:TableView_title_Payed])//已付款  根据实际订单状态判断 前去预约 还是 再次购买
    {
        status = @"have_pay";

    }else if ([title isEqualToString:TableView_title_TuiHuan])//退换
    {
        status = @"refund";

    }else if ([title isEqualToString:TableView_title_WanCheng]) //完成
    {
        status = @"complete";
    }
    
    __weak typeof(RefreshTableView)*weakTable = table;
    NSString *api = ORDER_GET_MY_ORDERS;
    NSDictionary *params = @{@"authcode":authey,
                             @"status":status,
                             @"per_page":[NSNumber numberWithInt:10],
                             @"page":[NSNumber numberWithInt:weakTable.pageNum]};
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *list = result[@"list"];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:list.count];
        for (NSDictionary *aDic in list) {

            OrderModel *aModel = [[OrderModel alloc]initWithDictionary:aDic];
            [temp addObject:aModel];
        }

        [weakTable reloadData:temp pageSize:10 noDataView:[self noDataView]];
        
    } failBlock:^(NSDictionary *result) {
        [weakTable reloadData:nil pageSize:10 noDataView:[self noDataView]];

    }];

}

/**
 *  没有数据自定义view
 *
 *  @return
 */
- (UIView *)noDataView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 135)];
    view.backgroundColor = [UIColor clearColor];
    //图标
    
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 73, 80)];
    imageV.image = [UIImage imageNamed:@"my_indent_no"];
    [view addSubview:imageV];
    imageV.centerX = view.width/2.f;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, imageV.bottom + 20, DEVICE_WIDTH, 30) title:@"您还没有相关订单哦" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"646464"]];
    [view addSubview:label];
    
    return view;
}

/**
 *  没有数据自定义view
 *
 *  @return
 */
- (UIView *)erroView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 135)];
    view.backgroundColor = [UIColor clearColor];
    //图标
    
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 73, 80)];
    imageV.image = [UIImage imageNamed:@"my_indent_no"];
    [view addSubview:imageV];
    imageV.centerX = view.width/2.f;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, imageV.bottom + 20, DEVICE_WIDTH, 30) title:@"您还没有相关订单哦" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"646464"]];
    [view addSubview:label];
    
    return view;
}

#pragma - mark 事件处理

/**
 *  再次购买
 *
 *  @param sender
 */
- (void)buyAgain:(OrderModel *)order
{
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:order.products.count];
    for (NSDictionary *aDic in order.products) {
        
        ProductModel *aModel = [[ProductModel alloc]initWithDictionary:aDic];
        [temp addObject:aModel];
    }
    NSArray *productArr = temp;
    ConfirmOrderViewController *confirm = [[ConfirmOrderViewController alloc]init];
    confirm.dataArray = productArr;
    confirm.lastViewController = self;
    [self.navigationController pushViewController:confirm animated:YES];
    
}


/**
 *  去支付 确认收货 评价 再次购买
 *
 *  @param sender
 */
- (void)clickToAction:(PropertyButton *)sender
{
    int actionType = sender.actionType;
    
    OrderModel *aModel = sender.aModel;
    
    if (actionType == ORDERACTIONTYPE_BuyAgain) {
        //再次购买
        [self buyAgain:aModel];
        
    }else if (actionType == ORDERACTIONTYPE_Appoint){
        
        OrderProductListController *list = [[OrderProductListController alloc]init];
        list.orderId = aModel.order_id;
        [self.navigationController pushViewController:list animated:YES];
        
    }else if (actionType == ORDERACTIONTYPE_Comment){
        //评价晒单
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:aModel.products.count];
        for (NSDictionary *aDic in aModel.products) {
            
            ProductModel *t_Model = [[ProductModel alloc]initWithDictionary:aDic];
            [temp addObject:t_Model];
        }
        AddCommentViewController *comment = [[AddCommentViewController alloc]init];
        comment.dingdanhao = aModel.order_no;
        comment.theModelArray = temp;
        [self.navigationController pushViewController:comment animated:YES];
        
    }else if (actionType == ORDERACTIONTYPE_Pay){
        //支付
        [self pushToPayPageWithOrderId:aModel.order_id orderNum:aModel.order_no sumPrice:[aModel.real_price floatValue] payStyle:[aModel.pay_type intValue]];
    }
}

/**
 *  跳转至支付页面
 */
- (void)pushToPayPageWithOrderId:(NSString *)orderId
                        orderNum:(NSString *)orderNum
                        sumPrice:(CGFloat)sumPrice
                        payStyle:(int)payStyle
{
    PayActionViewController *pay = [[PayActionViewController alloc]init];
    pay.orderId = orderId;
    pay.orderNum = orderNum;
    pay.sumPrice = sumPrice;
    pay.payStyle = payStyle;
    pay.lastViewController = self;
    [self.navigationController pushViewController:pay animated:YES];
}

/**
 *  获取button 根据tag
 */
- (UIButton *)buttonForTag:(int)tag
{
    return (UIButton *)[self.view viewWithTag:tag];
}

/**
 *  根据下标来获取tableView
 *
 *  @param index 下标 1，2，3，4
 */
- (RefreshTableView *)refreshTableForIndex:(int)index
{
    return (RefreshTableView *)[self.view viewWithTag:index + 200];
}

/**
 *  根据标题获取tableView
 *
 *  @param title
 *
 *  @return
 */
- (RefreshTableView *)refreshTableForTitle:(NSString *)title
{
    for (int i = 0; i < Title_array.count; i ++) {
        
        RefreshTableView *table = [self refreshTableForIndex:i];
        if ([table.tableTitle isEqualToString:title]) {
            return table;
        }
    }
    return nil;
}

/**
 *  控制button选中状态
 */
- (void)controlSelectedButtonTag:(int)tag
{
    for (int i = 0; i < _buttonNum; i ++) {

        [self buttonForTag:100 + i].selected = (i + 100 == tag) ? YES : NO;
    }
    
    __weak typeof(_indicator)weakIndicator = _indicator;
    [UIView animateWithDuration:0.1 animations:^{
       
        weakIndicator.left = DEVICE_WIDTH / _buttonNum * (tag - 100);
    }];
    
    int index = tag - 100;
    if (![self refreshTableForIndex:index].isHaveLoaded) {
        DDLOG(@"tableView request %d",index);
        [[self refreshTableForIndex:index] showRefreshHeader:YES];
    }
}

/**
 *  点击button
 *
 *  @param sender
 */
- (void)clickToSelect:(UIButton *)sender
{
    [self controlSelectedButtonTag:(int)sender.tag];
    
//    __weak typeof(_scroll)weakScroll = _scroll;
//    [UIView animateWithDuration:0.1 animations:^{
    
        [_scroll setContentOffset:CGPointMake(DEVICE_WIDTH * (sender.tag - 100), 0)];
//    }];
}

#pragma - mark 视图创建

#pragma - 代理

#pragma - mark UIAlertViewDelegate <NSObject>
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
//        NSString *authey = [GMAPI getAuthkey];
//
//        int index = (int)alertView.tag;
    }

}


#pragma mark - RefreshDelegate

- (void)loadNewDataForTableView:(RefreshTableView *)tableView
{
    [self getOrderListWithRefreshTable:tableView];
}
- (void)loadMoreDataForTableView:(RefreshTableView *)tableView
{
    [self getOrderListWithRefreshTable:tableView];
}

//新加
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    OrderModel *aModel = [((RefreshTableView *)tableView).dataArray objectAtIndex:indexPath.row];

    OrderInfoViewController *orderInfo = [[OrderInfoViewController alloc]init];
    orderInfo.order_id = aModel.order_id;
    orderInfo.lastViewController = self;
    [self.navigationController pushViewController:orderInfo animated:YES];
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
//    return 372/2.f;
    OrderModel *aModel = [((RefreshTableView *)tableView).dataArray objectAtIndex:indexPath.row];
    return [OrderCell heightForAddress:aModel.address];
}

#pragma - mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RefreshTableView *refreshTable = (RefreshTableView *)tableView;
    return refreshTable.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"OrderCell";
    OrderCell *cell = (OrderCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    RefreshTableView *table = (RefreshTableView *)tableView;
    
    NSString *text = @"";
    
    int refund_status = 0;
    
    OrderModel *aModel = [table.dataArray objectAtIndex:indexPath.row];
    [cell setCellWithModel:aModel];
    
    cell.indexPath = indexPath;
    if (cell.contentScroll) {
        @WeakObj(self);
        @WeakObj(cell);
        [cell.contentScroll setTouchEventBlock:^(TouchEventState state) {
            
            if (state == TouchEventState_ended) {
                
                [Weakself didSelectRowAtIndexPath:Weakcell.indexPath tableView:(RefreshTableView *)tableView];
            }
        }];
    }
    
    cell.commentButton.aModel = aModel;
    cell.actionButton.aModel = aModel;
    
    refund_status = [aModel.refund_status intValue];
    
    //代表有退款状态
    if (refund_status > 0) {
        
        if (refund_status == 1 || refund_status == 2) {
            text = @"退款中";
        }else if (refund_status == 3){
            text = @"退款成功";
        }else if (refund_status == 4 || refund_status == 5){
            text = @"退款失败";
        }
        
    }
    
//    PropertyButton *commentButton;//右边按钮
//    PropertyButton *actionButton;//左边按钮
    
    cell.actionButton.hidden = YES;//默认左边隐藏
    
    NSString *title = table.tableTitle;
    if ([title isEqualToString:TableView_title_All]) { //全部
        ORDERACTIONTYPE type = ORDERACTIONTYPE_Default;
        
        int status = [aModel.status intValue];
        NSString *text1 = nil;
        if (status == 1) {
            //待支付
            text1 = @"去支付";
            type = ORDERACTIONTYPE_Pay;
        }else if (status == 2){ // 新版本没有2
            //待预约
            text1 = @"前去预约";
            type = ORDERACTIONTYPE_Appoint;
            
        }else if (status == 3){// 新版本没有3
            //已预约
            text1 = @"再次购买";
            type = ORDERACTIONTYPE_BuyAgain;
        }
        else if (status == 4){
            //已完成
            text1 = @"再次购买";
            type = ORDERACTIONTYPE_BuyAgain;
            
            //代表已评价
            if ([aModel.is_comment intValue] == 0) {
                cell.actionButton.hidden = NO;
            }else
            {
                cell.actionButton.hidden = YES;
            }
        }else if (status == 5){
            
            text1 = @"已取消";
            type = ORDERACTIONTYPE_Default;

        }else if (status == 6){
            text1 = @"已删除";
            type = ORDERACTIONTYPE_Default;
            
        }else if (status == 7){
            //已付款
            BOOL is_appoint = [aModel.is_appoint boolValue];
            if (is_appoint) {
                text1 = @"前去预约";
                type = ORDERACTIONTYPE_Appoint;
            }else
            {
                text1 = @"已预约";
                type = ORDERACTIONTYPE_Default;
                
                cell.actionButton.hidden = NO;
                [cell.actionButton setTitle:@"再次购买" forState:UIControlStateNormal];
                cell.actionButton.actionType = ORDERACTIONTYPE_BuyAgain;

            }
        }
        
        //1=》待付款      新版本没有2、3状态       4=》已完成 5=》已取消 6=》已删除 7=>已付款

        //显示退款状态
        if (refund_status == 3) { //退款成功 只显示一个退款状态
            cell.actionButton.hidden = YES;
            text1 = text;
            type = ORDERACTIONTYPE_Refund;
            
        }else if(refund_status > 0) //显示退款状态、显示前去预约
        {
            cell.actionButton.hidden = NO;
            [cell.actionButton setTitle:text forState:UIControlStateNormal];
        }
        
        [cell.commentButton setTitle:text1 forState:UIControlStateNormal];
        cell.commentButton.actionType = type;
        
    }
    else if ([title isEqualToString:TableView_title_DaiFu])//待付款
    {
        [cell.commentButton setTitle:@"去支付" forState:UIControlStateNormal];
        cell.commentButton.actionType = ORDERACTIONTYPE_Pay;
        
    }else if ([title isEqualToString:TableView_title_Payed])//已付款  根据实际订单状态判断 前去预约 还是 再次购买
    {
        //已付款
        BOOL is_appoint = [aModel.is_appoint boolValue];
        if (is_appoint) {
            [cell.commentButton setTitle:@"前去预约" forState:UIControlStateNormal];
            cell.commentButton.actionType = ORDERACTIONTYPE_Appoint;
        }else
        {
            [cell.commentButton setTitle:@"已预约" forState:UIControlStateNormal];
            cell.commentButton.actionType = ORDERACTIONTYPE_Default;
            
            cell.actionButton.hidden = NO;
            [cell.actionButton setTitle:@"再次购买" forState:UIControlStateNormal];
            cell.actionButton.actionType = ORDERACTIONTYPE_BuyAgain;
        }
        
    }else if ([title isEqualToString:TableView_title_TuiHuan])//退换
    {
        [cell.commentButton setTitle:text forState:UIControlStateNormal];
        
    }else if ([title isEqualToString:TableView_title_WanCheng]) //完成
    {
        [cell.commentButton setTitle:@"再次购买" forState:UIControlStateNormal];
        cell.actionButton.hidden = NO;
        cell.actionButton.actionType = ORDERACTIONTYPE_Comment;
        
        //代表已评价
        if ([aModel.is_comment intValue] == 0) {
            cell.actionButton.hidden = NO;
        }else
        {
            cell.actionButton.hidden = YES;
        }
        
        cell.commentButton.actionType = ORDERACTIONTYPE_BuyAgain;
    }
    
    [cell.actionButton addTarget:self action:@selector(clickToAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.commentButton addTarget:self action:@selector(clickToAction:) forControlEvents:UIControlEventTouchUpInside];
        
    return cell;
}

#pragma - mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
        
    int page = floor((scrollView.contentOffset.x - DEVICE_WIDTH / 2) / DEVICE_WIDTH) + 1;//只要大于半页就算下一页
    //选中状态
    [self controlSelectedButtonTag:page + 100];

}


@end
