//
//  GoHealthProductDetailController.m
//  TiJian
//
//  Created by lichaowei on 16/6/8.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GoHealthProductDetailController.h"
#import "GoHealthBugController.h"
#import "ThirdProductModel.h"
#import "LPhotoBrowser.h"
#import "ThirdServiceModel.h"
#import "SDZoomHeaderView.h"

#define kTag_ServicePhone 200 //拨打客服电话
#define kTag_cancelService 201 //取消服务

@interface GoHealthProductDetailController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    UITableView *_table;
    NSArray *_discriptionImages;//详情描述为图片
    UIImageView *_coverImageView;//封面图片
    UIView *_selectCityView;//选择服务城市
    UILabel *_cityLabel;//选择城市label
    CGFloat _smallHeight;//可选城市一行高度
    CGFloat _maxHeight;//可选城市全显示高度
    UIButton *_arrowbtn;
    ThirdProductModel *_productModel;
    ThirdServiceModel *_serviceModel;
    UIButton *_salesButton;//显示已售数量
    UIView *_cityTopView;//可用
    
}

@property(nonatomic,retain)UIButton *backButton;
@property (nonatomic, strong) SDZoomHeaderView *headerZoomView;

@end

@implementation GoHealthProductDetailController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareRefreshTableView];
    
    //服务详情
    if (self.detailType == DetailType_serviceDetail) {
        
        [self netWorkForServiceDetail];
        
    }
    else //产品详情
    {
        [self netWorkForDetail:self.productId];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建

-(UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [[UIButton alloc]initWithframe:CGRectMake(9, 20 + 6, 32, 32) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"back_storehome"] selectedImage:nil target:self action:@selector(leftButtonTap:)];
    }
    return _backButton;
}

- (void)prepareRefreshTableView
{
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _table.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];
    [self.view addSubview:self.backButton];
}

- (void)prepareTableHeaderWithModel:(ThirdProductModel *)model
{
    NSString *name = model.name;
    NSNumber *dicountPrice = model.discountPrice;
    NSString *price = [NSString stringWithFormat:@"¥%.2f",[dicountPrice floatValue]];
    
    NSDictionary *pic = [model.pictures firstObject];
    CGFloat imageWidth = [pic[@"width"]floatValue];
    CGFloat imageHeight = [pic[@"height"]floatValue];
    
    
    CGFloat showHeight = DEVICE_WIDTH / 1.6f;//实际显示大小
    
    if (imageHeight) {
        imageHeight = DEVICE_WIDTH * imageHeight / imageWidth;//宽度为屏幕宽度,自适应高度
    }
    
//    CGFloat dis = imageHeight - showHeight;//图片大小与实际显示大小高的差
    
    NSString *imageUrl = [model.pictures firstObject][@"url"];
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0)];
    
    //图 背景view
    UIView *imageBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, showHeight)];
    imageBgView.clipsToBounds = YES;
    [headerView addSubview:imageBgView];
    imageBgView.backgroundColor = [UIColor redColor];
    
