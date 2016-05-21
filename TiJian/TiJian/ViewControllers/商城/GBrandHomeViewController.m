//
//  GBrandHomeViewController.m
//  TiJian
//
//  Created by gaomeng on 16/1/28.
//  Copyright © 2016年 lcw. All rights reserved.
//


//品牌店

#import "GBrandHomeViewController.h"
#import "GSearchView.h"
#import "ProductListViewController.h"
#import "GShopCarViewController.h"
#import "DLNavigationEffectKit.h"
#import "GoneClassListViewController.h"
#import "GTranslucentSideBar.h"
#import "GPushView.h"
#import "GUpToolView.h"
#import "GmyFootViewController.h"
#import "GCustomSearchViewController.h"
#import "GBrandTabHeaderView.h"
#import "GProductCellTableViewCell.h"
#import "GproductDetailViewController.h"
#import "BrandDetailViewController.h"
#import "BrandSearchViewController.h"

@interface GBrandHomeViewController ()<RefreshDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewDelegate,GsearchViewDelegate,GpushViewDelegate,GTranslucentSideBarDelegate>
{
    YJYRequstManager *_request;
    
    UIView *_mySearchView;//点击搜索盖上的搜索浮层
    UIView *_searchView;//输入框下层view
    NSArray *_hotSearchArray;//热门搜索
    
    UIBarButtonItem *_rightItem1;
    UILabel *_rightItem2Label;
    UIView *_kuangView;
    int _searchState;
    UIButton *_rightItem2Btn;
    
    UIView *_backBlackView;//筛选界面下面的黑色透明view
    
    //轻扫手势
    UIPanGestureRecognizer *_panGestureRecognizer;
    
    GPushView *_pushView;//筛选view
    
    RefreshTableView *_table;
    
    //顶部工具栏
    GUpToolView *_upToolView;
    
    UIView *_downToolBlackView;
    
    BOOL _toolShow;
    
    //底部
    UIView *_downView;
    
    UILabel *_shopCarNumLabel;
    
    BOOL _isPresenting;//是否在模态
    
    
    
    //tableHeaderView
    GBrandTabHeaderView *_tabHeaderView;
    
    NSMutableArray *_productOneClassArray;
    
    NSDictionary *_classDic;
    
    
    BOOL _priceState;
    
    NSDictionary *_shopCarDic;
    int _gouwucheNum;//购物车里商品数量
    
    
    UIView *_fourBtn_sectionHeaderView;
    
}

@property (nonatomic, strong) GTranslucentSideBar *rightSideBar;//筛选view

@end

@implementation GBrandHomeViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_UPDATE_TO_CART object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_LOGIN object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.haveChooseGender = YES;//筛选条件添加性别
    
    _backBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    _backBlackView.backgroundColor = [UIColor blackColor];
    _backBlackView.alpha = 0.5;
    
    _searchState = 0;
    
    [self prepareBrandDetail];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateShopCarNum) name:NOTIFICATION_UPDATE_TO_CART object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateShopCarNum) name:NOTIFICATION_LOGIN object:nil];
    
    //视图创建
    [self creatTab];
    [self setupNavigation];
    [self creatMysearchView];
    [self creatRightTranslucentSideBar];
    [self prepareBrandListWithLocation];
    [self creatUpToolView];
    [self creatDownBtnView];
    
    [self getshopcarNum];//购物车数量
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 网络请求

//获取购物车数量
-(void)getshopcarNum{
    
    if ([LoginViewController isLogin]) {
        [self getShopcarNumWithLoginSuccess];
    }else{
        
    }
}


