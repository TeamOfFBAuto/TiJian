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
#import "DLNavigationEffectKit.h"
#import "GSearchView.h"

@interface GoneClassListViewController ()<RefreshDelegate,UITableViewDataSource,GTranslucentSideBarDelegate,UITableViewDelegate,UITextFieldDelegate,GpushViewDelegate,GsearchViewDelegate>
{
    RefreshTableView *_table;//主tableview
    GPushView *_pushView;//筛选view
    
    YJYRequstManager *_request;//网络请求
    AFHTTPRequestOperation *_request_ProductOneClass;
    AFHTTPRequestOperation *_request_BrandListWithLocation;
    AFHTTPRequestOperation *_request_hotSearch;
    
    NSMutableArray *_productOneClassArray;//商品列表
    int _count;//网络请求个数
    UIView *_backBlackView;//筛选界面下面的黑色透明view
    UIButton *_filterButton;//筛选按钮
    
    //搜索框相关
    UIView *_searchView;
    UIView *_kuangView;
    UIBarButtonItem *_rightItem1;
    UIButton *_rightItem2Btn;
    UIView *_mySearchView;//点击搜索盖上的搜索浮层
    GSearchView *_theCustomSearchView;//自定义搜索view
    int _searchState;
    NSArray *_hotSearchArray;//热门搜索
    
    //轻扫手势
    UIPanGestureRecognizer *_panGestureRecognizer;
    
    
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
    
    
    if (self.shaixuanDic) {
        if (![LTools isEmpty:[self.shaixuanDic stringValueForKey:@"category_id"]]) {
            self.category_id = [[self.shaixuanDic stringValueForKey:@"category_id"]intValue];
        }
        if (![LTools isEmpty:[self.shaixuanDic stringValueForKey:@"brand_id"]]) {
            self.brand_id = [self.shaixuanDic stringValueForKey:@"brand_id"];
        }

    }
    
    
    _backBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    _backBlackView.backgroundColor = [UIColor blackColor];
    _backBlackView.alpha = 0.5;
    
    _searchState = 0;
    
    //视图创建
    [self creatTableView];
    [self setupNavigation];
    [self creatMysearchView];
    [self getHotSearch];
    [self creatRightTranslucentSideBar];
    //网络请求
    [self prepareBrandListWithLocation];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建
//创建搜索界面
-(void)creatMysearchView{
    _mySearchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    _mySearchView.backgroundColor = [UIColor whiteColor];
    _mySearchView.hidden = YES;
    [self.view addSubview:_mySearchView];
    
    _theCustomSearchView = [[GSearchView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, _mySearchView.frame.size.height)];
    _theCustomSearchView.delegate = self;
    
    __weak typeof (self)bself = self;
    
    [_theCustomSearchView setKuangBlock:^(NSString *theStr) {
        [bself searchBtnClickedWithStr:theStr isHotSearch:NO];
    }];
    
    [_mySearchView addSubview:_theCustomSearchView];
}


//创建自定义navigation
- (void)setupNavigation{
    
    self.rightImage = [UIImage imageNamed:@"shaixuan"];
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeOther];
    
    //右边
    _searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 7, DEVICE_WIDTH - 70, 30)];
    _searchView.layer.cornerRadius = 5;
    _searchView.backgroundColor = RGBCOLOR(248, 248, 248);
    
    //带框的view
    _kuangView = [[UIView alloc]initWithFrame:CGRectZero];
    _kuangView.layer.cornerRadius = 5;
    _kuangView.layer.borderColor = [RGBCOLOR(192, 193, 194)CGColor];
    _kuangView.layer.borderWidth = 0.5;
    [_searchView addSubview:_kuangView];
    
    
    UIImageView *fdjImv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 13, 13)];
    [fdjImv setImage:[UIImage imageNamed:@"search_fangdajing.png"]];
    [_searchView addSubview:fdjImv];
    
    self.searchTf = [[UITextField alloc]initWithFrame:CGRectZero];
    self.searchTf.font = [UIFont systemFontOfSize:13];
    self.searchTf.backgroundColor = RGBCOLOR(248, 248, 248);
    self.searchTf.layer.cornerRadius = 5;
    self.searchTf.placeholder = @"输入您要找的商品";
    self.searchTf.delegate = self;
    self.searchTf.returnKeyType = UIReturnKeySearch;
    self.searchTf.text = self.theSearchWorld;
    self.searchTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_kuangView addSubview:self.searchTf];
    
    [self changeSearchViewAndKuangFrameAndTfWithState:0];
    
    _rightItem1 = [[UIBarButtonItem alloc]initWithCustomView:_searchView];
    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:      UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [spaceButtonItem setWidth:-15];
    self.currentNavigationItem.rightBarButtonItems = @[spaceButtonItem,_rightItem1];
    
    UIView *effectView = self.currentNavigationBar.effectContainerView;
    if (effectView) {
        UIView *alphaView = [[UIView alloc] initWithFrame:effectView.bounds];
        [effectView addSubview:alphaView];
        alphaView.backgroundColor = [UIColor whiteColor];
        alphaView.tag = 10000;
    };
    
    [self setEffectViewAlpha:1];
    
}

