//
//  GoneClassListViewController.m
//  TiJian
//
//  Created by gaomeng on 15/11/2.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GoneClassListViewController.h"
#import "RefreshTableView.h"
#import "NSDictionary+GJson.h"
#import "GProductCellTableViewCell.h"
#import "GproductDetailViewController.h"
#import "GTranslucentSideBar.h"
#import "GPushView.h"
#import "ProductModel.h"

@interface GoneClassListViewController ()<RefreshDelegate,UITableViewDataSource,GTranslucentSideBarDelegate,UITableViewDelegate>
{
    RefreshTableView *_table;
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_ProductOneClass;
    AFHTTPRequestOperation *_request_BrandListWithLocation;
    
    NSMutableArray *_productOneClassArray;
    int _count;//网络请求个数
    UIView *_backBlackView;//筛选界面下面的黑色透明view
    UIButton *_filterButton;//筛选按钮
}

@property (nonatomic, strong) GTranslucentSideBar *rightSideBar;


@end

@implementation GoneClassListViewController


- (void)dealloc
{
    NSLog(@"dealloc %@",self);
    _table.refreshDelegate = nil;
    _table.dataSource = nil;
    _table = nil;
    [_request removeOperation:_request_ProductOneClass];
    [self removeObserver:self forKeyPath:@"_count"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addObserver:self forKeyPath:@"_count" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeOther];
    self.myTitle = self.className;
    self.rightImage = [UIImage imageNamed:@"shaixuan.png"];
    
    _backBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    _backBlackView.backgroundColor = [UIColor blackColor];
    _backBlackView.alpha = 0.5;
    
    
    [self creatTableView];
    [self creatRightTranslucentSideBar];
    [self prepareBrandListWithLocation];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建

-(void)creatTableView{
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    [_table showRefreshHeader:YES];
}

//创建侧滑栏
-(void)creatRightTranslucentSideBar{
    
    // Create Right SideBar
    self.rightSideBar = [[GTranslucentSideBar alloc] initWithDirection:YES];
    self.rightSideBar.delegate = self;
    self.rightSideBar.sideBarWidth = DEVICE_WIDTH*670.0/750;
    self.rightSideBar.translucentStyle = UIBarStyleBlack;
    self.rightSideBar.tag = 1;
    
    // Add PanGesture to Show SideBar by PanGesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    //避免滑动返回手势与此冲突
    [panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];

    GPushView *pushView = [[GPushView alloc]initWithFrame:CGRectMake(0, 0, self.rightSideBar.sideBarWidth, self.rightSideBar.view.frame.size.height)gender:self.haveChooseGender];
    pushView.delegate = self;
    [self.rightSideBar setContentViewInSideBar:pushView];

}

#pragma mark - 逻辑处理


-(void)shaixuanFinishWithDic:(NSDictionary *)dic{
    self.shaixuanDic = dic;
    [_table showRefreshHeader:YES];
}


-(void)therightSideBarDismiss{
    
    [self.rightSideBar dismiss];
}


-(void)rightButtonTap:(UIButton *)sender{
    [self.rightSideBar show];
}


-(void)clickToFilter:(UIButton *)sender{
    
    
    [self.rightSideBar show];
}

#pragma mark - Gesture Handler
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    
    
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        
//        CGPoint startPoint = [recognizer locationInView:self.view];
//        NSLog(@"startPoint.x :%f  startPoint.y :%f",startPoint.x,startPoint.y);
//        self.rightSideBar.isCurrentPanGestureTarget = YES;
//    }
    
    self.rightSideBar.isCurrentPanGestureTarget = YES;
    [self.rightSideBar handlePanGestureToShow:recognizer inView:self.view];
    
}

#pragma mark - CDRTranslucentSideBarDelegate
- (void)sideBar:(GTranslucentSideBar *)sideBar didAppear:(BOOL)animated
{
    
    if (sideBar.tag == 1) {
        NSLog(@"Right SideBar did appear");
        
    }
}

- (void)sideBar:(GTranslucentSideBar *)sideBar willAppear:(BOOL)animated
{
    if (sideBar.tag == 1) {
        NSLog(@"Right SideBar will appear");
        
        [self.navigationController.view addSubview:_backBlackView];
        
    }
}

- (void)sideBar:(GTranslucentSideBar *)sideBar didDisappear:(BOOL)animated
{
    
    if (sideBar.tag == 1) {
        NSLog(@"Right SideBar did disappear");
        [_backBlackView removeFromSuperview];
    }
}

- (void)sideBar:(GTranslucentSideBar *)sideBar willDisappear:(BOOL)animated
{
    if (sideBar.tag == 1) {
        NSLog(@"Right SideBar will disappear");
        
    }
}



#pragma mark - 请求网络数据

