//
//  OrderInfoViewController.m
//  WJXC
//
//  Created by lichaowei on 15/7/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "OrderInfoViewController.h"
#import "ProductBuyCell.h"
#import "ConfirmInfoCell.h"
#import "AddressModel.h"
#import "ProductModel.h"
#import "FBActionSheet.h"
#import "PayActionViewController.h"//支付页面
#import "ConfirmOrderViewController.h"//确认订单
#import "OrderProductListController.h"//套餐详情
#import "SelectCell.h"
#import "OrderOtherInfoCell.h"
#import "TuiKuanViewController.h"//申请退款
#import "BrandModel.h"//品牌model
#import "GconfirmOrderCell.h"

#import "RCIM.h"

#import "OrderModel.h"
#import "CouponModel.h"

#define ALIPAY @"支付宝支付"
#define WXPAY  @"微信支付"

#define ALERT_TAG_PHONE 100 //拨打电话
#define ALERT_TAG_CANCEL_ORDER 101 //取消订单
#define ALERT_TAG_DEL_ORDER 102 //删除订单
#define ALERT_TAG_RECIEVER_CONFIRM 103 //确认收货


@interface OrderInfoViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_table;
    NSArray *_titles;
    NSArray *_titlesSub;
    UITextField *_inputTf;//备注
    NSString *_selectAddressId;//选中的地址
    
    UIImageView *_nameIcon;//名字icon
    
    UILabel *_nameLabel;//收货人name
    UILabel *_phoneLabel;//收货人电话
    UILabel *_addressLabel;//收货地址
    UIImageView *_phoneIcon;//电话icon
    
    NSString *_payStyle;//支付类型
    
    UILabel *_priceLabel;//邮费加产品价格
    
    MBProgressHUD *_loading;//加载
    
    UILabel *_addressHintLabel;//收货地址提示
    OrderModel *_orderModel;//订单model
    
    YJYRequstManager *_request;
    
}

@property(nonatomic,retain)NSArray *dataArray;

@end

@implementation OrderInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"订单详情";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 50) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _table.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    
    [self getOrderInfo];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求

/**
 *  获取
 */
- (void)getOrderInfo
{
    NSString *authkey = [GMAPI getAuthkey];

    if ([self.order_id intValue] == 0) {
        
        [LTools showMBProgressWithText:@"查看订单无效" addToView:self.view];
        return;
    }
    
    NSDictionary *params = @{
                             @"authcode":authkey,
                             @"order_id":self.order_id,
                             @"detail":[NSNumber numberWithInt:1]
                             };
    
//    __weak typeof(_table)weakTable = _table;
    __weak typeof(self)weakSelf = self;
    
    [[YJYRequstManager shareInstance] requestWithMethod:YJYRequstMethodGet api:ORDER_GET_ORDER_INFO parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"获取订单详情%@ %@",result[RESULT_INFO],result);
        [weakSelf parseDataWithResult:result];
        
    } failBlock:^(NSDictionary *result) {
        NSLog(@"获取订单详情 失败 %@",result);
    }];
    
}

#pragma mark - 数据处理

- (void)parseDataWithResult:(NSDictionary *)result
{
    NSDictionary *info = result[@"info"];
    NSArray *products = info[@"products"];
    OrderModel *aModel = [[OrderModel alloc]initWithDictionary:info];
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:products.count];
    for (NSDictionary *aDic in products) {
        BrandModel *b_model = [[BrandModel alloc]initWithDictionary:aDic];//品牌
        NSMutableArray *p_temp = [NSMutableArray arrayWithCapacity:b_model.list.count];
        for (NSDictionary *p_dic in b_model.list) {
            ProductModel *p_model = [[ProductModel alloc]initWithDictionary:p_dic];//商品
            [p_temp addObject:p_model];
        }
        b_model.productsArray = [NSArray arrayWithArray:p_temp];
        [temp addObject:b_model];
        
//        //test
//        BrandModel *c_model = [[BrandModel alloc]init];
//        c_model.brand_id = @"2";
//        c_model.brand_name = @"慈铭体检";
//        c_model.productsArray = [NSArray arrayWithArray:p_temp];
//        [temp addObject:c_model];
        
    }
    _dataArray = [NSArray arrayWithArray:temp];
    
    _orderModel = aModel;
    
    [self setViewsWithModel:aModel];
    
    [_table reloadData];
}