-(void)creatTableView{
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
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

    //避免滑动返回手势与此冲突
    [_panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];

    _pushView = [[GPushView alloc]initWithFrame:CGRectMake(0, 0, self.rightSideBar.sideBarWidth, self.rightSideBar.view.frame.size.height)gender:self.haveChooseGender isHaveShaixuanDic:self.shaixuanDic];
    _pushView.delegate = self;
    [self.rightSideBar setContentViewInSideBar:_pushView];

}

#pragma mark - 逻辑处理
-(void)searchBtnClickedWithStr:(NSString*)theWord isHotSearch:(BOOL)isHot{
    
    [self changeSearchViewAndKuangFrameAndTfWithState:0];
    
    [_searchTf resignFirstResponder];
    _mySearchView.hidden = YES;
    
    if (!isHot) {
        if (![LTools isEmpty:self.searchTf.text]) {
            [GMAPI setuserCommonlyUsedSearchWord:self.searchTf.text];
        }
        
    }

    
    self.searchTf.text = theWord;
    self.theSearchWorld = self.searchTf.text;
    [_table showRefreshHeader:YES];
    
}

-(void)myNavcRightBtnClicked{
    
    if (_searchState == 0) {
        [self.rightSideBar show];
    }else if (_searchState == 1){
        [self changeSearchViewAndKuangFrameAndTfWithState:0];
        [_searchTf resignFirstResponder];
        _mySearchView.hidden = YES;
    }
}

//返回上个界面
-(void)gogoback{
    [self.navigationController popViewControllerAnimated:YES];
}


/**
 *  改变searchTf和框的大小
 *
 *  @param state 1 编辑状态 0常态
 */
-(void)changeSearchViewAndKuangFrameAndTfWithState:(int)state{
    if (state == 0) {//常态
        _searchState = 0;
        [_searchView setFrame:CGRectMake(0, 7, DEVICE_WIDTH - 40, 30)];
        [_kuangView setFrame:CGRectMake(0, 0, _searchView.frame.size.width - 45, 30)];
        [self.searchTf setFrame:CGRectMake(30, 0, _kuangView.frame.size.width - 30, 30)];
        
        if (!_rightItem2Btn) {
            _rightItem2Btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_rightItem2Btn setFrame:CGRectMake(_searchView.frame.size.width - 45, 0, 45, 30)];
            [_rightItem2Btn setTitle:@"筛选" forState:UIControlStateNormal];
            _rightItem2Btn.titleLabel.font = [UIFont systemFontOfSize:13];
            [_rightItem2Btn setTitleColor:RGBCOLOR(134, 135, 136) forState:UIControlStateNormal];
            [_rightItem2Btn setImage:[UIImage imageNamed:@"shaixuan.png"] forState:UIControlStateNormal];
            [_rightItem2Btn setTitle:nil forState:UIControlStateNormal];
            
            [_rightItem2Btn addTarget:self action:@selector(myNavcRightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [_searchView addSubview:_rightItem2Btn];
        }else{
            [_rightItem2Btn setFrame:CGRectMake(_searchView.frame.size.width - 45, 0, 45, 30)];
            [_rightItem2Btn setImage:[UIImage imageNamed:@"shaixuan.png"] forState:UIControlStateNormal];
            [_rightItem2Btn setTitle:nil forState:UIControlStateNormal];
        }
        
        if (!_panGestureRecognizer) {
            _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        }
        [self.view addGestureRecognizer:_panGestureRecognizer];
        
        
    }else if (state == 1){//编辑状态
        _searchState = 1;
        [_searchView setWidth:DEVICE_WIDTH - 10];
        [_kuangView setWidth:_searchView.frame.size.width - 45];
        [self.searchTf setFrame:CGRectMake(30, 0, _kuangView.frame.size.width - 30, 30)];
        if (!_rightItem2Btn) {
            _rightItem2Btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_rightItem2Btn setFrame:CGRectMake(_searchView.frame.size.width - 45, 0, 45, 30)];
            [_rightItem2Btn setTitle:@"取消" forState:UIControlStateNormal];
            [_rightItem2Btn setImage:nil forState:UIControlStateNormal];
            _rightItem2Btn.titleLabel.font = [UIFont systemFontOfSize:13];
            [_rightItem2Btn setTitleColor:RGBCOLOR(134, 135, 136) forState:UIControlStateNormal];
            [_rightItem2Btn addTarget:self action:@selector(myNavcRightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [_searchView addSubview:_rightItem2Btn];
        }else{
            [_rightItem2Btn setFrame:CGRectMake(_searchView.frame.size.width - 45, 0, 45, 30)];
            [_rightItem2Btn setTitle:@"取消" forState:UIControlStateNormal];
            [_rightItem2Btn setImage:nil forState:UIControlStateNormal];
        }
        
        [self.navigationController.navigationBar bringSubviewToFront:_searchView];
        
        [self.view removeGestureRecognizer:_panGestureRecognizer];
        
    }
}

-(void)setEffectViewAlpha:(CGFloat)theAlpha{
    UIView *effectView = self.currentNavigationBar.effectContainerView;
    if (effectView) {
        UIView *alphaView = [effectView viewWithTag:10000];
        alphaView.alpha = theAlpha;
    }
}


-(void)shaixuanFinishWithDic:(NSDictionary *)dic{
    if (self.category_id>0) {//有分类id
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [tmpDic safeSetString:NSStringFromInt(self.category_id) forKey:@"category_id"];
        self.shaixuanDic = (NSDictionary *)tmpDic;
    }else{
        self.shaixuanDic = dic;
    }
    [_table showRefreshHeader:YES];
}


-(void)therightSideBarDismiss{
    
    [self.rightSideBar dismiss];
}

-(void)clickToFilter:(UIButton *)sender{
    [self.rightSideBar show];
}

#pragma mark - Gesture Handler
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
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
        
        _pushView.tempDic = self.shaixuanDic;
        
    }
}