//    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -dis / 2.f, DEVICE_WIDTH, imageHeight)];
//    imageView.backgroundColor = [UIColor redColor];
//    [imageBgView addSubview:imageView];
//    
//    [imageView l_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:DEFAULT_HEADIMAGE];
////    [imageView l_setImageWithURL:[NSURL URLWithString:imageUrl] clipSize:CGSizeMake(imageWidth, imageHeight) placeholderImage:DEFAULT_HEADIMAGE];
//    _coverImageView = imageView;
//    [imageView addTapGestureTaget:self action:@selector(tapToBrowser:) imageViewTag:0];
    
    //用于拉伸显示图片
    self.headerZoomView = [[SDZoomHeaderView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, imageHeight)];
    [_headerZoomView.imageView l_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:DEFAULT_HEADIMAGE];
    [imageBgView addSubview:_headerZoomView];
    
    _coverImageView = _headerZoomView.imageView;
    [_headerZoomView.imageView addTapGestureTaget:self action:@selector(tapToBrowser:) imageViewTag:0];
    
    //底部
    CGFloat height = [LTools fitWithIPhone6:50];
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, imageBgView.height - height, DEVICE_WIDTH, height)];
    [imageBgView addSubview:footView];
    footView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.5];
    
    
    //下拉放大图片,同步更新headerZoomView 父视图以及父视图上子视图
     @WeakObj(imageBgView);//图片的背景view
     @WeakObj(footView);//图片上文字、按钮等
     @WeakObj(self);
    [_headerZoomView setUpdateBlock:^(CGRect frame){
        
        WeakimageBgView.height = showHeight - frame.origin.y;
        WeakimageBgView.top = frame.origin.y;
        
        WeakfootView.top = imageBgView.height - height;
        Weakself.headerZoomView.top = -1 * frame.origin.y;//zoomView
    }];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, DEVICE_WIDTH - 90, footView.height) font:17 align:NSTextAlignmentLeft textColor:[UIColor whiteColor] title:name];
    [footView addSubview:titleLabel];
    
    //联系客服
    CGFloat chatWidth = [LTools fitWithIPhone6:67.f];
    UIButton *chatBtn = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 12 - chatWidth, 0, chatWidth, footView.height) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil target:self action:@selector(clickToPhone:)];
    [footView addSubview:chatBtn];
    [chatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [chatBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    chatBtn.backgroundColor = [UIColor clearColor];
    [chatBtn setImage:[UIImage imageNamed:@"goHealth_tel"] forState:UIControlStateNormal];
    [chatBtn setTitle:@"联系客服" forState:UIControlStateNormal];
    
    //服务详情
    if (self.detailType == DetailType_serviceDetail) {
        
        //服务信息
        footView = [[UIView alloc]initWithFrame:CGRectMake(0, imageBgView.bottom, DEVICE_WIDTH, 0)];
        footView.backgroundColor = [UIColor whiteColor];
        [headerView addSubview:footView];
        
        NSString *string = [NSString stringWithFormat:@"单号: %@",self.orderNum];
        CGFloat width = [LTools widthForText:string font:14.f];
        
        //单号
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, width, 58) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:string];
        [footView addSubview:label];
        
        //状态
        label = [[UILabel alloc]initWithFrame:CGRectMake(label.right + 5, label.top, DEVICE_WIDTH - 12 * 2 - 5 - width, 58) font:14 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE title:@""];
        [footView addSubview:label];
        
        int stateNum = [_serviceModel.state intValue];// 服务状态id
        NSString *state = [self serviceState:stateNum];
        string = [NSString stringWithFormat:@"状态: %@",state];
        [label setAttributedText:[LTools attributedString:string keyword:state color:DEFAULT_TEXTCOLOR_ORANGE]];
        
        //已出报告
        if (stateNum == 11) {
            [label addTaget:self action:@selector(clickToViewReportHtml) tag:0];
        }
        
        //线
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, label.bottom, DEVICE_WIDTH, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [footView addSubview:line];
        
        NSArray *titles = @[@"体 检 人 信 息:",@"预约上门时间:",@"上门服务地址:",@"护  士  信   息:"];
        for (int i = 0; i < titles.count; i ++)
        {
            BOOL have = YES;//判断是否有该项信息
            CGFloat top = label.bottom;
            NSString *key = @"";
            if (i == 0)
            {
                NSDictionary *dic = [_serviceModel.testees firstObject];
                key = [NSString stringWithFormat:@"%@  %@",dic[@"name"],dic[@"phone"]];
                top = line.bottom + 10.f;
                
            }else if (i == 1)
            {
                //zzz
                NSDate *date = [LTools dateFromString:_serviceModel.bookTime withFormat:@"yyyy-MM-dd HH:mm:ssZ"];
                key = [LTools timeDate:date withFormat:@"yyyy-MM-dd HH:mm"];
            }else if (i == 2)
            {
                NSDictionary *dic = _serviceModel.address;
                NSString *cityName = dic[@"cityName"];
                NSString *districtName = dic[@"districtName"];
                NSString *address = dic[@"address"];
                key = [NSString stringWithFormat:@"%@%@%@",cityName,districtName,address];
            }else if (i == 3)
            {
                have = NO;
                NSDictionary *dic = _serviceModel.nurse;
                if (dic && [LTools isDictinary:dic]) {
                    NSString *name = dic[@"name"];
                    NSString *phone = dic[@"phone"];
                    if (![LTools isEmpty:name] &&
                        ![LTools isEmpty:phone]) {
                        have = YES;
                        key = [NSString stringWithFormat:@"%@  %@",name,phone];
                    }else
                    {
                        have = NO;
                    }
                    
                }else
                {
                    have = NO;
                }
                
            }
            string = titles[i];
            
            if (have) {
                
                CGFloat titleWidth = [LTools widthForText:string font:14];
                
                CGFloat height = [LTools heightForText:string width:titleWidth font:14];
                
                label = [[UILabel alloc]initWithFrame:CGRectMake(12, top + 5, titleWidth, height) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:string];
//                label.backgroundColor = [UIColor redColor];
                [footView addSubview:label];
                
                
                CGFloat contentWidth = DEVICE_WIDTH - 12 - label.right - 5;
                height = [LTools heightForText:key width:contentWidth font:14];
                
                label = [[UILabel alloc]initWithFrame:CGRectMake(label.right + 5, label.top, contentWidth, height) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:key];
                label.numberOfLines = 0;
                label.lineBreakMode = NSLineBreakByClipping;
//                label.backgroundColor = [UIColor orangeColor];
                [footView addSubview:label];
            }
        }
        
        //state 1、2时可以取消服务 case 1: @"护士未接单";2: @"护士已接单";
        int stateCode = [_serviceModel.state intValue];
        if (stateCode == 1 ||
            stateCode == 2) {
            UIButton *cancelBtn = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 12 - 72, label.bottom + 5, 72, 30) buttonType:UIButtonTypeCustom normalTitle:@"取消服务" selectedTitle:nil target:self action:@selector(clickToCancelService)];
            [footView addSubview:cancelBtn];
            cancelBtn.backgroundColor = DEFAULT_TEXTCOLOR_ORANGE;
            [cancelBtn addCornerRadius:3.f];
            [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
            
            footView.height = cancelBtn.bottom + 12;
        }else
        {
            footView.height = label.bottom + 12;
        }
        
    }else
    {
        //价格和立即购买
        footView = [[UIView alloc]initWithFrame:CGRectMake(0, imageBgView.bottom, DEVICE_WIDTH, height)];
        [headerView addSubview:footView];
        footView.backgroundColor = [UIColor whiteColor];
        //标题
        UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 15, DEVICE_WIDTH - 90, footView.height) font:17 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_ORANGE title:price];
        [footView addSubview:priceLabel];
        
        NSString *key = @"(已包括护士服务费)";
        price = [NSString stringWithFormat:@"%@ %@",price,key];
        NSAttributedString *string = [LTools attributedString:price keyword:key color:DEFAULT_TEXTCOLOR_TITLE_SUB keywordFontSize:12];
        [priceLabel setAttributedText:string];
        
        //联系客服
        chatWidth = [LTools fitWithIPhone6:67.f];
        chatBtn = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 12 - chatWidth, footView.height - 30, chatWidth, 30) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil target:self action:@selector(clickToBuy:)];
        [footView addSubview:chatBtn];
        [chatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [chatBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        chatBtn.backgroundColor = DEFAULT_TEXTCOLOR_ORANGE;
        [chatBtn addCornerRadius:2.f];
        [chatBtn setTitle:@"立即购买" forState:UIControlStateNormal];
        
        //可测人数 空腹 已售
        footView = [[UIView alloc]initWithFrame:CGRectMake(0, footView.bottom, DEVICE_WIDTH, 65)];
        [headerView addSubview:footView];
        footView.backgroundColor = [UIColor whiteColor];
        
        chatWidth = (DEVICE_WIDTH - 12 * 2) / 3.f;
        
        NSArray *images = @[[UIImage imageNamed:@"goHealth_icon1"],
                            [UIImage imageNamed:@"goHealth_icon2"],
                            [UIImage imageNamed:@"goHealth_icon3"]];
        for (int i = 0; i < 3; i ++) {
            
            UIButton *chatBtn = [[UIButton alloc]initWithframe:CGRectMake(12 + chatWidth * i, 0, chatWidth, footView.height) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil target:self action:nil];
            [footView addSubview:chatBtn];
            [chatBtn setTitleColor:DEFAULT_TEXTCOLOR_TITLE forState:UIControlStateNormal];
            [chatBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
            chatBtn.backgroundColor = [UIColor clearColor];
            [chatBtn setImage:images[i] forState:UIControlStateNormal];
            
            NSString *title = @"";
            if (i == 0) {
                title = [NSString stringWithFormat:@" 可测%d",[model.testeeNum intValue]];
                [chatBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            }else if (i == 1)
            {
                //isFasting	YES	Int		0 - 不需要空腹, 1 - 需要空腹
                BOOL isFasting = [model.isFasting intValue];
                if (isFasting == 1) {
                    title = @" 需要空腹";
                }else
                {
                    title = @" 不需要空腹";
                }
            }else if (i == 2)
            {
                title = [NSString stringWithFormat:@" 已售%d",0];
                [chatBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
                _salesButton = chatBtn;
            }
            [chatBtn setTitle:title forState:UIControlStateNormal];
        }
    }
    
//    //服务城市=============================
//    footView = [[UIView alloc]initWithFrame:CGRectMake(0, footView.bottom, DEVICE_WIDTH, 40)];
//    [headerView addSubview:footView];
//    footView.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];
//    //可服务城市
//    UILabel *cityTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, DEVICE_WIDTH - 12 * 2, footView.height) font:15 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_ORANGE title:@"可服务城市"];
//    [footView addSubview:cityTitleLabel];
//    
//    footView = [[UIView alloc]initWithFrame:CGRectMake(0, footView.bottom, DEVICE_WIDTH, 0)];
//    [headerView addSubview:footView];
//    footView.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];
//    
//    _selectCityView = footView;
//    
//    width = DEVICE_WIDTH - 12 * 2 - 11;
//    NSString *cityString = @"";
//    _smallHeight =  [LTools heightForText:@"北京、上海" width:width font:14];
//    _maxHeight = [LTools heightForText:cityString width:width font:14];
//    if (_maxHeight < _smallHeight) {
//        _maxHeight = _smallHeight;
//    }
//    
//    UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, width, _smallHeight) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:cityString];
//    [footView addSubview:cityLabel];
//    cityLabel.numberOfLines = 0;
//    cityLabel.lineBreakMode = NSLineBreakByTruncatingTail;
//    _cityLabel = cityLabel;
//    
//    footView.height = cityLabel.height;
//    //箭头
//    if (_maxHeight > _smallHeight) {
//        UIButton *arrow = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 12 - 11, 0, 11, _smallHeight) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"jiantou_down"] selectedImage:[UIImage imageNamed:@"jiantou_up"] target:self action:@selector(clickToMoreCity:)];
//        [footView addSubview:arrow];
//        [footView addTaget:self action:@selector(clickToMoreCity:) tag:0];
//        _arrowbtn = arrow;
//    }
    
    headerView.height = footView.bottom;
    _table.tableHeaderView = headerView;
    [_table reloadData];
}

#pragma mark - 网络请求

- (void)netWorkForDetail:(NSString *)productId
{
    NSString *nonceStr = [LTools randomNum:32];//随机字符串
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetValue:GoHealthAppId forKey:@"appId"];
    [params safeSetValue:nonceStr forKey:@"nonceStr"];
    [params safeSetValue:@"wap" forKey:@"osType"];
    
    NSString *sign = [MiddleTools goHealthSignWithParams:params];
    [params safeSetValue:sign forKey:@"sign"];
    
    NSString *api = [NSString stringWithFormat:GoHealth_productionsDetail,productId];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
     @WeakObj(self);
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet_goHealth api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        [MBProgressHUD hideHUDForView:Weakself.view animated:YES];
        [Weakself parseDataWithResult:result];
        
    } failBlock:^(NSDictionary *result) {
        
        //        NSLog(@"goHealth fail result %@",result);
        NSLog(@"%@",result[@"msg"]);
        [MBProgressHUD hideHUDForView:Weakself.view animated:YES];
    }];
}

