//
//  HospitalDetailViewController.m
//  TiJian
//
//  Created by lichaowei on 16/1/26.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "HospitalDetailViewController.h"
#import "MapViewController.h"
#import "LPhotoBrowser.h"
#import "ProductModel.h"
#import "HospitalModel.h"
#import "GProductCellTableViewCell.h"

@interface HospitalDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    HospitalModel *_hospitalModel;
    CGFloat _recommentTop;//推荐部分y坐标
    
    UITableView *_tab;
    UIView *_tabFooterView;
    UIView *_tabHeaderView;
    int _page;//当前页
    NSMutableArray *_productsArray;
    UIView *_clickToMoreView;//点击查看更多
    UIButton *_clickedToMoreBtn;
    UIActivityIndicatorView *_act;
    NSString *_centerBannerDefaultImName;
}

@end

@implementation HospitalDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"分院详情";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    _productsArray = [NSMutableArray arrayWithCapacity:1];
    
    [self creatTab];
    
    //分院详情
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    _page = 1;
    [self netWorkForDetail];
    [self networkForProducts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建



-(void)creatTab{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-64) style:UITableViewStyleGrouped];
    _tab.delegate =self;
    _tab.dataSource = self;
    [self.view addSubview:_tab];
    
    _tab.tableFooterView = [self createTabFooterView];
    _tab.tableHeaderView = [self creatTabHeader];
}

-(UIView *)creatTabHeader{
    _tabHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_WIDTH*370/750)];
    
    UIImageView *imv = [[UIImageView alloc]initWithFrame:_tabHeaderView.bounds];
    [imv sd_setImageWithURL:[NSURL URLWithString:_hospitalModel.cover_pic] placeholderImage:[UIImage imageNamed:_centerBannerDefaultImName]];
//    [imv l_setImageWithURL:[NSURL URLWithString:_hospitalModel.cover_pic] placeholderImage:[UIImage imageNamed:_centerBannerDefaultImName]];
    [_tabHeaderView addSubview:imv];
    
    UIView *centerNameView = [[UIView alloc]initWithFrame:CGRectMake(0, _tabHeaderView.frame.size.height - 30, DEVICE_WIDTH, 30)];
    centerNameView.backgroundColor = [UIColor blackColor];
    centerNameView.alpha = 0.3;
    [_tabHeaderView addSubview:centerNameView];
    
    UILabel *centerNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, _tabHeaderView.frame.size.height - 30, _tabHeaderView.frame.size.width-10, 30)];
    centerNameLabel.text = [NSString stringWithFormat:@"%@ %@",_hospitalModel.brand_name,_hospitalModel.center_name];
    centerNameLabel.textColor = [UIColor whiteColor];
    centerNameLabel.font = [UIFont systemFontOfSize:12];
    [_tabHeaderView addSubview:centerNameLabel];
    
    return _tabHeaderView;
}

- (UIView *)createTabFooterView
{
    _tabFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0)];
    _tabFooterView.backgroundColor =  RGBCOLOR(244, 244, 244);
    
    //分院名称
    UIView *nameView = [[UIView alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 30)];
    nameView.backgroundColor = [UIColor whiteColor];
    [_tabFooterView addSubview:nameView];
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 60, nameView.height) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@"分院介绍"];
    [nameView addSubview:title];
    
