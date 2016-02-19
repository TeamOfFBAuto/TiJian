//
//  BrandRecommendController.m
//  TiJian
//
//  Created by lichaowei on 16/1/27.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "BrandRecommendController.h"
#import "BrandRecomendCell.h"
#import "ConfirmOrderViewController.h"
#import "ProductModel.h"

@interface BrandRecommendController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_table;
    UIView *_bottom;
    UIButton *_selectAllBtn;
    UILabel *_sumLabel;//总价
    int _selectIndex;//选择的下标
    BOOL _firstLoad;//是否是第一次load
    NSDictionary *_selectSetmeal;//选中的套餐和附加项
}

@end

@implementation BrandRecommendController

//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"品牌推荐";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    _selectIndex = 0;//默认选择第一个
    _firstLoad = YES;
    [self prepareRefreshTableView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建

-(UIView *)resultView
{
    if (!_resultView) {
        
        _resultView = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"] title:@"温馨提示" content:@"没找到符合条件的品牌"];
    }
    return _resultView;
}

- (void)prepareRefreshTableView
{
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 50) style:UITableViewStylePlain];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    
//    [self creatBottomTools];
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5)];
    _table.tableFooterView = footer;
    
    [_table showRefreshHeader:YES];
}

/**
 *  创建底部工具条
 */
- (void)creatBottomTools
{
    _bottom = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 64 - 50, DEVICE_WIDTH, 50)];
    [self.view addSubview:_bottom];
    _bottom.backgroundColor = [UIColor whiteColor];
    
    CGFloat top = 0.f;
    //其他
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, top - 0.5, _bottom.width, 0.5)];
    line.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [_bottom addSubview:line];
    
    UILabel *label_heJi = [[UILabel alloc]initWithFrame:CGRectMake(10, line.bottom, 30, _bottom.height - line.height) title:@"合计" font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"494949"]];
    [_bottom addSubview:label_heJi];
    
    _sumLabel = [[UILabel alloc]initWithFrame:CGRectMake(label_heJi.right + 10, top, 100, _bottom.height - top) title:@"￥0.00" font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"f88600"]];
    [_bottom addSubview:_sumLabel];
    
//    [self updateSumPrice];//更新数据
    
    UIButton *payButton = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 110, top, 110, _bottom.height - top) buttonType:UIButtonTypeCustom normalTitle:@"去结算" selectedTitle:nil target:self action:@selector(clickToPay:)];
    [payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    payButton.backgroundColor = [UIColor colorWithHexString:@"f98700"];
    [_bottom addSubview:payButton];
    
}

#pragma mark - 网络请求

/**
 *  获取加强包
 */
- (void)netWorkForSetmeal
{
//    &result_id=16&type=3
    NSDictionary *params = @{@"result_id":self.result_id,
                             @"type":[NSNumber numberWithInt:self.starNum]};;
    NSString *api = Get_c_setmeal_product;
    
    __weak typeof(self)weakSelf = self;
    __weak typeof(_table)weakTable = _table;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        NSArray *temp = result[@"data"];
//        NSMutableArray *tt = [NSMutableArray arrayWithArray:temp];
//        [tt addObjectsFromArray:temp];
//        [tt addObjectsFromArray:temp];
//        [tt addObjectsFromArray:temp];
//        [tt addObjectsFromArray:temp];[tt addObjectsFromArray:temp];
//        [tt addObjectsFromArray:temp];[tt addObjectsFromArray:temp];
//        [tt addObjectsFromArray:temp];
        if (temp.count > 0) {
            
            if (!_bottom) {
                [weakSelf creatBottomTools];
            }
        }
        [weakTable reloadData:temp pageSize:10 noDataView:self.resultView];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        ResultView *resultView = (ResultView *)weakSelf.resultView;
        resultView.content = @"请检查网络稍后再试";
        [weakTable loadFailWithView:weakSelf.resultView pageSize:10];
        
    }];
}

#pragma mark - 数据解析处理

#pragma mark - 事件处理

