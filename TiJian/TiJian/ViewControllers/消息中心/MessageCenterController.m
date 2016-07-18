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
#import "MessageModel.h"
#import "ReportDetailController.h"//体检报告
#import "OrderInfoViewController.h"//订单详情
#import "AppointDetailController.h"//预约详情
#import "NSDate+FSExtension.h"
#import "WebviewController.h"
#import "GoHealthProductDetailController.h"//go健康服务详情

#define TableView_tag_Notification 200 //通知
#define TableView_tag_Activity 202 //活动

#define Tag_redpoint 400 //红点

@interface MessageCenterController ()<RefreshDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    int _buttonNum;//button个数
    UIView *_indicator;//指示器
    UIScrollView *_scroll;
}

@end

@implementation MessageCenterController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"消息中心";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
//    NSArray *titles = @[@"通知",@"客服",@"活动"];
    NSArray *titles = @[@"通知",@"客服"];
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
        
        //第一个不显示红点
        if (i != 0) {
            
            //红点
            CGFloat width = 6.f;
            UIView *point = [[UIView alloc]initWithFrame:CGRectMake(btn.width/2.f + 15, 5, width, width)];
            [btn addSubview:point];
            point.backgroundColor = [UIColor colorWithHexString:@"ec2120"];
            [point setBorderWidth:0.5f borderColor:[UIColor whiteColor]];
            [point addRoundCorner];
            point.tag = Tag_redpoint + i;
            
            int num = 0;
            if (i == 0) {
                num = [[LTools objectForKey:USER_Notice_Num]intValue];
            }else if (i == 1){
                
                num = [LTools rongCloudUnreadNum];
                
            }
            if (num > 0) {
                point.hidden = NO;
            }else
            {
                point.hidden = YES;
            }
        }
        
        
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
    
    //活动未读数量
//    [self getUnreadActivityNum];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 通知处理


#pragma - mark 网络请求

/**
 *  获取通知列表
 *
 *  @param
 */
- (void)getListWithIndex:(int)index
{
    NSString *authey = [UserInfo getAuthkey];
    if (authey.length == 0) {
        return;
    }
    
    __weak typeof(RefreshTableView)*weakTable = [self refreshTableForIndex:index];
    NSString *api = GET_MY_MSG;
    NSString *sort;
    if (index == 0) {
        sort = @"notice";//notice: 包含type=2, 4, 5, 6
    }else if (index == 2){
        //活动
        sort = @"ac";
    }
    
    NSDictionary *params = @{@"authcode":authey,
                             @"per_page":[NSNumber numberWithInt:10],
                             @"page":[NSNumber numberWithInt:weakTable.pageNum],
                             @"sort":sort};
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *list = result[@"list"];
        NSArray *temp = [MessageModel modelsFromArray:list];
        
       [weakTable reloadData:temp pageSize:10 noDataView:[self noDataView]];
        
        //获取列表请求成功
        if (index == 2){
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATEMSGNUM object:nil];//更新消息未读个数
        }
        
    } failBlock:^(NSDictionary *result) {
        [weakTable reloadData:nil pageSize:10 noDataView:[self noDataView]];
        
    }];
    
}

/**
 *  获取未读活动数量
 *
 *  @param
 */
- (void)getUnreadActivityNum
{
    NSString *authey = [UserInfo getAuthkey];
    if (authey.length == 0) {
        return;
    }
    
    NSString *api = GET_MSG_NUM;
    NSString *sort = @"ac"; //活动
    
    NSDictionary *params = @{@"authcode":authey,
                             @"sort":sort};
     @WeakObj(self);
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        int num = [result[@"count"]intValue];
        [Weakself buttonForTag:Tag_redpoint + 2].hidden = num > 0 ? NO : YES;
        
    } failBlock:^(NSDictionary *result) {
        
    }];
}

/**
 *  更新活动未读状态
 *
 *  @param
 */
- (void)updateActivityStatusWithMsgId:(NSString *)msgId
                              msgType:(MsgType)type
{
    NSString *authey = [UserInfo getAuthkey];
    if (authey.length == 0 || [LTools isEmpty:msgId]) {
        return;
    }
    NSString *api = UPDATE_MSG_STATUE;
    NSDictionary *params = @{@"authcode":authey,
                             @"msg_id":msgId};
    @WeakObj(self);
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result)
    {
        DDLOG(@"update success");
        [Weakself updateMsgNumType:type];

    } failBlock:^(NSDictionary *result) {
        
    }];
}

/**
 *  没有数据自定义view
 *
 *  @return
 */
- (UIView *)noDataView
{
    
    ResultView *result = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"] title:@"暂无通知消息" content:nil];
    
    return result;
}