//    NSString *centerName = _hospitalModel.center_name;
    UILabel *content = [[UILabel alloc]initWithFrame:CGRectMake(title.right + 15, 0, DEVICE_WIDTH - 10 - title.right - 15, nameView.height) font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:nil];
    [nameView addSubview:content];
    
    //公交路线
    
    NSString *brandDesc = _hospitalModel.bus_route;

    CGFloat height = 0.f;
    
    if ([brandDesc isKindOfClass:[NSString class]] && brandDesc.length > 0) {
        
        nameView = [[UIView alloc]initWithFrame:CGRectMake(0, nameView.bottom + 5, DEVICE_WIDTH, 45)];
        nameView.backgroundColor = [UIColor whiteColor];
        [_tabFooterView addSubview:nameView];
        
        title = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 60, nameView.height) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@"公交路线"];
        [nameView addSubview:title];
        
        content = [[UILabel alloc]initWithFrame:CGRectMake(title.right + 15, 15, DEVICE_WIDTH - 10 - title.right - 15, nameView.height) font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:brandDesc];
        [nameView addSubview:content];
        content.numberOfLines = 0;
        content.lineBreakMode = NSLineBreakByCharWrapping;
        height = [LTools heightForText:brandDesc width:content.width font:13];
        content.height = height;
        nameView.height = content.bottom + 15;
    }
    
    
    //休息日
    NSString *restDayDesc = _hospitalModel.rest_day;
    height = 0.f;
    
    if ([restDayDesc isKindOfClass:[NSString class]] && restDayDesc.length > 0) {
        
        nameView = [[UIView alloc]initWithFrame:CGRectMake(0, nameView.bottom + 5, DEVICE_WIDTH, 45)];
        nameView.backgroundColor = [UIColor whiteColor];
        [_tabFooterView addSubview:nameView];
        
        title = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 60, nameView.height) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@"休息时间"];
        [nameView addSubview:title];
        
        content = [[UILabel alloc]initWithFrame:CGRectMake(title.right + 15, 15, DEVICE_WIDTH - 10 - title.right - 15, nameView.height) font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:restDayDesc];
        [nameView addSubview:content];
        content.numberOfLines = 0;
        content.lineBreakMode = NSLineBreakByCharWrapping;
        height = [LTools heightForText:restDayDesc width:content.width font:13];
        content.height = height;
        nameView.height = content.bottom + 15;
    }
    
    //分院地址
    nameView = [[UIView alloc]initWithFrame:CGRectMake(0, nameView.bottom + 5, DEVICE_WIDTH, 45)];
    nameView.backgroundColor = [UIColor whiteColor];
    [_tabFooterView addSubview:nameView];
    
    title = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 60, nameView.height) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@"分院地址"];
    [nameView addSubview:title];
    
    NSString *address = _hospitalModel.address;
    content = [[UILabel alloc]initWithFrame:CGRectMake(title.right + 15, 22.5 - 6.5 - 2, DEVICE_WIDTH - 10 - title.right - 15 - 20, nameView.height) font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:address];
    content.numberOfLines = 0.f;
    [nameView addSubview:content];
    
    CGFloat address_height = [LTools heightForText:address width:content.width font:13];
    content.height = address_height;
    
    nameView.height = content.bottom + 12;
    
    //图标
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"personal_yuyue_daohang"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(10, 0, nameView.width - 20, nameView.height);
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [nameView addSubview:btn];
    [btn addTarget:self action:@selector(clickToMap) forControlEvents:UIControlEventTouchUpInside];
    
    //line
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, nameView.bottom, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [_tabFooterView addSubview:line];
    
    
    //分院电话
    nameView = [[UIView alloc]initWithFrame:CGRectMake(0, line.bottom, DEVICE_WIDTH, 45)];
    nameView.backgroundColor = [UIColor whiteColor];
    [_tabFooterView addSubview:nameView];
    
    title = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 60, nameView.height) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@"分院电话"];
    [nameView addSubview:title];
    
    NSString *phone = _hospitalModel.center_phone;
    content = [[UILabel alloc]initWithFrame:CGRectMake(title.right + 15, 0, DEVICE_WIDTH - 10 - title.right - 15, nameView.height) font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:phone];
    [nameView addSubview:content];
    
    //图标
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"personal_yuyue_dianhua"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(10, 0, nameView.width - 20, nameView.height);
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [nameView addSubview:btn];
    [btn addTarget:self action:@selector(clickToPhone) forControlEvents:UIControlEventTouchUpInside];
    
    //line
    line = [[UIImageView alloc]initWithFrame:CGRectMake(0, nameView.bottom, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [_tabFooterView addSubview:line];
    
    //分院环境
    
    //分院环境的图片
    
    NSArray *pic = _hospitalModel.pic;
    
    CGFloat re_top = line.bottom;
    
    if (pic &&
        [pic isKindOfClass:[NSArray class]] &&
        pic.count > 0) {
        
        nameView = [[UIView alloc]initWithFrame:CGRectMake(0, line.bottom, DEVICE_WIDTH, 45)];
        nameView.backgroundColor = [UIColor whiteColor];
        [_tabFooterView addSubview:nameView];
        
        title = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 60, nameView.height) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:@"分院环境"];
        [nameView addSubview:title];
        
        CGFloat width = (DEVICE_WIDTH - 20);
        CGFloat imageBottom = title.bottom + 5;
        int count = (int)pic.count;
        for (int i = 0; i < count; i ++) {
            NSDictionary *dic = pic[i];
            if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                
                CGFloat image_width = [dic[@"width"]floatValue];
                CGFloat image_height = [dic[@"height"]floatValue];
                
                height = width * image_height / image_width;

                NSString *url = dic[@"url"];
                
                UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(10, imageBottom, width, height)];
                [imageview l_setImageWithURL:[NSURL URLWithString:url] placeholderImage:DEFAULT_HEADIMAGE];
                imageview.tag = 200 + i;
                [nameView addSubview:imageview];
                [imageview addTapGestureTaget:self action:@selector(tapToBrowser:) imageViewTag:200 + i];
                imageBottom = imageview.bottom + 5;
                
                nameView.height = imageview.bottom;
                
                re_top = nameView.bottom;

            }
        }
        
    }
    
    _recommentTop = re_top;
    
