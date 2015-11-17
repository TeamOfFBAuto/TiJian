//
//  ConfirmOrderViewController.m
//  TiJian
//
//  Created by gaomeng on 15/11/12.
//  Copyright © 2015年 lcw. All rights reserved.
//


//确认订单

#import "ConfirmOrderViewController.h"
#import "ProductModel.h"
#import "AddAddressController.h"
#import "PayActionViewController.h"

@interface ConfirmOrderViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tab;
    UIView *_addressView;
    
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_confirmOrder;
    
    CGFloat _sumPrice_pay;
    
    
}
@end

@implementation ConfirmOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"确认订单";
    
    _sumPrice_pay = 0;
    
    [self creatTab];
    [self creatAddressView];
    [self creatDownView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 视图创建
-(void)creatTab{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 50) style:UITableViewStyleGrouped];
    _tab.delegate = self;
    _tab.dataSource = self;
    [self.view addSubview:_tab];
    
    
}


-(void)creatAddressView{
    _addressView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 115)];
    _addressView.backgroundColor = RGBCOLOR(244, 245, 246);
    
   
    
    
    //上分割线
    UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 2.5)];
    [imv setImage:[UIImage imageNamed:@"shoppingcart_dd_top_line.png"]];
    [_addressView addSubview:imv];
    
    //内容
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(imv.frame), DEVICE_WIDTH, 100)];
    contentView.backgroundColor = [UIColor whiteColor];
    [_addressView addSubview:contentView];
    [contentView addTaget:self action:@selector(goToEditAddress) tag:0];
    
    //姓名
    UIImageView *nameLogoImv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 12, 17.5)];
    [nameLogoImv setImage:[UIImage imageNamed:@"shoppingcart_dd_top_name.png"]];
    [contentView addSubview:nameLogoImv];
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nameLogoImv.frame)+8, 10, 80, nameLogoImv.frame.size.height)];
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.text = @"张欣";
    [contentView addSubview:nameLabel];
    
    //电话
    UIImageView *phoneLogoImv = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame)+10, nameLabel.frame.origin.y, 12, 17.5)];
    [phoneLogoImv setImage:[UIImage imageNamed:@"shoppingcart_dd_top_phone.png"]];
    [contentView addSubview:phoneLogoImv];
    UILabel *phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(phoneLogoImv.frame)+8, 10, 110, phoneLogoImv.frame.size.height)];
    phoneLabel.font = [UIFont systemFontOfSize:14];
    phoneLabel.text = @"13302020202";
    [contentView addSubview:phoneLabel];
    
    //详细地址
    UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(phoneLabel.frame)+10, DEVICE_WIDTH - 20, contentView.frame.size.height - nameLogoImv.frame.size.height -30)];
    addressLabel.font = [UIFont systemFontOfSize:13];
    addressLabel.textColor = [UIColor blackColor];
    addressLabel.text = @"地址地址地址地址地址地址地址地址";
    [contentView addSubview:addressLabel];
    
    //自适应地址label高度
    [addressLabel setMatchedFrame4LabelWithOrigin:CGPointMake(10, CGRectGetMaxY(phoneLabel.frame)+10) height:contentView.frame.size.height - nameLogoImv.frame.size.height -30 limitMaxWidth:DEVICE_WIDTH - 20];
    
    //调整contentview高度
    [contentView setHeight:CGRectGetMaxY(addressLabel.frame)+10];
    
    //下分割线
    UIImageView *imv1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(contentView.frame), DEVICE_WIDTH, 2.5)];
    [imv1 setImage:[UIImage imageNamed:@"shoppingcart_dd_top_line.png"]];
    [_addressView addSubview:imv1];
    
    //调整addressview高度
    [_addressView setHeight:CGRectGetMaxY(imv1.frame)+5];
    
    _tab.tableHeaderView = _addressView;
}


//创建下面view
-(void)creatDownView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 64 - 50, DEVICE_WIDTH, 50)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    UIButton *confirmOrderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmOrderBtn setFrame:CGRectMake(DEVICE_WIDTH - 80, 0, 80, 50)];
    confirmOrderBtn.backgroundColor = [UIColor orangeColor];
    confirmOrderBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [confirmOrderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmOrderBtn setTitle:@"提交订单" forState:UIControlStateNormal];
    [confirmOrderBtn addTarget:self action:@selector(confirmOrderBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:confirmOrderBtn];
    
}