//获取购物车数量
-(void)getShopcarNumWithLoginSuccess{
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey]
                          };
    [_request requestWithMethod:YJYRequstMethodGet api:GET_SHOPPINGCAR_NUM parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _shopCarDic = result;
        _gouwucheNum = [_shopCarDic intValueForKey:@"num"];
        
        if (_shopCarNumLabel) {
            
            int num = [[NSString stringWithFormat:@"%d",[_shopCarDic intValueForKey:@"num"]]intValue];
            NSString *num_str;
            if (num >= 100) {
                num_str = @"99+";
            }else{
                num_str = [NSString stringWithFormat:@"%d",num];
            }
            _shopCarNumLabel.text = num_str;
            [self updateShopCarNumAndFrame];
        }
        
        
        
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

-(void)updateShopCarNumAndFrame{
    
    if ([_shopCarNumLabel.text intValue] == 0) {
        _shopCarNumLabel.hidden = YES;
    }else{
        _shopCarNumLabel.hidden = NO;
        UIButton *oneBtn = (UIButton*)[_downView viewWithTag:103];
        if (![LTools isEmpty:_shopCarNumLabel.text]) {
            if ([_shopCarNumLabel.text intValue]<10) {
                [_shopCarNumLabel setFrame:CGRectMake(oneBtn.bounds.size.width - 45, 5, 10, 10)];
            }else{
                [_shopCarNumLabel setFrame:CGRectMake(oneBtn.bounds.size.width - 48, 5, 18, 10)];
            }
        }
        
    }
    
    
}

//登录成功更新购物车数量
-(void)updateShopCarNum{
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey]
                          };
    [_request requestWithMethod:YJYRequstMethodGet api:GET_SHOPPINGCAR_NUM parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _shopCarDic = result;
        
        if (_shopCarNumLabel) {
            
            int num = [[NSString stringWithFormat:@"%d",[_shopCarDic intValueForKey:@"num"]]intValue];
            NSString *num_str;
            if (num >= 100) {
                num_str = @"99+";
            }else{
                num_str = [NSString stringWithFormat:@"%d",num];
            }
            _shopCarNumLabel.text = num_str;
            [self updateShopCarNumAndFrame];
        }
        
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
}



//根据城市查询品牌列表
-(void)prepareBrandListWithLocation{
    
    //商城首页品牌跳转 单品详情页品牌跳转
    if ([self.brand_id intValue] > 0) {
        //过滤掉其他品牌
        if ([LTools isEmpty:self.brand_name]) {
            self.brand_name = @"其他品牌";
        }
        NSDictionary *dic = @{@"brand_id":self.brand_id,
                              @"brand_name":self.brand_name
                              };
        self.brand_city_list = @[dic];
        return;
    }
    
}


#pragma mark - 视图创建

-(void)creatTab{
    
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64-50) style:UITableViewStylePlain];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    [self creatTabHeaderView];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];
    [_table showRefreshHeader:YES];
    
}


-(void)creatTabHeaderView{
    _tabHeaderView = [[GBrandTabHeaderView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 100)];
    __weak typeof (self)bself = self;
    
    _fourBtn_sectionHeaderView = [_tabHeaderView getFourBtnView];
    
    [_tabHeaderView setFourBtnClickedBlock:^(NSInteger index, BOOL state) {
        [bself fourBtnClicked:index isSelect:state];
    }];
    
    [_tabHeaderView setClassImvClickedBlock:^(NSInteger index) {
        [bself classImvClicked:index];
    }];
    
    [_tabHeaderView setBannerImvClickedBlock:^{
        [bself brandBannerClicked];
    }];
    
    _table.tableHeaderView = _tabHeaderView;
    
}

-(void)brandBannerClicked{
    BrandDetailViewController *cc = [[BrandDetailViewController alloc]init];
    cc.brand_id = self.brand_id;
    [self.navigationController pushViewController:cc animated:YES];
}

-(void)classImvClicked:(NSInteger)theIndex{
    NSArray *arr = [_classDic arrayValueForKey:@"data"];
    NSDictionary *dic = arr[theIndex-100];
    GoneClassListViewController *cc = [[GoneClassListViewController alloc]init];
    cc.brand_id = self.brand_id;
    cc.brand_name = self.brand_name;
    int categoryid = [[dic stringValueForKey:@"category_id"]intValue];
    cc.category_id = categoryid;
    
    if (categoryid == 6 || categoryid == 4) {// 6:精英男士 4:都市丽人
        cc.haveChooseGender = NO;
    }else{
        cc.haveChooseGender = YES;
    }
    
    [self.navigationController pushViewController:cc animated:YES];
    
}


