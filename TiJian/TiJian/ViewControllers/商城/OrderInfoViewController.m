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
//#import "ConfirmOrderController.h"//确认订单
#import "ConfirmOrderViewController.h"//确认订单
#import "SelectCell.h"
#import "OrderOtherInfoCell.h"
#import "TuiKuanViewController.h"//申请退款
#import "ShopModel.h"//店铺model

#import "RCIM.h"

#import "OrderModel.h"
#import "ShopModel.h"
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
    
    NSArray *_shop_arr;
    
    
    YJYRequstManager *_request;
    
}

@end

@implementation OrderInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"订单详情";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
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
    
    __weak typeof(_table)weakTable = _table;
    __weak typeof(self)weakSelf = self;
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    [_request requestWithMethod:YJYRequstMethodGet api:ORDER_GET_ORDER_INFO parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"获取订单详情%@ %@",result[RESULT_INFO],result);
        NSDictionary *info = result[@"info"];
        OrderModel *aModel = [[OrderModel alloc]initWithDictionary:info];
        
        //判断是否使用 首单减免
        if (aModel.newer_coupons && [aModel.newer_coupons isKindOfClass:[NSDictionary class]]) {
            
            CouponModel *c_model = [[CouponModel alloc]initWithDictionary:aModel.newer_coupons];
            aModel.couponModel = c_model;
        }
        
        [weakSelf setViewsWithModel:aModel];
        
        NSArray *arr = [info arrayValueForKey:@"shop_products"];
        NSMutableArray *temp = [NSMutableArray array];
        if (arr) {
            for (NSDictionary *aDic in arr) {
                ShopModel *aModel = [[ShopModel alloc]initWithDictionary:aDic];
                aModel.note = aModel.order_note;
                
                CGFloat sum = 0.f;//计算单品总价
                NSInteger p_sum = 0;//单品的个数
                //对应的单品
                NSArray *productsArray = [aDic arrayValueForKey:@"products"];
                NSMutableArray *temp_product = [NSMutableArray arrayWithCapacity:productsArray.count];
                for (NSDictionary *p_dic in productsArray) {
                    ProductModel *p_model = [[ProductModel alloc]initWithDictionary:p_dic];
                    [temp_product addObject:p_model];
                    
                    sum += ([p_model.product_price floatValue] * [p_model.product_num intValue]);
                    
                    p_sum += [p_model.product_num integerValue];
                }
                aModel.productsArray = temp_product;
                
                //优惠劵
                NSArray *couponArray = [aDic arrayValueForKey:@"coupons"];
                NSMutableArray *temp_coupon = [NSMutableArray arrayWithCapacity:couponArray.count];
                for (NSDictionary *c_dic in couponArray) {
                    CouponModel *c_model = [[CouponModel alloc]initWithDictionary:c_dic];
                    [temp_coupon addObject:c_model];
                }
                aModel.couponsArray = temp_coupon;
                
                //单品个数
                
                aModel.productNum = [NSString stringWithFormat:@"%d",(int)p_sum];
                
                //使用的优惠劵
                if (temp_coupon.count) {
                    aModel.couponModel = [temp_coupon lastObject];
                }
                
                //总价
                aModel.total_price = [NSString stringWithFormat:@"%.2f",sum];
                
                //是否只用于显示
                aModel.onlyShow = YES;
                
                [temp addObject:aModel];
            }
        }
        _shop_arr = [NSArray arrayWithArray:temp];
        [weakTable reloadData];
    } failBlock:^(NSDictionary *result) {
        NSLog(@"获取订单详情 失败 %@",result);
    }];
    
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
    if (section > 0 && section <= _shop_arr.count) {
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
    ShopModel *shopModel = _shop_arr[indexPath.section - 1];
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
//    //先返回购物车,然后
//    
//    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:order.products.count];
//    for (NSDictionary *aDic in order.shop_products) {
//        
//        //test
//        ShopModel *shopModel = [[ShopModel alloc]initWithDictionary:aDic];
//        for (NSDictionary *p_dic in shopModel.products) {
//            ProductModel *aModel = [[ProductModel alloc]initWithDictionary:p_dic];
//            aModel.product_shop_id = shopModel.product_shop_id;
//            [temp addObject:aModel];
//        }
//    }
//    NSArray *productArr = temp;
//    ConfirmOrderController *confirm = [[ConfirmOrderController alloc]init];
//    confirm.productArray = productArr;
//    confirm.lastViewController = self;
//    [self.navigationController pushViewController:confirm animated:YES];
    
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
        
    }else if ([text isEqualToString:@"确认收货"]){
        
        NSString *msg = [NSString stringWithFormat:@"收货成功之后再确定,避免不必要损失!"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"确认收货" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = ALERT_TAG_RECIEVER_CONFIRM;
        [alert show];
        
    }else if ([text isEqualToString:@"查看物流"]){
        //
    }else if ([text isEqualToString:@"再次购买"]){
        
        //再次购买通知
        [self buyAgain:_orderModel];
        
    }else if ([text isEqualToString:@"删除订单"]){
        
        NSString *msg = [NSString stringWithFormat:@"是否确定删除订单"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = ALERT_TAG_DEL_ORDER;
        [alert show];
        
    }else if ([text isEqualToString:@"申请退款"]){
        
        OrderModel *aModel = _orderModel;
        TuiKuanViewController *tuiKuan = [[TuiKuanViewController alloc]init];
        tuiKuan.tuiKuanPrice = [aModel.total_fee floatValue];
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
    NSString *msg = [NSString stringWithFormat:@"拨打:%@",_orderModel.merchant_phone];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}


#pragma mark - 创建视图
/**
 *  底部工具条
 */
- (void)createBottomView
{
    UIView *bottom = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 64 - 50, DEVICE_WIDTH, 50)];
    bottom.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottom];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.5f)];
    line.backgroundColor = [UIColor colorWithHexString:@"e4e4e4"];
    [bottom addSubview:line];
    
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 36, 50) title:@"合计:" font:15 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"303030"]];
//    [bottom addSubview:label];
//    
//    //总价
//    _priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right + 10, 5, 150, 20) title:@"" font:12 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR];
//    [bottom addSubview:_priceLabel];
//    
//    //原价
//    UILabel *_price_original = [[UILabel alloc]initWithFrame:CGRectMake(_priceLabel.left, _priceLabel.bottom, _priceLabel.width, _priceLabel.height) title:@"原价" font:11 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"7e7e7e"]];
//    [bottom addSubview:_price_original];
//    
//    //未优惠之前总费用
//    NSString *sum_price = [NSString stringWithFormat:@"￥%.2f",[_orderModel.product_total_price floatValue] + [_orderModel.express_fee floatValue]];
//    [_price_original setAttributedText:[LTools attributedUnderlineString:sum_price]];
//    
//    //判断是否有收单减优惠劵
//    
//    //显示实际的
//    _priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[_orderModel.total_fee floatValue]];
//    
//    
    
    NSString *text1 = nil;
    NSString *text2 = nil;
    
    //订单状态 1=》待付款 2=》已付款 3=》已发货 4=》已送达（已收货） 5=》已取消 6=》已删除
    //退单状态 0=>未申请退款 1=》用户已提交申请退款 2=》同意退款（已提交微信/支付宝）3=》同意退款（退款成功） 4=》同意退款（退款失败） 5=》拒绝退款