- (void)sideBar:(GTranslucentSideBar *)sideBar didDisappear:(BOOL)animated
{
    
    if (sideBar.tag == 1) {
        NSLog(@"Right SideBar did disappear");
        [_backBlackView removeFromSuperview];
        if (!_pushView.isRightBtnClicked) {
            [_pushView leftBtnClicked];
            _pushView.isRightBtnClicked = NO;
        }
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
            [temp_dic setObject:voucherId forKey:@"uc_id"];//加上代金券id
            dic = temp_dic;
        }else
        {
            dic = temp_dic;
        }
        
        if (self.brand_id) {
            if ([[temp_dic stringValueForKey:@"brand_id"]intValue] != [self.brand_id intValue]) {
                [temp_dic safeSetString:[temp_dic stringValueForKey:@"brand_id"] forKey:@"brand_id"];
            }else{
                [temp_dic setObject:self.brand_id forKey:@"brand_id"];
            }
            
            dic = temp_dic;
        }
        if (self.category_id) {
            [temp_dic setObject:[NSString stringWithFormat:@"%d",self.category_id] forKey:@"category_id"];
            dic = temp_dic;
        }
        
    }else{
        
        dic = @{
                  @"category_id":[NSString stringWithFormat:@"%d",self.category_id],
                  @"province_id":[GMAPI getCurrentProvinceId],
                  @"city_id":[GMAPI getCurrentCityId],
                  @"uc_id":self.uc_id ? self.uc_id : @"", //加上代金券id
                  @"page":NSStringFromInt(_table.pageNum),
                  @"per_page":NSStringFromInt(PAGESIZE_MID)
                  };
        
        if (self.brand_id) {
            NSMutableDictionary *temp_dic = [NSMutableDictionary dictionaryWithDictionary:theDic];
            [temp_dic setObject:NSStringFromInt(_table.pageNum) forKey:@"page"];
            [temp_dic setObject:NSStringFromInt(PAGESIZE_MID) forKey:@"per_page"];
            [temp_dic setObject:self.brand_id forKey:@"brand_id"];//加上代金券id
            dic = temp_dic;
        }
        
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

//热门搜索
-(void)getHotSearch{

    _request_hotSearch = [_request requestWithMethod:YJYRequstMethodGet api:ProductHotSearch parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        _hotSearchArray = [result arrayValueForKey:@"list"];
        _theCustomSearchView.hotSearch = _hotSearchArray;
        [_theCustomSearchView.tab reloadData];
    } failBlock:^(NSDictionary *result) {
        
        
    }];
}



