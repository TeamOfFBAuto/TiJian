//
//  AppointProgressDetailController.m
//  TiJian
//
//  Created by lichaowei on 16/3/8.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "AppointProgressDetailController.h"

@interface AppointProgressDetailController ()<UITableViewDelegate>
{
    UITableView *_table;
    NSDictionary *_finished_info;//进度详情
    NSArray *_report_status;//进度信息
}

@end

@implementation AppointProgressDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"已体检";
    [self netWorkForList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建

- (void)prepareRefreshTableView
{
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    [self.view addSubview:scroll];
    
    //人员基本信息
    UIView *basicView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 66)];
    basicView.backgroundColor = [UIColor whiteColor];
    [scroll addSubview:basicView];
    
    for (int i = 0; i < 2; i ++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 33 * i, DEVICE_WIDTH, 33) font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:nil];
        [basicView addSubview:label];
        
        if (i == 0) {
            label.text = [NSString stringWithFormat:@"体检人信息:%@(%@) %@",_finished_info[@"user_relation"],_finished_info[@"user_name"],_finished_info[@"center_name"]];
        }else if (i == 1){
            //2015.07.28 12:10:24
            //
            NSString *time = _finished_info[@"appointment_exam_time"];
            label.text = [NSString stringWithFormat:@"体检时间:%@",[LTools timeString:time withFormat:@"yyyy.MM.dd"]];
        }
    }
    //line
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, basicView.bottom, DEVICE_WIDTH, 5)];
    line.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [scroll addSubview:line];
    
    //报告进度信息
    UIView *infoView = [[UIView alloc]initWithFrame:CGRectMake(0, line.bottom, DEVICE_WIDTH, 35)];
    infoView.backgroundColor = [UIColor whiteColor];
    [scroll addSubview:infoView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, DEVICE_WIDTH - 10, 25) font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@"报告信息:"];
    [infoView addSubview:label];
    
    int sum = (int)_report_status.count;
    
    CGFloat bottom = label.bottom;
    //进度
    for (int i = 0; i < sum; i ++) {
        
        UIView *stateView = [[UIView alloc]initWithFrame:CGRectMake(0, infoView.bottom + 46 * i, DEVICE_WIDTH, 46)];
        stateView.backgroundColor = [UIColor whiteColor];
        [scroll addSubview:stateView];
        
        bottom = stateView.bottom;
        
        //左侧线
        
        UIImageView *leftLine;
        if (sum > 1) {
            
            leftLine = [[UIImageView alloc]initWithFrame:CGRectMake(17 + 5 - 0.25, 0, 0.5, stateView.height)];
            leftLine.backgroundColor = DEFAULT_LINECOLOR;
            [stateView addSubview:leftLine];
        }
        
        UIButton *stateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        stateBtn.frame = CGRectMake(17, 10, 10, 10);
        [stateBtn setImage:[UIImage imageNamed:@"appointProgresscircle_1"] forState:UIControlStateSelected];
        [stateBtn setImage:[UIImage imageNamed:@"appointProgresscircle_2"] forState:UIControlStateNormal];
        [stateView addSubview:stateBtn];
        
        NSDictionary *stateDic = _report_status[i];
        NSString *title = [NSString stringWithFormat:@"%@\n%@",stateDic[@"report_status"],[LTools timeString:stateDic[@"dateline"] withFormat:@"yyyy-MM-dd HH:mm:ss"]];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(stateBtn.right + 10, 0, DEVICE_WIDTH - (stateBtn.right + 10)* 2, 40) font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:title];
        titleLabel.numberOfLines = 2;
        [stateView addSubview:titleLabel];

        
        if (i == 0) {
            stateBtn.selected = YES;
            
            leftLine.top = 20;
            leftLine.height = stateView.height - 20;
            titleLabel.textColor = DEFAULT_TEXTCOLOR;
        }
        
        if (i == sum - 1) {
            
            leftLine.height = stateBtn.bottom - 2;
        }else
        {
            //底部分割线
            line = [[UIImageView alloc]initWithFrame:CGRectMake(titleLabel.left, 45.5, DEVICE_WIDTH - titleLabel.left, 0.5)];
            line.backgroundColor = DEFAULT_LINECOLOR;
            [stateView addSubview:line];
        }
    }
    //跳转scroll内容视图大小
    if (bottom > DEVICE_HEIGHT - 64) {
        scroll.contentSize = CGSizeMake(DEVICE_WIDTH, bottom);
    }
}

#pragma mark - 网络请求

- (void)netWorkForList
{
    if (!self.appointId) {
        return;
    }
    NSDictionary *params = @{@"authcode":[UserInfo getAuthkey],
                             @"appoint_id":self.appointId};;
    NSString *api = GET_AppointProgressDetail;
    
    __weak typeof(self)weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        _finished_info = result[@"finished_info"];
        _report_status = _finished_info[@"report_status"];//进度信息
        [weakSelf prepareRefreshTableView];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

#pragma mark - 数据解析处理

#pragma mark - 事件处理

#pragma mark - 代理

@end
