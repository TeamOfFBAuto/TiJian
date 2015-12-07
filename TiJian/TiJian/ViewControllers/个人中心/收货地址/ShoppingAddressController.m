//
//  ShoppingAddressController.m
//  WJXC
//
//  Created by lichaowei on 15/7/7.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ShoppingAddressController.h"
#import "AddressCell.h"
#import "AddAddressController.h"//添加收货地址
#import "AddressModel.h"
#import "SelectAddressCell.h"
#import "RefreshTableView.h"

#define kPadding_Default 100
#define kPadding_Delete 1000
#define kPadding_Edit 2000

@interface ShoppingAddressController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_table;
    __weak AddressModel *_defaultAddress;//记录默认地址
    int _deleteIndexrow;
    UIView *_footer;
}

@end

@implementation ShoppingAddressController

- (void)dealloc
{
    [_table removeObserver];
    _table.dataSource = nil;
    _table.refreshDelegate = nil;
    _table = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"收货地址";
    
    if (self.isSelectAddress) {
//        self.rightString = @"管理";
        self.rightImageName = @"myaddress_add";
        [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
    }else
    {
        [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    }
    
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH,DEVICE_HEIGHT - 64) showLoadMore:NO];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];
    [_table showRefreshHeader:YES];
    
    __weak typeof(self)weakSelf = self;
//    __weak typeof(_table)weakTable = _table;
    [_table setDataArrayObeserverBlock:^(NSString *keyPath,NSDictionary *change){
                
        int new = [change[@"new"]intValue];
        if (new > 0) {
            
            [weakSelf addFooter];
            
        }else
        {
            [weakSelf removeFooter];
        }
        
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateAddress) name:NOTIFICATION_ADDADDRESS object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 通知处理

- (void)updateAddress
{
    [_table showRefreshHeader:YES];
}

#pragma mark - 网络请求

- (void)updateDefaultAddress:(UIButton *)sender
{
//    __weak typeof(_table)weakTable = _table;
    __weak typeof(self)weakSelf = self;
    __weak AddressModel *aModel = [_table.dataArray objectAtIndex:sender.tag - kPadding_Default];
    
    NSString *authkey = [UserInfo getAuthkey];
    NSDictionary *params = @{@"authcode":authkey,
                             @"address_id":aModel.address_id};
    [MBProgressHUD  showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:USER_ADDRESS_SETDEFAULT parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        [weakSelf updateSortForAddress:aModel];
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];

    }];

}

/**
 *  更新默认地址顺序
 *
 *  @param addressModel
 */
- (void)updateSortForAddress:(AddressModel *)addressModel
{
    addressModel.default_address = @"1";
    _defaultAddress.default_address = @"0";
    [_table reloadData];
    [_table.dataArray removeObject:addressModel];
    [_table.dataArray insertObject:addressModel atIndex:0];
    [_table reloadData];
}

/**
 *  删除地址
 *
 *  @param index 删掉的下标
 */
- (void)deleteAddress:(int)index
{
    __weak AddressModel *aModel = [_table.dataArray objectAtIndex:index];

    __weak typeof(_table)weakTable = _table;
    __weak typeof(self)weakSelf = self;
    NSString *authkey = [UserInfo getAuthkey];
    NSDictionary *params = @{@"authcode":authkey,
                             @"address_id":aModel.address_id};
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:USER_ADDRESS_DELETE parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        weakTable.pageNum = 1;
        weakTable.isReloadData = YES;
        [weakSelf getAddressList];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    }];

}

//收货地址

- (void)getAddressList
{
    __weak typeof(_table)weakTable = _table;
    
    NSString *authkey = [UserInfo getAuthkey];

    NSDictionary *params = @{@"authcode":authkey,
                             @"page":[NSNumber numberWithInt:_table.pageNum],
                             @"per_page":[NSNumber numberWithInt:G_PER_PAGE]};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:USER_ADDRESS_LIST parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSArray *list = result[@"list"];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:list.count];
        for (NSDictionary *aDic in list) {
            
            AddressModel *address = [[AddressModel alloc]initWithDictionary:aDic];
            [temp addObject:address];
        }
        [weakTable reloadData:temp pageSize:G_PER_PAGE noDataView:[self footerViewForNoAddress]];
        
    } failBlock:^(NSDictionary *result) {
        
        [weakTable loadFail];

    }];
   
}

#pragma mark - 创建视图

- (void)addFooter
{
    if (_footer) {
        
        return;
    }
    
    _table.height = DEVICE_HEIGHT - 64 - 43 - 25;
    _footer = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 43 - 25 - 64, DEVICE_WIDTH, 43 + 25)];
    [self.view addSubview:_footer];
    
    UIButton *btn = [[UIButton alloc]initWithframe:CGRectMake(50, 14, DEVICE_WIDTH - 100, 40) buttonType:UIButtonTypeCustom normalTitle:@"添加新地址" selectedTitle:nil target:self action:@selector(clickToAddNewAddress:)];
    btn.backgroundColor = DEFAULT_TEXTCOLOR;
    [btn addCornerRadius:3.f];
    [_footer addSubview:btn];
}

