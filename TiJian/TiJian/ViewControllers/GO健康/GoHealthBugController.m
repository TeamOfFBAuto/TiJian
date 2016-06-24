//
//  GoHealthBugController.m
//  TiJian
//
//  Created by lichaowei on 16/6/12.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GoHealthBugController.h"
#import "PayActionViewController.h"
#import "PayResultViewController.h"

@interface GoHealthBugController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_table;
    UILabel *_numLabel;
    NSArray *_itemsArray;//体检项目
    UILabel *_priceLabel;
    UIButton *_stateButton;
}

@end

@implementation GoHealthBugController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"结算";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    if (self.productModel)
    {
        [self prepareRefreshTableView];
    }else if (self.productId)
    {
        [self netWorkForProductDetail];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建

- (void)prepareRefreshTableView
{
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 49) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self tableViewHeaderViewWithModel:self.productModel];
    
    //底部view
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 49 - 64, DEVICE_WIDTH, 49)];
    footer.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];
    [self.view addSubview:footer];
    
    UIButton *sender = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 80, 0, 80, 49) buttonType:UIButtonTypeCustom normalTitle:@"提交订单" selectedTitle:nil target:self action:@selector(clickToSure:)];
    [sender.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [sender setBackgroundColor:DEFAULT_TEXTCOLOR_ORANGE];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [footer addSubview:sender];

    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, 150, 49) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:nil];
    [footer addSubview:priceLabel];
    _priceLabel = priceLabel;
    
    //显示价格
    [self updateSumPrice];
}

- (void)tableViewHeaderViewWithModel:(ThirdProductModel *)model
{
    _itemsArray = [NSArray arrayWithArray:model.items];
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 115)];
    
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 10, DEVICE_WIDTH - 12 * 2, 20)];
    contentLabel.font = [UIFont systemFontOfSize:16];
    [header addSubview:contentLabel];
    contentLabel.text = model.name;
    
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(contentLabel.left, contentLabel.bottom + 5, 100, 25)];
    priceLabel.font = [UIFont systemFontOfSize:13];
    priceLabel.textColor = RGBCOLOR(237, 108, 22);
    [header addSubview:priceLabel];
    priceLabel.text = [NSString stringWithFormat:@"¥%.2f",[model.discountPrice floatValue]];
    
    //加减
    UIImageView *numImv = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 12 - 80, priceLabel.top, 80, 25)];
    [numImv setImage:[UIImage imageNamed:@"shuliang.png"]];
    numImv.userInteractionEnabled = YES;
    [header addSubview:numImv];
    
    UIButton *jianBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jianBtn setFrame:CGRectMake(0, 0, numImv.frame.size.height, numImv.frame.size.height)];
    [jianBtn setImage:[UIImage imageNamed:@"shuliang-.png"] forState:UIControlStateNormal];
    [jianBtn addTarget:self action:@selector(clickToReduce:) forControlEvents:UIControlEventTouchUpInside];
    [numImv addSubview:jianBtn];
    
    UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(jianBtn.frame), 0, numImv.frame.size.width/3, numImv.frame.size.height)];
    numLabel.font = [UIFont systemFontOfSize:12];
    numLabel.textColor = [UIColor blackColor];
    numLabel.textAlignment = NSTextAlignmentCenter;
    [numImv addSubview:numLabel];
    numLabel.text = @"1";
    _numLabel = numLabel;
    
    UIButton *jiaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jiaBtn setFrame:CGRectMake(CGRectGetMaxX(numLabel.frame), 0, numImv.frame.size.width/3, numImv.frame.size.height)];
    [jiaBtn setImage:[UIImage imageNamed:@"shuliang+.png"] forState:UIControlStateNormal];
    [jiaBtn addTarget:self action:@selector(clickToAdd:) forControlEvents:UIControlEventTouchUpInside];
    [numImv addSubview:jiaBtn];
    
    
    //line
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, numImv.bottom + 20, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [header addSubview:line];
    
    //检测详情
    UIButton *sender = [UIButton buttonWithType:UIButtonTypeCustom];
    sender.frame = CGRectMake(12, line.bottom, DEVICE_WIDTH - 12 * 2, header.height - line.bottom);
    [sender setImage:[UIImage imageNamed:@"jiantou_up"] forState:UIControlStateNormal];
    [sender setImage:[UIImage imageNamed:@"jiantou_down"] forState:UIControlStateSelected];
    [sender setTitle:@"检测详情" forState:UIControlStateNormal];
    [sender setTitle:@"检测详情" forState:UIControlStateSelected];
    [sender setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -55)];
    [sender setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
    [sender setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    [sender setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [sender.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [header addSubview:sender];
    [sender addTarget:self action:@selector(clickToDetail:) forControlEvents:UIControlEventTouchUpInside];
    
    _table.tableHeaderView = header;

}


-(ResultView *)resultViewWithType:(PageResultType)type
                              msg:(NSString *)errMsg
{
    NSString *content;
    NSString *btnTitle;
    SEL selector = NULL;
    if (type == PageResultType_requestFail) {
        
        content = errMsg ? : @"获取数据异常,点击重新加载";
        btnTitle = @"重新加载";
        selector = @selector(refreshData);
        
    }else if (type == PageResultType_nodata){
        
        content = errMsg ? : @"没有获取到您想要的内容";
        btnTitle = @"重新加载";
        selector = @selector(refreshData);
    }
    
    if (_resultView) {
        
        [_resultView setContent:content];
        [_stateButton setTitle:btnTitle forState:UIControlStateNormal];
        return _resultView;
    }
    
    _resultView = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"]
                                             title:@"温馨提示"
                                           content:content];
    
    if (!_stateButton) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 140, 36);
        [btn addCornerRadius:5.f];
        btn.backgroundColor = DEFAULT_TEXTCOLOR;
        [btn setTitle:btnTitle forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        [_resultView setBottomView:btn];
        _stateButton = btn;
    }
    
    return _resultView;
}

/**
 *  开始刷新数据
 */
- (void)refreshData
{
    [_resultView removeFromSuperview];
    [self netWorkForProductDetail];
}

/**
 *  完成数据加载
 *
 *  @param type   结果type
 *  @param errMsg 错误信息
 */
- (void)finishLoadDataWithType:(PageResultType)type
                           msg:(NSString *)errMsg
{
    _resultView = [self resultViewWithType:type msg:errMsg];
    _resultView.centerY = (DEVICE_HEIGHT- 64) / 2.f;
    [self.view addSubview:_resultView];
}

#pragma mark - 网络请求

- (void)netWorkForProductDetail
{
    NSString *nonceStr = [LTools randomNum:32];//随机字符串
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetValue:GoHealthAppId forKey:@"appId"];
    [params safeSetValue:nonceStr forKey:@"nonceStr"];
    [params safeSetValue:@"wap" forKey:@"osType"];
    
    NSString *sign = [MiddleTools goHealthSignWithParams:params];
    [params safeSetValue:sign forKey:@"sign"];
    
    NSString *api = [NSString stringWithFormat:GoHealth_productionsDetail,self.productId];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    @WeakObj(self);
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet_goHealth api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        [MBProgressHUD hideHUDForView:Weakself.view animated:YES];
        [Weakself parseDataWithResult:result];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"%@",result[@"msg"]);
        [MBProgressHUD hideHUDForView:Weakself.view animated:YES];
        [Weakself finishLoadDataWithType:PageResultType_requestFail msg:result[@"msg"]];
    }];
}