#pragma mark - 事件处理

/**
 *  判断section是否是显示单品
 *
 *  @param section
 *
 *  @return
 */
- (BOOL)productsSection:(NSInteger)section
{
    if (section < _dataArray.count) {
        return YES;
    }
    return NO;
}

/**
 *  判断是否是否是单品IndexPath
 *
 *  @param indexPath
 *
 *  @return
 */
- (BOOL)productIndexPath:(NSIndexPath *)indexPath
{
    BrandModel *shopModel = _dataArray[indexPath.section];
    if (indexPath.row < shopModel.productsArray.count) {
        
        return YES;
    }
    return NO;
}

/**
 *  再次购买
 *
 *  @param sender
 */
- (void)buyAgain:(OrderModel *)order
{
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:order.products.count];
    for (NSDictionary *aDic in order.products) {
        
        ProductModel *aModel = [[ProductModel alloc]initWithDictionary:aDic];
        [temp addObject:aModel];
    }
    NSArray *productArr = temp;
    ConfirmOrderViewController *confirm = [[ConfirmOrderViewController alloc]init];
    confirm.dataArray = productArr;
    [self.navigationController pushViewController:confirm animated:YES];
}


/**
 *  事件处理
 *
 *  @param sender
 */
- (void)clickToAction:(UIButton *)sender
{
    NSString *text = sender.titleLabel.text;
    NSLog(@"text %@",text);
    
    if ([text isEqualToString:@"去支付"]) {
        
        //去支付
        [self pushToPayPageWithOrderId:_orderModel.order_id orderNum:_orderModel.order_no];
        
    }else if ([text isEqualToString:@"取消订单"]){
        
        NSString *msg = [NSString stringWithFormat:@"是否确定取消订单"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = ALERT_TAG_CANCEL_ORDER;
        [alert show];
        
    }else if ([text isEqualToString:@"再次购买"]){
        
        //再次购买通知
        [self buyAgain:_orderModel];
        
    }else if ([text isEqualToString:@"前去预约"]){
        OrderProductListController *list = [[OrderProductListController alloc]init];
        list.orderId = _orderModel.order_id;
        [self.navigationController pushViewController:list animated:YES];
        
    }else if ([text isEqualToString:@"删除订单"]){
        
        NSString *msg = [NSString stringWithFormat:@"是否确定删除订单"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = ALERT_TAG_DEL_ORDER;
        [alert show];
        
    }else if ([text isEqualToString:@"申请退款"]){
        
        OrderModel *aModel = _orderModel;
        TuiKuanViewController *tuiKuan = [[TuiKuanViewController alloc]init];
        tuiKuan.tuiKuanPrice = [aModel.real_price floatValue];
        tuiKuan.orderId = aModel.order_id;
        tuiKuan.lastVc = self;
        [self.navigationController pushViewController:tuiKuan animated:YES];
    }
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
    pay.sumPrice = [_orderModel.total_fee floatValue];
    pay.payStyle = [_orderModel.pay_type intValue];//支付类型
    pay.lastVc = self;
    pay.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:pay animated:YES];
}

- (void)clickToHidderkeyboard
{
    [_inputTf resignFirstResponder];
}

/**
 *  联系客服
 *
 *  @param sender
 */
- (void)clickToChat:(UIButton *)sender
{
//    NSString *text = [NSString stringWithFormat:@"订单编号:%@",_orderModel.order_no];
//    RCTextMessage *msg = [[RCTextMessage alloc]init];
//    msg.content = text;
//    msg.extra = @"订单编号:";
//    
//    
//    [[RCIM sharedRCIM]sendTextMessage:ConversationType_PRIVATE targetId:_orderModel.yy_uid textMessage:msg delegate:nil object:nil];
//    
//    
//    [MiddleTools chatWithUserId:_orderModel.yy_uid userName:_orderModel.yy_username forViewController:self lastNavigationHidden:NO];

}

/**
 *  拨打电话
 *
 *  @param sender
 */
- (void)clickToPhone:(UIButton *)sender
{
    NSString *msg = [NSString stringWithFormat:@"拨打:%@",_orderModel.receiver_mobile];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = ALERT_TAG_PHONE;
    [alert show];
}


#pragma mark - 创建视图
/**
 *  底部工具条
 */
- (void)createBottomView
{
    UIView *bottom = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 64 - 50, DEVICE_WIDTH, 50)];
    bottom.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [self.view addSubview:bottom];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.5f)];
    line.backgroundColor = [UIColor colorWithHexString:@"e4e4e4"];
    [bottom addSubview:line];
    
    NSString *text1 = nil;
    NSString *text2 = nil;
    NSString *text3 = nil;

    //订单状态 1=》待付款 2=》待预约 3=》已预约 4=》已完成 5=》已取消 6=》已删除
    //退单状态 0=>未申请退款 1=》用户已提交申请退款 2=》同意退款（已提交微信/支付宝）3=》同意退款（退款成功） 4=》同意退款（退款失败） 5=》拒绝退款

