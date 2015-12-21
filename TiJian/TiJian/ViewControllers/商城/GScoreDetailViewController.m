//
//  GScoreDetailViewController.m
//  TiJian
//
//  Created by gaomeng on 15/12/21.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GScoreDetailViewController.h"
#import "GUserScoreDetailTableViewCell.h"

@interface GScoreDetailViewController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_rtab;
    
    NSArray *_dataArray;
    
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_1;
    
    UILabel *_scoreLabel;
    
}
@end

@implementation GScoreDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.myTitle = @"我的积分";
    
    
    [self creatTab];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - 视图创建
-(void)creatTab{
    _rtab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _rtab.refreshDelegate = self;
    _rtab.dataSource = self;
    
    _rtab.tableHeaderView = [self creatTabHeaderView];
    
    [self.view addSubview:_rtab];
    
    [_rtab showRefreshHeader:YES];
}

-(UIView *)creatTabHeaderView{
    UIView *tabHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 150)];
    tabHeaderView.backgroundColor = [UIColor whiteColor];
    
    UILabel *jifenGuizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 12 - 80, 0, 80, 30)];
    [jifenGuizeLabel addTaget:self action:@selector(jifenGuizeLabelClicked) tag:0];
    jifenGuizeLabel.font = [UIFont systemFontOfSize:11];
    jifenGuizeLabel.textAlignment = NSTextAlignmentRight;
    jifenGuizeLabel.textColor = [UIColor grayColor];
    jifenGuizeLabel.text = @"积分规则";
    [tabHeaderView addSubview:jifenGuizeLabel];
    
    
    UIView *yuanView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    yuanView.layer.cornerRadius = 50;
    yuanView.center = tabHeaderView.center;
    yuanView.backgroundColor = RGBCOLOR(241, 108, 22);
    [tabHeaderView addSubview:yuanView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, yuanView.frame.size.height*0.25, yuanView.frame.size.width, yuanView.frame.size.height*0.25)];
    titleLabel.text = @"积分";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:12];
    [yuanView addSubview:titleLabel];
    
    _scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, yuanView.frame.size.height*0.5, yuanView.frame.size.width, yuanView.frame.size.height*0.25)];
    _scoreLabel.font = [UIFont systemFontOfSize:12];
    _scoreLabel.textAlignment = NSTextAlignmentCenter;
    _scoreLabel.textColor = [UIColor whiteColor];
    [yuanView addSubview:_scoreLabel];
    
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(12, tabHeaderView.frame.size.height - 5, DEVICE_WIDTH*0.5-12 - 30, 0.5)];
    line1.backgroundColor = RGBCOLOR(200, 200, 200);
    [tabHeaderView addSubview:line1];
    
    UILabel *ttt = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(line1.frame), line1.frame.origin.y-5, 60, 10)];
    ttt.text = @"积分明细";
    ttt.font = [UIFont systemFontOfSize:10];
    ttt.textColor = RGBCOLOR(200, 200, 200);
    ttt.textAlignment = NSTextAlignmentCenter;
    [tabHeaderView addSubview:ttt];
    
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(ttt.frame), tabHeaderView.frame.size.height - 5, DEVICE_WIDTH*0.5-12 - 30, 0.5)];
    line2.backgroundColor = RGBCOLOR(200, 200, 200);
    [tabHeaderView addSubview:line2];
    
    
    
    
    return tabHeaderView;
}




#pragma mark - 请求网络数据
-(void)prepareNetData{
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey],
                          };
    
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    
    _request_1 = [_request requestWithMethod:YJYRequstMethodGet api:USER_SCORE_DETAIL parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        _dataArray = [result arrayValueForKey:@"list"];
        
        
        _scoreLabel.text = [result stringValueForKey:@"user_score"];
        
        [_rtab reloadData:_dataArray pageSize:G_PER_PAGE];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
}


#pragma mark - 点击方法
-(void)jifenGuizeLabelClicked{
    NSLog(@"%s",__FUNCTION__);
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"正在建设中" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [al show];
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
    NSInteger num = _rtab.dataArray.count;
    return num;
}


- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    CGFloat height = 40;
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
    GUserScoreDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GUserScoreDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSDictionary *dic = _rtab.dataArray[indexPath.row];
    
    [cell loadDataWithDic:dic];
    
    
    return cell;
}



- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    NSLog(@"%s",__FUNCTION__);
}

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%s",__FUNCTION__);
}




@end