#pragma mark - 数据解析处理

- (void)parseDataWithResult:(NSDictionary *)result
{
    NSDictionary *data = result[@"data"];
    NSDictionary *production = data[@"production"];
    
    ThirdProductModel *model = [[ThirdProductModel alloc]initWithDictionary:production];
    _productModel = model;
    
    [self prepareRefreshTableView];
}


//提交订单
-(void)confirmOrderBtnClicked{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic safeSetValue:[UserInfo getAuthkey] forKey:@"authcode"];//authcode
    
    /**
     *  商品数据处理
     */
    NSString *imageUrl = [self.productModel.pictures firstObject][@"thumb"];//套餐封面图片地址
    int num = [_numLabel.text intValue];//商品数量
    NSMutableDictionary *productInfo = [NSMutableDictionary dictionary];
    [productInfo safeSetValue:self.productModel.id forKey:@"product_id"];
    [productInfo safeSetValue:self.productModel.name forKey:@"product_name"];
    [productInfo safeSetValue:imageUrl forKey:@"product_cover_url"];
    [productInfo safeSetValue:self.productModel.discountPrice forKey:@"product_price"];
    [productInfo safeSetInt:num forKey:@"product_num"];
    
    NSArray *products = @[productInfo];
    NSString *product_infos = [LTools JSONStringWithObject:products];
    
    [dic safeSetValue:product_infos forKey:@"product_infos"];
    CGFloat sumPrice = [self sumPrice];
    [dic safeSetValue:[NSString stringWithFormat:@"%f",sumPrice] forKey:@"total_price"];//总价格
    [dic safeSetValue:[NSString stringWithFormat:@"%f",sumPrice] forKey:@"real_price"];// 优惠后价格

    __weak typeof(self)weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance] requestWithMethod:YJYRequstMethodPost api:GoHealth_submit_order parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        [weakSelf parseConfirmOrderSuccessResult:result];
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        DDLOG(@"%@",result);
    }];
    
    
}

#pragma mark - 数据解析处理

/**
 *  处理GoHealth提交订单成功
 *
 *  @param result
 */
