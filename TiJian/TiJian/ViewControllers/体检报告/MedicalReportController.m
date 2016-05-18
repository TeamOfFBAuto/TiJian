//
//  MedicalReportController.m
//  TiJian
//
//  Created by lichaowei on 15/12/4.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "MedicalReportController.h"
#import "AddReportViewController.h"
#import "ReportDetailController.h"

@interface MedicalReportController ()<RefreshDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    RefreshTableView *_table;
}

@property(nonatomic,retain)ResultView *nodataView;//未登录view
@property(nonatomic,retain)UIButton *stateButton;//结果页的按钮

@end

@implementation MedicalReportController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"体检报告";
    self.rightImage = [UIImage imageNamed:@"personal_jiaren_tianjia"];
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeOther];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotify:) name:NOTIFICATION_REPORT_ADD_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotify:) name:NOTIFICATION_REPORT_DEL_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotify:) name:NOTIFICATION_LOGOUT object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotify:) name:NOTIFICATION_LOGIN object:nil];
    
    [self prepareRefreshTableView];
    
    if ([LoginManager isLogin]) {
        
        [_table showRefreshHeader:YES];
    }else
    {
        [_table reloadData:nil pageSize:0 noDataView:[self resultViewWithType:PageResultType_nologin]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 通知

- (void)actionForNotify:(NSNotification *)notify
{
    [_table refreshNewData];
}

#pragma mark - 视图创建

- (void)prepareRefreshTableView
{
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 49) style:UITableViewStylePlain];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];
}

-(ResultView *)resultViewWithType:(PageResultType)type
{
    NSString *content;
    NSString *btnTitle;
    SEL selector = NULL;
    if (type == PageResultType_requestFail) {
        
        content = @"获取数据异常,点击重新加载";
        btnTitle = @"重新加载";
        selector = @selector(clickToResfresh);
        
    }else if (type == PageResultType_nodata){
        
        content = @"您还没有上传过体检报告,赶快去上传吧";
        btnTitle = @"立即上传";
        selector = @selector(clickToUploadReport);
        
    }else if (type == PageResultType_nologin){
        
        content = @"登录后可查询上传的体检报告";
        btnTitle = @"登录";
        selector = @selector(clickToLogin);
    }
    
    if (_nodataView) {
        
        [_nodataView setContent:content];
        [self.stateButton setTitle:btnTitle forState:UIControlStateNormal];
        
        return _nodataView;
    }
    
    ResultView *result = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"]
                                                    title:@"温馨提示"
                                                  content:content];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 140, 36);
    [btn addCornerRadius:5.f];
    btn.backgroundColor = DEFAULT_TEXTCOLOR;
    [btn setTitle:btnTitle forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [result setBottomView:btn];
    
    self.stateButton = btn;
    
    self.nodataView = result;
    
    return result;
}

#pragma mark - 网络请求

- (void)deleteReportId:(NSString *)reportId
{
    if (!reportId) {
        [LTools showMBProgressWithText:@"报告不存在" addToView:self.view];
        return;
    }
    NSDictionary *params = @{@"authcode":[UserInfo getAuthkey],
                             @"report_id":reportId};;
    NSString *api = REPORT_DEL;
    
    __weak typeof(self)weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        if ([result[RESULT_CODE]intValue] == 0) {
            
            [LTools showMBProgressWithText:@"删除报告成功" addToView:weakSelf.view];
        }
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];

}

- (void)netWorkForList
{
    if (![LoginManager isLogin]) {
        
        [_table reloadData:nil pageSize:G_PER_PAGE noDataView:[self resultViewWithType:PageResultType_nologin]];

        return;
    }
    
    NSDictionary *params = @{@"authcode":[UserInfo getAuthkey],
                                 @"page":NSStringFromInt(_table.pageNum),
                             @"per_page":NSStringFromInt(G_PER_PAGE)};;
    NSString *api = REPORT_LIST;
    
    __weak typeof(self)weakSelf = self;
    __weak typeof(_table)weakTable = _table;

    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        DDLOG(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        NSArray *temp = [UserInfo modelsFromArray:result[@"list"]];
        [weakTable reloadData:temp pageSize:G_PER_PAGE noDataView:[weakSelf resultViewWithType:PageResultType_nodata]];
        
    } failBlock:^(NSDictionary *result) {
        
        DDLOG(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        [weakTable reloadData:nil pageSize:G_PER_PAGE noDataView:[weakSelf resultViewWithType:PageResultType_requestFail]];
    }];
}

