//
//  MyCouponViewController.m
//  TiJian
//
//  Created by gaomeng on 15/11/29.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "MyCouponViewController.h"
#import "MyCouponTableViewCell.h"

@interface MyCouponViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    int _buttonNum;//button个数
    UIScrollView *_scroll;
    UITableView *_tab0;
    UITableView *_tab1;
    
    YJYRequstManager* _requst;//网络请求单例
    
    NSMutableArray *_tab0Array;//可用的数据源
    NSMutableArray *_tab1Array;//不可用的数据源
    
}
@end

@implementation MyCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    if (self.type == GCouponType_youhuiquan) {//优惠券
        [self setMyViewControllerLeftButtonType:0 WithRightButtonType:5];
        self.myTitle = @"我的优惠券";
    }else if (self.type == GCouponType_daijinquan){//代金券
        [self setMyViewControllerLeftButtonType:0 WithRightButtonType:5];
        self.myTitle = @"我的代金券";
    }else if (self.type == GCouponType_use_youhuiquan){//使用优惠券
        [self setMyViewControllerLeftButtonType:0 WithRightButtonType:5];
        self.myTitle = @"使用优惠券";
    }else if (self.type == GCouponType_use_daijinquan){//使用代金券
        [self setMyViewControllerLeftButtonType:0 WithRightButtonType:5];
        self.myTitle = @"使用代金券";
    }
    
    
    
    [self prepareNetData];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建
//创建上方选择btn 和 下方展示tab
-(void)creatUpBtnAndDownScrollView{
    
    
    if (self.type == GCouponType_youhuiquan || self.type == GCouponType_daijinquan) {
        
    }
    
    int abelCount = 0;
    int disAbelCount = 0;
    
    for (NSArray * arr in _tab0Array) {
        abelCount +=arr.count;
    }
    
    for (NSArray *arr in _tab1Array) {
        disAbelCount +=  arr.count;
    }
    
    
    NSString *ableNum = [NSString stringWithFormat:@"可用优惠券(%d)",abelCount];
    NSString *noAbleNum = [NSString stringWithFormat:@"不可用优惠券(%d)",disAbelCount];
    NSArray *titles = @[ableNum,noAbleNum];
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
        //横滑上方的按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        btn.tag = 100 + i;
        btn.frame = CGRectMake(width * i, 0, width, 40);
        [btn setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
        [btn setTitleColor:RGBCOLOR(235, 110, 21) forState:UIControlStateSelected];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn addTarget:self action:@selector(clickToSelect:) forControlEvents:UIControlEventTouchUpInside];
        btn.selected = YES;
        
        UITableView *_table = [[UITableView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH * i, 0, DEVICE_WIDTH,_scroll.height) style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        [_scroll addSubview:_table];
        _table.tag = 200 + i;
        
        if (_table.tag == 200) {
            _tab0 = _table;
        }else if (_table.tag == 201){
            _tab1 = _table;
        }
        
    }
    
    
    //默认选中第一个
    [self controlSelectedButtonTag:100];
    self.view.backgroundColor = [UIColor whiteColor];
}



#pragma mark - 网络请求
-(void)prepareNetData{
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    NSDictionary *dic;
    
    NSString *url;
    
    if (self.type == GCouponType_youhuiquan) {//查看优惠券
        url = USER_MYYOUHUIQUANLIST;
        dic = @{
                @"authcode":[LTools cacheForKey:USER_AUTHOD]
                };
    }else if (self.type == GCouponType_use_youhuiquan){//使用优惠券
        url = ORDER_GETYOUHUIQUANLIST;
        dic = @{
                @"authcode":[LTools cacheForKey:USER_AUTHOD],
                @"coupon":self.coupon
                };
    }else if (self.type == GCouponType_daijinquan){//查看代金券
        url = USER_MYDAIJINQUANLIST;
        dic = @{
                @"authcode":[LTools cacheForKey:USER_AUTHOD]
                };
    }else if (self.type == GCouponType_use_daijinquan){//使用代金券
        url = ORDER_GETDAIJIQUANLIST;
        dic = @{
                @"authcode":[LTools cacheForKey:USER_AUTHOD],
                @"brand_ids":self.brand_ids
                };
    }
    
    
    if (!_requst) {
        _requst = [YJYRequstManager shareInstance];
    }
    [_requst requestWithMethod:YJYRequstMethodGet api:url parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *list = [result arrayValueForKey:@"coupon_list"];
        
        _tab0Array = [NSMutableArray arrayWithCapacity:1];
        _tab1Array = [NSMutableArray arrayWithCapacity:1];
        
        NSMutableArray *tab0_tongyongArray = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *tab0_feitongyongArray = [NSMutableArray arrayWithCapacity:1];
        
        NSMutableArray *tab1_tongyongArray = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *tab1_feitongyongArray = [NSMutableArray arrayWithCapacity:1];
        
        
        
        
        
        for (NSDictionary *dic in list) {
            CouponModel *model = [[CouponModel alloc]initWithDictionary:dic];
            if (model.enable_use) {//可用
                if (model.brand_id) {//非通用
                    [tab0_feitongyongArray addObject:model];
                }else{//通用
                    [tab0_tongyongArray addObject:model];
                }
            }else{//不可用
                if (model.brand_id) {//非通用
                    [tab1_feitongyongArray addObject:model];
                }else{//通用
                    [tab1_tongyongArray addObject:model];
                }
            }
        }
        
        
        if (tab0_tongyongArray.count>0) {
            [_tab0Array addObject:tab0_tongyongArray];
        }
        
        if (tab0_feitongyongArray.count>0) {
            [_tab0Array addObject:tab0_feitongyongArray];
        }
        
        if (tab1_tongyongArray.count>0) {
            [_tab1Array addObject:tab1_tongyongArray];
        }
        
        if (tab1_feitongyongArray.count>0) {
            [_tab1Array addObject:tab1_feitongyongArray];
        }
        
        
        [_tab0 reloadData];
        [_tab1 reloadData];
        
        
        
        [self creatUpBtnAndDownScrollView];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }];
    
    
    
    
    
}