//    待付款：去支付、取消订单
//    待预约：前去预约、 申请退款
//    已预约    申请退款
//    已完成：评价晒单（根据返回参数判断是否显示）、删除订单、再次购买
//    退    换：显示退货状态，字段为refund_status，  退款中（1和2）、退款成功（3）、退款失败（4和5）
    
    int refund_status = [_orderModel.refund_status intValue];
    
    //代表有退款状态
    if (refund_status > 0) {
        
        if (refund_status == 1 || refund_status == 2) {
            text1 = @"退款中";
        }else if (refund_status == 3){
            text1 = @"退款成功";
        }else if (refund_status == 4 || refund_status == 5){
            text1 = @"退款失败";
        }
        
    }else
    {
        int status = [_orderModel.status intValue];
        
        if (status == 1) {
            //待支付
            text1 = @"去支付";
            text2 = @"取消订单";
        }else if (status == 2){ //已付款就是待预约
            //待预约
            text1 = @"前去预约";
            text2 = @"申请退款";
            
        }else if (status == 3){
            //已预约
            text1 = @"申请退款";
        }
        else if (status == 4){
            //已完成
            text1 = @"再次购买";
            text2 = @"评价晒单";
            text3 = @"删除订单";
        }
    }
    
    CGFloat btn_width = 70;
    CGFloat btn_height = 30;
    CGFloat top = (bottom.height - btn_height)/2.f;
    UIButton *button1 = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 15 - btn_width, top, btn_width, btn_height) buttonType:UIButtonTypeRoundedRect normalTitle:text1 selectedTitle:nil target:self action:@selector(clickToAction:)];
    [button1 addCornerRadius:3.f];
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button1 setBackgroundColor:DEFAULT_TEXTCOLOR_ORANGE];
    [button1.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [bottom addSubview:button1];
    
    UIButton *button2;
    if (text2.length) {
        button2 = [[UIButton alloc]initWithframe:CGRectMake(button1.left - 15 - btn_width, top, btn_width, btn_height) buttonType:UIButtonTypeRoundedRect normalTitle:text2 selectedTitle:nil target:self action:@selector(clickToAction:)];
        [button2 addCornerRadius:3.f];
        [button2 setTitleColor:DEFAULT_TEXTCOLOR_TITLE forState:UIControlStateNormal];
        [button2.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [button2 setBorderWidth:0.5f borderColor:DEFAULT_TEXTCOLOR_TITLE_THIRD];
        [bottom addSubview:button2];
    }
    
    if (text3.length) {
        UIButton *button3 = [[UIButton alloc]initWithframe:CGRectMake(button2.left - 15 - btn_width, top, btn_width, btn_height) buttonType:UIButtonTypeRoundedRect normalTitle:text3 selectedTitle:nil target:self action:@selector(clickToAction:)];
        [button3 addCornerRadius:3.f];
        [button3 setTitleColor:DEFAULT_TEXTCOLOR_TITLE forState:UIControlStateNormal];
        [button3.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [button3 setBorderWidth:0.5f borderColor:DEFAULT_TEXTCOLOR_TITLE_THIRD];
        [bottom addSubview:button3];
        button2.backgroundColor = DEFAULT_TEXTCOLOR;
        [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)tableViewFooter
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 61 + 30)];
    footerView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0.5, DEVICE_WIDTH, 31)];
    bgView.backgroundColor = [UIColor whiteColor];
    [footerView addSubview:bgView];
    
    UIButton *chatBtn = [[UIButton alloc]initWithframe:CGRectMake(0, 0, DEVICE_WIDTH/2.f, 31) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil target:self action:@selector(clickToChat:)];
    [bgView addSubview:chatBtn];
    [chatBtn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    [chatBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    chatBtn.backgroundColor = [UIColor whiteColor];
    [chatBtn setImage:[UIImage imageNamed:@"order_chat"] forState:UIControlStateNormal];
    [chatBtn setTitle:@"  联系卖家" forState:UIControlStateNormal];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(chatBtn.right, 5, 0.5, 21)];
    line.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [bgView addSubview:line];
    
    UIButton *phoneBtn = [[UIButton alloc]initWithframe:CGRectMake(line.right, 0, DEVICE_WIDTH/2.f, 31) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil target:self action:@selector(clickToPhone:)];
    [bgView addSubview:phoneBtn];
    [phoneBtn setImage:[UIImage imageNamed:@"order_phone"] forState:UIControlStateNormal];
    [phoneBtn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    [phoneBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    phoneBtn.backgroundColor = [UIColor whiteColor];
    [phoneBtn setTitle:@"  拨打电话" forState:UIControlStateNormal];
    
//    real_price;//实际付款
//    coupon_offset_money;  //优惠券优惠金额
//    vouchers_offset_money;//代金券优惠金额
//    score_offset_money;// 积分优惠金额
//    express_fee; //运费
    
//    NSArray *titles = @[@"商品金额",@"运费",@"优惠劵",@"代金卷",@"积分"];
    
    //存放所有标题
    NSMutableArray *titles = [NSMutableArray arrayWithObjects:@"商品金额",@"运费", nil];
    
    //实付款
    NSString *price = [NSString stringWithFormat:@"￥%.2f",[_orderModel.total_fee floatValue]];
    //运费
    NSString *expressFee = [NSString stringWithFormat:@"免运费"];
    if ([_orderModel.express_fee floatValue] > 0) {
        expressFee = [NSString stringWithFormat:@"+  ￥%.2f",[_orderModel.express_fee floatValue]];
    }
    //存放所有显示内容
    NSMutableArray *values = [NSMutableArray arrayWithObjects:price,expressFee, nil];
    
    //优惠劵
    if ([_orderModel.coupon_offset_money floatValue] > 0) {
        NSString *coupeMoney = [NSString stringWithFormat:@"-  ￥%.2f",[_orderModel.coupon_offset_money floatValue]];
        [titles addObject:@"优惠劵"];
        [values addObject:coupeMoney];
    }
    //代金卷
    if ([_orderModel.vouchers_offset_money floatValue] > 0) {
        NSString *coupeMoney = [NSString stringWithFormat:@"-  ￥%.2f",[_orderModel.vouchers_offset_money floatValue]];
        [titles addObject:@"代金卷"];
        [values addObject:coupeMoney];
    }
    
    //积分
    if ([_orderModel.score_offset_money floatValue] > 0) {
        NSString *coupeMoney = [NSString stringWithFormat:@"-  ￥%.2f",[_orderModel.score_offset_money floatValue]];
        [titles addObject:@"积分"];
        [values addObject:coupeMoney];
    }
    
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, phoneBtn.bottom + 5, DEVICE_WIDTH, titles.count * 22 + 10 + 10)];
    view.backgroundColor = [UIColor whiteColor];
    [bgView addSubview:view];
    
    for (int i = 0; i < titles.count; i ++) {
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 10 + 22 * i, 100, 22) title:titles[i] font:14.f align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_THIRD];
        [view addSubview:label];
        
        NSString *text = values[i];
        label = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 100 - 15, 10 + 22 * i, 100, 22) title:text font:14.f align:NSTextAlignmentRight textColor:DEFAULT_TEXTCOLOR_ORANGE];
        [view addSubview:label];
    }
    
    //line
    line = [[UIImageView alloc]initWithFrame:CGRectMake(0, view.bottom, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [bgView addSubview:line];
    //实际付款
    
    UIView *realPriceView = [[UIView alloc]initWithFrame:CGRectMake(0, line.bottom, DEVICE_WIDTH, 50)];
    realPriceView.backgroundColor = [UIColor whiteColor];
    [bgView addSubview:realPriceView];
    
    NSString *realPrice = [NSString stringWithFormat:@"￥%.2f",[_orderModel.real_price floatValue]];
    NSString *title = @"实付款:";
    NSString *content = [NSString stringWithFormat:@"%@%@",title,realPrice];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH - 15, 50) title:realPrice font:14.f align:NSTextAlignmentRight textColor:DEFAULT_TEXTCOLOR_ORANGE];
    [realPriceView addSubview:label];
    label.backgroundColor = [UIColor whiteColor];
    [label setAttributedText:[LTools attributedString:content keyword:title color:DEFAULT_TEXTCOLOR_TITLE_SUB ]];
    
    footerView.height = realPriceView.bottom;
    _table.tableFooterView = footerView;
}


