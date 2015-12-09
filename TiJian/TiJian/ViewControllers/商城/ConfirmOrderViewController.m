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
#import "GconfirmOrderCell.h"
#import "AddressModel.h"
#import "GuserAddressViewController.h"
#import "ShoppingAddressController.h"
#import "MyCouponViewController.h"
#import "PayResultViewController.h"

@interface ConfirmOrderViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    UITableView *_tab;
    UIView *_addressView;
    
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_confirmOrder;
    AFHTTPRequestOperation *_request_address;
    
    CGFloat _sumPrice_pay;//实付款
    
    NSMutableArray *_addressArray;
    
    UIView *_tabFooterView;
    
    NSString *_selectAddressId;//选中的地址
    
    NSMutableArray *_theData;//本类内部使用的二维数组
    
    UIView *_theNewbilityView;//商品金额 运费 优惠券 代金券 积分 统计view
    
    UILabel *_shifukuangLabel;//实付款label
    
    UITextField *_liuyantf;//给卖家留言的label
    
    CGFloat _price_total;//商品金额
    
    CGFloat _finalPrice;//计算后的价钱
    
    UIButton *_confirmOrderBtn;//提交订单按钮
    
    AddressModel *_theAddressModel;//用户选择的收货地址
    
    AddressModel *_theDefaultAddressModel;//用户默认收货地址
    
    
    UILabel *_userChooseYouhuiquan_label;//使用几张
    UILabel *_userChooseDaijinquan_label;//使用几张
    
    int _count;//网络请求个数
    
    UILabel *_jifenMiaoshuLabel;//积分描述label
    
    UITextField *_useScoreTf;//用户输入积分的tf
    
    UIView *_shouView;//用于收键盘的点击view
    UILabel *_realScore_dijia;//用户使用积分后抵价多少
    
    NSInteger _keyongJifen;//使用完优惠券和代金券之后可用的积分
    
    BOOL _isUseScore;//是否使用积分
    NSInteger _fanal_usedScore;//最终使用的积分
    
    
    NSInteger _enabledNum_coupon;//可用优惠券数量
    NSInteger _enabledNum_vouchers;//可用代金券数量
    
    UILabel *_enabledNum_coupon_label;//可用优惠券数量label
    UILabel *_enabledNum_vouchers_label;//可用代金券数量label
    
}

@end

@implementation ConfirmOrderViewController


- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"_count"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"确认订单";
    
    _sumPrice_pay = 0;

    _keyongJifen = 0;
    _fanal_usedScore = 0;
    
    _enabledNum_coupon = 0;
    _enabledNum_vouchers = 0;
    
    
    
    [self addObserver:self forKeyPath:@"_count" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    [self makeDyadicArray];
    
    [self prepareNetData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 逻辑处理

//一维数组(里面装产品model)做成二维数组(以品牌id区分)
-(void)makeDyadicArray{
    
    
    for (ProductModel *model in self.dataArray) {
        model.afterUsedYouhuiquan_Price = [model.current_price floatValue];
        model.afterUsedDaijinquan_Price = [model.current_price floatValue];
    }
    
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    for (ProductModel *model in self.dataArray) {
        if (![dic objectForKey:model.brand_id]) {
            NSMutableArray * arr = [NSMutableArray arrayWithCapacity:1];
            [arr addObject:model];
            [dic setValue:arr forKey:model.brand_id];
        }else{
            NSMutableArray *arr = [dic objectForKey:model.brand_id];
            [arr addObject:model];
        }
    }
    
    NSArray *keys = [dic allKeys];
    
    _theData = [NSMutableArray arrayWithCapacity:1];
    
    for (NSString *key in keys) {
        NSMutableArray *arr = [dic objectForKey:key];
        [_theData addObject:arr];
    }
}


//计算金额
-(void)jisuanPrice{
    
    _confirmOrderBtn.userInteractionEnabled = NO;
    
    //商品金额
    _price_total = 0;
    for (ProductModel *model in self.dataArray) {
        CGFloat tprice_one = ([model.current_price floatValue]*[model.product_num intValue]);
        _price_total += tprice_one;
        model.afterUsedYouhuiquan_Price = [model.current_price floatValue];
        
    }
    //运费
    CGFloat yunfei = 0;
    
    //优惠券
    CGFloat youhuiquan = 0;//使用优惠券优惠的总价格
    if (self.userSelectYouhuiquanArray.count > 0) {
        _userChooseYouhuiquan_label.text = [NSString stringWithFormat:@"使用%lu张",(unsigned long)self.userSelectYouhuiquanArray.count];
        
        for (CouponModel *coupon in self.userSelectYouhuiquanArray) {
            if ([coupon.brand_id intValue]!=0) {//非通用 品牌优惠券
                if ([coupon.type intValue] == 1) {//满减
                    CGFloat total_p = 0;
                    for (ProductModel *product in self.dataArray) {
                        if (product.brand_id == coupon.brand_id) {
                            total_p +=[product.current_price floatValue]*[product.product_num intValue];
                        }
                    }
                    
                    float youhuiquan_1 = 0;
                    
                    if (total_p>[coupon.vouchers_price floatValue]) {
                        youhuiquan_1 = [coupon.minus_money floatValue];
                    }else{
                        youhuiquan_1 = total_p;
                    }
                    
                    youhuiquan +=youhuiquan_1;
                    
                    
                    for (ProductModel *prodt in self.dataArray) {
                        if (prodt.brand_id == coupon.brand_id) {
                            //按比例均摊到每件商品上的满减价格
                            CGFloat bili = [prodt.current_price floatValue] * [prodt.product_num intValue]/total_p;
                            prodt.afterUsedYouhuiquan_Price = [prodt.current_price floatValue] - youhuiquan_1*bili;
                        }
                    }
                    
                    
                    
                }else if ([coupon.type intValue] == 2){//打折
                    CGFloat p_t_price = 0;
                    for (ProductModel *product in self.dataArray) {
                        if (coupon.brand_id == product.brand_id) {
                            p_t_price += [product.current_price floatValue] *[product.product_num intValue];
                            product.afterUsedYouhuiquan_Price = [product.current_price floatValue]*[coupon.discount_num floatValue];
                        }
                    }
                    CGFloat zhe = coupon.discount_num.floatValue;
                    youhuiquan += p_t_price * (1 - zhe);
                    
                    
                    
                }else if ([coupon.type intValue] == 3){//新人优惠
                    
                }
            }else if([coupon.brand_id intValue] == 0) {//通用
                if ([coupon.type intValue] == 1) {//满减
                    
                    
                    float youhuiquan_1 = 0;
                    
                    if (_price_total>[coupon.vouchers_price floatValue]) {
                        youhuiquan_1 = [coupon.minus_money floatValue];
                    }else{
                        youhuiquan_1 = _price_total;
                    }
                    youhuiquan += youhuiquan_1;
                    
                    
                    for (ProductModel *prodt in self.dataArray) {
                        //按比例均摊到每件商品上的满减价格
                        CGFloat bili = [prodt.current_price floatValue] * [prodt.product_num intValue]/_price_total;
                        prodt.afterUsedYouhuiquan_Price = [prodt.current_price floatValue] - (youhuiquan_1*bili/[prodt.product_num intValue]);
                    }
                    
                    
                    
                }else if ([coupon.type intValue] == 2){//打折
                    
                    CGFloat p_t_price = 0;
                    for (ProductModel *product in self.dataArray) {
                        p_t_price += [product.current_price floatValue] *[product.product_num intValue];
                        product.afterUsedYouhuiquan_Price = [product.current_price floatValue]*[coupon.discount_num floatValue];
                    }
                    
                    
                    CGFloat zhe = coupon.discount_num.floatValue;
                    youhuiquan += p_t_price *(1 - zhe);
                }else if ([coupon.type intValue] == 3){//新人优惠
                    
                }
            }
            
        }
        
    }else{
        _userChooseYouhuiquan_label.text = @"未使用";
    }
    
    //代金券
    CGFloat daijinquan = 0;//使用优惠券优惠的总价格
    if (self.userSelectDaijinquanArray.count>0) {
        _userChooseDaijinquan_label.text = [NSString stringWithFormat:@"使用%lu张",(unsigned long)self.userSelectDaijinquanArray.count];
        
        CGFloat afterUseYhqPrice_total = 0;//使用完优惠券之后的总价格
        for (ProductModel *model in self.dataArray) {
            afterUseYhqPrice_total += model.afterUsedYouhuiquan_Price *[model.product_num intValue];
            model.afterUsedDaijinquan_Price  = model.afterUsedYouhuiquan_Price;
        }
        
        
        
        for (CouponModel *model in self.userSelectDaijinquanArray) {
            
            if ([model.brand_id intValue] == 0) {//通用
                if (afterUseYhqPrice_total > [model.vouchers_price floatValue]) {
                    daijinquan += [model.vouchers_price floatValue];
                }else{
                    daijinquan += afterUseYhqPrice_total;
                }
            }else{//非通用
                
                CGFloat p_t_price = 0;
                for (ProductModel *product in self.dataArray) {
                    if (model.brand_id == product.brand_id) {
                        p_t_price += product.afterUsedYouhuiquan_Price *[product.product_num intValue];
                    }
                }
                
                if (p_t_price > [model.vouchers_price floatValue]) {
                    daijinquan += [model.vouchers_price floatValue];
                }else{
                    daijinquan += p_t_price;
                }
                
                
            }
        }
        
    }else{
        _userChooseDaijinquan_label.text = @"未使用";
    }
    
    
    
    
    
    
    if (_isUseScore) {//使用积分
        //积分
        CGFloat jifen = 0;
        
        UserInfo *userInfoModel = [UserInfo userInfoForCache];
        NSInteger maxAbleUseScore = [userInfoModel.score integerValue];
        _keyongJifen = ((_price_total - youhuiquan - daijinquan)*100) > maxAbleUseScore ? maxAbleUseScore : ((_price_total - youhuiquan - daijinquan)*100);
        
        _jifenMiaoshuLabel.text = [NSString stringWithFormat:@"共%ld积分,可用%ld积分,抵%.2f元",(long)maxAbleUseScore,_keyongJifen,_keyongJifen/100.0];
        
        if ([_useScoreTf.text integerValue]> _keyongJifen) {
            jifen = _keyongJifen;
        }else{
            jifen = [_useScoreTf.text integerValue];
        }
        
        _fanal_usedScore = jifen;
    }else{
        _fanal_usedScore = 0;
    }
    
    
    
    
    //实付款
    _finalPrice = 0;
    _finalPrice = _price_total + yunfei - youhuiquan - daijinquan - _fanal_usedScore/100.0;
    
    UILabel *l0 = [_theNewbilityView viewWithTag:10];//商品金额
    UILabel *l1 = [_theNewbilityView viewWithTag:11];//运费
    UILabel *l2 = [_theNewbilityView viewWithTag:12];//优惠券
    UILabel *l3 = [_theNewbilityView viewWithTag:13];//代金券
    UILabel *l4 = [_theNewbilityView viewWithTag:14];//积分
    
    l0.text = [NSString stringWithFormat:@"￥ %.2f",_price_total];
    l1.text = [NSString stringWithFormat:@"+ %.2f",yunfei];
    l2.text = [NSString stringWithFormat:@"- %.2f",youhuiquan];
    l3.text = [NSString stringWithFormat:@"- %.2f",daijinquan];
    l4.text = [NSString stringWithFormat:@"- %.2f",_fanal_usedScore/100.0];
    _shifukuangLabel.text = [NSString stringWithFormat:@"￥%.2f",_finalPrice];
    
    
    _confirmOrderBtn.userInteractionEnabled = YES;
    
    
}

#pragma mark - 请求网络数据


//网路请求
-(void)prepareNetData{
    
    _count = 0;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self getUserDefaultAddress];
    
    
}


//获取用户收货地址
-(void)getUserDefaultAddress{
    
    
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey]
                          };
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    _request_address = [_request requestWithMethod:YJYRequstMethodGet api:ORDER_GET_DEFAULT_ADDRESS parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        _addressArray = [NSMutableArray arrayWithCapacity:1];
        
        NSArray *arr = [result arrayValueForKey:@"list"];
        for (NSDictionary *dic in arr) {
            AddressModel *model = [[AddressModel alloc]initWithDictionary:dic];
            [_addressArray addObject:model];
        }
        
        _theDefaultAddressModel = nil;
        for (AddressModel *model in _addressArray) {
            if ([model.default_address intValue] == 1) {
                _theDefaultAddressModel = model;
            }
        }
        
        [self creatDownView];
        [self creatTab];
        [self creatAddressViewWithModel:_theDefaultAddressModel];
        
        [self getDaijinquanNum];
        [self getYouhuiquanNum];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
}