/**
 *  服务详情
 */
- (void)netWorkForServiceDetail
{
    NSString *nonceStr = [LTools randomNum:32];//随机字符串
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetValue:GoHealthAppId forKey:@"appId"];
    [params safeSetValue:nonceStr forKey:@"nonceStr"];
    
    NSString *sign = [MiddleTools goHealthSignWithParams:params];
    [params safeSetValue:sign forKey:@"sign"];
    
    NSString *api = [NSString stringWithFormat:GoHealth_serviceDetail,self.serviceId];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    @WeakObj(self);
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet_goHealth api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        [MBProgressHUD hideHUDForView:Weakself.view animated:YES];
        [Weakself parseDataWithServiceResult:result];
        
    } failBlock:^(NSDictionary *result) {
        
        //        NSLog(@"goHealth fail result %@",result);
        NSLog(@"%@",result[@"msg"]);
        [MBProgressHUD hideHUDForView:Weakself.view animated:YES];
    }];
}

/**
 *  取消服务
 */
- (void)netWorkForCancelService
{
    NSString *nonceStr = [LTools randomNum:32];//随机字符串
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetValue:GoHealthAppId forKey:@"appId"];
    [params safeSetValue:nonceStr forKey:@"nonceStr"];
    [params safeSetValue:@"海马医生iOS" forKey:@"operator"];
    
    NSString *sign = [MiddleTools goHealthSignWithParams:params];
    [params safeSetValue:sign forKey:@"sign"];
    
    NSString *api = [NSString stringWithFormat:GoHealth_serviceCancel,self.serviceId];
    
    id jsonString = [LTools JSONStringWithObject:params];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    @WeakObj(self);
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost_goHealth api:api parameters:jsonString constructingBodyBlock:nil completion:^(NSDictionary *result) {
        [MBProgressHUD hideHUDForView:Weakself.view animated:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_APPOINT_CANCEL_SUCCESS object:nil];
        
        [LTools showMBProgressWithText:@"成功取消本次服务！" addToView:Weakself.view];
        
        [Weakself performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];
        
    } failBlock:^(NSDictionary *result) {
        
        DDLOG(@"%@",result[@"msg"]);
        [MBProgressHUD hideHUDForView:Weakself.view animated:YES];
    }];
}