//    _scrollView.contentSize = CGSizeMake(DEVICE_WIDTH, nameView.bottom > DEVICE_HEIGHT ? nameView.bottom + 20 : DEVICE_HEIGHT);
    
    [_tabFooterView setHeight:_recommentTop];
    
    return _tabFooterView;
    
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = 1;
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    num = _productsArray.count;
    return num;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = 0.01;
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CGFloat height = 0.01;
    if (_productsArray.count>0) {
        height = 30;
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    height = [GProductCellTableViewCell getCellHight];
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    _clickToMoreView = [[UIView alloc]init];
    _clickToMoreView.backgroundColor = [UIColor whiteColor];
    
    if (_productsArray.count >0) {
        
        [_clickToMoreView setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 30)];
        
        _act = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_clickToMoreView addSubview:_act];
        _act.center = _clickToMoreView.center;
        
        _clickedToMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clickedToMoreBtn setFrame:CGRectMake(0, 0, 150, 30)];
        [_clickedToMoreBtn setTitle:@"点击查看更多" forState:UIControlStateNormal];
        [_clickedToMoreBtn setImage:[UIImage imageNamed:@"center_downPoint.png"] forState:UIControlStateNormal];
        [_clickedToMoreBtn setTitleEdgeInsets:UIEdgeInsetsMake(-5, 0, 0, 0)];
        [_clickedToMoreBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 64, -20, 0)];
        
        
        _clickedToMoreBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [_clickedToMoreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_clickedToMoreBtn addTarget:self action:@selector(clickedToMore) forControlEvents:UIControlEventTouchUpInside];
        [_clickToMoreView addSubview:_clickedToMoreBtn];
        _clickedToMoreBtn.center = _clickToMoreView.center;
        
    }else{
        [_clickToMoreView setFrame:CGRectZero];
    }
    
    
    return _clickToMoreView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    GProductCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GProductCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    ProductModel *p = _productsArray[indexPath.row];
    
    [cell loadData:p];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ProductModel *aModel = _productsArray[indexPath.row];
    [MiddleTools pushToProductDetailWithProductId:aModel.product_id viewController:self extendParams:nil];
}