//获取可用优惠券个数
-(void)getYouhuiquanNum{
    
    
    NSLog(@"%s",__FUNCTION__);
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
    CGFloat totolPrice = 0;
    for (ProductModel *model in self.dataArray) {
        NSString *price = [NSString stringWithFormat:@"%.2f",[model.current_price floatValue]*[model.product_num intValue]];
        NSString *str = [NSString stringWithFormat:@"%@:%@",model.brand_id,price];
        [arr addObject:str];
        
        totolPrice += ([model.current_price floatValue]*[model.product_num intValue]);
        
    }
    [arr addObject:[NSString stringWithFormat:@"0:%.2f",totolPrice]];
    
    NSString *coupon = [arr componentsJoinedByString:@"|"];
    
    NSString *url = ORDER_GETYOUHUIQUANLIST;
    NSDictionary *parame = @{
                      @"authcode":[UserInfo getAuthkey],
                      @"coupon":coupon
                      };
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    [_request requestWithMethod:YJYRequstMethodGet api:url parameters:parame constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSDictionary *listDic = [result dictionaryValueForKey:@"list"];
        
        //可用
        NSDictionary *enableDic = [listDic dictionaryValueForKey:@"enable"];
        
        //可用里的通用
        NSArray *enableDic_common_Array = [enableDic arrayValueForKey:@"common"];
        //可用里的非通用
        NSArray *enableDic_uncommon_Array = [enableDic arrayValueForKey:@"uncommon"];
        
        _enabledNum_coupon = enableDic_common_Array.count +enableDic_uncommon_Array.count;
        
        
        if (_enabledNum_coupon_label) {
            _enabledNum_coupon_label.text = [NSString stringWithFormat:@"%d张可用",_enabledNum_coupon];
        }
  
        
        
    } failBlock:^(NSDictionary *result) {
        
        
    }];
    
    
    
    
    
    
    
    
}

//获取可用代金券个数
-(void)getDaijinquanNum{
    
    NSLog(@"%s",__FUNCTION__);
    
    NSArray *brand_ids_Array = [NSMutableArray arrayWithCapacity:1];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    for (ProductModel *model in self.dataArray) {
        [dic setValue:@"1" forKey:model.brand_id];
    }
    
    brand_ids_Array = [dic allKeys];
    NSString *brand_ids_str = [brand_ids_Array componentsJoinedByString:@","];
    
    
    
    NSString* url = ORDER_GETDAIJIQUANLIST;
    NSDictionary* parame = @{
            @"authcode":[UserInfo getAuthkey],
            @"brand_ids":brand_ids_str
            };
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    [_request requestWithMethod:YJYRequstMethodGet api:url parameters:parame constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSDictionary *listDic = [result dictionaryValueForKey:@"list"];
        
        //可用
        NSDictionary *enableDic = [listDic dictionaryValueForKey:@"enable"];
        
        
        //可用里的通用
        NSArray *enableDic_common_Array = [enableDic arrayValueForKey:@"common"];
        //可用里的非通用
        NSArray *enableDic_uncommon_Array = [enableDic arrayValueForKey:@"uncommon"];
        
        
        _enabledNum_vouchers = enableDic_common_Array.count +enableDic_uncommon_Array.count;
        
        if (_enabledNum_vouchers_label) {
            _enabledNum_vouchers_label.text = [NSString stringWithFormat:@"%d张可用",_enabledNum_vouchers];
        }
        
        
        for (NSDictionary *dic in enableDic_common_Array) {
            CouponModel *model = [[CouponModel alloc]initWithDictionary:dic];
            if (self.voucherId == model.coupon_id) {
                NSArray *aarr = @[model];
                self.userSelectDaijinquanArray = aarr;
            }
        }
        
        for (NSDictionary *dic in enableDic_uncommon_Array) {
            CouponModel *model = [[CouponModel alloc]initWithDictionary:dic];
            if (self.voucherId == model.coupon_id) {
                NSArray *aarr = @[model];
                self.userSelectDaijinquanArray = aarr;
            }
        }
        
        
        [self jisuanPrice];
        
        
        
        
        
        
        
    } failBlock:^(NSDictionary *result) {
        
        
    }];
    
    
    
}

#pragma mark - 网络请求完成
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        return;
    }
    
    NSNumber *num = [change objectForKey:@"new"];
    
    if ([num intValue] == 1) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [self creatDownView];
        [self creatTab];
        [self creatAddressViewWithModel:_theDefaultAddressModel];
        
    }
    
    
}

#pragma mark - 视图创建
-(void)creatTab{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 50) style:UITableViewStylePlain];
    _tab.delegate = self;
    _tab.dataSource = self;
    [self.view addSubview:_tab];
    _tab.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    
    [self creatTabFooterViewWithUseState:NO];
    
}