#pragma mark - 点击事件

//提交订单
-(void)confirmOrderBtnClicked{
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    
    
    NSMutableArray *product_ids_arr = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *product_nums_arr = [NSMutableArray arrayWithCapacity:1];
    NSString *total_price = @"0";
    CGFloat price = 0;
    for (NSArray *arr in self.dataArray) {
        for (ProductModel *oneModel in arr) {
            [product_ids_arr addObject:oneModel.product_id];
            [product_nums_arr addObject:oneModel.product_num];
            price += [oneModel.current_price floatValue] * [oneModel.product_num intValue];
        }
    }
    
    _sumPrice_pay = price;
    
    total_price = [NSString stringWithFormat:@"%.2f",price];
    
    
    NSLog(@"%@",product_ids_arr);
    NSString *product_ids_str = [product_ids_arr componentsJoinedByString:@","];
    NSString *product_nums_str = [product_nums_arr componentsJoinedByString:@","];

    
    
    
    
    NSDictionary *dic = @{
                          @"authcode":[GMAPI testAuth],
                          @"product_ids":product_ids_str,
                          @"product_nums":product_nums_str,
                          @"address_id":@"1",
                          @"order_note":@"订单备注",
                          @"is_use_score":@"0",
                          @"total_price":total_price
                          };
    
    
//    NSDictionary *dic1 = @{
//                           @"authcode":[GMAPI testAuth],
//                           @"product_ids":@"1,2",
//                           @"product_nums":@"1,1",
//                           @"address_id":@"订单id",
//                           @"order_note":@"订单备注",
//                           @"is_use_score":@"是否使用积分",
//                           @"score":@"使用的积分",
//                           @"coupon_id":@"优惠券id",
//                           @"vouchers_id":@"代金券",
//                           @"is_appoint":@"是否是预约页面跳转过来的 1：是； 由购物车跳转过来的不用传递这个参数",
//                           @"total_price":@"总价格"
//                           };
    
    __weak typeof(self)weakSelf = self;
    
    _request_confirmOrder = [_request requestWithMethod:YJYRequstMethodPost api:ORDER_SUBMIT parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"%@",result);
        NSString *orderId = [result stringValueForKey:@"order_id"];
        NSString *orderNum = [result stringValueForKey:@"order_no"];
        [weakSelf pushToPayPageWithOrderId:orderId orderNum:orderNum];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"%@",result);
    }];
    
    
}


/**
 *  跳转至支付页面
 */
- (void)pushToPayPageWithOrderId:(NSString *)orderId
                        orderNum:(NSString *)orderNum
{
    PayActionViewController *pay = [[PayActionViewController alloc]init];
    pay.orderId = orderId;
    pay.orderNum = orderNum;
    pay.sumPrice = _sumPrice_pay;
    pay.lastVc = self;
    if (self.lastViewController) {
        
        [self.lastViewController.navigationController popToViewController:self.lastViewController animated:NO];
        [self.lastViewController.navigationController pushViewController:pay animated:YES];
        return;
    }
    [self.navigationController pushViewController:pay animated:YES];
}



-(void)goToEditAddress{
    NSLog(@"%s",__FUNCTION__);
    AddAddressController *cc = [[AddAddressController alloc]init];
    [self.navigationController pushViewController:cc animated:YES];
}



#pragma mark - UITableViewDelegate && UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = 0;
    num = self.dataArray.count;
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    NSArray *arr = self.dataArray[section];
    num = arr.count;
    return num;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/80];
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CGFloat height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/100];
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/230];
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    
    NSArray *arr = self.dataArray[section];
    
    ProductModel *amodel = arr[0];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/80])];
    titleLabel.backgroundColor = [UIColor orangeColor];
    titleLabel.text = amodel.brand_name;
    [view addSubview:titleLabel];
    
    [view setFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/80])];
    return view;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    [view setFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/100])];
    view.backgroundColor = [UIColor purpleColor];
    
    UIView *upLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/10])];
    upLine.backgroundColor = RGBCOLOR(244, 245, 246);
    [view addSubview:upLine];
    
    UIView *midView = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(upLine.frame), DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/80])];
    midView.backgroundColor = [UIColor whiteColor];
    
    
    
    
    UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(midView.frame), DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/10])];
    [view addSubview:downLine];
    
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    
    
    
    return cell;
}


@end
