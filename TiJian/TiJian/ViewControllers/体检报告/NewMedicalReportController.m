//
//  NewMedicalReportController.m
//  TiJian
//
//  Created by lichaowei on 16/1/6.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "NewMedicalReportController.h"
#import "MedicalReportController.h"
#import "AddReportViewController.h"
#import "ReportDetailController.h"
#import "ArticleListController.h"
#import "QueryReportController.h"//查询报告
#import "ArticleModel.h"
#import "LSuitableView.h"

@interface NewMedicalReportController ()<RefreshDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    RefreshTableView *_table;
    NSArray *_articleArray;//体检资讯
    BOOL _moreReport;//更多报告
    BOOL _moreArticle;//更多体检常识
}

@property(nonatomic,retain)ResultView *nodataView;//未登录view
@property(nonatomic,retain)UIButton *stateButton;//结果页的按钮

@property(nonatomic,retain)UIView *noLoginView;//未登录
@property(nonatomic,retain)UIView *loginView;//登录

@end

@implementation NewMedicalReportController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"体检报告";
//    self.rightImage = [UIImage imageNamed:@"personal_jiaren_tianjia"];
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeNull WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotify:) name:NOTIFICATION_REPORT_ADD_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotify:) name:NOTIFICATION_REPORT_DEL_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotify:) name:NOTIFICATION_LOGOUT object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotify:) name:NOTIFICATION_LOGIN object:nil];
    
    [self prepareRefreshTableView];
    
    if ([LoginManager isLogin]) {
        
        _table.tableHeaderView = self.loginView;
    }else
    {
        _table.tableHeaderView = self.noLoginView;
    }
    
    [_table showRefreshHeader:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 通知

- (void)actionForNotify:(NSNotification *)notify
{
    //退出登录
    if ([notify.name isEqualToString:NOTIFICATION_LOGOUT]) {
        _table.tableHeaderView = self.noLoginView;
    }
    //登录
    else if ([notify.name isEqualToString:NOTIFICATION_LOGIN]){
        _table.tableHeaderView = self.loginView;
    }
    [_table refreshNewData];
}

#pragma mark - 视图创建
/**
 *  未登录view
 *
 *  @return
 */
-(UIView *)noLoginView
{
    if (!_noLoginView) {
        _noLoginView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 220)];
        _noLoginView.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
        
        //登录按钮
        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        loginBtn.backgroundColor = DEFAULT_TEXTCOLOR;
        loginBtn.frame = CGRectMake((DEVICE_WIDTH - 75)/2.f, 32, 75, 75);
        [_noLoginView addSubview:loginBtn];
        [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [loginBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [loginBtn addTarget:self action:@selector(clickToLogin) forControlEvents:UIControlEventTouchUpInside];
        [loginBtn addRoundCorner];
        
        //title
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, loginBtn.bottom + 22, DEVICE_WIDTH, 15) title:@"温馨提示" font:14 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE];
        [_noLoginView addSubview:titleLabel];
        
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, titleLabel.bottom + 5, DEVICE_WIDTH, 15) title:@"您还没有登录,登录后才能查看上传报告" font:12 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE_THIRD];
        [_noLoginView addSubview:contentLabel];
        
    }
    return _noLoginView;
}

/**
 *  登录view
 *
 *  @return
 */
-(UIView *)loginView
{
    if (!_loginView) {
        _loginView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 142)];
        _loginView.backgroundColor = [UIColor whiteColor];
        
        NSArray *images = @[[UIImage imageNamed:@"report_daoru"],
                            [UIImage imageNamed:@"report_tianjiabaogao"]];
        for (int i = 0; i < 2; i ++) {
            //登录按钮
            UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            loginBtn.backgroundColor = DEFAULT_TEXTCOLOR;
            loginBtn.frame = CGRectMake(0, 32, 90, 90);
            [_loginView addSubview:loginBtn];
            [loginBtn setImage:images[i] forState:UIControlStateNormal];
            [loginBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
            
            if (i == 0) {
                [loginBtn addTarget:self action:@selector(clickToQueryReport:) forControlEvents:UIControlEventTouchUpInside];
            }else if (i == 1){
                [loginBtn addTarget:self action:@selector(clickToUploadReport) forControlEvents:UIControlEventTouchUpInside];
            }
            
            [loginBtn addRoundCorner];
            
            loginBtn.centerX = (DEVICE_WIDTH / 4) * (i * 2 + 1);
        }
    }
    return _loginView;
}

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