///**
// *  品牌推荐view
// */
//- (void)createRecommendViewWithTop:(CGFloat)top
//{    
//    //没有推荐套餐则不显示该部分
//    if (!_recommendArray || _recommendArray.count == 0) {
//        return;
//    }
//    
//    NSInteger count = _recommendArray.count;
//    CGFloat height = 0.f;
//    
//    if (count >= 3) {
//        count = 3;
//        height = 175 + 20;
//    }
//    
//    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, top, DEVICE_WIDTH, height)];
//    backView.backgroundColor = [UIColor whiteColor];
//    [_scrollView addSubview:backView];
//    
//    UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 60, 45)];
//    tLabel.textColor = DEFAULT_TEXTCOLOR_TITLE;
//    tLabel.text = @"套餐推荐";
//    tLabel.font = [UIFont systemFontOfSize:14];
//    [backView addSubview:tLabel];
//    
//    CGFloat theW = (DEVICE_WIDTH - 20 - 10)/3;
//    CGFloat theH = [GMAPI scaleWithHeight:0 width:theW theWHscale:230.0/265];
//    
//    for (int i = 0; i < count; i++) {
//        
//        ProductModel *amodel = _recommendArray[i];
//        UIView *logoAndContentView = [[UIView alloc]initWithFrame:CGRectMake(10+i*(theW+5), tLabel.bottom, theW, theH)];
//        logoAndContentView.layer.borderWidth = 0.5;
//        logoAndContentView.layer.borderColor = [RGBCOLOR(235, 236, 238)CGColor];
//        [backView addSubview:logoAndContentView];
//        
//        logoAndContentView.tag = 100 + i;
//        [logoAndContentView addTaget:self action:@selector(clickToProductDetail:) tag:logoAndContentView.tag];
//        
//        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, logoAndContentView.frame.size.width, [GMAPI scaleWithHeight:0 width:theW theWHscale:230.0/145])];
//        [imv l_setImageWithURL:[NSURL URLWithString:amodel.cover_pic] placeholderImage:nil];
//        [logoAndContentView addSubview:imv];
//        
//        UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(imv.frame)+5, theW-10, [GMAPI scaleWithHeight:0 width:theW theWHscale:230.0/60])];
//        titleLable.text = amodel.setmeal_name;
//        titleLable.numberOfLines = 2;
//        titleLable.font = [UIFont systemFontOfSize:11];
//        [logoAndContentView addSubview:titleLable];
//        
//        
//        NSString *xianjia = [NSString stringWithFormat:@"%.1f",[amodel.setmeal_price floatValue]];
//        NSString *yuanjia = [NSString stringWithFormat:@"%.1f",[amodel.setmeal_original_price floatValue]];
//        UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(titleLable.frame)+5, imv.frame.size.width - 5, 12)];
//        NSString *price = [NSString stringWithFormat:@"￥%@ ￥%@",xianjia,yuanjia];
//        NSMutableAttributedString  *aaa = [[NSMutableAttributedString alloc]initWithString:price];
//        [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(238, 115, 0) range:NSMakeRange(0, xianjia.length+1)];
//        [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, xianjia.length+1)];
//        
//        [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(105, 106, 107) range:NSMakeRange(xianjia.length+1, yuanjia.length+2)];
//        [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:8] range:NSMakeRange(xianjia.length+1, yuanjia.length+2)];
//        [aaa addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(xianjia.length+2, yuanjia.length+1)];
//        priceLabel.attributedText = aaa;
//        [logoAndContentView addSubview:priceLabel];
//    }
//    
//    if (count>0) {
//
//    }else{
//        
//        UILabel *tt = [[UILabel alloc]initWithFrame:CGRectMake(20, 45, DEVICE_WIDTH - 40, 30)];
//        tt.text = @"暂无可推荐套餐";
//        tt.textAlignment = NSTextAlignmentCenter;
//        tt.font = [UIFont systemFontOfSize:11];
//        tt.textColor = [UIColor grayColor];
//        [backView addSubview:tt];
//    }
//    
//    _scrollView.contentSize = CGSizeMake(DEVICE_WIDTH, backView.bottom > DEVICE_HEIGHT ? backView.bottom + 20 : DEVICE_HEIGHT);
//}

#pragma mark - 网络请求

/**
 *  分院详情
 */
