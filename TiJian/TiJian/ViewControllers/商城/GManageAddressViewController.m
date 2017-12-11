//
//  GManageAddressViewController.m
//  TiJian
//
//  Created by gaomeng on 15/11/24.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GManageAddressViewController.h"
#import "GuserAddressTableViewCell.h"
#import "AddAddressController.h"
@interface GManageAddressViewController ()<RefreshDelegate,UITableViewDataSource>
{
    
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_getAddress;
    
    GuserAddressTableViewCell *_tmpCell;
    
    
    UIView *_downAddAddressView;
}

@end

@implementation GManageAddressViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_ADDADDRESS object:nil];
    self.rtab.refreshDelegate = nil;
    self.rtab.dataSource = nil;
    self.rtab = nil;
    
    [_request removeOperation:_request_getAddress];
    _request = nil;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"地址管理";
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updataRtabData) name:NOTIFICATION_ADDADDRESS object:nil];
    
    
    [self creatTab];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 视图创建
-(void)creatTab{
    self.rtab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - HMFitIphoneX_navcBarHeight) style:UITableViewStyleGrouped];
    self.rtab.refreshDelegate = self;
    self.rtab.dataSource = self;
    self.rtab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.rtab];
    [self.rtab showRefreshHeader:YES];
}


#pragma mark - 点击方法
//添加新地址
-(void)downAddAddressBtnClicked{
    NSLog(@"%s",__FUNCTION__);
    AddAddressController *cc = [[AddAddressController alloc]init];
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



#pragma mark - 网络请求
//更新数据
-(void)updataRtabData{
    _rtab.pageNum = 1;
    [_rtab showRefreshHeader:YES];
}


//获取地址列表
-(void)prepareNetData{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey],
                          @"page":[NSString stringWithFormat:@"%d",self.rtab.pageNum],
                          @"per_page":[NSString stringWithFormat:@"%d",G_PER_PAGE]
                          };
    _request_getAddress = [_request requestWithMethod:YJYRequstMethodGet api:USER_ADDRESS_LIST parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSArray *list = [result arrayValueForKey:@"list"];
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in list) {
            AddressModel *model = [[AddressModel alloc]initWithDictionary:dic];
            [arr addObject:model];
        }
        
        [self.rtab reloadData:arr pageSize:G_PER_PAGE];
    } failBlock:^(NSDictionary *result) {
        [self.rtab loadFail];
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
    num = self.rtab.dataArray.count;
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
    
    AddressModel *model = self.rtab.dataArray[indexPath.row];
    
    height = [_tmpCell loadCustomViewWithModel:model type:ADDRESSCELL_EDIT indexPath:indexPath];
    
    return height;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    return height;
}

-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 100;
    return height;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}

-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    _downAddAddressView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 100)];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, DEVICE_WIDTH - 60, 44)];
    btn.layer.cornerRadius = 6;
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.backgroundColor = RGBCOLOR(237, 108, 22);
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"添加新地址" forState:UIControlStateNormal];
    [_downAddAddressView addSubview:btn];
    btn.center = _downAddAddressView.center;
    [btn addTarget:self action:@selector(downAddAddressBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.rtab.tableFooterView = _downAddAddressView;
    
    return _downAddAddressView;
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
    
    AddressModel *model = self.rtab.dataArray[indexPath.row];
    
    cell.delegate = self;
    
    [cell loadCustomViewWithModel:model type:ADDRESSCELL_EDIT indexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    NSLog(@"%s",__FUNCTION__);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
