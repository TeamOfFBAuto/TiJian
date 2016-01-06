//
//  MessageCenterController.m
//  TiJian
//
//  Created by lichaowei on 16/1/5.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "MessageCenterController.h"
#import "MessageViewController.h"
#import "ActivityCell.h"

#define TableView_tag_Notification 200 //通知
#define TableView_tag_Activity 202 //活动

@interface MessageCenterController ()<RefreshDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    int _buttonNum;//button个数
    UIView *_indicator;//指示器
    UIScrollView *_scroll;
}

@end

@implementation MessageCenterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"消息中心";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    NSArray *titles = @[@"通知",@"客服",@"活动"];
    int count = (int)titles.count;
    CGFloat left = 30.f;
    CGFloat width = (DEVICE_WIDTH - left * 2) / count;
    _buttonNum = count;
    
    _scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 50)];
    _scroll.delegate = self;
    _scroll.contentSize = CGSizeMake(DEVICE_WIDTH * count, _scroll.height);
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.pagingEnabled = YES;
    [self.view addSubview:_scroll];
    
    //scrollView 和 系统手势冲突问题
    [_scroll.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    
    UIView *sectionBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
    sectionBgView.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [self.view addSubview:sectionBgView];
    
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(left, 10, DEVICE_WIDTH - left * 2, 30)];
    sectionView.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [sectionBgView addSubview:sectionView];
    [sectionView addCornerRadius:5.f];
    sectionView.clipsToBounds = YES;
    [sectionView setBorderWidth:1.f borderColor:DEFAULT_TEXTCOLOR];
    
    for (int i = 0; i < count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [sectionView addSubview:btn];
        btn.tag = 100 + i;
        btn.frame = CGRectMake(width * i, 0, width, 30);
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn addTarget:self action:@selector(clickToSelect:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor whiteColor];
        [btn setBorderWidth:0.5 borderColor:DEFAULT_TEXTCOLOR];
        btn.selected = YES;
        
        if (i == 1) {
            MessageViewController *chatService = [[MessageViewController alloc] init];
            chatService.view.frame = CGRectMake(DEVICE_WIDTH * i, 0, DEVICE_WIDTH,_scroll.height);
            [_scroll addSubview:chatService.view];
            [self addChildViewController:chatService];
        }else
        {
            RefreshTableView *_table = [[RefreshTableView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH * i, 0, DEVICE_WIDTH,_scroll.height)];
            _table.refreshDelegate = self;
            _table.dataSource = self;
            _table.separatorStyle = UITableViewCellSeparatorStyleNone;
            [_scroll addSubview:_table];
            _table.tag = 200 + i;
        }
    }
    
//    _indicator = [[UIView alloc]initWithFrame:CGRectMake(0, 38, width, 2)];
//    _indicator.backgroundColor = DEFAULT_TEXTCOLOR;
//    [self.view addSubview:_indicator];
    
    //默认选中第一个
    [self controlSelectedButtonTag:100];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

#pragma - mark 通知处理


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
            
//            OrderModel *aModel = [[OrderModel alloc]initWithDictionary:aDic];
//            [temp addObject:aModel];
        }
        
//        [weakTable reloadData:temp pageSize:10 noDataView:[self noDataView]];
        
    } failBlock:^(NSDictionary *result) {
//        [weakTable reloadData:nil pageSize:10 noDataView:[self noDataView]];
        
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
    imageV.image = [UIImage imageNamed:@"hema_heart"];
    [view addSubview:imageV];
    imageV.centerX = view.width/2.f;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, imageV.bottom + 20, DEVICE_WIDTH, 30) title:@"暂无数据" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"646464"]];
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
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, imageV.bottom + 20, DEVICE_WIDTH, 30) title:@"暂无数据" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"646464"]];
    [view addSubview:label];
    
    return view;
}

#pragma - mark 事件处理

/**
 *  去支付 确认收货 评价 再次购买
 *
 *  @param sender
 */