- (void)parseConfirmOrderSuccessResult:(NSDictionary *)result
{
    //提交订单成功
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_ORDER_COMMIT object:nil];
    CGFloat sum = [self sumPrice];
    
    NSString *orderId = [result stringValueForKey:@"order_id"];
    NSString *orderNum = [result stringValueForKey:@"order_no"];
    
    if (sum < 0.001) {
        [self payResultSuccess:PAY_RESULT_TYPE_Success erroInfo:nil oderid:orderId sumPrice:sum orderNum:orderNum];
    }else{
        [self pushToPayPageWithOrderId:orderId orderNum:orderNum];
    }
}

/**
 *  计算总价
 *
 *  @return
 */
- (CGFloat)sumPrice
{
    CGFloat price = [self.productModel.discountPrice floatValue] * 100.f;
    price /= 100.f;
    CGFloat sum =  price * [_numLabel.text intValue];
    return sum;
}

#pragma mark - 事件处理

- (void)clickToSure:(UIButton *)sender
{
    [LoginManager isLogin:self loginBlock:^(BOOL success) {
        if (success) {
            [self confirmOrderBtnClicked];
        }
    }];
}

/**
 *  跳转至支付页面
 */
- (void)pushToPayPageWithOrderId:(NSString *)orderId
                        orderNum:(NSString *)orderNum
{
    CGFloat sum = [self.productModel.discountPrice floatValue] * [_numLabel.text intValue];
    PayActionViewController *pay = [[PayActionViewController alloc]init];
    pay.orderId = orderId;
    pay.orderNum = orderNum;
    pay.sumPrice = sum;
    pay.lastViewController = self.lastViewController;
    pay.platformType = PlatformType_goHealth;
    
    int num = (int)[self.navigationController viewControllers].count;
    if (num > 2) {
        UIViewController *lastViewController = self.navigationController.viewControllers[num - 2];
        [lastViewController.navigationController popToViewController:lastViewController animated:NO];
        [lastViewController.navigationController pushViewController:pay animated:YES];
        return;
    }
    [self.navigationController pushViewController:pay animated:YES];
}

/**
 *  订单金额为0直接支付成功
 */
- (void)payResultSuccess:(PAY_RESULT_TYPE)resultType
                erroInfo:(NSString *)erroInfo
                  oderid:(NSString *)theOderId
                sumPrice:(CGFloat)theSumPrice
                orderNum:(NSString *)theOrderNum
{
    //更新购物车
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];
    
    //支付成功通知
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_PAY_SUCCESS object:nil];
    
    PayResultViewController *result = [[PayResultViewController alloc]init];
    result.orderId = theOderId;
    result.orderNum = theOrderNum;
    result.sumPrice = theSumPrice;
    result.payResultType = resultType;
    result.erroInfo = erroInfo;
    result.platformType = PlatformType_goHealth;
    
    if (self.lastViewController && (resultType != PAY_RESULT_TYPE_Fail)) { //成功和等待中需要pop掉,失败的时候不需要,有可能返回重新支付
        [self.lastViewController.navigationController popViewControllerAnimated:NO];
        [self.lastViewController.navigationController pushViewController:result animated:YES];
        return;
    }
    [self.navigationController pushViewController:result animated:YES];
}


- (void)clickToAdd:(UIButton *)sender
{
    _numLabel.text = NSStringFromInt([_numLabel.text intValue] + 1);
    //显示价格
    [self updateSumPrice];
}

- (void)clickToReduce:(UIButton *)sender
{
    int num = [_numLabel.text intValue];
    if (num > 1) {
        num -= 1;
    }
    _numLabel.text = NSStringFromInt(num);
    //显示价格
    [self updateSumPrice];
}

/**
 *  控制检测详情显示
 *
 *  @param sender
 */
- (void)clickToDetail:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        _itemsArray = nil;
    }else
    {
        _itemsArray = [NSArray arrayWithArray:self.productModel.items];
    }
    [_table reloadData];
}

- (void)updateSumPrice
{
    CGFloat sum = [self.productModel.discountPrice floatValue] * [_numLabel.text intValue];
    
    NSString *price = [NSString stringWithFormat:@"¥%.2f",sum];
    NSString *text = [NSString stringWithFormat:@"实付款: %@",price];
    NSAttributedString *string = [LTools attributedString:text keyword:price color:DEFAULT_TEXTCOLOR_ORANGE keywordFontSize:14];
    [_priceLabel setAttributedText:string];
}

#pragma mark - 代理

#pragma - mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40.f)];
    return view;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return [UIView new];
}

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _itemsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"identify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(12, 35 - 0.5, DEVICE_WIDTH - 12 * 2, 0.5)];
        line.image = [UIImage imageNamed:@"goHealth_line"];
        [cell.contentView addSubview:line];
        
        cell.textLabel.font = [UIFont systemFontOfSize:14.f];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *item = _itemsArray[indexPath.row];
    NSString *itemName = item[@"name"];
    cell.textLabel.text = itemName;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