#pragma - mark UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_TAG_PHONE) {
        
        if (buttonIndex == 1) {
            
            NSString *phone = _orderModel.receiver_mobile;
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone]]];
        }
    }else if (alertView.tag == ALERT_TAG_CANCEL_ORDER){
        
        if (buttonIndex == 1) {
            
            NSString *authkey = [GMAPI getAuthkey];
            
            __weak typeof(self)weakSelf = self;
            NSDictionary *params = @{
                                     @"authcode":authkey,
                                     @"order_id":_orderModel.order_id,
                                     @"action":@"cancel"
                                     };
            
            [[YJYRequstManager shareInstance] requestWithMethod:YJYRequstMethodGet api:ORDER_HANDLE_ORDER parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
                NSLog(@"result取消订单 %@",result);
                
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_ORDER_CANCEL object:nil];
                [weakSelf.navigationController popViewControllerAnimated:YES];

            } failBlock:^(NSDictionary *result) {
                
            }];
        }
        
    }else if (alertView.tag == ALERT_TAG_DEL_ORDER){
        
        if (buttonIndex == 1) {
            NSString *authkey = [GMAPI getAuthkey];
            
            __weak typeof(self)weakSelf = self;
            NSDictionary *params = @{@"authcode":authkey,
                                     @"order_id":_orderModel.order_id,
                                     @"action":@"del"};
            
            [[YJYRequstManager shareInstance] requestWithMethod:YJYRequstMethodGet api:ORDER_HANDLE_ORDER parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
                
            } failBlock:^(NSDictionary *result) {
                NSLog(@"删除订单");
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_ORDER_DEL object:nil];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
            
        }

    }else if (alertView.tag == ALERT_TAG_RECIEVER_CONFIRM){
     
        if (buttonIndex == 1) {
            
            NSString *authkey = [GMAPI getAuthkey];
            
            __weak typeof(self)weakSelf = self;
            NSDictionary *params = @{
                                     @"authcode":authkey,
                                     @"order_id":_orderModel.order_id
                                     };
            
            [[YJYRequstManager shareInstance] requestWithMethod:YJYRequstMethodGet api:ORDER_RECEIVING_CONFIRM parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_RECIEVE_CONFIRM object:nil];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } failBlock:^(NSDictionary *result) {
                
            }];
            
        }

    }
    
}