//创建 更新 tabFooterView
-(void)creatTabFooterViewWithUseState:(BOOL)state{
    
    if (!_tabFooterView) {
        _tabFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 435)];
        _tabFooterView.backgroundColor = [UIColor whiteColor];
    }else{
        for (UIView *view in _tabFooterView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    //第一条分割线
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5)];
    line1.backgroundColor = RGBCOLOR(244, 245, 246);
    [_tabFooterView addSubview:line1];
    
    //留言view
    UIView *liuyanView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line1.frame), DEVICE_WIDTH, 50)];
    liuyanView.backgroundColor = [UIColor whiteColor];
    [_tabFooterView addSubview:liuyanView];
    
    UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 80, 50)];
    tLabel.font = [UIFont systemFontOfSize:14];
    tLabel.text = @"给卖家留言:";
    tLabel.textColor = DEFAULT_TEXTCOLOR_TITLE_SUB;
    [liuyanView addSubview:tLabel];
    
    _liuyantf = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(tLabel.frame)+10, 0, DEVICE_WIDTH - 7-7-10 - tLabel.frame.size.width, 50)];
    _liuyantf.font = [UIFont systemFontOfSize:15];
    _liuyantf.delegate = self;
    _liuyantf.tag = 10000;
    _liuyantf.placeholder = @"选填";
    [liuyanView addSubview:_liuyantf];
    
    //第二条分割线
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(liuyanView.frame), DEVICE_WIDTH, 2)];
    line2.backgroundColor = RGBCOLOR(244, 245, 246);
    [_tabFooterView addSubview:line2];
    
    //联系卖家
    UIButton *chatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [chatBtn setFrame:CGRectMake(0, CGRectGetMaxY(line2.frame), DEVICE_WIDTH/2, 45)];
    [chatBtn setImage:[UIImage imageNamed:@"order_chat.png"] forState:UIControlStateNormal];
    [chatBtn setTitle:@"联系卖家" forState:UIControlStateNormal];
    [chatBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    chatBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [chatBtn setTitleColor:RGBCOLOR(93, 148, 201) forState:UIControlStateNormal];
    [_tabFooterView addSubview:chatBtn];
    
    
    //竖条
    UIView *line_shu = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(chatBtn.frame), chatBtn.frame.origin.y+10, 1, 25)];
    line_shu.backgroundColor = RGBCOLOR(244, 245, 246);
    [_tabFooterView addSubview:line_shu];
    
    //拨打电话
    UIButton *phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [phoneBtn setFrame:CGRectMake(CGRectGetMaxX(line_shu.frame), chatBtn.frame.origin.y, DEVICE_WIDTH/2, 45)];
    [phoneBtn setImage:[UIImage imageNamed:@"order_phone.png"] forState:UIControlStateNormal];
    [phoneBtn setTitle:@"拨打电话" forState:UIControlStateNormal];
    [phoneBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    phoneBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [phoneBtn setTitleColor:RGBCOLOR(93, 148, 201) forState:UIControlStateNormal];
    [_tabFooterView addSubview:phoneBtn];
    
    //第3条分割线
    UIView *line3 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(phoneBtn.frame), DEVICE_WIDTH, 5)];
    line3.backgroundColor = RGBCOLOR(244, 245, 246);
    [_tabFooterView addSubview:line3];
    
    //优惠券
    UIView *youhuiquanView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line3.frame), DEVICE_WIDTH, 44)];
    youhuiquanView.backgroundColor = [UIColor whiteColor];
    [youhuiquanView addTaget:self action:@selector(youhuiquanViewClicked) tag:0];
    
    UILabel *y_tLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 50, 44)];
    y_tLabel.font = [UIFont systemFontOfSize:14];
    y_tLabel.text = @"优惠券";
    y_tLabel.textColor = DEFAULT_TEXTCOLOR_TITLE_SUB;
    [youhuiquanView addSubview:y_tLabel];
    
    _userChooseYouhuiquan_label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(y_tLabel.frame)+5, y_tLabel.frame.origin.y, DEVICE_WIDTH - 20 - 5 - 15 - 50 - 5, y_tLabel.frame.size.height)];
    _userChooseYouhuiquan_label.textAlignment = NSTextAlignmentRight;
    _userChooseYouhuiquan_label.font = [UIFont systemFontOfSize:15];
    _userChooseYouhuiquan_label.text = @"未使用";
    [youhuiquanView addSubview:_userChooseYouhuiquan_label];
    
    
    _enabledNum_coupon_label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(y_tLabel.frame)+5, 13, 55, 18)];
    _enabledNum_coupon_label.backgroundColor = RGBCOLOR(237, 108, 22);
    _enabledNum_coupon_label.font = [UIFont systemFontOfSize:11];
    _enabledNum_coupon_label.textColor = [UIColor whiteColor];
    _enabledNum_coupon_label.layer.cornerRadius = 4;
    _enabledNum_coupon_label.layer.masksToBounds = YES;
    _enabledNum_coupon_label.textAlignment = NSTextAlignmentCenter;
    _enabledNum_coupon_label.text = [NSString stringWithFormat:@"%d张可用",_enabledNum_vouchers];
    [youhuiquanView addSubview:_enabledNum_coupon_label];
    
    
    

    UIImageView *jiantou_y = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 20, 14, 8, 16)];
    [jiantou_y setImage:[UIImage imageNamed:@"personal_jiantou_r.png"]];
    [youhuiquanView addSubview:jiantou_y];
    
    [_tabFooterView addSubview:youhuiquanView];
    
    //第4条分割线
    UIView *line4 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(youhuiquanView.frame), DEVICE_WIDTH, 1)];
    line4.backgroundColor = RGBCOLOR(244, 245, 246);
    [_tabFooterView addSubview:line4];
    
    
    //代金券
    UIView *daijinquanView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line4.frame), DEVICE_WIDTH, 44)];
    daijinquanView.backgroundColor = [UIColor whiteColor];
    [daijinquanView addTaget:self action:@selector(daijinquanViewClicked) tag:0];
    [_tabFooterView addSubview:daijinquanView];
    
    UILabel *daijinquanLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 50, 44)];
    daijinquanLabel.text = @"代金券";
    daijinquanLabel.font = [UIFont systemFontOfSize:14];
    daijinquanLabel.textColor = DEFAULT_TEXTCOLOR_TITLE_SUB;
    [daijinquanView addSubview:daijinquanLabel];
    
    _userChooseDaijinquan_label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(y_tLabel.frame)+5, y_tLabel.frame.origin.y, DEVICE_WIDTH - 20 - 5 - 15 - 50 - 5, y_tLabel.frame.size.height)];
    _userChooseDaijinquan_label.textAlignment = NSTextAlignmentRight;
    _userChooseDaijinquan_label.font = [UIFont systemFontOfSize:15];
    _userChooseDaijinquan_label.text = @"未使用";
    [daijinquanView addSubview:_userChooseDaijinquan_label];
    
    _enabledNum_vouchers_label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(y_tLabel.frame)+5, 13, 55, 18)];
    _enabledNum_vouchers_label.layer.cornerRadius = 4;
    _enabledNum_vouchers_label.layer.masksToBounds = YES;
    _enabledNum_vouchers_label.backgroundColor = RGBCOLOR(237, 108, 22);
    _enabledNum_vouchers_label.font = [UIFont systemFontOfSize:11];
    _enabledNum_vouchers_label.textColor = [UIColor whiteColor];
    _enabledNum_vouchers_label.textAlignment = NSTextAlignmentCenter;
    _enabledNum_vouchers_label.text = [NSString stringWithFormat:@"%d张可用",_enabledNum_coupon];
    [daijinquanView addSubview:_enabledNum_vouchers_label];
    
    
    

    
    UIImageView *jiantou_d = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 20, 14, 8, 16)];
    [jiantou_d setImage:[UIImage imageNamed:@"personal_jiantou_r.png"]];
    [daijinquanView addSubview:jiantou_d];
    
    
    //第5条分割线
    UIView *line5 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(daijinquanView.frame), DEVICE_WIDTH, 1)];
    line5.backgroundColor = RGBCOLOR(244, 245, 246);
    [_tabFooterView addSubview:line5];
    

    
    //积分
    UIView *jifenView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line5.frame), DEVICE_WIDTH, 44)];
    jifenView.backgroundColor = [UIColor whiteColor];
    [_tabFooterView addSubview:jifenView];
    UILabel *jifenLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 30, 44)];
    jifenLabel.text = @"积分";
    jifenLabel.font = [UIFont systemFontOfSize:14];
    jifenLabel.textColor = DEFAULT_TEXTCOLOR_TITLE_SUB;
    [jifenView addSubview:jifenLabel];
    
    _jifenMiaoshuLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(jifenLabel.frame)+10, jifenLabel.frame.origin.y, DEVICE_WIDTH - 15 - 30 - 10 - 65, jifenLabel.frame.size.height)];
    _jifenMiaoshuLabel.font = [UIFont systemFontOfSize:12];
    _jifenMiaoshuLabel.textColor = DEFAULT_TEXTCOLOR_TITLE_SUB;
    [jifenView addSubview:_jifenMiaoshuLabel];
    
    UISwitch *switchView = [[UISwitch alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 60, _jifenMiaoshuLabel.frame.origin.y+5, 50, 44)];
    switchView.onTintColor = RGBCOLOR(237, 108, 22);
    [switchView setOn:state];
    [jifenView addSubview:switchView];
    
    [switchView addTarget:self action:@selector(getValue:) forControlEvents:UIControlEventValueChanged];
    
    
    //最后一条分割线
    UIView *lastLine;
    if (state) {//使用积分
        //第6条分割线
        UIView *line6 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(jifenView.frame), DEVICE_WIDTH, 1)];
        line6.backgroundColor = RGBCOLOR(244, 245, 246);
        [_tabFooterView addSubview:line6];
        
        //使用积分
        UIView *useJifenView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line6.frame), DEVICE_WIDTH, 44)];
        useJifenView.backgroundColor = [UIColor whiteColor];
        [_tabFooterView addSubview:useJifenView];
        
        UILabel *lb1 = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 40, 44)];
        lb1.textColor = DEFAULT_TEXTCOLOR_TITLE_SUB;
        lb1.font = [UIFont systemFontOfSize:14];
        lb1.text = @"使用";
        [useJifenView addSubview:lb1];
        
        
        _useScoreTf = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lb1.frame)+10, 10, 100, 24)];
        _useScoreTf.keyboardType = UIKeyboardTypeNumberPad;
        _useScoreTf.tag = 10001;
        _useScoreTf.font = [UIFont systemFontOfSize:15];
        _useScoreTf.textAlignment = NSTextAlignmentCenter;
        _useScoreTf.delegate = self;
        _useScoreTf.layer.borderWidth = 0.5;
        _useScoreTf.layer.cornerRadius = 2;
        _useScoreTf.layer.borderColor = [[UIColor grayColor]CGColor];
        [useJifenView addSubview:_useScoreTf];
        
        UILabel *lb2 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_useScoreTf.frame)+10, 0, 40, 44)];
        lb2.text = @"积分,";
        lb2.textColor = DEFAULT_TEXTCOLOR_TITLE_SUB;
        lb2.font = [UIFont systemFontOfSize:15];
        [useJifenView addSubview:lb2];
        
        _realScore_dijia= [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lb2.frame), 0, 100, 44)];
        _realScore_dijia.textColor = RGBCOLOR(240, 109, 23);
        _realScore_dijia.font = [UIFont systemFontOfSize:15];
        _realScore_dijia.text = @"抵0.00元";
        [useJifenView addSubview:_realScore_dijia];
        
        
        
        //第7条分割线
        UIView *line7 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(useJifenView.frame), DEVICE_WIDTH, 5)];
        line7.backgroundColor = RGBCOLOR(244, 245, 246);
        [_tabFooterView addSubview:line7];
        lastLine = line7;
        
    }else{//不使用积分
        lastLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(jifenView.frame), DEVICE_WIDTH, 5)];
        lastLine.backgroundColor = RGBCOLOR(244, 245, 246);
        [_tabFooterView addSubview:lastLine];
    }

    //商品金额 运费 优惠券 代金券 积分 统计view
    _theNewbilityView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lastLine.frame), DEVICE_WIDTH, 140)];
    [_tabFooterView addSubview:_theNewbilityView];
    
    NSArray *titleArray = @[@"商品金额",@"运费",@"优惠券",@"代金券",@"积分"];
    for (int i = 0; i<titleArray.count; i++) {
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10+i*25, 70, 20)];
        tLabel.font = [UIFont systemFontOfSize:14];
        tLabel.text = titleArray[i];
        tLabel.textColor = DEFAULT_TEXTCOLOR_TITLE_SUB;
        [_theNewbilityView addSubview:tLabel];
        
    }
    
    
    for (int i = 0; i<titleArray.count; i++) {
        UILabel *cLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, 10+i*25, DEVICE_WIDTH-100, 20)];
        cLabel.textAlignment = NSTextAlignmentRight;
        cLabel.textColor = RGBCOLOR(237, 108, 22);
        cLabel.font = [UIFont systemFontOfSize:14];
        cLabel.tag = 10 + i;
        [_theNewbilityView addSubview:cLabel];
    }
    
    UIView *linelast = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_theNewbilityView.frame), DEVICE_WIDTH, 5)];
    linelast.backgroundColor = RGBCOLOR(244, 245, 246);
    [_tabFooterView addSubview:linelast];
    
    [_tabFooterView setHeight:CGRectGetMaxY(linelast.frame)];
    
    _tab.tableFooterView = _tabFooterView;
    
    [self jisuanPrice];
    
}