/**
 *  显示疾病
 *
 *  @param array
 */
- (void)updateSickness:(NSArray *)array
{
    NSArray *titles = @[@"高血压",@"颈动脉斑块",@"甲状腺结节",@"眼底动脉硬化",@"心率不齐"];
    UIView *footer = [[UIView alloc]init];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH - 20, 35 + 0.5) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@"检后异常病症"];
    [footer addSubview:label];
    
    LSuitableView *suitable = [[LSuitableView alloc]initWithFrame:CGRectMake(10, label.bottom, DEVICE_WIDTH, 0) itemsArray:titles];
    [footer addSubview:suitable];
    footer.height = suitable.bottom;
    _table.tableFooterView = footer;
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
     @WeakObj(_table);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        if ([result[RESULT_CODE]intValue] == 0) {
            
            [LTools showMBProgressWithText:@"删除报告成功" addToView:weakSelf.view];
        }
        [Weak_table refreshNewData];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
    
}

/**
 *  体检报告 最多只显示三条
 */
- (void)netWorkForList
{
    if (![LoginManager isLogin]) {
        
        [_table reloadData:nil isHaveMore:NO];
        return;
    }
    
    NSDictionary *params = @{@"authcode":[UserInfo getAuthkey],
                             @"page":NSStringFromInt(_table.pageNum),
                             @"per_page":NSStringFromInt(4)};;
    NSString *api = REPORT_LIST;
    
    __weak typeof(self)weakSelf = self;
    __weak typeof(_table)weakTable = _table;
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        DDLOG(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        NSArray *temp = [UserInfo modelsFromArray:result[@"list"]];
        if (temp.count > 3) {
            _moreReport = YES;//有更多报告
            NSMutableArray *mu_arr = [NSMutableArray arrayWithArray:temp];
            [mu_arr removeLastObject];
            temp = [NSArray arrayWithArray:mu_arr];
        }else
        {
            _moreReport = NO;
        }
        [weakTable reloadData:temp isHaveMore:NO];
        
    } failBlock:^(NSDictionary *result) {
        
        DDLOG(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        [weakTable reloadData:nil pageSize:G_PER_PAGE noDataView:[weakSelf resultViewWithType:PageResultType_requestFail]];
    }];
}

/**
 *  体检常识
 */
- (void)netWorkForMeditalTestInfo
{
    
    NSDictionary *params = @{@"page":@"1",
                             @"per_page":@"10",
                             @"category_id":@"2"};;
    NSString *api = HEALTH_ACTICAL_LIST;
    
//    __weak typeof(self)weakSelf = self;
    __weak typeof(_table)weakTable = _table;
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        
        NSArray *temp = [ArticleModel modelsFromArray:result[@"article_list"]];
        if (temp.count > 3) {
            _moreArticle = YES;//有更多常识
            NSMutableArray *mu_arr = [NSMutableArray arrayWithArray:temp];
            [mu_arr removeLastObject];
            temp = [NSArray arrayWithArray:mu_arr];
        }else
        {
            _moreArticle = NO;
        }
        _articleArray = [NSArray arrayWithArray:temp];
        [weakTable reloadData];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        
    }];
}


/**
 *  异常疾病
 */
- (void)netWorkForSickness
{
    
    NSDictionary *params = @{@"page":@"1",
                             @"per_page":@"10",
                             @"category_id":@"2"};;
    NSString *api = HEALTH_ACTICAL_LIST;
    
    //    __weak typeof(self)weakSelf = self;
    __weak typeof(_table)weakTable = _table;
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        
        NSArray *temp = [ArticleModel modelsFromArray:result[@"article_list"]];
//        if (temp.count > 3) {
//            _moreArticle = YES;//有更多常识
//            NSMutableArray *mu_arr = [NSMutableArray arrayWithArray:temp];
//            [mu_arr removeLastObject];
//            temp = [NSArray arrayWithArray:mu_arr];
//        }else
//        {
//            _moreArticle = NO;
//        }
//        _articleArray = [NSArray arrayWithArray:temp];
//        [weakTable reloadData];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        
    }];
}


