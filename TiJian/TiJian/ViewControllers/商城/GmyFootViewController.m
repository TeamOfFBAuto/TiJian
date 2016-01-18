//
//  GmyFootViewController.m
//  TiJian
//
//  Created by gaomeng on 16/1/13.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GmyFootViewController.h"
#import "ProductModel.h"
#import "GProductCellTableViewCell.h"
#import "GproductDetailViewController.h"
#import "GCustomSearchViewController.h"

@interface GmyFootViewController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_rtab;
    
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_foot;
    
    //顶部工具栏
    UIView *_upToolView;
    
    UIView *_downToolBlackView;
    
    BOOL _toolShow;
    
    
    NSMutableArray *_dataArray;//二维数组数据源
    
    
}
@end

@implementation GmyFootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeOther];
    self.rightImage = [UIImage imageNamed:@"dian_three.png"];
    self.myTitle = @"足迹";
    
    [self creatRTab];
    
    [self creatUpToolView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 点击处理

-(void)rightButtonTap:(UIButton *)sender{
    
    _toolShow = !_toolShow;
    
    if (_toolShow) {
        
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
        } completion:^(BOOL finished) {
            if (!_downToolBlackView) {
                _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
                _downToolBlackView.backgroundColor = [UIColor blackColor];
                _downToolBlackView.alpha = 0.6;
                [self.view addSubview:_downToolBlackView];
                
                [_downToolBlackView addTapGestureTaget:self action:@selector(upToolShou) imageViewTag:0];
            }
            _downToolBlackView.hidden = NO;
        }];
        
        
    }else{
        if (!_downToolBlackView) {
            _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
            _downToolBlackView.backgroundColor = [UIColor blackColor];
            _downToolBlackView.alpha = 0.6;
            [self.view addSubview:_downToolBlackView];
        }
        _downToolBlackView.hidden = YES;
        
        
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, -50, DEVICE_WIDTH, 50)];
        }];
    }
    
    
}

-(void)upToolShou{
    
    if (_toolShow) {
        if (!_downToolBlackView) {
            _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
            _downToolBlackView.backgroundColor = [UIColor blackColor];
            _downToolBlackView.alpha = 0.6;
            [self.view addSubview:_downToolBlackView];
        }
        _downToolBlackView.hidden = YES;
        
        
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, -50, DEVICE_WIDTH, 50)];
        }];
        
        _toolShow = !_toolShow;
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
        } completion:^(BOOL finished) {
            if (!_downToolBlackView) {
                _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
                _downToolBlackView.backgroundColor = [UIColor blackColor];
                _downToolBlackView.alpha = 0.6;
                [self.view addSubview:_downToolBlackView];
                
                [_downToolBlackView addTapGestureTaget:self action:@selector(upToolShou) imageViewTag:0];
            }
            _downToolBlackView.hidden = NO;
        }];
        _toolShow = !_toolShow;
    }
}



//工具栏按钮点击
-(void)upToolBtnClicked1:(NSInteger)index{
    if (index == 20) {//搜索
        GCustomSearchViewController *cc = [[GCustomSearchViewController alloc]init];
        [self.navigationController pushViewController:cc animated:YES];
        
    }else if (index == 21){//首页
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}




#pragma mark - 视图创建


-(void)creatUpToolView{
    GMAPI *gmapi = [GMAPI sharedManager];
    _upToolView = [gmapi creatTwoBtnUpToolView];
    [self.view addSubview:_upToolView];
    __weak typeof (self)bself = self;
    [gmapi setUpToolViewBlock1:^(NSInteger index) {
        [bself upToolBtnClicked1:index];
    }];
}


-(void)creatRTab{
    _rtab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStyleGrouped];
    _rtab.refreshDelegate = self;
    _rtab.dataSource = self;
    [self.view addSubview:_rtab];
    
    [_rtab showRefreshHeader:YES];
}



#pragma mark - RefreshDelegate && UITableViewDataSource