-(void)creatAddressViewWithModel:(AddressModel*)theModel{
    
    _theAddressModel = theModel;
    
    if (!_addressView) {
        _addressView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 115)];
        _addressView.backgroundColor = RGBCOLOR(244, 245, 246);
    }else{
        for (UIView *view in _addressView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    if (!theModel) {//没有地址
        
        //上分割线
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 2.5)];
        [imv setImage:[UIImage imageNamed:@"shoppingcart_dd_top_line.png"]];
        [_addressView addSubview:imv];
        
        //内容
        UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(imv.frame), DEVICE_WIDTH, 60)];
        contentView.backgroundColor = [UIColor whiteColor];
        [_addressView addSubview:contentView];
        [contentView addTaget:self action:@selector(goToAddressVC) tag:0];
        
        UILabel *aLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, 150, 20)];
        aLabel.text = @"请填写收货地址";
        aLabel.textColor = RGBCOLOR(80, 81, 82);
        aLabel.font = [UIFont systemFontOfSize:15];
        [contentView addSubview:aLabel];
        
        UIImageView *jiantouImv = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 20, 22, 8, 16)];
        [jiantouImv setImage:[UIImage imageNamed:@"personal_jiantou_r.png"]];
        [contentView addSubview:jiantouImv];
        
        //下分割线
        UIImageView *imv1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(contentView.frame), DEVICE_WIDTH, 2.5)];
        [imv1 setImage:[UIImage imageNamed:@"shoppingcart_dd_top_line.png"]];
        [_addressView addSubview:imv1];
        
        //调整addressview高度
        [_addressView setHeight:CGRectGetMaxY(imv1.frame)+5];
        
        _tab.tableHeaderView = _addressView;
        
        
    }else{
        //上分割线
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 2.5)];
        [imv setImage:[UIImage imageNamed:@"shoppingcart_dd_top_line.png"]];
        [_addressView addSubview:imv];
        
        //内容
        UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(imv.frame), DEVICE_WIDTH, 100)];
        contentView.backgroundColor = [UIColor whiteColor];
        [_addressView addSubview:contentView];
        [contentView addTaget:self action:@selector(goToAddressVC) tag:0];
        
        //姓名
        UIImageView *nameLogoImv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 12, 17.5)];
        [nameLogoImv setImage:[UIImage imageNamed:@"shoppingcart_dd_top_name.png"]];
        [contentView addSubview:nameLogoImv];
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nameLogoImv.frame)+8, 10, 80, nameLogoImv.frame.size.height)];
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.text = theModel.receiver_username;
        [contentView addSubview:nameLabel];
        
        //电话
        UIImageView *phoneLogoImv = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame)+10, nameLabel.frame.origin.y, 12, 17.5)];
        [phoneLogoImv setImage:[UIImage imageNamed:@"shoppingcart_dd_top_phone.png"]];
        [contentView addSubview:phoneLogoImv];
        UILabel *phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(phoneLogoImv.frame)+8, 10, 110, phoneLogoImv.frame.size.height)];
        phoneLabel.font = [UIFont systemFontOfSize:14];
        phoneLabel.text = theModel.mobile;
        [contentView addSubview:phoneLabel];
        
        //详细地址
        UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(phoneLabel.frame)+10, DEVICE_WIDTH - 20, contentView.frame.size.height - nameLogoImv.frame.size.height -30)];
        addressLabel.font = [UIFont systemFontOfSize:14];
        addressLabel.textColor = [UIColor blackColor];
        addressLabel.text = theModel.address;
        [contentView addSubview:addressLabel];
        
        
        //自适应地址label高度
        [addressLabel setMatchedFrame4LabelWithOrigin:CGPointMake(10, CGRectGetMaxY(phoneLabel.frame)+10) width:DEVICE_WIDTH - 20];
        
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
}