#pragma mark - 数据解析处理

#pragma mark - 事件处理

- (void)clickToResfresh
{
    [_table showRefreshHeader:YES];
}

- (void)clickToLogin
{
    [LoginManager isLogin:self loginBlock:^(BOOL success) {
       
        if (success) {
            [_table showRefreshHeader:YES];
        }
    }];
}

/**
 *  去上传报告
 */
- (void)clickToUploadReport
{
    [LoginManager isLogin:self loginBlock:^(BOOL success) {
        if (success) {
            
            AddReportViewController *add = [[AddReportViewController alloc]init];
            add.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:add animated:YES];
        }
    }];
}

- (void)rightButtonTap:(UIButton *)sender
{
    [self clickToUploadReport];
}

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
    UserInfo *user = _table.dataArray[indexPath.row];
    
    int type = [user.type intValue];
    if (type == 2) {
        
        NSString *url = [NSString stringWithFormat:@"%@",user.url];
        [MiddleTools pushToWebFromViewController:self weburl:url title:@"体检报告" moreInfo:NO hiddenBottom:YES];
        return;
    }
    ReportDetailController *detail = [[ReportDetailController alloc]init];
    detail.reportId = user.report_id;
    detail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detail animated:YES];
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    return 55.f + 5.f;
}

-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(RefreshTableView *)tableView
{
    return 5.f;
}

-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(RefreshTableView *)tableView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5)];
    view.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    return view;
}

#pragma - mark UITableViewDataSource

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return tableView.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"identify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 55)];
        view.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:view];
        
        UIImageView *iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 55, 55)];
        iconImage.image = [UIImage imageNamed:@"report_b"];
        iconImage.contentMode = UIViewContentModeCenter;
        [view addSubview:iconImage];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(iconImage.right, 11, 200, 16) title:nil font:15 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE];
        [view addSubview:titleLabel];
        titleLabel.tag = 200;
        
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(iconImage.right, titleLabel.bottom, titleLabel.width, 20) title:nil font:12 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB];
        [view addSubview:timeLabel];
        timeLabel.tag = 201;
        
        //箭头
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 35, 0, 35, 55)];
        arrow.image = [UIImage imageNamed:@"personal_jiantou_r"];
        arrow.contentMode = UIViewContentModeCenter;
        [view addSubview:arrow];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    UILabel *titleLabel = [cell.contentView viewWithTag:200];
    UILabel *timeLabel = [cell.contentView viewWithTag:201];
    UserInfo *user = _table.dataArray[indexPath.row];
    titleLabel.text = [NSString stringWithFormat:@"%@  %@的体检报告",user.appellation,user.family_user_name];
    timeLabel.text = user.checkup_time;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UserInfo *user = _table.dataArray[indexPath.row];

        NSString *title = [NSString stringWithFormat:@"是否确定删除(%@)的体检报告",user.family_user_name];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:title delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 100 + indexPath.row;
        [alert show];
    }
}

// 这里默认删除的按钮为英文，想要改变成中文，需要再实现一个方法。

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0){
    
    return @"删除";
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {

        int index = (int)alertView.tag - 100;
        UserInfo *user = _table.dataArray[index];
        //todo
        [_table.dataArray removeObjectAtIndex:index];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [_table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self deleteReportId:user.report_id];
        if (_table.dataArray.count == 0) {
            [_table reloadData:nil pageSize:G_PER_PAGE noDataView:self.resultView];
        }
    }
}

@end