-(void)prepareNetDataWithDic:(NSDictionary *)theDic{
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    _count = 0;

    NSDictionary *dic;
    
    if (theDic) {
        NSString *voucherId = self.uc_id ? self.uc_id : @"";
        NSMutableDictionary *temp_dic = [NSMutableDictionary dictionaryWithDictionary:theDic];
        [temp_dic setObject:NSStringFromInt(_table.pageNum) forKey:@"page"];
        [temp_dic setObject:NSStringFromInt(PAGESIZE_MID) forKey:@"per_page"];
        
        if (voucherId.length > 0) {
            [temp_dic setObject:voucherId forKey:@"uc_id"];//加上代金卷id
            dic = temp_dic;
        }else
        {
            dic = temp_dic;
        }
    }else{
        
        dic = @{
                  @"category_id":[NSString stringWithFormat:@"%d",self.category_id],
                  @"province_id":[GMAPI getCurrentProvinceId],
                  @"city_id":[GMAPI getCurrentCityId],
                  @"uc_id":self.uc_id ? self.uc_id : @"", //加上代金卷id
                  @"page":NSStringFromInt(_table.pageNum),
                  @"per_page":NSStringFromInt(PAGESIZE_MID)
                  };
    }
    
    _request_ProductOneClass = [_request requestWithMethod:YJYRequstMethodGet api:StoreProductList parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *arr = [result arrayValueForKey:@"data"];
        
        _productOneClassArray = [NSMutableArray arrayWithCapacity:1];
        
        for (NSDictionary *dic in arr) {
            ProductModel *model = [[ProductModel alloc]initWithDictionary:dic];
            [_productOneClassArray addObject:model];
        }
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        [_table reloadData:_productOneClassArray pageSize:PAGESIZE_MID noDataView:[self resultViewWithType:PageResultType_nodata]];
        
        if (_productOneClassArray.count == 0) {
            [_table reloadData:nil pageSize:PAGESIZE_MID noDataView:[self resultViewWithType:PageResultType_nodata]];
            
        }else{
            _filterButton.hidden = NO;
        }
        
        
    } failBlock:^(NSDictionary *result) {
        
        [_table reloadData:nil pageSize:PAGESIZE_MID noDataView:[self resultViewWithType:PageResultType_nodata]];
    }];
 
    
}

//根据城市查询品牌列表
-(void)prepareBrandListWithLocation{
    
    //代金卷购买,并且非通用
    if (self.isVoucherPush && [self.brandId intValue] > 0) {
        //过滤掉其他品牌
        if ([LTools isEmpty:self.brandName]) {
            self.brandName = @"未知品牌";
        }
        NSDictionary *dic = @{@"brand_id":self.brandId,
                              @"brand_name":self.brandName
                              };
//        [self creatFilterBtn];
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        self.brand_city_list = @[dic];
        
        return;
    }
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSDictionary *dic = @{
                          @"province_id":[GMAPI getCurrentProvinceId],
                          @"city_id":[GMAPI getCurrentCityId]
                          };
    
//    __weak typeof(self)weakSelf = self;
    _request_BrandListWithLocation = [_request requestWithMethod:YJYRequstMethodGet api:BrandList_oneClass parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *arr = [result arrayValueForKey:@"data"];
        self.brand_city_list = [NSArray arrayWithArray:arr];
//        [self creatFilterBtn];
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
}

//网络请求完成
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        return;
    }
    
    NSNumber *num = [change objectForKey:@"new"];
    
    if ([num intValue] >= 2) {
        
    
    }
}

#pragma - mark RefreshDelegate


- (void)loadNewDataForTableView:(UITableView *)tableView{
    
    [_request removeOperation:_request_ProductOneClass];
    
    [self prepareNetDataWithDic:self.shaixuanDic];
    
}
- (void)loadMoreDataForTableView:(UITableView *)tableView{
    
    [self prepareNetDataWithDic:self.shaixuanDic];
    
}


- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    
    NSLog(@"%s",__FUNCTION__);
    GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
    ProductModel *model = _table.dataArray[indexPath.row];
    cc.productId = model.product_id;
    cc.isVoucherPush = self.isVoucherPush;
    cc.userChooseLocationDic = self.shaixuanDic;
    if (self.isVoucherPush) {
        cc.VoucherId = self.vouchers_id;
    }
    [self.navigationController pushViewController:cc animated:YES];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%s",__FUNCTION__);
    
}


- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    return [GProductCellTableViewCell getCellHight];
}
//将要显示
- (void)refreshTableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
    });
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger num = 0;
    if (tableView.tag ==1) {
        num = 4;
    }else{
        num = _table.dataArray.count;
    }
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 1) {
        static NSString *ident = @"ident";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
        }
        return cell;
    }else{
        static NSString *identifier = @"identifier";
        GProductCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[GProductCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        
        ProductModel *model = _table.dataArray[indexPath.row];
        
        [cell loadData:model];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    
    return [[UITableViewCell alloc]init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}



#pragma mark - 无数据默认view
-(ResultView *)resultViewWithType:(PageResultType)type
{
    NSString *content;
    if (type == PageResultType_nodata){
        
        content = @"暂无可用套餐";
    }
    
    
    ResultView *result = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"]
                                                    title:@"温馨提示"
                                                  content:content];
    
    return result;
}



@end