//创建下面view
-(void)creatDownView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 64 - 50, DEVICE_WIDTH, 50)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    UILabel *tl0 = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 50, 50)];
    tl0.font = [UIFont systemFontOfSize:15];
    tl0.text = @"实付款:";
    [view addSubview:tl0];
    
    _shifukuangLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(tl0.frame)+5, 0, DEVICE_WIDTH - 70 - 5 - 80, 50)];
    _shifukuangLabel.font = [UIFont systemFontOfSize:15];
    _shifukuangLabel.textColor = RGBCOLOR(225, 102, 18);
    [view addSubview:_shifukuangLabel];

    
    
    _confirmOrderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_confirmOrderBtn setFrame:CGRectMake(DEVICE_WIDTH - 80, 0, 80, 50)];
    _confirmOrderBtn.backgroundColor = [UIColor orangeColor];
    _confirmOrderBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_confirmOrderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_confirmOrderBtn setTitle:@"提交订单" forState:UIControlStateNormal];
    [_confirmOrderBtn addTarget:self action:@selector(confirmOrderBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_confirmOrderBtn];
    
}


#pragma mark - 点击事件

//选择使用优惠券
-(void)youhuiquanViewClicked{
    NSLog(@"%s",__FUNCTION__);
    
    MyCouponViewController *cc = [[MyCouponViewController alloc]init];
    cc.userChooseYouhuiquanArray = self.userSelectYouhuiquanArray;
    cc.delegate = self;
    cc.type = GCouponType_use_youhuiquan;
    
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
    CGFloat totolPrice = 0;
    for (ProductModel *model in self.dataArray) {
        NSString *price = [NSString stringWithFormat:@"%.2f",[model.current_price floatValue]*[model.product_num intValue]];
        NSString *str = [NSString stringWithFormat:@"%@:%@",model.brand_id,price];
        [arr addObject:str];
        
        totolPrice += ([model.current_price floatValue]*[model.product_num intValue]);
        
    }
    
    [arr addObject:[NSString stringWithFormat:@"0:%.2f",totolPrice]];

    cc.coupon = [arr componentsJoinedByString:@"|"];
    
    NSLog(@"%@",cc.coupon);
    
    [self.navigationController pushViewController:cc animated:YES];
    
    
    
}