- (void)clickToAction:(PropertyButton *)sender
{
    
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
        UIButton *btn = [self buttonForTag:100 + i];
        btn.selected = (i + 100 == tag) ? YES : NO;
        
        if (btn.selected) {
            btn.backgroundColor = DEFAULT_TEXTCOLOR;
        }else
        {
            btn.backgroundColor = [UIColor whiteColor];
        }
    }
    
    __weak typeof(_indicator)weakIndicator = _indicator;
    [UIView animateWithDuration:0.1 animations:^{
        
        weakIndicator.left = DEVICE_WIDTH / _buttonNum * (tag - 100);
    }];
    
//    int index = tag - 100;
//    if (![self refreshTableForIndex:index].isHaveLoaded) {
//        NSLog(@"请求数据 %d",index);
//        [[self refreshTableForIndex:index] showRefreshHeader:YES];
//    }
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
//    OrderModel *aModel = [((RefreshTableView *)tableView).dataArray objectAtIndex:indexPath.row];
//    
//    OrderInfoViewController *orderInfo = [[OrderInfoViewController alloc]init];
//    orderInfo.order_id = aModel.order_id;
//    orderInfo.lastViewController = self;
//    [self.navigationController pushViewController:orderInfo animated:YES];
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    if (tableView.tag == TableView_tag_Notification) {
        return 60.f;
    }else if (tableView.tag == TableView_tag_Activity){
        return [ActivityCell heightForCellWithImage:YES content:@"这是活动的标摘要部分这是活动的标摘要部分这是活动的标摘要部分这是活动的标摘要部分这是活动的标摘要部分这是活动的标摘要部分"];
    }
    return 60.f;
}

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

#pragma - mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RefreshTableView *refreshTable = (RefreshTableView *)tableView;
    return refreshTable.dataArray.count + 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //通知
    if (tableView.tag == TableView_tag_Notification) {
        static NSString *identify = @"notification";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 55)];
            bgView.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:bgView];
            
            UIImageView *iconView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 13, 32, 32)];
            iconView.image = [UIImage imageNamed:@"message_baogao"];
            [cell.contentView addSubview:iconView];
            iconView.tag = 300;
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(iconView.right + 10, 13, DEVICE_WIDTH - iconView.right - 10 - 90, 14) title:nil font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE];
            [cell.contentView addSubview:titleLabel];
            titleLabel.tag = 301;
            
            UILabel *subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(iconView.right + 10, titleLabel.bottom + 6, DEVICE_WIDTH - iconView.right - 10 - 10, 13) title:nil font:11 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB];
            [cell.contentView addSubview:subTitleLabel];
            subTitleLabel.tag = 302;
            
            UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 10 - 40, titleLabel.top, 40, 13) title:nil font:11 align:NSTextAlignmentRight textColor:DEFAULT_TEXTCOLOR_TITLE_SUB];
            [cell.contentView addSubview:timeLabel];
            timeLabel.tag = 303;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
        UIImageView *iconView = [cell.contentView viewWithTag:300];
        UILabel *titleLabel = [cell.contentView viewWithTag:301];
        UILabel *subTitleLabel = [cell.contentView viewWithTag:302];
        UILabel *timeLabel = [cell.contentView viewWithTag:303];

        titleLabel.text = @"听ask卡三季度可垃圾是看得见阿克苏来得及克拉撒娇的卡老实交代克拉斯加抵抗力";
        subTitleLabel.text = @"听ask卡三季度可垃圾是看得见阿克苏来得及克拉撒娇的卡老实交代克拉斯加抵抗力";
        timeLabel.text = @"12-30";
        
        return cell;
    }
    
    if (tableView.tag == TableView_tag_Activity) {
        
        static NSString *identify = @"ActivityCell";
        ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[ActivityCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setCellWithModel:nil];
        
        return cell;
    }
    
    static NSString *identify = @"OrderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

#pragma - mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    int page = floor((scrollView.contentOffset.x - DEVICE_WIDTH / 2) / DEVICE_WIDTH) + 1;//只要大于半页就算下一页
    //选中状态
    [self controlSelectedButtonTag:page + 100];
    
}


@end