-(void)fourBtnClicked:(NSInteger)theIndex isSelect:(BOOL)state{
    if (theIndex == 13){//价格
        if (state) {//升序
        }else{//降序
        }
        _priceState = state;
    }
    
    [_table refreshNewData];
}


-(void)creatUpToolView{
    
    _upToolView = [[GUpToolView alloc]initWithFrame:CGRectZero count:4];
    [self.view addSubview:_upToolView];
    __weak typeof (self)bself = self;
    [_upToolView setUpToolViewBlock:^(NSInteger index) {
        [bself upToolBtnClicked:index];
    }];
}

//创建下层四个按钮view
-(void)creatDownBtnView{
    
    _downView = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 50-64, DEVICE_WIDTH, 50)];
    _downView.backgroundColor = RGBCOLOR(38, 51, 62);
    [self.view addSubview:_downView];
    
    
    CGFloat tw = _downView.frame.size.width/4;
    NSArray *titleArray = @[@"客服",@"收藏",@"筛选",@"购物车"];
    NSArray *imageNameArray = @[@"kefu_pd.png",@"shoucangjia.png",@"shaixuan_white.png",@"gouwuche_pd.png"];
    for (int i = 0; i<4; i++) {
        UIButton *oneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [oneBtn setFrame:CGRectMake(i*tw, 0, tw, 50)];
        [oneBtn setTitle:titleArray[i] forState:UIControlStateNormal];
        [oneBtn setImage:[UIImage imageNamed:imageNameArray[i]] forState:UIControlStateNormal];
        
        if (i<3) {
            [oneBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 17, 25, 0)];
        }else{
            if (DEVICE_WIDTH<375) {//4s 5s
                [oneBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 22, 25, 17)];
            }else{
                [oneBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 25, 25, 0)];
            }
            
        }
        
        [oneBtn setTitleEdgeInsets:UIEdgeInsetsMake(25, -20, 0, 0)];
        oneBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        oneBtn.tag = 100+i;
        [oneBtn addTarget:self action:@selector(downBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_downView addSubview:oneBtn];
        
        if (i == 3) {
            _shopCarNumLabel = [[UILabel alloc]initWithFrame:CGRectZero];
            _shopCarNumLabel.textColor = RGBCOLOR(242, 120, 47);
            _shopCarNumLabel.backgroundColor = [UIColor whiteColor];
            _shopCarNumLabel.layer.cornerRadius = 5;
            _shopCarNumLabel.layer.borderColor = [[UIColor whiteColor]CGColor];
            _shopCarNumLabel.layer.borderWidth = 0.5f;
            _shopCarNumLabel.layer.masksToBounds = YES;
            _shopCarNumLabel.font = [UIFont systemFontOfSize:8];
            _shopCarNumLabel.textAlignment = NSTextAlignmentCenter;
            _shopCarNumLabel.text = [NSString stringWithFormat:@"0"];
            [oneBtn addSubview:_shopCarNumLabel];
        }
        
    }
    [self.view addSubview:_downView];
}



- (void)setupNavigation{
    
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
    self.searchTf.placeholder = @"在店内搜索您要找的商品";
    self.searchTf.delegate = self;
    self.searchTf.returnKeyType = UIReturnKeySearch;
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
    _pushView.tab4.tableFooterView = nil;
    [self.rightSideBar setContentViewInSideBar:_pushView];
    
}


//创建搜索界面
-(void)creatMysearchView{
    
    _mySearchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    _mySearchView.backgroundColor = [UIColor blackColor];
    _mySearchView.alpha = 0.3;
    [_mySearchView addTapGestureTaget:self action:@selector(myNavcRightBtnClicked) imageViewTag:0];
    _mySearchView.hidden = YES;
    [self.view addSubview:_mySearchView];
    
    
    
}



#pragma mark - RefreshDelegate && UITableViewDataSource