//选择使用代金券
-(void)daijinquanViewClicked{
    NSLog(@"%s",__FUNCTION__);
    
    MyCouponViewController *cc = [[MyCouponViewController alloc]init];
    cc.userChooseDaijinquanArray = self.userSelectDaijinquanArray;
    cc.delegate = self;
    cc.type = GCouponType_use_daijinquan;
    
    NSArray *brand_ids_Array = [NSMutableArray arrayWithCapacity:1];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    for (ProductModel *model in self.dataArray) {
        [dic setValue:@"1" forKey:model.brand_id];
    }
    
    brand_ids_Array = [dic allKeys];
    NSString *brand_ids_str = [brand_ids_Array componentsJoinedByString:@","];
    cc.brand_ids = brand_ids_str;
    
    [self.navigationController pushViewController:cc animated:YES];
    
}


//获取开关按钮的值
-(void)getValue:(UISwitch*)sender{
    
    _isUseScore = sender.isOn;
    
    [self creatTabFooterViewWithUseState:sender.isOn];
    
}

//提交订单
-(void)confirmOrderBtnClicked{
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSMutableArray *product_ids_arr = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *product_nums_arr = [NSMutableArray arrayWithCapacity:1];
    
    for (NSArray *arr in _theData) {
        for (ProductModel *oneModel in arr) {
            [product_ids_arr addObject:oneModel.product_id];
            [product_nums_arr addObject:oneModel.product_num];
        }
    }
    
    NSLog(@"%@",product_ids_arr);
    NSString *product_ids_str = [product_ids_arr componentsJoinedByString:@","];
    NSString *product_nums_str = [product_nums_arr componentsJoinedByString:@","];

    if (!_theAddressModel) {
        
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"请选择收货地址" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
        
        
        return;
    }
    
    
    
    
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [dic setValue:[UserInfo getAuthkey] forKey:@"authcode"];//authcode
    [dic setValue:product_ids_str forKey:@"product_ids"];//产品id
    [dic setValue:product_nums_str forKey:@"product_nums"];//产品数量
    [dic setValue:_theAddressModel.address_id forKey:@"address_id"];//地址
    [dic setValue:[NSString stringWithFormat:@"%.2f",_price_total] forKey:@"total_price"];//总价钱
    [dic setValue:[NSString stringWithFormat:@"%.2f",_finalPrice] forKey:@"real_price"];//实际价钱
    
    //订单备注
    if (_liuyantf.text.length>0) {
        [dic setValue:_liuyantf.text forKey:@"order_note"];//留言
    }
    
    
    //是否从预约跳转过来
    if (self.isVoucherPush) {
        
        BOOL isTrue = NO;//是否选择了这张代金券
        
        for (CouponModel *model in self.userSelectDaijinquanArray) {
            if ([model.coupon_id intValue] == [self.voucherId intValue]) {
                isTrue = YES;
                continue;
            }
        }
        
        if (isTrue) {
            [dic setValue:@"1" forKey:@"is_appoint"];
            [dic setValue:self.voucherId forKey:@"appoint_vouchers_id"];
            [dic setValue:[UserInfo getUserId] forKey:@"company_user_id"];
        }
        
        
    }
    
    if (self.userSelectYouhuiquanArray.count>0) {//使用优惠券
        
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        for (CouponModel *model in self.userSelectYouhuiquanArray) {
            [arr addObject:model.coupon_id];
        }
        
        NSString *coupon_id = [arr componentsJoinedByString:@","];
        
        [dic setValue:coupon_id forKey:@"coupon_id"];
    }
    
    if (self.userSelectDaijinquanArray.count>0) {//使用代金券
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        for (CouponModel *model in self.userSelectDaijinquanArray) {
            [arr addObject:model.coupon_id];
        }
        NSString *vouchers_id = [arr componentsJoinedByString:@","];
        [dic setValue:vouchers_id forKey:@"vouchers_id"];
    }
    
    
    
    if (_isUseScore) {//使用积分
        NSString *aa = [NSString stringWithFormat:@"%ld",_fanal_usedScore];
        [dic setValue:aa forKey:@"score"];//使用的积分
        [dic setValue:@"1" forKey:@"is_use_score"];//是否使用积分
    }
    
    __weak typeof(self)weakSelf = self;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _request_confirmOrder = [_request requestWithMethod:YJYRequstMethodPost api:ORDER_SUBMIT parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [weakSelf updateUserInfo];
        
        
        
        NSLog(@"%@",result);
        NSString *orderId = [result stringValueForKey:@"order_id"];
        NSString *orderNum = [result stringValueForKey:@"order_no"];
        _sumPrice_pay = _finalPrice;
        
        if (_sumPrice_pay == 0) {
            [weakSelf payResultSuccess:PAY_RESULT_TYPE_Success erroInfo:nil oderid:orderId sumPrice:_sumPrice_pay orderNum:orderNum];
        }else{
            [weakSelf pushToPayPageWithOrderId:orderId orderNum:orderNum];
        }
        
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog(@"%@",result);
    }];
    
    
}