/**
 *  获取可用城市
 */
-(void)networkForAvailableCityWithProductId:(NSString *)productId
{
    if ([LTools isEmpty:productId]) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *nonceStr = [LTools randomNum:32];//随机字符串
    [params safeSetValue:nonceStr forKey:@"nonceStr"];
    [params safeSetValue:GoHealthAppId forKey:@"appId"];
    [params safeSetString:self.productId forKey:@"productionIds"];
    
    NSString *sign = [MiddleTools goHealthSignWithParams:params];
    [params safeSetValue:sign forKey:@"sign"];
    
     @WeakObj(self);
    [[YJYRequstManager shareInstance] requestWithMethod:YJYRequstMethodGet_goHealth api:GoHealth_citylist parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [Weakself setCityDataWithDic:result];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
}

/**
 *  获取产品销量
 */
- (void)netWorkForProductSalesWithProductId:(NSString *)productId
{
    if ([LTools isEmpty:productId]) {
        return;
    }
    NSString *api = GoHealth_product_sale;
    NSDictionary *params = @{@"product_id":productId};
    __weak typeof(self)weakSelf = self;
    //    __weak typeof(RefreshTableView *)weakTable = _table;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [weakSelf showSaleWithResult:result];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        
    }];
}

/**
 *  显示销售数量
 *
 *  @param result
 */