- (void)netWorkForDetail
{
    if (!self.centerId) {
        
        [LTools showMBProgressWithText:@"该分院不存在!" addToView:self.view];
        
        [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.3];
        
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params safeSetString:self.centerId forKey:@"exam_center_id"];
    
    NSString *api = Get_hospital_detail;
    
    __weak typeof(self)weakSelf = self;

    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [weakSelf parseDataWithResult:result];
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

- (void)parseDataWithResult:(NSDictionary *)result
{
    NSDictionary *data = result[@"data"];
    _hospitalModel = [[HospitalModel alloc]initWithDictionary:data];
    if ([_hospitalModel.brand_id intValue] == 1) {//慈铭
        _centerBannerDefaultImName = @"center_banner_ciming";
    }else if ([_hospitalModel.brand_id intValue] == 2){//美年
        _centerBannerDefaultImName = @"center_banner_meinian";
    }else if ([_hospitalModel.brand_id intValue] == 3){//爱康
        _centerBannerDefaultImName = @"center_banner_aikang";
    }
    _tab.tableFooterView = [self createTabFooterView];
    _tab.tableHeaderView = [self creatTabHeader];;
}

//推荐的体检商品
-(void)networkForProducts
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param safeSetString:self.centerId forKey:@"exam_center_id"];
    [param safeSetString:NSStringFromInt(_page) forKey:@"page"];
    [param safeSetString:@"3" forKey:@"per_page"];
    
    
    
     @WeakObj(_tab);
    [[YJYRequstManager shareInstance] requestWithMethod:YJYRequstMethodGet api:Get_hospital_products parameters:param constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _page++;
        
        NSArray *data = result[@"data"];
        NSArray *arr = [NSArray arrayWithArray:[ProductModel modelsFromArray:data]];
        
        for (ProductModel *model in arr) {
            [_productsArray addObject:model];
        }
        
        
        [Weak_tab reloadData];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }];
}

#pragma mark - 数据解析处理
#pragma mark - 事件处理


-(void)clickedToMore{
    _clickedToMoreBtn.hidden = YES;
    [_act startAnimating];
    [self networkForProducts];
}



/**
 *  品牌推荐->单品详情
 */
- (void)clickToProductDetail:(UIButton *)btn
{
    int index = (int)btn.tag - 100;
    ProductModel *aModel = _productsArray[index];
    [MiddleTools pushToProductDetailWithProductId:aModel.product_id viewController:self extendParams:nil];
}

- (void)clickToMap
{
    MapViewController *map = [[MapViewController alloc]init];
    map.coordinate = CLLocationCoordinate2DMake([_hospitalModel.latitude floatValue], [_hospitalModel.longitude floatValue]);
    
//    118.367589,35.115255
//    116.312857,39.990157
    
//    map.coordinate = CLLocationCoordinate2DMake(39.990157, 116.312857);
    map.titleName = _hospitalModel.center_name;
    [self presentViewController:map animated:YES completion:^{
    }];
}

- (void)clickToPhone
{
    NSString *msg = [NSString stringWithFormat:@"拨打:%@",_hospitalModel.center_phone];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        
        NSString *msg = [NSString stringWithFormat:@"%@",_hospitalModel.center_phone];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",msg]]];
    }
}


/**
 *  手势
 *
 *  @param sender 手势
 */
- (void)tapToBrowser:(UITapGestureRecognizer *)sender
{
    int index = (int)sender.view.tag - 200;
    
    NSArray *img = _hospitalModel.pic;
    
    int count = (int)[img count];
    
    NSInteger initPage = index;
    
    @WeakObj(_tabFooterView);
    [LPhotoBrowser showWithViewController:self initIndex:initPage photoModelBlock:^NSArray *{
        
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:7];
        
        for (int i = 0; i < count; i ++) {
            
            NSDictionary *imageDic = img[i];
            
            UIImageView *imageView = [Weak_tabFooterView viewWithTag:200 + i];
            LPhotoModel *photo = [[LPhotoModel alloc]init];
            if ([imageDic isKindOfClass:[NSDictionary class]]) {
                photo.imageUrl = imageDic[@"url"];
            }else if([imageDic isKindOfClass:[NSString class]]){
                photo.imageUrl = (NSString *)imageDic;
            }
            imageView = imageView;
            photo.thumbImage = imageView.image;
            photo.sourceImageView = imageView;
            
            [temp addObject:photo];
        }
        
        return temp;
    }];
}

#pragma mark - 代理

@end