#pragma mark - 数据解析处理

#pragma mark - 事件处理

/**
 *  查看更多
 *
 *  @param sender
 */
- (void)clickToMore:(UIButton *)sender
{
    int index = (int)sender.tag - 500;
    if (index == 0) {
        //体检报告更多
        MedicalReportController *report = [[MedicalReportController alloc]init];
        report.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:report animated:YES];
    }else
    {
        //体检常识更多
        
        ArticleListController *list = [[ArticleListController alloc]init];
        list.category_id = @"2";
        list.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:list animated:YES];
    }
}

- (void)clickToResfresh
{
    [_table showRefreshHeader:YES];
}

- (void)clickToLogin
{
    [LoginManager isLogin:self];
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

/**
 *  查询报告
 *
 *  @param sender
 */
- (void)clickToQueryReport:(UIButton *)sender
{
    [LoginManager isLogin:self loginBlock:^(BOOL success) {
        if (success) {
            QueryReportController *query = [[QueryReportController alloc]init];
            query.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:query animated:YES];
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
//    [self netWorkForMeditalTestInfo];
    [self netWorkForSickness];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    [self netWorkForList];
//    [self netWorkForMeditalTestInfo];
    [self netWorkForSickness];
}
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    if (indexPath.section == 0) {
        
        if (_table.dataArray.count == 0) {
            return;
        }
        UserInfo *user = _table.dataArray[indexPath.row];
        int type = [user.type intValue];
        if (type == 2 || type == 3) {
            
            NSString *url = [NSString stringWithFormat:@"%@",user.url];
            [MiddleTools pushToWebFromViewController:self weburl:url title:@"体检报告" moreInfo:NO hiddenBottom:YES];
            return;
        }
        ReportDetailController *detail = [[ReportDetailController alloc]init];
        detail.reportId = user.report_id;
        detail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detail animated:YES];
        
    }else
    {
        DDLOG(@"跳转至疾病详情");
//        ArticleModel *article = _articleArray[indexPath.row];
//        NSString *shareImageUrl = article.cover_pic;
//        NSString *shareTitle = article.title;
//        NSString *shareContent = article.summary;
//        NSDictionary *params = @{Share_imageUrl:shareImageUrl ? : @"",
//                                 Share_title:shareTitle,
//                                 Share_content:shareContent};
//        [MiddleTools pushToWebFromViewController:self weburl:article.url extensionParams:params moreInfo:YES hiddenBottom:YES updateParamsBlock:nil];
    }
    
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    if (indexPath.section == 0) {
        if (_table.dataArray.count == 0) {
            return 40.f;
        }
        return 55.f + 0.5;
    }else if (indexPath.section == 1){
        return 63.f;
    }
    return 55.f + 5.f;
}

//-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(RefreshTableView *)tableView
//{
//    return 5.f;
//}
//
//-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(RefreshTableView *)tableView
//{
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5)];
//    view.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
//    return view;
//}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(RefreshTableView *)tableView
{
    if (section == 0) {
        if (![LoginManager isLogin]) {
            return nil;
        }
    }
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 35 + 0.5)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, view.width - 20, view.height) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:section == 0 ? @"体检报告" : @"体检常识"];
    [view addSubview:label];
    
    //体检报告3条 体检常识10条
    if ((section == 0 && _moreReport) ||
        (section == 1 && _moreArticle))
    {
        UILabel *moreLabel = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 50 - 15, 0, 50, view.height) font:13 align:NSTextAlignmentRight textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:@"更多"];
        [view addSubview:moreLabel];
        [view addTaget:self action:@selector(clickToMore:) tag:500 + section];//查看更多
    }
    
    //line
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 35.f, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [view addSubview:line];
    
    return view;
}
- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(RefreshTableView *)tableView
{
    if (section == 0) {
        if (![LoginManager isLogin]) {
            return 0.f;
        }
    }
    return 35.f + 0.5f;
}