//    待付款：取消订单、去付款
//    待发货：申请退款
//    配送中:  确认收货
//    已完成: 删除订单、再次购买
//    退换：退款中、退款成功、退款失败
    
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
        }else if (status == 2){ //已付款就是待发货
            //待发货
            text1 = @"申请退款";
            
        }else if (status == 3){
            //配送中
            text1 = @"确认收货";
        }
        else if (status == 4){
            //已完成
            text1 = @"再次购买";
            text2 = @"删除订单";
        }
    }
    
    CGFloat btn_width = 70;
    CGFloat btn_height = 30;
    CGFloat top = (bottom.height - btn_height)/2.f;
    UIButton *button1 = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 15 - btn_width, top, btn_width, btn_height) buttonType:UIButtonTypeRoundedRect normalTitle:text1 selectedTitle:nil target:self action:@selector(clickToAction:)];
    [button1 addCornerRadius:btn_height/2.f];
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button1 setBackgroundColor:DEFAULT_TEXTCOLOR];
    [button1.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [button1 setBorderWidth:0.5f borderColor:DEFAULT_TEXTCOLOR];
    [bottom addSubview:button1];
    
    if (text2.length) {
        UIButton *button2 = [[UIButton alloc]initWithframe:CGRectMake(button1.left - 15 - btn_width, top, btn_width, btn_height) buttonType:UIButtonTypeRoundedRect normalTitle:text2 selectedTitle:nil target:self action:@selector(clickToAction:)];
        [button2 addCornerRadius:btn_height/2.f];
        [button2 setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
        [button2.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [button2 setBorderWidth:0.5f borderColor:DEFAULT_TEXTCOLOR];
        [bottom addSubview:button2];
    }
}

- (void)tableViewFooter
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 61 + 30)];
    footerView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    _table.tableFooterView = footerView;
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0.5, DEVICE_WIDTH, 31)];
    bgView.backgroundColor = [UIColor whiteColor];
    [footerView addSubview:bgView];
    
    UIButton *chatBtn = [[UIButton alloc]initWithframe:CGRectMake(0, 0, DEVICE_WIDTH/2.f, 31) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil target:self action:@selector(clickToChat:)];
    [bgView addSubview:chatBtn];
    [chatBtn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    [chatBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    chatBtn.backgroundColor = [UIColor whiteColor];
    [chatBtn setImage:[UIImage imageNamed:@"order_chat"] forState:UIControlStateNormal];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(chatBtn.right, 5, 0.5, 21)];
    line.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [bgView addSubview:line];
    
    UIButton *phoneBtn = [[UIButton alloc]initWithframe:CGRectMake(line.right, 0, DEVICE_WIDTH/2.f, 31) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil target:self action:@selector(clickToPhone:)];
    [bgView addSubview:phoneBtn];
    [phoneBtn setImage:[UIImage imageNamed:@"order_phone"] forState:UIControlStateNormal];
    [phoneBtn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    [phoneBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    phoneBtn.backgroundColor = [UIColor whiteColor];

}


#pragma - mark UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_TAG_PHONE) {
        
        if (buttonIndex == 1) {
            
            NSString *phone = _orderModel.merchant_phone;
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
            
            if (!_request) {
                _request = [YJYRequstManager shareInstance];
            }
            
            [_request requestWithMethod:YJYRequstMethodGet api:ORDER_HANDLE_ORDER parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
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
            
            
            if (!_request) {
                _request = [YJYRequstManager shareInstance];
            }
            
            [_request requestWithMethod:YJYRequstMethodGet api:ORDER_HANDLE_ORDER parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
                
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
            
            
            if (!_request) {
                _request = [YJYRequstManager shareInstance];
            }
            
            [_request requestWithMethod:YJYRequstMethodGet api:ORDER_RECEIVING_CONFIRM parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
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
    headerView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    
    UIImageView *topImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, DEVICE_WIDTH, 3)];
    [headerView addSubview:topImage];
    topImage.image = [UIImage imageNamed:@"qrdd_top"];
    
    UIView *addressView = [[UIView alloc]initWithFrame:CGRectMake(0, topImage.bottom, DEVICE_WIDTH, 100)];
    addressView.backgroundColor = [UIColor colorWithHexString:@"fffaf4"];
    [headerView addSubview:addressView];
    
    //名字icon
    _nameIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 13, 12, 17.5)];
    [addressView addSubview:_nameIcon];
    _nameIcon.image = [UIImage imageNamed:@"qrdd_xingming"];
    _nameIcon.hidden = !haveAddress;
    
    //名字
    CGFloat aWidth = [LTools widthForText:name font:15];
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(_nameIcon.right + 10, 13, aWidth, _nameIcon.height) title:name font:15.f align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [addressView addSubview:_nameLabel];
    
    //电话icon
    _phoneIcon = [[UIImageView alloc]initWithFrame:CGRectMake(_nameLabel.right + 10, 13, 12, 17.5)];
    [addressView addSubview:_phoneIcon];
    _phoneIcon.image = [UIImage imageNamed:@"qrdd_dianhua"];
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
    
    UIImageView *bottomImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, addressView.bottom, DEVICE_WIDTH, 4.5)];
    [headerView addSubview:bottomImage];
    bottomImage.image = [UIImage imageNamed:@"qrdd_bottom"];
    
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
    if (indexPath.section == 0) {
        return 0;
    }
    if ([self productsSection:indexPath.section]) {
        
        if ([self productIndexPath:indexPath]) {
            
            return 85;
        }
        
        //优惠劵 备注部分
        return 276 / 2.f + 4;
    }
    
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self productsSection:section]) {
        return 50;
    }
    
    return 37.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if ([self productsSection:section]) {
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
        view.backgroundColor = [UIColor whiteColor];
        ShopModel *aModel = _shop_arr[section - 1];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
        [view addSubview:imageView];
        [imageView sd_setImageWithURL:[NSURL URLWithString:aModel.brand_logo] placeholderImage:DEFAULT_YIJIAYI];
        
        NSString *title = [NSString stringWithFormat:@"%@-%@",aModel.brand_name,aModel.mall_name];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(imageView.right + 10, 0, DEVICE_WIDTH - 10 - imageView.right - 10, view.height) title:title font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"313131"]];
        [view addSubview:titleLabel];
        
        return view;
    }else
    {
        NSString *title;
        //商品清单
        if (section == 0) {
            title = @"商品清单";
        }else
        {
            title = @"价格清单";
        }
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 35)];
        
        UIView *redPoint = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 4, 4)];
        redPoint.backgroundColor = DEFAULT_TEXTCOLOR;
        [redPoint addRoundCorner];
        [view addSubview:redPoint];
        redPoint.centerY = view.height/2.f;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(redPoint.right + 8, 0, 100, view.height) title:title font:12 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"9d9d9d"]];
        [view addSubview:label];
        view.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
        
        return view;
        
    }
    
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self productsSection:section]) {
        ShopModel *aModel = _shop_arr[section - 1];
        return aModel.productsArray.count + 1;
    }
    
    if (section == 0) {
        return 0;
    }else
    {
        if (_orderModel.couponModel) {
            
            return 3;
        }
        
        return 2;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self productsSection:indexPath.section]) {
        
        if ([self productIndexPath:indexPath]) {
            
            static NSString *identify = @"ProductBuyCell";
            ProductBuyCell *cell = (ProductBuyCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            ShopModel *shopModel = _shop_arr[indexPath.section - 1];
            
            ProductModel *aModel = [shopModel.productsArray objectAtIndex:indexPath.row];
            
            [cell setCellWithModel:aModel];
            
            return cell;
        }
        
        static NSString *identify = @"OrderOtherInfoCell";
        OrderOtherInfoCell *cell = (OrderOtherInfoCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[OrderOtherInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        ShopModel *shopModel = _shop_arr[indexPath.section - 1];
        [cell setCellWithModel:shopModel];
        
        cell.tf.indexPath = indexPath;
        
        
        return cell;
        
    }
    
    static NSString *identify = @"ConfirmInfoCell";
    ConfirmInfoCell *cell = (ConfirmInfoCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    if (indexPath.row == 1) {
        
        cell.nameLabel.text = @"运费";
        
        NSString *text = @"免运费";
        if ([_orderModel.express_fee floatValue] > 0) {
            text = [NSString stringWithFormat:@"%.2f",[_orderModel.express_fee floatValue]];
        }
        cell.priceLabel.text = text;
        
    }else if (indexPath.row == 2){
        
        cell.nameLabel.text = @"优惠";
        
        //显示实际的
        NSString *other = @"";
        CouponModel *c_mdoel = (CouponModel *)_orderModel.couponModel;
        if (c_mdoel) {
            
            other = [NSString stringWithFormat:@"首单立减%@元",c_mdoel.newer_money];
        }
        cell.priceLabel.text = other;
        
    }else if (indexPath.row == 0){
        cell.nameLabel.text = @"实付款";
        //显示实际的
        cell.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[_orderModel.total_fee floatValue]];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _shop_arr.count + 1 + 1;//单品部分、商品清单、其他
}


@end