#pragma - mark 事件处理
/**
 *  更新未读通知
 */
- (void)updateMsgNumType:(MsgType)type
{
    int num = [[LTools objectForKey:USER_MSG_NUM]intValue];
    if (num > 0) {
        num --;
    }else
    {
        num = 0;
    }
    
    if (type == MsgType_Activity)//活动
    {
        int num_ac = [[LTools objectForKey:USER_Ac_Num]intValue];
        
        if (num_ac > 0) {
            num_ac --;
        }else
        {
            num_ac = 0;
        }
        [LTools setObject:[NSNumber numberWithInt:num_ac] forKey:USER_Ac_Num];
        
    }else //除了活动的通知
    {
        int num_notice = [[LTools objectForKey:USER_Notice_Num]intValue];
        if (num_notice > 0) {
            num_notice --;
        }else
        {
            num_notice = 0;
        }
        [LTools setObject:[NSNumber numberWithInt:num_notice] forKey:USER_Notice_Num];

    }
    
    [LTools setObject:[NSNumber numberWithInt:num] forKey:USER_MSG_NUM];
    [LTools updateTabbarUnreadMessageNumber];
}

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
            [btn viewWithTag:Tag_redpoint + i].hidden = YES;//隐藏红点
        }else
        {
            btn.backgroundColor = [UIColor whiteColor];
        }
    }
    
    __weak typeof(_indicator)weakIndicator = _indicator;
    [UIView animateWithDuration:0.1 animations:^{
        
        weakIndicator.left = DEVICE_WIDTH / _buttonNum * (tag - 100);
    }];
    
    int index = tag - 100;
    if (![self refreshTableForIndex:index].isHaveLoaded) {
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
    int index = (int)tableView.tag - 200;
    [self getListWithIndex:index];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    int index = (int)tableView.tag - 200;
    [self getListWithIndex:index];
}

//新加
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(RefreshTableView *)tableView
{
    //消息通知
    if (tableView.tag == TableView_tag_Notification) {
        MessageModel *msg = tableView.dataArray[indexPath.row];
        MsgType type = [msg.type intValue];
        
        PlatformType platformType = PlatformType_default;//默认 0 海马体检商城
        if ([msg.app_id intValue] == 2) {
            platformType = PlatformType_goHealth;//为2是go健康的订单
        }
         @WeakObj(self);
         @WeakObj(tableView);
         @WeakObj(msg);
        if (type == MsgType_PEReportReadFinish) //报告解读完成
        {
            //报告详情页
            ReportDetailController *detail = [[ReportDetailController alloc]init];
            detail.reportId = msg.theme_id;
            if ([msg.is_read intValue] == 1) { //未读的时候才传
                detail.msg_id = msg.msg_id;
                detail.updateParamsBlock = ^(NSDictionary *params){
                    Weakmsg.is_read = @"2";
                    [WeaktableView reloadData];
                    [Weakself updateMsgNumType:type];
                };
            }
            [self.navigationController pushViewController:detail animated:YES];
            
        }else if (type == MsgType_OrderRefundState){ //订单申请退款
            
            OrderInfoViewController *orderInfo = [[OrderInfoViewController alloc]init];
            orderInfo.order_id = msg.theme_id;
            orderInfo.lastViewController = self;
            orderInfo.platformType = platformType;
            if ([msg.is_read intValue] == 1) { //未读的时候才传
                orderInfo.msg_id = msg.msg_id;
                orderInfo.updateParamsBlock = ^(NSDictionary *params){
                    Weakmsg.is_read = @"2";
                    [WeaktableView reloadData];
                    [Weakself updateMsgNumType:type];
                };
            }
            [self.navigationController pushViewController:orderInfo animated:YES];
            
        }else if (type == MsgType_PEAlert){ //体检提醒
            
            AppointDetailController *detail = [[AppointDetailController alloc]init];
            detail.appoint_id = msg.theme_id;
            if ([msg.is_read intValue] == 1) { //未读的时候才传
                detail.msg_id = msg.msg_id;
                detail.updateParamsBlock = ^(NSDictionary *params){
                    Weakmsg.is_read = @"2";
                    [WeaktableView reloadData];
                    [Weakself updateMsgNumType:type];
                };
            }
            [self.navigationController pushViewController:detail animated:YES];
        }else if (type == MsgType_GoHealthAppointState) //go健康预约状态
        {
            NSString *url = msg.url;
            if (![LTools isEmpty:url]) //说明出报告了
            {
                @WeakObj(self);
                [MiddleTools pushToWebFromViewController:self weburl:msg.url extensionParams:@{Share_title:@"体检报告"} moreInfo:NO hiddenBottom:YES updateParamsBlock:^(NSDictionary *params) {
                    //更新未读状态
                    [Weakself updateActivityStatusWithMsgId:msg.msg_id msgType:type];
                }];
            }else
            {
                NSString *serviceId = msg.theme_id;
                NSString *productId = msg.productId;
                NSString *orderNum  = msg.orderNum;
                GoHealthProductDetailController *detail = [[GoHealthProductDetailController alloc]init];
                detail.detailType = DetailType_serviceDetail;
                detail.serviceId = serviceId;
                detail.productId = productId;
                detail.orderNum = orderNum;
                if ([msg.is_read intValue] == 1) { //未读的时候才传
                    detail.updateParamsBlock = ^(NSDictionary *params){
                        Weakmsg.is_read = @"2";
                        [WeaktableView reloadData];
                        if (![LTools isEmpty:msg.msg_id]) {
                            [Weakself updateActivityStatusWithMsgId:msg.msg_id msgType:type];
                        }
                    };
                }
                [self.navigationController pushViewController:detail animated:YES];
            }
        }
    }
    //活动详情
    else if (tableView.tag == TableView_tag_Activity){
        
        MessageModel *aModel = tableView.dataArray[indexPath.row];
        NSString *shareImageUrl = aModel.pic;
        NSString *shareTitle = aModel.title;
        NSString *shareContent = aModel.summary;
        NSDictionary *params = @{Share_imageUrl:shareImageUrl ? : @"",
                                 Share_title:shareTitle,
                                 Share_content:shareContent};
        @WeakObj(self);
        [MiddleTools pushToWebFromViewController:self weburl:aModel.url extensionParams:params moreInfo:YES hiddenBottom:YES updateParamsBlock:^(NSDictionary *params) {
            //更新未读状态
            //更新未读状态
            if ([params[@"result"]boolValue]) {
                [Weakself updateActivityStatusWithMsgId:aModel.msg_id msgType:MsgType_Activity];
            }
        }];
    }
}

- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(RefreshTableView *)tableView
{
    if (tableView.tag == TableView_tag_Notification) {
        return 60.f;
    }else if (tableView.tag == TableView_tag_Activity){
        
        MessageModel *aModel = tableView.dataArray[indexPath.row];
        BOOL image;
        if (aModel.pic && [aModel.pic hasPrefix:@"http"]) {
            image = YES;
        }
        return [ActivityCell heightForCellWithImage:image content:aModel.content];
    }
    return 60.f;
}

-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(RefreshTableView *)tableView
{
    return 5.f;
}
-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(RefreshTableView *)tableView
{
    return [UIView new];
}

#pragma - mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RefreshTableView *refreshTable = (RefreshTableView *)tableView;
    return refreshTable.dataArray.count;
}

- (UITableViewCell *)tableView:(RefreshTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
            
            CGFloat width = 8.f;
            UIView *point = [[UIView alloc]initWithFrame:CGRectMake(iconView.width - width/2.f, -width/2.f, 8, 8)];
            [iconView addSubview:point];
            point.backgroundColor = [UIColor colorWithHexString:@"ec2120"];
            [point setBorderWidth:1.f borderColor:[UIColor whiteColor]];
            [point addRoundCorner];
            point.tag = 304;
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(iconView.right + 10, 13, DEVICE_WIDTH - iconView.right - 10 - 90, 14) title:nil font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE];
            [cell.contentView addSubview:titleLabel];
            titleLabel.font = [UIFont boldSystemFontOfSize:13];
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
        UIView *point = [cell.contentView viewWithTag:304];

        MessageModel *msg = [tableView.dataArray objectAtIndex:indexPath.row];
        titleLabel.text = msg.title;
        subTitleLabel.text = msg.content;
        timeLabel.text = [LTools showIntervalTimeWithTimestamp:msg.send_time withFormat:@"yyyy-MM-dd"];
        
        point.hidden = [msg.is_read intValue] == 1 ? NO : YES;
        
        MsgType type = [msg.type intValue];
        if (type == MsgType_PEReportReadFinish || //报告解读完成
            type == MsgType_PEProgress) {  //体检报告进度
            
            iconView.image = [UIImage imageNamed:@"message_baogao"];
        }else if (type == MsgType_OrderRefundState){
            iconView.image = [UIImage imageNamed:@"message_tuikuan"];
        }else if (type == MsgType_PEAlert){
            iconView.image = [UIImage imageNamed:@"message_yuyue"];
        }
        
        return cell;
    }
    
    if (tableView.tag == TableView_tag_Activity) {
        
        static NSString *identify = @"ActivityCell";
        ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[ActivityCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        MessageModel *aModel = [tableView.dataArray objectAtIndex:indexPath.row];
        
        [cell setCellWithModel:aModel];
        
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
