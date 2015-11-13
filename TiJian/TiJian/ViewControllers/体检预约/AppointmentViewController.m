//
//  AppointmentViewController.m
//  TiJian
//
//  Created by lichaowei on 15/11/13.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "AppointmentViewController.h"

#import "PersonalCustomViewController.h"//个性化定制
#import "PhysicalTestResultController.h"//测试结果
#import "ChooseHopitalController.h"//选择分院和时间
#import "ProductModel.h"
#import "AppointmentCell.h"
#define kTagButton 100
#define kTagTableView 200

@interface AppointmentViewController ()<RefreshDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    RefreshTableView *_table;
    NSArray *_company;
    NSArray *_personal;
    int _currentPage;//当前页面
}
@property(nonatomic,retain)UIScrollView *scroll;

@end

@implementation AppointmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"预约";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    //创建视图
    [self prepareView];
    //请求数据
    [self tableViewWithIndex:0].isHaveLoaded = YES;
    [[self tableViewWithIndex:0] showRefreshHeader:YES];
    [self buttonWithIndex:0].selected = YES;
    _currentPage = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建

- (RefreshTableView *)tableViewWithIndex:(int)index
{
    return (RefreshTableView *)[self.view viewWithTag:kTagTableView + index];
}
- (UIButton *)buttonWithIndex:(int)index
{
    return (UIButton *)[self.view viewWithTag:kTagButton + index];
}

- (void)prepareView
{
    self.scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 45, DEVICE_WIDTH, DEVICE_HEIGHT - 45 - 64)];
    _scroll.pagingEnabled = YES;
    _scroll.delegate = self;
    [self.view addSubview:_scroll];
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.contentSize = CGSizeMake(DEVICE_WIDTH * 3, _scroll.height);
    
    NSArray *arr = @[@"未预约",@"已预约",@"已过期"];
    CGFloat width = DEVICE_WIDTH / 3.f;
    for (int i = 0; i < arr.count; i ++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(width * i, 0, width, 45);
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        [btn setTitleColor:DEFAULT_TEXTCOLOR_TITLE forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"f68326"] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        btn.backgroundColor = [UIColor whiteColor];
        [btn addTarget:self action:@selector(clickToSwap:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = kTagButton + i;
        [self.view addSubview:btn];
        
        RefreshTableView *table = [[RefreshTableView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH * i, 0, DEVICE_WIDTH, _scroll.height) style:UITableViewStylePlain];
        table.refreshDelegate = self;
        table.dataSource = self;
        [_scroll addSubview:table];
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        table.tag = kTagTableView + i;
    }

}

#pragma mark - 网络请求

- (void)netWorkForListWithTable:(RefreshTableView *)table
{
    int index = (int)table.tag - kTagTableView;
    NSDictionary *params;
    NSString *api;
    if (table == [self tableViewWithIndex:0]) {
        
        api = GET_NO_APPOINTS;
        NSString *authkey = [LTools cacheForKey:USER_AUTHOD];
        authkey = @"WiUHflsiULYOtVfKVeVciwitUbMD9lKjAi8CM186ATEFNVVgBGVWZAUzV2FSNA5+BjI=";
        params = @{@"authcode":authkey};
    }
    
    __weak typeof(self)weakSelf = self;
    __weak typeof(table)weakTable = table;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        [weakSelf parseDataWithResult:result withIndex:index];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        [weakTable loadFail];
        
    }];
}

#pragma mark - 数据解析处理

- (void)parseDataWithResult:(NSDictionary *)result
                  withIndex:(int)index
{
    NSDictionary *setmeal_list = result[@"setmeal_list"];
    //待预约
    if (index == 0) {
        
        _company = [ProductModel modelsFromArray:setmeal_list[@"company"]];
        _personal = [ProductModel modelsFromArray:setmeal_list[@"personal"]];
        [[self tableViewWithIndex:0]finishReloadigData];
    }
}

#pragma mark - 事件处理

/**
 *  更改button状态
 *
 *  @param index 选中index
 */
- (void)updateButtonStateWithSelectedIndex:(int)index
{
    if (index == _currentPage) {
        
        return;
    }else
    {
        _currentPage = index;
    }
    
    NSLog(@"%s",__FUNCTION__);
    for (int i = 0; i < 3; i ++) {
        [self buttonWithIndex:i].selected = (index == i);
    }
    
    if (![self tableViewWithIndex:index].isHaveLoaded) {
        NSLog(@"请求数据 %d",index);
        [[self tableViewWithIndex:index] showRefreshHeader:YES];
    }
}