#pragma - mark UITableViewDataSource

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section == 0) {
        if (_table.dataArray.count == 0 && [LoginManager isLogin]) {
            return 1.f;
        }
        return _table.dataArray.count;
    }else if (section == 1){
        return _articleArray.count;
    }
    return 0.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    //健康资讯
    if (indexPath.section == 1) {
        static NSString *identifier = @"healthInfo";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 63.f)];
            view.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:view];
            
            //图
            UIImageView *iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12, 40, 40)];
            iconImage.image = [UIImage imageNamed:@"report_b"];
            iconImage.contentMode = UIViewContentModeCenter;
            iconImage.backgroundColor = [UIColor redColor];
            [iconImage addRoundCorner];
            [view addSubview:iconImage];
            iconImage.tag = 300;
            
            //标题
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(iconImage.right + 10, 11, DEVICE_WIDTH - iconImage.right - 10 - 35, 16) title:nil font:15 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE];
            [view addSubview:titleLabel];
            titleLabel.tag = 301;
            
            //摘要
            UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(iconImage.right + 10, titleLabel.bottom + 5, titleLabel.width, 20) title:nil font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB];
            [view addSubview:contentLabel];
            contentLabel.tag = 302;
            
            //箭头
            UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 35, 0, 35, 55)];
            arrow.image = [UIImage imageNamed:@"personal_jiantou_r"];
            arrow.contentMode = UIViewContentModeCenter;
            [view addSubview:arrow];
            
            //line
            UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(15, 63 - 0.5, DEVICE_WIDTH - 15, 0.5)];
            line.backgroundColor = DEFAULT_LINECOLOR;
            [cell.contentView addSubview:line];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
        
        UIImageView *iconImage = [cell.contentView viewWithTag:300];
        UILabel *titleLabel = [cell.contentView viewWithTag:301];
        UILabel *contentLabel = [cell.contentView viewWithTag:302];
        
        ArticleModel *aModel = [_articleArray objectAtIndex:indexPath.row];
        titleLabel.text = aModel.title;
        contentLabel.text = aModel.summary;
        [iconImage l_setImageWithURL:[NSURL URLWithString:aModel.cover_pic] placeholderImage:DEFAULT_HEADIMAGE];
        
        return cell;
        
    }else if (indexPath.section == 0 && _table.dataArray.count > 0){ //有报告
        //体检报告
        static NSString *identifier = @"report";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 55)];
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
            
            //line
            UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(15, 55.f, DEVICE_WIDTH - 15, 0.5)];
            line.backgroundColor = DEFAULT_LINECOLOR;
            [cell.contentView addSubview:line];
            
            //箭头
            UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 35, 0, 35, 55)];
            arrow.image = [UIImage imageNamed:@"personal_jiantou_r"];
            arrow.contentMode = UIViewContentModeCenter;
            [view addSubview:arrow];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //    cell.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
        UILabel *titleLabel = [cell.contentView viewWithTag:200];
        UILabel *timeLabel = [cell.contentView viewWithTag:201];
        UserInfo *user = _table.dataArray[indexPath.row];
        titleLabel.text = [NSString stringWithFormat:@"%@  %@的体检报告",user.appellation,user.family_user_name];
        timeLabel.text = user.checkup_time;
        return cell;
    }
    
    //体检报告
    static NSString *identifier = @"identify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
        view.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:view];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 40) title:nil font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_THIRD];
        [view addSubview:titleLabel];
        titleLabel.tag = 200;
        
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 40 - 0.5, DEVICE_WIDTH, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [cell.contentView addSubview:line];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *titleLabel = [cell.contentView viewWithTag:200];
    titleLabel.text = @"目前暂无报告";
    
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;//先去掉体检常识部分
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
        
        //剩最后一行了,直接删除会有问题
        if (_table.dataArray.count > 0){
            [_table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [self deleteReportId:user.report_id];
        if (_table.dataArray.count == 0) {
            [_table reloadData:nil pageSize:G_PER_PAGE noDataView:self.resultView];
        }
    }
}

@end
