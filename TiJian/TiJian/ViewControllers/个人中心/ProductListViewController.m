//
//  ProductListViewController.m
//  TiJian
//
//  Created by lichaowei on 15/11/24.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "ProductListViewController.h"
#import "GProductCellTableViewCell.h"
#import "GproductDetailViewController.h"

@interface ProductListViewController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_table;
}

@end

@implementation ProductListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"我的收藏";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    [self prepareRefreshTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建

-(ResultView *)resultView
{
    if (_resultView) {
        
        return _resultView;
    }
    self.resultView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    _resultView.backgroundColor = [UIColor clearColor];
    
    
    self.resultView = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"] title:@"温馨提示" content:@"您还没有添加收藏"];
    
    return _resultView;
}

- (void)prepareRefreshTableView
{
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    [_table showRefreshHeader:YES];
}

#pragma mark - 网络请求

- (void)netWorkForList
{
    NSDictionary *params = @{@"authcode":[UserInfo getAuthkey],
                             @"page":NSStringFromInt(_table.pageNum),
                             @"per_page":NSStringFromInt(G_PER_PAGE)};;
    NSString *api = PRODUCT_COLLECT_LIST;
    
    __weak typeof(self)weakSelf = self;
    __weak typeof(_table)weakTable = _table;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        
        NSArray *temp = [ProductModel modelsFromArray:result[@"list"]];
        [weakTable reloadData:temp pageSize:G_PER_PAGE noDataView:weakSelf.resultView];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        
    }];
}

/**
 *  收藏 取消收藏商品
 *
 *  @param type 1 收藏 2 取消收藏
 */
-(void)cancelCollectProductid:(NSString *)productId
{
    NSDictionary *dic = @{
                          @"product_id":productId,
                          @"authcode":[UserInfo getAuthkey]
                          };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance] requestWithMethod:YJYRequstMethodGet api:QUXIAOSHOUCANG parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
    }];
}

#pragma mark - 数据解析处理

#pragma mark - 事件处理

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
    GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
    ProductModel *model = _table.dataArray[indexPath.row];
    cc.productId = model.product_id;
    [self.navigationController pushViewController:cc animated:YES];
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    return [GProductCellTableViewCell getCellHight];
}

#pragma - mark UITableViewDataSource

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return tableView.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"identifier";
    GProductCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GProductCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    ProductModel *model = _table.dataArray[indexPath.row];
    
    [cell loadData:model];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
        //todo
        
        ProductModel *model = _table.dataArray[indexPath.row];
        [_table.dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self cancelCollectProductid:model.product_id];
        if (_table.dataArray.count == 0) {
            [_table reloadData:nil pageSize:G_PER_PAGE noDataView:self.resultView];
        }
    }
}


// 这里默认删除的按钮为英文，想要改变成中文，需要再实现一个方法。

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0){
    
    return @"删除";
}

@end
