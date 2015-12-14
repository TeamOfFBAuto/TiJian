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
#define TABLEVIEW_TAG_DaiFu 0 //待付款
#define TABLEVIEW_TAG_NoAppoint 1 //待预约
#define TABLEVIEW_TAG_Appointed 2 //已预约
#define TABLEVIEW_TAG_WanCheng 3 //完成
#define TABLEVIEW_TAG_TuiHuan 4 //退换

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

    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"我的订单";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    NSArray *titles = @[@"待付款",@"待预约",@"已预约",@"已完成",@"退换"];
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
        _table.tag = 200 + i;
        
        [_table reloadData:nil pageSize:10 noDataView:[self noDataView]];
        
    }
    
    _indicator = [[UIView alloc]initWithFrame:CGRectMake(0, 38, width, 2)];
    _indicator.backgroundColor = DEFAULT_TEXTCOLOR;
    [self.view addSubview:_indicator];
    
    //默认选中第一个
    [self controlSelectedButtonTag:100];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForPaySuccess:) name:NOTIFICATION_PAY_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForRecieveConfirm:) name:NOTIFICATION_RECIEVE_CONFIRM object:nil];//确认收货
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForCancelOrder:) name:NOTIFICATION_ORDER_CANCEL object:nil];//取消订单
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForDelOrder:) name:NOTIFICATION_ORDER_DEL object:nil];//删除订单
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForTuiKuan:) name:NOTIFICATION_TUIKUAN_SUCCESS object:nil];//退款

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 通知处理

/**
 *  支付成功通知
 *
 *  @param notify
 */
- (void)notificationForPaySuccess:(NSNotification *)notify
{
    //支付成功 更新
    
    [[self refreshTableForIndex:TABLEVIEW_TAG_DaiFu]showRefreshHeader:YES];//待付款
    [[self refreshTableForIndex:TABLEVIEW_TAG_NoAppoint]showRefreshHeader:YES];//
}

/**
 *  确认收货通知
 */
- (void)notificationForRecieveConfirm:(NSNotification *)notify
{
//    [[self refreshTableForIndex:TABLEVIEW_TAG_NoComment]showRefreshHeader:YES];//配送
    [[self refreshTableForIndex:TABLEVIEW_TAG_WanCheng]showRefreshHeader:YES];//完成
}

/**
 *  取消订单通知 只有待付款可以取消订单
 */
- (void)notificationForCancelOrder:(NSNotification *)notify
{
    [[self refreshTableForIndex:TABLEVIEW_TAG_DaiFu]showRefreshHeader:YES];//待付款
}

/**
 *  删除订单通知 完成的可以删除
 */
- (void)notificationForDelOrder:(NSNotification *)notify
{
    [[self refreshTableForIndex:TABLEVIEW_TAG_WanCheng]showRefreshHeader:YES];//待评价
}

/**
 *  退款通知刷新待付款和退换
 *
 */
- (void)notificationForTuiKuan:(NSNotification *)notify
{
    
    [[self refreshTableForIndex:TABLEVIEW_TAG_NoAppoint]showRefreshHeader:YES];//待付款
    [[self refreshTableForIndex:TABLEVIEW_TAG_TuiHuan]showRefreshHeader:YES];//退货列表
}

#pragma - mark 网络请求

/**
 *  获取订单列表
 *
 *  @param orderType 不同的订单状态
 */
- (void)getOrderListWithStatus:(ORDERTYPE)orderType
{
    NSString *authey = [UserInfo getAuthkey];
    if (authey.length == 0) {
        return;
    }
    NSString *status = nil;
    switch (orderType) {
        case ORDERTYPE_DaiFu:
            status = @"no_pay";
            break;
        case ORDERTYPE_NoAppoint:
            status = @"no_appointment";
            break;
        case ORDERTYPE_Appointed:
            status = @"appointment";
            break;
        case ORDERTYPE_WanCheng:
            status = @"complete";
            break;
        case ORDERTYPE_TuiHuan:
            status = @"refund";
            break;
        default:
            break;
    }
    __weak typeof(RefreshTableView)*weakTable = [self refreshTableForIndex:orderType - 1];
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
        comment.dingdanhao = aModel.order_id;
        comment.theModelArray = temp;
        [self.navigationController pushViewController:comment animated:YES];
        
    }else if (actionType == ORDERACTIONTYPE_Pay){
        //支付
        [self pushToPayPageWithOrderId:aModel.order_id orderNum:aModel.order_no sumPrice:[aModel.total_fee floatValue] payStyle:[aModel.pay_type intValue]];
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
        NSLog(@"请求数据 %d",index);
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
    
    __weak typeof(_scroll)weakScroll = _scroll;
    [UIView animateWithDuration:0.1 animations:^{
       
        [weakScroll setContentOffset:CGPointMake(DEVICE_WIDTH * (sender.tag - 100), 0)];
    }];
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

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    int tableTag = (int)tableView.tag - 200 + 1;
    
    [self getOrderListWithStatus:tableTag];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    int tableTag = (int)tableView.tag - 200 + 1;
    
    [self getOrderListWithStatus:tableTag];
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

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView
{
    
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
    
    if (indexPath.row < table.dataArray.count) {
        
        OrderModel *aModel = [table.dataArray objectAtIndex:indexPath.row];
        [cell setCellWithModel:aModel];
        
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
    }
    
    cell.actionButton.hidden = YES;

    int tableViewTag = (int)tableView.tag;
    switch (tableViewTag) {
        case TABLEVIEW_TAG_DaiFu + 200:
        {
            [cell.commentButton setTitle:@"去支付" forState:UIControlStateNormal];
            cell.commentButton.actionType = ORDERACTIONTYPE_Pay;
        }
            break;
        case TABLEVIEW_TAG_NoAppoint + 200:
        {
            [cell.commentButton setTitle:@"前去预约" forState:UIControlStateNormal];
            cell.commentButton.actionType = ORDERACTIONTYPE_Appoint;

        }
            break;
        case TABLEVIEW_TAG_Appointed + 200:
        {
            [cell.commentButton setTitle:@"再次购买" forState:UIControlStateNormal];
            cell.commentButton.actionType = ORDERACTIONTYPE_BuyAgain;
        }
            break;
        case TABLEVIEW_TAG_WanCheng + 200:
        {
            [cell.commentButton setTitle:@"再次购买" forState:UIControlStateNormal];
            cell.actionButton.hidden = NO;
            cell.actionButton.actionType = ORDERACTIONTYPE_Comment;
            cell.commentButton.actionType = ORDERACTIONTYPE_BuyAgain;
            [cell.actionButton addTarget:self action:@selector(clickToAction:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case TABLEVIEW_TAG_TuiHuan + 200:
        {
            [cell.commentButton setTitle:text forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    
    [cell.commentButton addTarget:self action:@selector(clickToAction:) forControlEvents:UIControlEventTouchUpInside];
        
    return cell;
}

#pragma - mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
        
    int page = floor((scrollView.contentOffset.x - DEVICE_WIDTH / 2) / DEVICE_WIDTH) + 1;//只要大于半页就算下一页
    NSLog(@"page %d",page);
    //选中状态
    [self controlSelectedButtonTag:page + 100];
    
}


@end