- (void)loadNewDataForTableView:(UITableView *)tableView{
    [self prepareNetDataWithDic:self.shaixuanDic];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView{
    [self prepareNetDataWithDic:self.shaixuanDic];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = 1;
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    num = _table.dataArray.count;
    return num;
}


- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    CGFloat height = 0;
    height = [GProductCellTableViewCell getCellHight];
    return height;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    height = 42;
    return height;
}

-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    return height;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    view = _fourBtn_sectionHeaderView;
    return view;
}

-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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



- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    
    GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
    ProductModel *model = _table.dataArray[indexPath.row];
    cc.productId = model.product_id;
    cc.userChooseLocationDic = self.shaixuanDic;
    [self.navigationController pushViewController:cc animated:YES];

    
}



- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self controlTopButtonWithScrollView:scrollView];
    
}

#pragma mark - 网络请求

-(void)prepareBrandDetail{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic safeSetString:self.brand_id forKey:@"brand_id"];
    
    [_request requestWithMethod:YJYRequstMethodGet api:StoreHomeDetail parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        [_tabHeaderView reloadViewWithBrandDic:result classDic:nil];
        _table.tableHeaderView = _tabHeaderView;
    } failBlock:^(NSDictionary *result) {
        
    }];
    
    
    
    [_request requestWithMethod:YJYRequstMethodGet api:StoreProductClass parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        _classDic = result;
        [_tabHeaderView reloadViewWithBrandDic:nil classDic:result];
        _table.tableHeaderView = _tabHeaderView;
    } failBlock:^(NSDictionary *result) {
        
    }];
    
    NSDictionary *liulanliangDic = @{
                          @"brand_id":self.brand_id
                          };
    [_request requestWithMethod:YJYRequstMethodGet api:BrandStoreLiulanliangNumAdd parameters:liulanliangDic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        DDLOG(@"品牌店浏览量+1");
        
    } failBlock:^(NSDictionary *result) {
        
    }];
    
    
    
    
}


-(void)prepareNetDataWithDic:(NSDictionary *)theDic{
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSDictionary *dic;
    
    if (theDic) {
        NSMutableDictionary *temp_dic = [NSMutableDictionary dictionaryWithDictionary:theDic];
        [temp_dic setObject:NSStringFromInt(_table.pageNum) forKey:@"page"];
        [temp_dic setObject:NSStringFromInt(PAGESIZE_MID) forKey:@"per_page"];
        [temp_dic setObject:self.brand_id forKey:@"brand_id"];
        dic = temp_dic;
        
        
    }else{
        
        NSMutableDictionary *temp_dic = [NSMutableDictionary dictionaryWithCapacity:1];
        [temp_dic safeSetString:[GMAPI getCurrentProvinceId] forKey:@"province_id"];
        [temp_dic safeSetString:[GMAPI getCurrentCityId] forKey:@"city_id"];
        [temp_dic safeSetString:NSStringFromInt(_table.pageNum) forKey:@"page"];
        [temp_dic safeSetString:NSStringFromInt(PAGESIZE_MID) forKey:@"per_page"];
        [temp_dic safeSetString:self.brand_id forKey:@"brand_id"];
        
        dic = temp_dic;
        
    }
    
    
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    
    for (UIButton *btn in _tabHeaderView.fourBtnArray) {
        if (btn.selected) {
            if (btn.tag == 10) {//推荐
                [tempDic safeSetString:@"recommend" forKey:@"order_field"];
            }else if (btn.tag == 11){//热销
                [tempDic safeSetString:@"sale_num" forKey:@"order_field"];
            }else if (btn.tag == 12){//新品
                [tempDic safeSetString:@"new_product" forKey:@"order_field"];
            }else if (btn.tag == 13){//价格
                [tempDic safeSetString:@"sale_price" forKey:@"order_field"];
                if (_priceState) {
                    [tempDic safeSetString:@"asc" forKey:@"order_direct"];//升序
                }else{
                    [tempDic safeSetString:@"desc" forKey:@"order_direct"];//降序
                }
                
            }
        }
    }
    
    dic = tempDic;
    
    
    [_request requestWithMethod:YJYRequstMethodGet api:StoreProductList parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *arr = [result arrayValueForKey:@"data"];
        
        _productOneClassArray = [NSMutableArray arrayWithCapacity:1];
        
        for (NSDictionary *dic in arr) {
            ProductModel *model = [[ProductModel alloc]initWithDictionary:dic];
            [_productOneClassArray addObject:model];
        }
        
        [_table reloadData:_productOneClassArray pageSize:PAGESIZE_MID];
        
    } failBlock:^(NSDictionary *result) {
        [_table loadFail];
    }];
    
    
}






