//
//  GRegisterListViewController.m
//  TiJian
//
//  Created by gaomeng on 16/7/26.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GRegisterListViewController.h"
#import "GRegisterListCell.h"

@interface GRegisterListViewController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_rTab;
    AFHTTPRequestOperation *_requestOperation;
}
@end

@implementation GRegisterListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.myTitle = @"挂号转诊";
    
    [self creatHeadView];
    [self creatRtab];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 视图创建

-(void)creatHeadView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
    view.backgroundColor = RGBCOLOR(222, 238, 248);
    [self.view addSubview:view];
    
    UILabel *hospitalNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH *245.0/750, 40)];
    hospitalNameLabel.textColor = RGBCOLOR(89, 140, 187);
    hospitalNameLabel.font = [UIFont systemFontOfSize:12];
    hospitalNameLabel.textAlignment = NSTextAlignmentCenter;
    hospitalNameLabel.text = @"申请医院";
    [view addSubview:hospitalNameLabel];
    
    UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(hospitalNameLabel.right, 0, hospitalNameLabel.width, 40)];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = RGBCOLOR(89, 140, 187);
    timeLabel.text = @"申请时间及科室";
    [view addSubview:timeLabel];
    
    UILabel *stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(timeLabel.right, 0, DEVICE_WIDTH *130.0/750, 40)];
    stateLabel.textAlignment = NSTextAlignmentCenter;
    stateLabel.font = [UIFont systemFontOfSize:12];
    stateLabel.textColor = RGBCOLOR(89, 140, 187);
    stateLabel.text = @"状态";
    [view addSubview:stateLabel];
    
    UILabel *caozuoLabel =[[UILabel alloc]initWithFrame:CGRectMake(stateLabel.right, 0, stateLabel.width, 40)];
    caozuoLabel.textAlignment = NSTextAlignmentCenter;
    caozuoLabel.font = [UIFont systemFontOfSize:12];
    caozuoLabel.textColor = RGBCOLOR(89, 140, 187);
    caozuoLabel.text = @"操作";
    [view addSubview:caozuoLabel];
    
    
}

-(void)creatRtab{
    _rTab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 40, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 50) style:UITableViewStylePlain];
    _rTab.refreshDelegate = self;
    _rTab.dataSource = self;
    [self.view addSubview:_rTab];
    [_rTab showRefreshHeader:YES];
}


#pragma mark - RefreshDelegate && UITableViewDataSource

- (void)loadNewDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = 1;
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    num = _rTab.dataArray.count;
    return num;
}


- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    CGFloat height = 0;
    height = 75;
    return height;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    return height;
}

-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    return height;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}

-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    GRegisterListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GRegisterListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSDictionary *dic = _rTab.dataArray[indexPath.row];
    
    [cell loadDataWithDic:dic indexPath:indexPath];
    
    __weak typeof (self)bself = self;
    [cell setUpdataBlock:^(NSInteger index) {
        [bself btnOfCellClickedWithIndex:index];
    }];
    
    
    
    
    return cell;
}


- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    NSLog(@"%s",__FUNCTION__);
}

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - cell点击回调
-(void)btnOfCellClickedWithIndex:(NSInteger)index{
    
    if (index >0) {//跳转详情
        NSInteger tag = index;
        NSDictionary *dic = _rTab.dataArray[tag - 10];
        NSString *j_referral_id = [dic stringValueForKey:@"j_referral_id"];
        [self goToRegisterDetailWithId:j_referral_id];
    }else{//取消
        NSInteger tag = -index;
        NSDictionary *dic = _rTab.dataArray[tag - 10];
        NSString *j_referral_id = [dic stringValueForKey:@"j_referral_id"];
        [self prepareToCancelRegisterWithId:j_referral_id];
        
    }
    
    
}

#pragma mark - 请求网络数据
-(void)prepareNetData{
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey],
                          @"page":NSStringFromInt(_rTab.pageNum),
                          @"per_page":NSStringFromInt(PAGESIZE_MID)
                          };
    YJYRequstManager *request = [YJYRequstManager shareInstance];
   _requestOperation = [request requestWithMethod:YJYRequstMethodGet api:NGuahao_getYuyueList parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
       
       NSArray *data = [result arrayValueForKey:@"data"];
       [_rTab reloadData:data pageSize:PAGESIZE_MID noDataView:[self resultViewWithType:PageResultType_nodata]];
       
    } failBlock:^(NSDictionary *result) {
        
    }];
}

#pragma mark - 取消预约
-(void)prepareToCancelRegisterWithId:(NSString *)theId{
    NSLog(@"%s",__FUNCTION__);
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否取消预约" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    al.tag = [theId integerValue];
    [al show];
}



#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        
    }else if (buttonIndex == 1){
        [self sureToCancelWithId:[NSString stringWithFormat:@"%ld",(long)alertView.tag]];
    }
}

#pragma 取消预约网络请求
-(void)sureToCancelWithId:(NSString *)theId{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *dic = @{
                          @"j_referral_id":theId,
                          @"authcode":[UserInfo getAuthkey]
                          };
    YJYRequstManager *request = [YJYRequstManager shareInstance];
    [request requestWithMethod:YJYRequstMethodPost api:NGuahao_cancelYuyue parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [GMAPI showAutoHiddenMBProgressWithText:@"取消预约成功" addToView:self.view];
        [_rTab showRefreshHeader:YES];
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [GMAPI showAutoHiddenMBProgressWithText:@"取消预约失败" addToView:self.view];
        [_rTab showRefreshHeader:YES];
    }];
}

#pragma mark - 跳转挂号详情页
-(void)goToRegisterDetailWithId:(NSString *)theId{
    GRegisterDetailViewController *cc = [[GRegisterDetailViewController alloc]init];
    cc.j_referral_id = theId;
    [self.navigationController pushViewController:cc animated:YES];
    
}


#pragma mark - 无数据默认view
-(ResultView *)resultViewWithType:(PageResultType)type
{
    NSString *content;
    if (type == PageResultType_nodata){
        
        content = @"暂无预约";
    }
    
    
    ResultView *result = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"]
                                                    title:@"温馨提示"
                                                  content:content];
    
    return result;
}


@end