- (void)showSaleWithResult:(NSDictionary *)result
{
    NSNumber *sale_num = result[@"sale_num"];
    NSString *title = [NSString stringWithFormat:@" 已售%d",[sale_num intValue]];
    [_salesButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - 数据解析处理

-(void)setCityDataWithDic:(NSDictionary *)result{
    NSDictionary *dataDic = [result dictionaryValueForKey:@"data"];
    NSArray *provinceArray = [dataDic arrayValueForKey:@"geos"];
    
    //城市
    NSMutableArray *cityNameArray = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dic in provinceArray) {
        NSArray *geos = [dic arrayValueForKey:@"geos"];
        for (NSDictionary *cityDic in geos) {
            NSString *name = cityDic[@"name"];
            [cityNameArray addObject:name];
        }
    }
    
    NSString *cityString = [cityNameArray componentsJoinedByString:@"、"];
    [self showAvailableCityString:cityString];
}

/**
 *  显示可用服务城市
 *
 *  @param cityString
 */
- (void)showAvailableCityString:(NSString *)cityString
{
    if ([LTools isEmpty:cityString]) {
        return;
    }
    UIView *headerView = _table.tableHeaderView;
    //服务城市=============================
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, headerView.height, DEVICE_WIDTH, 40)];
    [headerView addSubview:footView];
    footView.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];
    //可服务城市
    UILabel *cityTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, DEVICE_WIDTH - 12 * 2, footView.height) font:15 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_ORANGE title:@"可服务城市"];
    [footView addSubview:cityTitleLabel];

    footView = [[UIView alloc]initWithFrame:CGRectMake(0, footView.bottom, DEVICE_WIDTH, 0)];
    [headerView addSubview:footView];
    footView.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];

    _selectCityView = footView;

    CGFloat width = DEVICE_WIDTH - 12 * 2 - 11;
    _smallHeight =  [LTools heightForText:@"北京、上海" width:width font:14];
    _maxHeight = [LTools heightForText:cityString width:width font:14];
    if (_maxHeight < _smallHeight) {
        _maxHeight = _smallHeight;
    }

    UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, width, _smallHeight) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:cityString];
    [footView addSubview:cityLabel];
    cityLabel.numberOfLines = 0;
    cityLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _cityLabel = cityLabel;

    footView.height = cityLabel.height;
    //箭头
    if (_maxHeight > _smallHeight) {
        UIButton *arrow = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 12 - 11, 0, 11, _smallHeight) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"jiantou_down"] selectedImage:[UIImage imageNamed:@"jiantou_up"] target:self action:@selector(clickToMoreCity:)];
        [footView addSubview:arrow];
        [footView addTaget:self action:@selector(clickToMoreCity:) tag:0];
        _arrowbtn = arrow;
    }
    
    headerView.height = footView.bottom + 20.f;
    _table.tableHeaderView = headerView;
}