#pragma mark - 改变searchTf和框的大小
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
            _rightItem2Btn.titleLabel.font = [UIFont systemFontOfSize:13];
            [_rightItem2Btn setTitleColor:RGBCOLOR(134, 135, 136) forState:UIControlStateNormal];
            [_rightItem2Btn setImage:[UIImage imageNamed:@"dian_three.png"] forState:UIControlStateNormal];
            [_rightItem2Btn setTitle:nil forState:UIControlStateNormal];
            
            [_rightItem2Btn addTarget:self action:@selector(myNavcRightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [_searchView addSubview:_rightItem2Btn];
        }else{
            [_rightItem2Btn setFrame:CGRectMake(_searchView.frame.size.width - 45, 0, 45, 30)];
            [_rightItem2Btn setImage:[UIImage imageNamed:@"dian_three.png"] forState:UIControlStateNormal];
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
        
        [self.view removeGestureRecognizer:_panGestureRecognizer];
        
    }
    
    [self.navigationController.navigationBar bringSubviewToFront:_searchView];
    
}

#pragma mark - 点击处理
//工具栏按钮点击
-(void)upToolBtnClicked:(NSInteger)index{
    if (index == 20) {//足迹
        if ([LoginViewController isLogin]) {
            GmyFootViewController *cc = [[GmyFootViewController alloc]init];
            [self.navigationController pushViewController:cc animated:YES];
        }else{
            [LoginViewController isLogin:self loginBlock:^(BOOL success) {
                if (success) {
                    GmyFootViewController *cc = [[GmyFootViewController alloc]init];
                    [self.navigationController pushViewController:cc animated:YES];
                }
                
            }];
        }
        
    }else if (index == 21){//搜索
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)myNavcRightBtnClicked{
    
    if (_searchState == 0) {
        _toolShow = !_toolShow;
        
        if (_toolShow) {
            
            [UIView animateWithDuration:0.2 animations:^{
                [_upToolView setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
            } completion:^(BOOL finished) {
                if (!_downToolBlackView) {
                    _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
                    _downToolBlackView.backgroundColor = [UIColor blackColor];
                    _downToolBlackView.alpha = 0.6;
                    [self.view addSubview:_downToolBlackView];
                    
                    [_downToolBlackView addTapGestureTaget:self action:@selector(upToolShou) imageViewTag:0];
                }
                _downToolBlackView.hidden = NO;
            }];
            
            
        }else{
            if (!_downToolBlackView) {
                _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
                _downToolBlackView.backgroundColor = [UIColor blackColor];
                _downToolBlackView.alpha = 0.6;
                [self.view addSubview:_downToolBlackView];
            }
            _downToolBlackView.hidden = YES;
            
            
            [UIView animateWithDuration:0.2 animations:^{
                [_upToolView setFrame:CGRectMake(0, -50, DEVICE_WIDTH, 50)];
            }];
        }
    }else if (_searchState == 1){
        [self changeSearchViewAndKuangFrameAndTfWithState:0];
        [_searchTf resignFirstResponder];
        _mySearchView.hidden = YES;
    }
    
    
}


-(void)upToolShou{
    
    if (_toolShow) {
        if (!_downToolBlackView) {
            _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
            _downToolBlackView.backgroundColor = [UIColor blackColor];
            _downToolBlackView.alpha = 0.6;
            [self.view addSubview:_downToolBlackView];
        }
        _downToolBlackView.hidden = YES;
        
        
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, -50, DEVICE_WIDTH, 50)];
        }];
        
        _toolShow = !_toolShow;
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
        } completion:^(BOOL finished) {
            if (!_downToolBlackView) {
                _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
                _downToolBlackView.backgroundColor = [UIColor blackColor];
                _downToolBlackView.alpha = 0.6;
                [self.view addSubview:_downToolBlackView];
                
                [_downToolBlackView addTapGestureTaget:self action:@selector(upToolShou) imageViewTag:0];
            }
            _downToolBlackView.hidden = NO;
        }];
        _toolShow = !_toolShow;
    }
}


