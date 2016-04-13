//
//  GuserAddressViewController.m
//  TiJian
//
//  Created by gaomeng on 15/11/20.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GuserAddressViewController.h"
#import "AddressModel.h"
#import "GuserAddressTableViewCell.h"
#import "GManageAddressViewController.h"
#import "AddAddressController.h"

@interface GuserAddressViewController ()<RefreshDelegate,UITableViewDataSource>
{
    
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_getAddress;
    
    GuserAddressTableViewCell *_tmpCell;
    
}
@end

@implementation GuserAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
    self.myTitle = @"选择收货地址";
    self.rightString = @"管理";
    [self creatTab];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 点击事件
-(void)rightButtonTap:(UIButton *)sender{
    NSLog(@"%s",__FUNCTION__);
    GManageAddressViewController *cc = [[GManageAddressViewController alloc]init];
    [self.navigationController pushViewController:cc animated:YES];
}

//编辑按钮点击
-(void)oneCellEditBtnClicked:(AddressModel*)passModel{
    NSLog(@"%s",__FUNCTION__);
    AddAddressController *cc = [[AddAddressController alloc]init];
    cc.isEditAddress = YES;
    cc.addressModel = passModel;
    [self.navigationController pushViewController:cc animated:YES];
}

#pragma mark - 视图创建
-(void)creatTab{
    self.tab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    self.tab.refreshDelegate = self;
    self.tab.dataSource = self;
    self.tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tab];
    [self.tab showRefreshHeader:YES];
}



#pragma mark - 网络请求
-(void)prepareNetData{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey],
                          @"page":[NSString stringWithFormat:@"%d",self.tab.pageNum],
                          @"per_page":[NSString stringWithFormat:@"%d",G_PER_PAGE]
                          };
    [_request requestWithMethod:YJYRequstMethodGet api:USER_ADDRESS_LIST parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSArray *list = [result arrayValueForKey:@"list"];
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in list) {
            AddressModel *model = [[AddressModel alloc]initWithDictionary:dic];
            [arr addObject:model];
        }
        
        [self.tab reloadData:arr pageSize:G_PER_PAGE];
    } failBlock:^(NSDictionary *result) {
        [self.tab loadFail];
    }];
    
    
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
    num = self.tab.dataArray.count;
    return num;
}


- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    
    if (!_tmpCell) {
        _tmpCell = [[GuserAddressTableViewCell alloc]init];
    }
    
    for (UIView *view in _tmpCell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    AddressModel *model = self.tab.dataArray[indexPath.row];
    
    height = [_tmpCell loadCustomViewWithModel:model type:ADDRESSCELL_SELECT indexPath:indexPath];
    
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
    GuserAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GuserAddressTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    AddressModel *model = self.tab.dataArray[indexPath.row];
    
    
    cell.delegate1 = self;
    
    [cell loadCustomViewWithModel:model type:ADDRESSCELL_SELECT indexPath:indexPath];
    
    
    return cell;
}


@end