- (void)clickToPay:(UIButton *)btn
{
    DDLOG(@"pay");
    
    //判断登录
    if (![LoginManager isLogin:self]) {
        
        return;
    }
    
    if (_selectSetmeal) {
        
        NSDictionary *dic = _table.dataArray[_selectIndex];
        NSDictionary *brand_info = dic[@"brand_info"];
        NSString *brandId = brand_info[@"brand_id"];
        NSString *brandName = brand_info[@"brand_name"];
        
        NSMutableArray *temp = [NSMutableArray array];
        NSDictionary *selectMain = _selectSetmeal[Select_main];
        NSArray *selectAddition = _selectSetmeal[Select_additon];//附加套餐
        NSString *mainProductId;
        if (selectMain && [selectMain isKindOfClass:[NSDictionary class]])
        {
            ProductModel *amodel = [[ProductModel alloc]initWithDictionary:selectMain];
            amodel.brand_id = brandId;
            amodel.brand_name = brandName;
            amodel.current_price = amodel.setmeal_price;
            amodel.original_price = amodel.setmeal_original_price;
            amodel.product_name = amodel.setmeal_name;
            amodel.product_num = @"1";
            amodel.main_product_id = amodel.product_id;//主套餐id
            mainProductId = amodel.product_id;//记录主套餐id
            [temp addObject:amodel];
            
        }
        
        if (selectAddition && [selectAddition isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic  in selectAddition) {
                ProductModel *amodel = [[ProductModel alloc]initWithDictionary:dic];
                amodel.brand_id = brandId;
                amodel.brand_name = brandName;
                amodel.product_name = amodel.package_name;
                amodel.is_append = [NSNumber numberWithInt:1];
                amodel.current_price = amodel.package_price;
                amodel.original_price = amodel.package_original_price;
                amodel.product_num = @"1";
                amodel.main_product_id = mainProductId;
                [temp addObject:amodel];
                
//                cover_pic\product_name\product_num\is_append
            }
        }
        ConfirmOrderViewController *cc = [[ConfirmOrderViewController alloc]init];
        cc.lastViewController = self;
        
        NSArray *arr = [NSArray arrayWithArray:temp];
        cc.dataArray = arr;
        [self.navigationController pushViewController:cc animated:YES];
        
    }else
    {
        [LTools showMBProgressWithText:@"请选择套餐" addToView:self.view];
    }
}

- (void)dealSelectSetmeal:(NSDictionary *)dic
{
    _selectSetmeal = dic;
    
    NSLog(@"dic %@",dic);
    if (dic) {
        CGFloat total = 0.f;//总价
        NSDictionary *selectMain = dic[Select_main];
        NSArray *selectAddition = dic[Select_additon];//附加套餐
        if (selectMain && [selectMain isKindOfClass:[NSDictionary class]]) {
            
            CGFloat price = [selectMain[@"setmeal_price"]floatValue];
            total += price;
        }
        
        if (selectAddition && [selectAddition isKindOfClass:[NSArray class]]) {
            
            for (NSDictionary *dic  in selectAddition) {
                CGFloat price = [dic[@"package_price"]floatValue];
                total += price;
            }
        }
        _sumLabel.text = [NSString stringWithFormat:@"¥%.2f",total];
    }else
    {
        _sumLabel.text = @"￥0.00";
    }
}

#pragma mark - 代理

#pragma - mark RefreshDelegate <NSObject>

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    [self netWorkForSetmeal];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    [self netWorkForSetmeal];
}
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    NSDictionary *dic = _table.dataArray[indexPath.section];

    return [BrandRecomendCell heightForCellWithModel:dic];
}

-(CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(RefreshTableView *)tableView
{
    return 45.f;
}

-(UIView *)viewForHeaderInSection:(NSInteger)section tableView:(RefreshTableView *)tableView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 45)];
    view.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    
    UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(0, 5, view.width, 40)];
    view2.backgroundColor = [UIColor whiteColor];
    [view addSubview:view2];
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 160, 40) font:15 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:nil];
    [view2 addSubview:title];
    
    NSDictionary *dic = _table.dataArray[section];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSDictionary *brand_info = dic[@"brand_info"];
        if ([brand_info isKindOfClass:[NSDictionary class]]) {
            NSString *brand_name = brand_info[@"brand_name"];
            title.text = brand_name;
        }
    }
    
    //line
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 39.5 - 0.5, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [view2 addSubview:line];
    
    return view;
}

#pragma - mark UITableViewDataSource

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *identifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section], (long)[indexPath row]];
    BrandRecomendCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[BrandRecomendCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dic = _table.dataArray[indexPath.section];
    [cell setCellWithModel:dic];
    cell.selectIndex = (int)indexPath.section;
     @WeakObj(tableView);
     @WeakObj(self);
    [cell setAdditonSelectBlock:^(int index,BOOL add, NSDictionary *dic) {
        
        _selectIndex = index;
        [WeaktableView reloadData];
        [Weakself dealSelectSetmeal:dic];
    }];
    
    if ((int)indexPath.section == _selectIndex) {
        
        if (_firstLoad) {
            
            _firstLoad = NO;
            
            [cell clickToSelectMain:cell.selectedButton];//默认选择第一个
        }
        
    }else
    {
        cell.selectedButton.selected = NO;
        [cell resetSelectState];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _table.dataArray.count;
}

@end