-(void)hotSearchBtnClicked:(UIButton *)sender{
    NSLog(@"%d",(int)sender.tag);
}


-(void)downBtnClicked:(UIButton *)sender{
    
    if (sender.tag == 100) {//客服
        
        
        [LoginManager isLogin:self loginBlock:^(BOOL success) {
            if (success) {
                [self clickToChat];
            }else
            {
                _isPresenting = YES;
                
            }
        }];
        
    }else if (sender.tag == 101){//收藏
        
        [LoginManager isLogin:self loginBlock:^(BOOL success) {
            if (success)
            {
                ProductListViewController *cc = [[ProductListViewController alloc]init];
                [self.navigationController pushViewController:cc animated:YES];
            }else
            {
                _isPresenting = YES;
                
            }
        }];
        
    }else if (sender.tag == 102){//筛选
        
        
        [self.rightSideBar show];
        
        
    }else if (sender.tag == 103){//购物车
        
        [LoginManager isLogin:self loginBlock:^(BOOL success) {
            if (success)
            {
                GShopCarViewController *cc = [[GShopCarViewController alloc]init];
                [self.navigationController pushViewController:cc animated:YES];
            }else
            {
                _isPresenting = YES;
                
            }
        }];
        
    }
}

- (void)clickToChat
{
    [MiddleTools pushToChatWithSourceType:SourceType_Normal fromViewController:self model:nil];
}


#pragma mark - 返回上个界面
-(void)gogoback{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"%s",__FUNCTION__);
    _mySearchView.hidden = NO;
    
    [self changeSearchViewAndKuangFrameAndTfWithState:1];
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (![LTools isEmpty:self.searchTf.text]) {
        [self searchBtnClickedWithStr:self.searchTf.text isHotSearch:NO];
        [self changeSearchViewAndKuangFrameAndTfWithState:0];
        [_searchTf resignFirstResponder];
        _mySearchView.hidden = YES;
    }
    
    
    return YES;
}


#pragma mark - GsearchViewDelegate

-(void)setEffectViewAlpha:(CGFloat)theAlpha{
    UIView *effectView = self.currentNavigationBar.effectContainerView;
    if (effectView) {
        UIView *alphaView = [effectView viewWithTag:10000];
        alphaView.alpha = theAlpha;
    }
}

-(void)searchBtnClickedWithStr:(NSString*)theWord isHotSearch:(BOOL)isHot{
    
    [_searchTf resignFirstResponder];
    
    if (!isHot) {
        if (![LTools isEmpty:self.searchTf.text]) {
            [GMAPI setuserCommonlyUsedSearchWord:self.searchTf.text];
        }
    }
    
    BrandSearchViewController *cc = [[BrandSearchViewController alloc]init];
    cc.brand_id = self.brand_id;
    cc.brand_name = self.brand_name;
    cc.theSearchWorld = theWord;
    [self.navigationController pushViewController:cc animated:YES];
    self.searchTf.text = nil;
    
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



#pragma mark - 代理方法

-(void)shaixuanFinishWithDic:(NSDictionary *)dic{
    BrandSearchViewController *cc = [[BrandSearchViewController alloc]init];
    cc.brand_id = self.brand_id;
    cc.brand_name = self.brand_name;
    cc.shaixuanDic = dic;
    [self.navigationController pushViewController:cc animated:YES];
}

-(void)therightSideBarDismiss{
    
    [self.rightSideBar dismiss];
}


@end