/**
 *  所有视图赋值
 *
 *  @param aModel
 */
- (void)setViewsWithModel:(OrderModel *)aModel
{
    _orderModel = aModel;
    [self tableHeaderViewWithAddressModel:aModel];
    [self tableViewFooter];
    [self createBottomView];
}

- (void)tableHeaderViewWithAddressModel:(OrderModel *)aModel
{
    NSString *name = aModel.receiver_username;
    NSString *phone = aModel.receiver_mobile;
    NSString *address = aModel.address;
    
    //是否有收货地址
    BOOL haveAddress = address ? YES : NO;
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 122)];
    headerView.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    
    UIImageView *topImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, DEVICE_WIDTH, 3)];
    [headerView addSubview:topImage];
    topImage.image = [UIImage imageNamed:@"shoppingcart_dd_top_line"];
    
    UIView *addressView = [[UIView alloc]initWithFrame:CGRectMake(0, topImage.bottom, DEVICE_WIDTH, 100)];
    addressView.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
    [headerView addSubview:addressView];
    
    //名字icon
    _nameIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 13, 12, 17.5)];
    [addressView addSubview:_nameIcon];
    _nameIcon.image = [UIImage imageNamed:@"shoppingcart_dd_top_name"];
    _nameIcon.hidden = !haveAddress;
    
    //名字
    CGFloat aWidth = [LTools widthForText:name font:15];
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(_nameIcon.right + 10, 13, aWidth, _nameIcon.height) title:name font:15.f align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [addressView addSubview:_nameLabel];
    
    //电话icon
    _phoneIcon = [[UIImageView alloc]initWithFrame:CGRectMake(_nameLabel.right + 10, 13, 12, 17.5)];
    [addressView addSubview:_phoneIcon];
    _phoneIcon.image = [UIImage imageNamed:@"shoppingcart_dd_top_phone"];
    _phoneIcon.hidden = !haveAddress;
    
    //电话
    _phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(_phoneIcon.right + 10, 13, 120, _nameIcon.height) title:phone font:15.f align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [addressView addSubview:_phoneLabel];
    
    //地址
    _addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, _phoneIcon.bottom + 15, DEVICE_WIDTH - 10 * 2, 40) title:address font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"646462"]];
    [addressView addSubview:_addressLabel];
    _addressLabel.numberOfLines = 2;
    _addressLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
