//
//  GRegisterDetailViewController.m
//  TiJian
//
//  Created by gaomeng on 16/7/26.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GRegisterDetailViewController.h"
#import "GRegisterDetailCell.h"

@interface GRegisterDetailViewController ()<UITableViewDataSource,RefreshDelegate,UIAlertViewDelegate>
{
    RefreshTableView *_rTab;
    AFHTTPRequestOperation *_requestOperation;
    
    NSArray *_dataArray;
    
    NSString *_status;
    GRegisterDetailCell *_tmpCell;
}
@end

@implementation GRegisterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"挂号详情";
    
    [self creatRtab];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建
-(void)creatRtab{
    _rTab = [[RefreshTableView alloc]initWithFrame:CGRectMake(12, 12, DEVICE_WIDTH - 24, DEVICE_HEIGHT - HMFitIphoneX_navcBarHeight) style:UITableViewStylePlain];
    _rTab.refreshDelegate = self;
    _rTab.dataSource = self;
    _rTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    _rTab.showsVerticalScrollIndicator = NO;
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
    NSInteger num = _rTab.dataArray.count;
    return num;
}


- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    CGFloat height = 45;
    if (!_tmpCell) {
        _tmpCell = [[GRegisterDetailCell alloc]init];
    }
    NSDictionary *dic = _rTab.dataArray[indexPath.row];
    height = [_tmpCell heightForCellWithDic:dic];
    return height;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    return height;
}

-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    height = 60;
    return height;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}

-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH - 24, 60)];
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(0, 60.0 * 45 / 120, view.width, 60.0 * 75 / 120)];
    cancelBtn.layer.cornerRadius = 4;
    [cancelBtn setTitle:@"取消预约" forState:UIControlStateNormal];
    cancelBtn.backgroundColor = RGBCOLOR(38, 106, 222);
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:cancelBtn];
    if ([_status intValue] == 1 || [_status intValue] == 2) {//有取消按钮
        cancelBtn.hidden = NO;
    }else{
        cancelBtn.hidden = YES;
    }
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    GRegisterDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GRegisterDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSDictionary *dic = _rTab.dataArray[indexPath.row];
    
    [cell loadCustomViewWithDic:dic];

    
    return cell;
}



- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    NSLog(@"%s",__FUNCTION__);
}

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%s",__FUNCTION__);
}


#pragma mark - 请求网络数据
-(void)prepareNetData{
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey],
                          @"j_referral_id":self.j_referral_id
                          };
    YJYRequstManager *request = [YJYRequstManager shareInstance];
    _requestOperation = [request requestWithMethod:YJYRequstMethodGet api:NGuahao_getYuyueDetail parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSDictionary *dic = [result dictionaryValueForKey:@"data"];
        NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:1];
        if (![LTools isEmpty:[dic stringValueForKey:@"status"]]) {
            _status = [dic stringValueForKey:@"status"];
            NSDictionary *theDic = @{
                                     @"title":@"预约状态：",
                                     @"content":[GMAPI orderStateStr:[dic stringValueForKey:@"status"]]
                                     };
            [mArray addObject:theDic];
        }
        
        if (![LTools isEmpty:[dic stringValueForKey:@"patient_name"]]) {
            NSDictionary *theDic = @{
                                     @"title":@"就  诊  人：",
                                     @"content":[dic stringValueForKey:@"patient_name"]
                                     };
            [mArray addObject:theDic];
        }
        
        if (![LTools isEmpty:[dic stringValueForKey:@"desc"]]) {
            NSDictionary *theDic = @{
                                     @"title":@"病情描述：",
                                     @"content":[dic stringValueForKey:@"desc"]
                                     };
            [mArray addObject:theDic];
        }
        
        if (![LTools isEmpty:[dic stringValueForKey:@"check_appoint_date"]]) {
            
            NSString *content = [dic stringValueForKey:@"check_appoint_date"];//具体时间点
            
            
            NSDictionary *theDic = @{
                                     @"title":@"预约时间：",
                                     @"content":content
                                     };
            [mArray addObject:theDic];
        }else{
            if (![LTools isEmpty:[dic stringValueForKey:@"appoint_date"]]) {
                NSString *content = [dic stringValueForKey:@"appoint_date"];//时间段
                
                
                NSDictionary *theDic = @{
                                         @"title":@"预约时间：",
                                         @"content":content
                                         };
                [mArray addObject:theDic];
            }
        }
        
        
        
        
        if (![LTools isEmpty:[dic stringValueForKey:@"hospital_name"]]) {
            NSDictionary *theDic = @{
                                     @"title":@"首选医院：",
                                     @"content":[NSString stringWithFormat:@"%@(%@)",[dic stringValueForKey:@"hospital_name"],[dic stringValueForKey:@"hospital_level_desc"]]
                                     };
            [mArray addObject:theDic];
        }
        
        if (![LTools isEmpty:[dic stringValueForKey:@"alternative_hospital_name"]]) {
            NSDictionary *theDic = @{
                                     @"title":@"备选医院：",
                                     @"content":[dic stringValueForKey:@"alternative_hospital_name"]
                                     };
            [mArray addObject:theDic];
        }
        
        if (![LTools isEmpty:[dic stringValueForKey:@"dept_name"]]) {
            NSDictionary *theDic = @{
                                     @"title":@"科       室：",
                                     @"content":[NSString stringWithFormat:@"%@ %@",[dic stringValueForKey:@"dept_top_name"],[dic stringValueForKey:@"dept_name"]]
                                     };
            [mArray addObject:theDic];
        }
        
        if (![LTools isEmpty:[dic stringValueForKey:@"add_time"]]) {
            NSString *dd = [dic stringValueForKey:@"add_time"];
            NSDictionary *theDic = @{
                                     @"title":@"提交时间：",
                                     @"content":[NSString stringWithFormat:@"%@",[GMAPI timechangeYMD:dd]]
                                     };
            [mArray addObject:theDic];
        }
        
        [_rTab reloadData:mArray pageSize:PAGESIZE_BIG noDataView:nil];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
}

#pragma mark - 取消预约点击
-(void)cancelBtnClicked{
    NSLog(@"%s",__FUNCTION__);
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否取消预约" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [al show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        
    }else if (buttonIndex == 1){
        [self sureToCancel];
    }
}

#pragma 取消预约网络请求
-(void)sureToCancel{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *dic = @{
                          @"j_referral_id":self.j_referral_id,
                          @"authcode":[UserInfo getAuthkey]
                          };
    YJYRequstManager *request = [YJYRequstManager shareInstance];
    [request requestWithMethod:YJYRequstMethodPost api:NGuahao_cancelYuyue parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [GMAPI showAutoHiddenMBProgressWithText:@"取消预约成功" addToView:self.view];
        [_rTab showRefreshHeader:YES];
        
        if (self.updateParamsBlock) {
            self.updateParamsBlock(nil);
        }
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [GMAPI showAutoHiddenMBProgressWithText:@"取消预约失败" addToView:self.view];
        [_rTab showRefreshHeader:YES];
    }];
}


@end