//根据关键词搜索
-(void)prepareNetDataWithSearchDic:(NSDictionary *)theDic{
    
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
            [temp_dic setObject:voucherId forKey:@"uc_id"];//加上代金券id
            dic = temp_dic;
        }else{
            
            dic = temp_dic;
        }
        
        if (self.brand_id) {
            [temp_dic setObject:self.brand_id forKey:@"brand_id"];//加上代金券id
            dic = temp_dic;
        }
        
        
    }else{
        
        dic = @{
                @"province_id":[GMAPI getCurrentProvinceId],
                @"city_id":[GMAPI getCurrentCityId],
                @"page":NSStringFromInt(_table.pageNum),
                @"per_page":NSStringFromInt(PAGESIZE_MID)
                };
        
        
        if (self.brand_id) {
            NSMutableDictionary *temp_dic = [NSMutableDictionary dictionaryWithDictionary:theDic];
            [temp_dic setObject:NSStringFromInt(_table.pageNum) forKey:@"page"];
            [temp_dic setObject:NSStringFromInt(PAGESIZE_MID) forKey:@"per_page"];
            [temp_dic setObject:self.brand_id forKey:@"brand_id"];//加上代金券id
            dic = temp_dic;
        }
        
    }
    
    
    
    
    
    NSMutableDictionary *m_dic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [m_dic safeSetString:self.theSearchWorld forKey:@"keywords"];
    
    _request_ProductOneClass = [_request requestWithMethod:YJYRequstMethodGet api:StoreProductList parameters:m_dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
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
    
    //代金券购买,并且非通用
    if (self.vouchers_id && [self.brandId intValue] > 0) {
        //过滤掉其他品牌
        if ([LTools isEmpty:self.brandName]) {
            self.brandName = @"其他品牌";
        }
        NSDictionary *dic = @{@"brand_id":self.brandId,
                              @"brand_name":self.brandName
                              };
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        self.brand_city_list = @[dic];
        
        return;
    }
    
    
//    //商城首页品牌跳转 单品详情页品牌跳转
//    if ([self.brand_id intValue] > 0) {
//        //过滤掉其他品牌
//        if ([LTools isEmpty:self.brand_name]) {
//            self.brand_name = @"其他品牌";
//        }
//        NSDictionary *dic = @{@"brand_id":self.brand_id,
//                              @"brand_name":self.brand_name
//                              };
//        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
//        self.brand_city_list = @[dic];
//        return;
//    }
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    _request_BrandListWithLocation = [_request requestWithMethod:YJYRequstMethodGet api:BrandList_oneClass parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *arr = [result arrayValueForKey:@"data"];
        self.brand_city_list = [NSArray arrayWithArray:arr];
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
        if (_pushView) {
            _pushView.tab4.tableFooterView = nil;
            [_pushView.tab4 reloadData];
        }
        
        
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
    
    
//    if (self.brand_id && self.category_id) {
//        NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:self.shaixuanDic];
//        [temp safeSetString:self.brand_id forKey:@"brand_id"];
//        [temp safeSetString:[NSString stringWithFormat:@"%d",self.category_id] forKey:@"category_id"];
//        self.shaixuanDic = temp;
//    }
    
    
    if (self.theSearchWorld) {
        [self prepareNetDataWithSearchDic:self.shaixuanDic];
    }else{
        [self prepareNetDataWithDic:self.shaixuanDic];
    }
    
    
    
}
- (void)loadMoreDataForTableView:(UITableView *)tableView{
    
    if (self.brand_id && self.category_id) {
        NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:self.shaixuanDic];
        [temp safeSetString:self.brand_id forKey:@"brand_id"];
        [temp safeSetString:[NSString stringWithFormat:@"%d",self.category_id] forKey:@"category_id"];
        self.shaixuanDic = temp;
    }
    
    
    
    if (self.theSearchWorld) {
        [self prepareNetDataWithSearchDic:self.shaixuanDic];
    }else{
        [self prepareNetDataWithDic:self.shaixuanDic];
    }
    
    
}


- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    [self controlTopButtonWithScrollView:scrollView];
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    
    NSLog(@"%s",__FUNCTION__);
    GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
    ProductModel *model = _table.dataArray[indexPath.row];
    cc.productId = model.product_id;
    cc.userChooseLocationDic = self.shaixuanDic;
    cc.VoucherId = self.vouchers_id;
    cc.user_voucher = self.user_voucher;
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


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"%s",__FUNCTION__);
    _mySearchView.hidden = NO;
    _theCustomSearchView.dataArray = [GMAPI cacheForKey:USERCOMMONLYUSEDSEARCHWORD];
    
    [_theCustomSearchView.tab reloadData];

    [self changeSearchViewAndKuangFrameAndTfWithState:1];
    
    
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (![LTools isEmpty:self.searchTf.text]) {
        [self searchBtnClickedWithStr:self.searchTf.text isHotSearch:NO];
    }
    
    return YES;
}











@end