- (void)removeFooter
{
    _table.height = DEVICE_HEIGHT - 64;
    if (_footer) {
        [_footer removeFromSuperview];
        _footer = nil;
    }
}

/**
 *  收货地址为空view
 */
- (UIView *)footerViewForNoAddress
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, _table.height)];
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 235)];
    [footerView addSubview:bgView];
    bgView.centerY = footerView.height/2.f;
    //图片
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 120, 107)];
    imageView.image = [UIImage imageNamed:@"shopping_cart_address_add"];
    [bgView addSubview:imageView];
    imageView.centerX = bgView.width/2.f;
    
    //购物车还是空的
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, imageView.bottom + 22, DEVICE_WIDTH, 15) title:@"您还没有添加地址哦" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"646464"]];
    [bgView addSubview:label];

    UIButton *btn = [[UIButton alloc]initWithframe:CGRectMake((DEVICE_WIDTH - 150) / 2.f, label.bottom + 20, 150, 30) buttonType:UIButtonTypeRoundedRect normalTitle:@"添加地址" selectedTitle:nil target:self action:@selector(clickToAddNewAddress:)];
    [bgView addSubview:btn];
    btn.backgroundColor = DEFAULT_TEXTCOLOR;
    [btn addCornerRadius:3.f];
    btn.centerX = bgView.width/2.f;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    return footerView;
}

#pragma mark - 事件处理
//编辑
- (void)clickToEditAddress:(UIButton *)sender
{
    AddressModel *aModel = [_table.dataArray objectAtIndex:sender.tag - kPadding_Edit];

    AddAddressController *address = [[AddAddressController alloc]init];
    address.isEditAddress = YES;
    address.addressModel = aModel;
    [self.navigationController pushViewController:address animated:YES];
}

/**
 *  跳转至收货地址管理
 *
 *  @param sender
 */
-(void)rightButtonTap:(UIButton *)sender
{
    if (self.isSelectAddress) {
        
        [self clickToAddNewAddress:sender];
        return;
    }
    ShoppingAddressController *shopAddress = [[ShoppingAddressController alloc]init];
    [self.navigationController pushViewController:shopAddress animated:YES];
}

- (void)clickToAddNewAddress:(UIButton *)sender
{
    AddAddressController *address = [[AddAddressController alloc]init];
    [self.navigationController pushViewController:address animated:YES];
}

/**
 *  选中默认地址
 *
 *  @param sender
 */
- (void)clickToSelectAddress:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

/**
 *  删除地址
 *
 *  @param sender
 */
- (void)clickToDeleteAddress:(UIButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"是否确定删除" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = sender.tag;
    sender.tag = 0;
    [alert show];
}

#pragma mark - 代理

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //确定删除
        
        [self deleteAddress:(int)alertView.tag - kPadding_Delete];
    }
}

#pragma mark - RefreshDelegate

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    [self getAddressList];

}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    [self getAddressList];

}

-(void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView

{
    AddressModel *aModel = _table.dataArray[indexPath.row];

    self.selectAddressId = aModel.address_id;
    
    [_table reloadData];
    
    if (self.isSelectAddress) {
        
        if (self.selectAddressBlock) {
            
            self.selectAddressBlock(aModel);
        }
        
        [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];
        
        return;
    }
    AddAddressController *address = [[AddAddressController alloc]init];
    address.isEditAddress = YES;
    address.addressModel = aModel;
    [self.navigationController pushViewController:address animated:YES];
}

-(CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    if (self.isSelectAddress) {
        
        return 88.f;
    }
    AddressModel *aModel = _table.dataArray[indexPath.row];
    
    return [AddressCell heightForCellWithAddress:aModel.address];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _table.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSelectAddress) {

        static NSString *identify = @"SelectAddressCell";
        SelectAddressCell *cell = (SelectAddressCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
        AddressModel *aModel = [_table.dataArray objectAtIndex:indexPath.row];
        [cell setCellWithModel:aModel];
        
        if ([aModel.address_id isEqualToString:self.selectAddressId]) {
            
            cell.selectImage.hidden = NO;
            cell.infoView.left = cell.selectImage.right;

        }else
        {
            cell.selectImage.hidden = YES;
            cell.infoView.left = 0;

        }
        
        [cell.editBtn addTaget:self action:@selector(clickToEditAddress:) tag:(int)(kPadding_Edit + indexPath.row)];
        
        return cell;
    }
    
    static NSString *identify = @"AddressCell";
    AddressCell *cell = (AddressCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    [cell.addressButton addTarget:self action:@selector(clickToSelectAddress:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    AddressModel *aModel = [_table.dataArray objectAtIndex:indexPath.row];
    [cell setCellWithModel:aModel];
    
    if ([aModel.default_address intValue] == 1) {
        _defaultAddress = aModel;
    }
    
    cell.addressButton.tag = kPadding_Default + indexPath.row;
    [cell.addressButton addTarget:self action:@selector(updateDefaultAddress:) forControlEvents:UIControlEventTouchUpInside];
    cell.deleteButton.tag = kPadding_Delete + indexPath.row;
    [cell.deleteButton addTarget:self action:@selector(clickToDeleteAddress:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.editButton.userInteractionEnabled = NO;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