/**
 *  服务详情
 *
 *  @param result
 */
- (void)parseDataWithServiceResult:(NSDictionary *)result
{
    NSDictionary *data = result[@"data"];
    NSDictionary *service = data[@"service"];
    _serviceModel = [[ThirdServiceModel alloc]initWithDictionary:service];
    
    NSString *productId = [_serviceModel.productionIds firstObject];
    [self netWorkForDetail:productId];
    
    //请求完服务详情回调
    if (self.updateParamsBlock) {
        self.updateParamsBlock(@{RESULT_INFO:@"ok"});
    }
}

/**
 *  套餐详情
 *
 *  @param result
 */
- (void)parseDataWithResult:(NSDictionary *)result
{
    NSDictionary *data = result[@"data"];
    NSDictionary *production = data[@"production"];
    
    ThirdProductModel *model = [[ThirdProductModel alloc]initWithDictionary:production];
    _productModel = model;
    
    //销量
    [self netWorkForProductSalesWithProductId:model.id];
    [self networkForAvailableCityWithProductId:model.id];
    
    NSString *desc = [production objectForKey:@"description"];
    
    if (![LTools isEmpty:desc]) {
        //找出<img>
        NSString *reg_img = @"<img[^>]*\\>";
        NSArray *srcArray = [self reExpressionString:desc matchInString:reg_img];
        
        //存储 图片src以及宽高
        NSMutableArray *arr = [NSMutableArray array];
        for (NSString *string in srcArray) {
            NSString *reg_src = @"(?<=src=\").+?(?=\")";
            NSString *reg_width = @"(?<=data-w=\").+?(?=\")";
            NSString *reg_heigth = @"(?<=data-h=\").+?(?=\")";
            
            NSArray *srcArray = [self reExpressionString:string matchInString:reg_src];
            NSArray *srcWidth = [self reExpressionString:string matchInString:reg_width];
            NSArray *srcHeigth = [self reExpressionString:string matchInString:reg_heigth];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            NSString *src = [srcArray lastObject];
            if (src) {
                [dic safeSetValue:[srcArray lastObject] forKey:@"src"];
                NSString *width = [srcWidth lastObject];
                if (!width) {
                    width = @"0";
                }
                [dic safeSetValue:width forKey:@"data-w"];
                
                NSString *heigth = [srcHeigth lastObject];
                if (!heigth) {
                    heigth = @"0";
                }
                [dic safeSetValue:heigth forKey:@"data-h"];
                [arr addObject:dic];
            }
        }
        _discriptionImages = [NSArray arrayWithArray:arr];
 
    }
    
    [self prepareTableHeaderWithModel:model];
}