- (void)clickToSwap:(UIButton *)sender
{
    int index = (int)sender.tag - kTagButton;
    [self updateButtonStateWithSelectedIndex:index];
    [_scroll setContentOffset:CGPointMake(DEVICE_WIDTH * index, 0) animated:NO];
}

- (void)clickToBuy
{
    NSLog(@"代金卷去购买");
}
- (void)clickToCustomization
{
    //先判断是否个性化定制过
    BOOL isOver = [LTools cacheBoolForKey:USER_CUSTOMIZATON_RESULT];
    if (isOver) {
        //已经个性化定制过
        PhysicalTestResultController *physical = [[PhysicalTestResultController alloc]init];
        physical.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:physical animated:YES];
    }else
    {
        PersonalCustomViewController *custom = [[PersonalCustomViewController alloc]init];
        custom.lastViewController = self;
        custom.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:custom animated:YES];
    }
}

#pragma mark - 代理

#pragma - mark UIScrollDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _scroll) {
        
        int page = floor((scrollView.contentOffset.x - DEVICE_WIDTH / 2) / DEVICE_WIDTH) + 1;//只要大于半页就算下一页
        NSLog(@"page %d",page);
        
        [self updateButtonStateWithSelectedIndex:page];
        
    }
    
}

#pragma - mark RefreshDelegate <NSObject>

- (void)loadNewDataForTableView:(RefreshTableView *)tableView
{
    [self netWorkForListWithTable:tableView];
}
- (void)loadMoreDataForTableView:(RefreshTableView *)tableView
{
    [self netWorkForListWithTable:tableView];
}
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    ProductModel *aModel = indexPath.section == 0 ? _company[indexPath.row] : _personal[indexPath.row];
    if ([aModel.type intValue] == 2) { //代金卷
        
        return;
    }

    int index = (int)tableView.tag - kTagTableView;
    if (index == 0) {
        ChooseHopitalController *choose = [[ChooseHopitalController alloc]init];
        [self.navigationController pushViewController:choose animated:YES];
    }
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    int index = (int)tableView.tag - kTagTableView;
    if (index == 0) {
        ProductModel *aModel = indexPath.section == 0 ? _company[indexPath.row] : _personal[indexPath.row];
        return [AppointmentCell heightForCellWithType:[aModel.type intValue]];
    }
    
    return 44.f;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView
{
    int index = (int)tableView.tag - kTagTableView;
    if (index == 0) {
        
        UIView *head = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40.f)];
        head.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
        NSString *title = section == 0 ? @"公司购买套餐" : @"个人购买套餐";
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 120, 40) title:title font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"989898"]];
        [head addSubview:label];
        return head;
    }
    return nil;
}
- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView
{
    int index = (int)tableView.tag - kTagTableView;
    if (index == 0) {
        return 40.f;
    }
    return 0.f;
}

#pragma - mark UITableViewDataSource

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    int index = (int)tableView.tag - kTagTableView;
    if (index == 0) {
        
        if (section == 0) {
            return _company.count;
        }else if (section == 1){
            return _personal.count;
        }
    }
    return tableView.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    int index = (int)tableView.tag - kTagTableView;
    if (index == 0) {
        
        AppointmentCell *cell;
        ProductModel *aModel = indexPath.section == 0 ? _company[indexPath.row] : _personal[indexPath.row];
        if ([aModel.type intValue] == 2) { //代金卷
            
            static NSString *identifier = @"AppointmentCell2";
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[AppointmentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier type:2];
            }
            
            [cell.buyButton addTarget:self action:@selector(clickToBuy) forControlEvents:UIControlEventTouchUpInside];
            [cell.customButton addTarget:self action:@selector(clickToCustomization) forControlEvents:UIControlEventTouchUpInside];
            
        }else
        {
            static NSString *identifier = @"AppointmentCell1";
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[AppointmentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier type:1];
            }
        }
        
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.section == 0) {
            
            [cell setCellWithModel:_company[indexPath.row]];
        }else
        {
            [cell setCellWithModel:_personal[indexPath.row]];
        }
        
        return cell;
    }
    
    static NSString *identifier = @"identify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(RefreshTableView *)tableView
{
    int index = (int)tableView.tag - kTagTableView;
    if (index == 0) {
        return 2;
    }
    return 1;
}

@end