/**
 *  更新用户积分
 *
 *  @return void
 */
-(void)updateUserInfo{
    NSString *authkey = [UserInfo getAuthkey];
    NSDictionary *params = @{@"authcode":authkey};;
    NSString *api = GET_USERINFO_WITHID;
    
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        //score
        NSDictionary *user_info = [result dictionaryValueForKey:@"user_info"];
        NSString *score = [user_info stringValueForKey:@"score"];
        [UserInfo updateUserScrore:score];
        
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        
    }];
}






/**
 *  跳转至支付页面
 */
- (void)pushToPayPageWithOrderId:(NSString *)orderId
                        orderNum:(NSString *)orderNum
{
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];
    
    
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
    if (self.lastViewController && (resultType != PAY_RESULT_TYPE_Fail)) { //成功和等待中需要pop掉,失败的时候不需要,有可能返回重新支付
        [self.lastViewController.navigationController popViewControllerAnimated:NO];
        [self.lastViewController.navigationController pushViewController:result animated:YES];
        return;
    }
    [self.navigationController pushViewController:result animated:YES];
}



//跳转编辑地址vc
-(void)goToAddressVC{
    
    if (_addressArray.count == 0) {//没有收货地址
        
    }else{//有收货地址
        
    }
    __weak typeof(self)wealSelf = self;
    ShoppingAddressController *address = [[ShoppingAddressController alloc]init];
    address.isSelectAddress = YES;
    address.selectAddressId = _selectAddressId;
    address.selectAddressBlock = ^(AddressModel *aModel){
        _selectAddressId = aModel.address_id;
        [wealSelf updateAddressInfoWithModel:aModel];//更新收货地址显示

    };
    
    [self.navigationController pushViewController:address animated:YES];
}
/**
 *  更新收货地址信息
 *
 *  @param aModel
 
 */
- (void)updateAddressInfoWithModel:(AddressModel *)aModel
{
    NSLog(@"---address %@",aModel.address);
    
    [_tab.tableHeaderView removeFromSuperview];
    _tab.tableHeaderView = nil;
    
    [self creatAddressViewWithModel:aModel];
}


/**
 *  切换购物地址时 更新邮费
 */
- (void)updateExpressFeeWithProviceId:(NSString *)privinceId
                               cityId:(NSString *)cityId
{
//    NSString *authkey = [GMAPI getAuthkey];
//    NSString *province_id = privinceId;
//    NSString *city_id = cityId;
//    NSString *total_price = NSStringFromFloat(_sumPrice_pay);
//    NSDictionary *params = @{@"authcode":authkey,
//                             @"province_id":province_id,
//                             @"city_id":city_id,
//                             @"total_price":total_price};
//    
//    __weak typeof(_table)weakTable = _table;
//    __weak typeof(self)weakSelf = self;
//    
//    NSString *url = [LTools url:ORDER_GET_EXPRESS_FEE withParams:params];
//    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
//    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
//        
//        NSLog(@"更新邮费%@ %@",result[RESULT_INFO],result);
//        float fee = [result[@"fee"]floatValue];
//        _expressFee = fee;
//        [weakSelf updateSumPrice];
//        [weakTable reloadData];
//        
//    } failBlock:^(NSDictionary *result, NSError *erro) {
//        
//        NSLog(@"更新邮费 失败 %@",result[RESULT_INFO]);
//        
//    }];
}



#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    
    if (!_shouView) {
        _shouView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenKeyBord)];
        [_shouView addGestureRecognizer:tap];
    }

    [self.view addSubview:_shouView];
//    
//    
//    CGSize ss = _tab.contentSize;
//    [_tab setContentSize:CGSizeMake(ss.width, ss.height+200)];
    
    CGPoint pp = _tab.contentOffset;
    [_tab setContentOffset:CGPointMake(0, pp.y +200) animated:YES];
    return YES;
}


-(void)hiddenKeyBord{
    
    [_shouView removeFromSuperview];
    
    CGPoint pp = _tab.contentOffset;
    [_tab setContentOffset:CGPointMake(0, pp.y - 200) animated:YES];
    
    [_liuyantf resignFirstResponder];
    [_useScoreTf resignFirstResponder];
    
    
    [self jisuanPrice];
    
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField.tag == 10001) {
        if (string.length == 0) {//删除
            NSInteger score = [[textField.text substringWithRange:NSMakeRange(0, textField.text.length-1)] integerValue];
            if (score>_keyongJifen) {
                
            }else{
                _realScore_dijia.text = [NSString stringWithFormat:@"抵%.2f元",score/100.0];
            }
            
            
        }else{//新输入
            NSString *str = [NSString stringWithFormat:@"%@%@",textField.text,string];
            NSInteger score = [str integerValue];
            
            if (score >_keyongJifen) {
                NSString *aa = [NSString stringWithFormat:@"%ld",(long)_keyongJifen];
                textField.text = aa;
                 _realScore_dijia.text = [NSString stringWithFormat:@"抵%.2f元",_keyongJifen/100.0];
                return NO;
                
            }else{
                _realScore_dijia.text = [NSString stringWithFormat:@"抵%.2f元",score/100.0];
            }
            
        }
        
    }
    
    return YES;
}



#pragma mark - UITableViewDelegate && UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = 0;
    num = _theData.count;
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    NSArray *arr = _theData[section];
    num = arr.count;
    return num;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/80];
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CGFloat height = 0.01;
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [GconfirmOrderCell heightForCell];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    
    NSArray *arr = _theData[section];
    
    ProductModel *amodel = arr[0];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH - 30 theWHscale:750.0/80])];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.text = amodel.brand_name;
    [view addSubview:titleLabel];
    
    [view setFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/80])];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    GconfirmOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GconfirmOrderCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSArray *arr = _theData[indexPath.section];
    ProductModel *model = arr[indexPath.row];
    
    [cell loadCustomViewWithModel:model];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {//取消
        
    }else if (buttonIndex == 1){
        [self goToAddressVC];
    }
}


@end