#pragma mark - UITableViewDelegate && UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = 0;
    if (tableView.tag == 200) {//可用
        num = _tab0Array.count;
    }else if (tableView.tag == 201){//不可用
        num = _tab1Array.count;
    }
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    if (tableView.tag == 200) {//可用
        NSArray *arr = _tab0Array[section];
        num = arr.count;
    }else if (tableView.tag == 201){
        NSArray *arr = _tab1Array[section];
        num = arr.count;
    }
    
    return num;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = 0.01;
    height = 45;
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CGFloat height = 0.01;
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 70;
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    
    [view setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 45)];
    view.backgroundColor = RGBCOLOR(244, 245, 246);
    
    CouponModel *model;
    if (tableView.tag == 200) {//可用
        NSArray *arr = _tab0Array[section];
        model = arr[0];
    }else if (tableView.tag == 201){//不可用
        NSArray *arr = _tab1Array[section];
        model = arr[0];
    }
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 45)];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = RGBCOLOR(134, 135, 136);
    [view addSubview:label];
    
    if (model.brand_id) {//非通用
        label.text = @"品牌优惠券";
    }else{//通用
        label.text = @"通用优惠券";
    }
    
    
    return view;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int tableViewTag = (int)tableView.tag;
    if (tableViewTag == 200) {//可用
        static NSString *identify = @"counponCell_canuse";
        MyCouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            
            cell = [[MyCouponTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify index:indexPath type:self.type];
        }
        
        NSArray *arr = _tab0Array[indexPath.section];
        CouponModel *model = arr[indexPath.row];
        
        [cell loadDataWithModel:model];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else if (tableViewTag == 201){//不可用
        static NSString *identify = @"counponCell_disabelUse";
        MyCouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            GCouponType aa;
            if (self.type == GCouponType_use_daijinquan) {
                aa = GCouponType_disUse_daijinquan;
            }else if (self.type == GCouponType_use_youhuiquan){
                aa = GCouponType_disUse_youhuiquan;
            }
            cell = [[MyCouponTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify index:indexPath type:aa];
        }
        
        NSArray *arr = _tab1Array[indexPath.section];
        CouponModel *model = arr[indexPath.row];
        
        [cell loadDataWithModel:model];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        return cell;
    }
    
    return [[UITableViewCell alloc]init];
}


#pragma - mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    int page = floor((scrollView.contentOffset.x - DEVICE_WIDTH / 2) / DEVICE_WIDTH) + 1;//只要大于半页就算下一页
    NSLog(@"page %d",page);
    //选中状态
    [self controlSelectedButtonTag:page + 100];
    
}

#pragma mark - 点击处理

/**
 *  获取button 根据tag
 */
- (UIButton *)buttonForTag:(int)tag
{
    return (UIButton *)[self.view viewWithTag:tag];
}


/**
 *  控制button选中状态
 */
- (void)controlSelectedButtonTag:(int)tag
{
    for (int i = 0; i < _buttonNum; i ++) {
        
        [self buttonForTag:100 + i].selected = (i + 100 == tag) ? YES : NO;
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



@end
