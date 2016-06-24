//
//  GoHealthProductlistController.m
//  TiJian
//
//  Created by lichaowei on 16/6/7.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GoHealthProductlistController.h"
#import "ThirdProductModel.h"
#import "GoHealthProductDetailController.h"

@interface GoHealthProductlistController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_table;
    UIButton *_stateButton;
}

@end

@implementation GoHealthProductlistController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"上门体检";
    [self prepareRefreshTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建

- (void)prepareRefreshTableView
{
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_table showRefreshHeader:YES];
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


#pragma mark - 网络请求

- (void)netWorkForList
{
    NSString *nonceStr = [LTools randomNum:32];//随机字符串
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetValue:GoHealthAppId forKey:@"appId"];
    [params safeSetValue:nonceStr forKey:@"nonceStr"];
    [params safeSetValue:NSStringFromInt(_table.pageNum) forKey:@"page"];//第几页
    [params safeSetValue:NSStringFromInt(10) forKey:@"limit"];//每页数量
    [params safeSetValue:@"wap" forKey:@"osType"];
    
    NSString *sign = [MiddleTools goHealthSignWithParams:params];
    [params safeSetValue:sign forKey:@"sign"];
    
     @WeakObj(_table);
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet_goHealth api:GoHealth_productionsList parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
//        NSLog(@"goHealth success result %@",result);
        
        NSDictionary *data = result[@"data"];
        NSArray *productions = data[@"productions"];
        NSArray *tempArr = [ThirdProductModel modelsFromArray:productions];
        
        [Weak_table reloadData:tempArr pageSize:10 noDataView:[self resultViewWithType:PageResultType_nodata msg:nil]];
        
    } failBlock:^(NSDictionary *result) {
        
//        NSLog(@"goHealth fail result %@",result);
        NSLog(@"%@",result[@"msg"]);
        [Weak_table loadFailWithView:[self resultViewWithType:PageResultType_nodata msg:result[@"msg"]] pageSize:10];
    }];
}

/**
 *  获取Go健康所有的可用城市
 */
- (void)netWorkForCityList
{
    NSString *nonceStr = [LTools randomNum:32];//随机字符串
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetValue:GoHealthAppId forKey:@"appId"];
    [params safeSetValue:nonceStr forKey:@"nonceStr"];
    
    NSString *version = [LTools objectForKey:@"gohelthCityVersion"];
    [params safeSetValue:version forKey:@"version"];
//    [params safeSetValue:@"100" forKey:@"state"];
    
    NSString *sign = [MiddleTools goHealthSignWithParams:params];
    [params safeSetValue:sign forKey:@"sign"];
    //http://121.40.167.147:3005/v1/geos?appId=gjk001061&sign=854B923F59BD8E66A2BA3232BC31230F&state=100&nonceStr=DLozSfSRgfBHNZ0c3UUJW8VwvzbqbqEN
    @WeakObj(_table);
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet_goHealth api:GoHealth_citylist parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        //        NSLog(@"goHealth success result %@",result);
        
        NSDictionary *data = result[@"data"];
        NSArray *productions = data[@"productions"];
        NSArray *tempArr = [ThirdProductModel modelsFromArray:productions];
        
        [Weak_table reloadData:tempArr pageSize:10 noDataView:[self resultViewWithType:PageResultType_nodata msg:nil]];
        
    } failBlock:^(NSDictionary *result) {
        
        //        NSLog(@"goHealth fail result %@",result);
        NSLog(@"%@",result[@"msg"]);
        [Weak_table loadFailWithView:[self resultViewWithType:PageResultType_nodata msg:result[@"msg"]] pageSize:10];
    }];
}

#pragma mark - 数据解析处理

- (void)parseCitylistWithResult:(NSDictionary *)result
{
    
}

#pragma mark - 事件处理

/**
 *  刷新数据
 */
- (void)refreshData
{
    [_table showRefreshHeader:YES];
}

#pragma mark - 代理

#pragma - mark RefreshDelegate <NSObject>

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    [self netWorkForList];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    [self netWorkForList];
}
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    ThirdProductModel *model = _table.dataArray[indexPath.row];
    GoHealthProductDetailController *detail = [[GoHealthProductDetailController alloc]init];
    detail.productId = model.id;
    [self.navigationController pushViewController:detail animated:YES];
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    return DEVICE_WIDTH / 1.6;
}

#pragma - mark UITableViewDataSource

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return tableView.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"identify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.contentView.clipsToBounds = YES;
        cell.clipsToBounds = YES;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_WIDTH / 1.6)];
        imageView.backgroundColor = [UIColor orangeColor];
        [cell.contentView addSubview:imageView];
        imageView.tag = 100;
        
        //底部
        CGFloat height = [LTools fitWithIPhone6:50];
        UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, imageView.height - height, DEVICE_WIDTH, height)];
        [cell.contentView addSubview:footView];
        footView.backgroundColor = [UIColor whiteColor];
        //标题
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, DEVICE_WIDTH - 90, footView.height) font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:nil];
        [footView addSubview:label];
        label.tag = 101;
        //价格
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 12 - 76, 10, 76, footView.height - 20) font:14 align:NSTextAlignmentCenter textColor:[UIColor whiteColor] title:nil];
        [footView addSubview:label2];
        label2.backgroundColor = DEFAULT_TEXTCOLOR_ORANGE;
        [label2 addCornerRadius:3.f];
        label2.tag = 102;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
    UILabel *label = [cell.contentView viewWithTag:101];
    UILabel *label2 = [cell.contentView viewWithTag:102];
    
    ThirdProductModel *model = _table.dataArray[indexPath.row];
    label.text = model.name;
    
    NSNumber *dicountPrice = model.discountPrice;
    NSString *price = [NSString stringWithFormat:@"¥%.2f",[dicountPrice floatValue]];
    label2.text = price;
    
    NSDictionary *pic = [model.pictures firstObject];
    CGFloat width = [pic[@"width"]floatValue];
    CGFloat height = [pic[@"height"]floatValue];
    
    NSString *imageUrl = [model.pictures firstObject][@"thumb"];
    
    imageView.height = DEVICE_WIDTH / 1.6;
//    [imageView l_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:DEFAULT_HEADIMAGE];
    
    [imageView l_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:DEFAULT_HEADIMAGE completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (height) {
            imageView.height = DEVICE_WIDTH * (width/height);;
        }
    }];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