//    addressView.backgroundColor = [UIColor redColor];
    
    CGFloat height = [LTools heightForText:address width:_addressHintLabel.width font:14];
    _addressLabel.height = height;
    addressView.height = _addressLabel.bottom + 10;
    
    UIImageView *bottomImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, addressView.bottom, DEVICE_WIDTH, 3)];
    [headerView addSubview:bottomImage];
    bottomImage.image = [UIImage imageNamed:@"shoppingcart_dd_top_line"];
    
    headerView.height = bottomImage.bottom;
    
    if (!haveAddress) {
        
        _addressHintLabel = [[UILabel alloc]initWithFrame:headerView.bounds title:@"请填写收货地址以确保商品顺利到达" font:13 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"646462"]];
        [headerView addSubview:_addressHintLabel];
    }
    
    
    _table.tableHeaderView = headerView;
    
    [_table reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ([self productsSection:indexPath.section]) {
//        
//        if ([self productIndexPath:indexPath]) {
//            
//            ShopModel *shopModel = _shop_arr[indexPath.section - 1];
//            ProductModel *aModel = [shopModel.productsArray objectAtIndex:indexPath.row];
//            [MiddleTools pushToProductDetailWithId:aModel.product_id fromViewController:self lastNavigationHidden:NO hiddenBottom:NO];
//        }
//    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self productsSection:indexPath.section]) {
        
        if ([self productIndexPath:indexPath]) {
            
            return [GconfirmOrderCell heightForCell];
        }
    }
    
    return 50 + 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self productsSection:section]) {
        return 45;
    }
    
    return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if ([self productsSection:section]) {
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 45)];
        view.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
        
        BrandModel *b_model = _dataArray[section];
        NSString *title = [NSString stringWithFormat:@"    %@",b_model.brand_name];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 40) title:title font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"313131"]];
        titleLabel.backgroundColor = [UIColor whiteColor];
        [view addSubview:titleLabel];
        
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, view.height - 0.5, DEVICE_WIDTH, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [view addSubview:line];
        
        return view;
    }
    
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self productsSection:section]) {
        
        BrandModel *aModel = _dataArray[section];
        return aModel.productsArray.count;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self productsSection:indexPath.section]) {
        
        if ([self productIndexPath:indexPath]) {
            
            static NSString *identify = @"GconfirmOrderCell";
            GconfirmOrderCell *cell = [[GconfirmOrderCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            BrandModel *b_model = _dataArray[indexPath.section];
            
            ProductModel *aModel = [b_model.productsArray objectAtIndex:indexPath.row];
            
            [cell loadCustomViewWithModel:aModel];
            
            return cell;
        }
    }
    
    static NSString *identify = @"identity";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 50)];
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, DEVICE_WIDTH - 15, 50) title:@"" font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"313131"]];
        titleLabel.backgroundColor = [UIColor whiteColor];
        [view addSubview:titleLabel];
        titleLabel.tag = 100;
        
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, view.height - 0.5, DEVICE_WIDTH, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [view addSubview:line];
        [cell.contentView addSubview:view];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    UILabel *label = [cell.contentView viewWithTag:100];
    
    NSString *title = @"给商家留言:";
    NSString *note = _orderModel.order_note ? _orderModel.order_note : @"无";
    NSString *content = [NSString stringWithFormat:@"%@%@",title,note];
    [label setAttributedText:[LTools attributedString:content keyword:title color:[UIColor colorWithHexString:@"979797"]]];
    
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count + 1;//单品部分、商品清单、其他
}


@end