- (NSArray *)reExpressionString:(NSString *)string
                   matchInString:(NSString *)reg_src
{
    NSError *erro;
    NSRegularExpression *rExpretion_src =[NSRegularExpression regularExpressionWithPattern:reg_src
                                                                                   options:0
                                                                                     error:&erro];
//    NSLog(@"erro%@",erro);
    NSArray *temp = [rExpretion_src matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    NSMutableArray *tempArr = [NSMutableArray array];
    for (NSTextCheckingResult *result in temp) {
        if (result) {
            NSRange firstHalfRange = [result rangeAtIndex:0];
            if (firstHalfRange.length > 0) {
                NSString *resultString1 = [string substringWithRange:firstHalfRange];
//                DDLOG(@"result ok = %@",resultString1);
                [tempArr addObject:resultString1];
            }
        }
    }
    
    return tempArr;

}

#pragma mark - 事件处理

- (NSString *)serviceState:(int)state
{
    switch (state) {
        case 1:
            return @"护士未接单";
            break;
        case 2:
            return @"护士已接单";
            break;
        case 3:
            return @"护士已出发";
            break;
        case 4:
            return @"护士已到达";
            break;
        case 5:
            return @"护士开始服务";
            break;
        case 6:
            return @"护士完成服务";
            break;
        case 7:
            return @"标本运送中";
            break;
        case 8:
            return @"标本已送达";
            break;
        case 9:
            return @"标本检测中";
            break;
        case 10:
            return @"检测完成";
            break;
        case 11:
            return @"已出报告(点击查看)";
            break;
        case 12:
            return @"用户取消服务";
            break;
        case 13:
            return @"用户取消服务";
            break;
        case 14:
            return @"护士取消";
            break;
        case 15:
            return @"管理员取消";
            break;
        case 16:
            return @"标本丢失(护士)";
            break;
        case 17:
            return @"标本丢失(物流)	";
            break;
        default:
            break;
    }
    return @"";
}

- (void)clickToCancelService
{
    NSString *msg = @"是否确定取消本次服务？";
    if ([_serviceModel.state intValue] == 2) {
        msg = [NSString stringWithFormat:@"护士已接单,%@",msg];
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = kTag_cancelService;
    [alert show];
}

//购买
- (void)clickToBuy:(UIButton *)sender
{
    GoHealthBugController *buy = [[GoHealthBugController alloc]init];
    buy.productModel = _productModel;
    [self.navigationController pushViewController:buy animated:YES];
}

//控制city显示更多或者折叠
- (void)clickToMoreCity:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _arrowbtn.selected = sender.selected;
    
    UIView *headerView = _table.tableHeaderView;
    
    sender.height = _cityLabel.height =_selectCityView.height = sender.selected ? _maxHeight : _smallHeight;
        
    CGFloat selectHeight = _selectCityView.bottom;
    headerView.height = floorf(selectHeight) + 20.f;
    _table.tableHeaderView = headerView;
   
}
/**
 *  拨打电话
 *
 *  @param sender
 */
- (void)clickToPhone:(UIButton *)sender
{
    NSString *msg = [NSString stringWithFormat:@"是否拨打:%@客服电话",HaiMa_service];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = kTag_ServicePhone;
    [alert show];
}

/**
 *  手势
 *
 *  @param sender 手势
 */
- (void)tapToBrowser:(UITapGestureRecognizer *)sender
{
    
//    NSDictionary *pic = [model.pictures firstObject];
//    CGFloat width = [pic[@"width"]floatValue];
//    CGFloat imageHeight = [pic[@"height"]floatValue];
//    if (imageHeight) {
//        imageHeight = DEVICE_WIDTH * (width/imageHeight);
//    }
//    NSString *imageUrl = [model.pictures firstObject][@"thumb"];
    
    NSArray *img = _productModel.pictures;
    
    int count = (int)[img count];
    
    NSInteger initPage = 0;
    
    [LPhotoBrowser showWithViewController:self initIndex:initPage photoModelBlock:^NSArray *{
        
        NSMutableArray *temp = [NSMutableArray array];
        
        for (int i = 0; i < count; i ++) {
                        
            NSDictionary *dic = img[i];
            
            UIImageView *imageView = _coverImageView;
            LPhotoModel *photo = [[LPhotoModel alloc]init];
            photo.imageUrl = dic[@"raw"];
            imageView = imageView;
            photo.thumbImage = imageView.image;
            photo.sourceImageView = imageView;
            
            [temp addObject:photo];
        }
        
        return temp;
    }];
}

/**
 *  查看体检报告
 *
 *  @param reportHtml
 */
- (void)clickToViewReportHtml
{
    if (self.report_html) {
        [MiddleTools pushToWebFromViewController:self weburl:self.report_html title:@"体检报告" moreInfo:NO hiddenBottom:NO];
    }
}

#pragma - mark UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kTag_ServicePhone)
    {
        if (buttonIndex == 1) {
            
            NSString *phone = HaiMa_service;
            
            if (phone) {
                
                NSString *phoneNum = phone;
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNum]]];
            }
        }
    }else if (alertView.tag == kTag_cancelService)
    {
        if (buttonIndex == 0)
        {
            //取消操作
        }else if (buttonIndex == 1)
        {
            //铁了心要取消服务
            [self netWorkForCancelService];
        }
    }
    
    
}
#pragma mark - 代理

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    self.headerZoomView.offsetY = offsetY;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offsetY = scrollView.contentOffset.y;
    
    CGFloat temp = -100.f;
    if (iPhone6PLUS) {
        temp = -140.f;
    }
    if (iPhone6) {
        temp = -120.f;
    }
    if (offsetY < temp) {
        [self tapToBrowser:nil];
    }
}

#pragma - mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = _discriptionImages[indexPath.row];
    float width = [dic[@"data-w"]floatValue];
    float height = [dic[@"data-h"]floatValue];
    if (width == 0) {
        return 0.f;
    }
    CGFloat cellHeight = DEVICE_WIDTH * height / width;
    return cellHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.f)];
    view.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];
    return view;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return [UIView new];
}

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _discriptionImages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"identify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0)];
        imageView.tag = 100;
        [cell.contentView addSubview:imageView];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
    
    NSDictionary *dic = _discriptionImages[indexPath.row];
    NSString *src = dic[@"src"];
    NSString *width = dic[@"data-w"];
    NSString *height = dic[@"data-h"];
    imageView.height = DEVICE_WIDTH * [height floatValue] / [width floatValue];
    [imageView l_setImageWithURL:[NSURL URLWithString:src] placeholderImage:DEFAULT_HEADIMAGE];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