- (void)loadNewDataForTableView:(UITableView *)tableView{
    
    [self prepareNetData];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = _dataArray.count;
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    NSArray *arr = _dataArray[section];
    num = arr.count;
    return num;
}


- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    return [GProductCellTableViewCell getCellHight];
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 30;
    return height;
}

-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    return height;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 30)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH-10, 30)];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textColor = RGBCOLOR(81, 82, 83);
    [view addSubview:titleLabel];
    
    NSArray *arr = _dataArray[section];
    ProductModel *model = arr[0];
    NSString *titleStr = model.track_time;
    
    if (section == 0) {//今天
        
        NSDate *now = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        NSString *nowTimeStr = [formatter stringFromDate:now];
        
        if ([nowTimeStr isEqualToString:model.track_time]) {
            titleStr = @"今天";
        }
    }else if (section == 1){//昨天
        
        NSDate *now = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        NSTimeInterval secondsPerDay1 = 24*60*60;
        NSDate *yesterDay = [now dateByAddingTimeInterval:-secondsPerDay1];
        NSString *yesterDayTimeStr = [formatter stringFromDate:yesterDay];
        
        if ([yesterDayTimeStr isEqualToString:model.track_time]) {
            titleStr = @"昨天";
        }
    }

    
    titleLabel.text = titleStr;
    return view;
}

-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    
    
    GProductCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GProductCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    NSArray *arr = _dataArray[indexPath.section];

    ProductModel *model = arr[indexPath.row];
    
    [cell loadData:model];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}



- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    
    GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
    ProductModel *model = _rtab.dataArray[indexPath.row];
    cc.productId = model.product_id;
    [self.navigationController pushViewController:cc animated:YES];
    
    
}

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
}


#pragma mark - 网络请求

-(void)prepareNetData{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey],
                          @"page":[NSString stringWithFormat:@"%d",_rtab.pageNum],
                          @"per_page":[NSString stringWithFormat:@"%d",G_PER_PAGE]
                          };
    
    _request_foot = [_request requestWithMethod:YJYRequstMethodGet api:GetMyProductsFoot parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSArray *list = [result arrayValueForKey:@"list"];

    
        NSMutableArray *dataArray_net = [NSMutableArray arrayWithCapacity:1];
        
        for (NSDictionary *dic in list) {
            ProductModel *model = [[ProductModel alloc]initWithDictionary:dic];
            model.track_time = [GMAPI timechangeYMD:[dic stringValueForKey:@"track_time"]];
            [dataArray_net addObject:model];
        }
        
        //数据融合
        BOOL isHaveMore = dataArray_net.count <= G_PER_PAGE ? NO : YES;
        [_rtab reloadDataWithNoFinishReloading:dataArray_net isHaveMore:isHaveMore];
        
        NSMutableDictionary *m_dic = [NSMutableDictionary dictionaryWithCapacity:1];
        
        //按时间分组
        for (ProductModel *model in dataArray_net) {
            NSMutableArray *arr = [m_dic objectForKey:model.track_time];
            if (arr.count>0) {
                [arr addObject:model];
                [m_dic setValue:arr forKey:model.track_time];
            }else{
                NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
                [arr addObject:model];
                [m_dic setValue:arr forKey:model.track_time];
            }
        }
        
        NSArray *allKeyArray = [m_dic allKeys];
        NSArray *allKeyArray_paixu = [allKeyArray sortedArrayUsingSelector:@selector(compare:)];
        NSMutableArray *arr_data = [NSMutableArray arrayWithCapacity:1];
        
        NSInteger count = allKeyArray_paixu.count;
        
        for (int i = 0; i < count; i++) {
            NSString *str = allKeyArray_paixu[count-i-1];
            NSArray *arr = [m_dic arrayValueForKey:str];
            [arr_data addObject:arr];
        }
        
        
        _dataArray = arr_data;
        
        
        //刷新界面
        [_rtab finishReloadingData];
        
        
    } failBlock:^(NSDictionary *result) {
        [_rtab loadFail];
        
    }];
    
}







@end
