//
//  BrandSearchViewController.m
//  TiJian
//
//  Created by gaomeng on 16/2/26.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "BrandSearchViewController.h"
#import "DLNavigationEffectKit.h"
#import "GTranslucentSideBar.h"
#import "ProductModel.h"
#import "GProductCellTableViewCell.h"
#import "GPushView.h"

@interface BrandSearchViewController ()<UITextFieldDelegate,RefreshDelegate,UITableViewDataSource,GTranslucentSideBarDelegate,GpushViewDelegate>
{
    UIView *_searchView;
    UIView *_kuangView;
    int _searchState;
    UIButton *_rightItem2Btn;
    UIBarButtonItem *_rightItem1;
    //轻扫手势
    UIPanGestureRecognizer *_panGestureRecognizer;
    UIView *_mySearchView;//点击搜索盖上的搜索浮层
    
    UIView *_backBlackView;//筛选界面下面的黑色透明view
    
    RefreshTableView *_rTab;
    YJYRequstManager *_request;
    NSMutableArray *_productOneClassArray;
    BOOL _priceState;
    
    GPushView *_pushView;
    
}


@property (nonatomic, strong) GTranslucentSideBar *rightSideBar;


@end

@implementation BrandSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _backBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    _backBlackView.backgroundColor = [UIColor blackColor];
    _backBlackView.alpha = 0.5;
    _searchState = 0;
    
    self.haveChooseGender = YES;
    
    if ([self.brand_id intValue] > 0) {
        //过滤掉其他品牌
        if ([LTools isEmpty:self.brand_name]) {
            self.brand_name = @"其他品牌";
        }
        NSDictionary *dic = @{@"brand_id":self.brand_id,
                              @"brand_name":self.brand_name
                              };
        self.brand_city_list = @[dic];
    }
    
    
    
    //视图创建
    [self setupNavigation];
    [self creatRightTranslucentSideBar];
    [self getFourBtnView];
    [self creatTab];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - 视图创建

//创建tab
-(void)creatTab{
    _rTab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 42, DEVICE_WIDTH, DEVICE_HEIGHT-64-42) style:UITableViewStylePlain];
    _rTab.refreshDelegate = self;
    _rTab.dataSource = self;
    _rTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_rTab];
    [_rTab refreshNewData];
    
}

-(void)getFourBtnView{
    //四个按钮view
    self.fourBtnView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 42)];
    self.fourBtnView.backgroundColor = [UIColor whiteColor];
    CGFloat width = DEVICE_WIDTH/4-0.5;
    NSArray *titleArray = @[@"推荐",@"热销",@"新品",@"价格"];
    
    self.fourBtnArray = [NSMutableArray arrayWithCapacity:1];
    
    for (int i = 0; i<4; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake((width+0.5)*i, 0.5, width, 37)];
        
        //竖线
        UIView *fenLine = [[UIView alloc]initWithFrame:CGRectMake(width*i-0.5, 8, 0.5, 23)];
        fenLine.backgroundColor = RGBCOLOR(226, 228, 229);
        [self.fourBtnView addSubview:fenLine];
        
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitleColor:RGBCOLOR(80, 81, 82) forState:UIControlStateNormal];
        [btn setTitleColor:RGBCOLOR(116, 162, 208) forState:UIControlStateSelected];
        
        
        if (i == 0) {
            btn.selected = YES;
        }else if (i == 3){
            [btn setImage:[UIImage imageNamed:@"pricejiantou_down.png"] forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -width+15)];
        }
        btn.backgroundColor = [UIColor whiteColor];
        btn.tag = 10+i;
        [btn addTarget:self action:@selector(forBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.fourBtnView addSubview:btn];
        [self.fourBtnArray addObject:btn];
    }
    
    //分割线
    UIView *upLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.5)];
    upLine.backgroundColor = RGBCOLOR(244, 245, 246);
    [self.fourBtnView addSubview:upLine];
    
    UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(0, 37, DEVICE_WIDTH, 5)];
    downLine.backgroundColor = RGBCOLOR(244, 245, 246);
    [self.fourBtnView addSubview:downLine];
    
    [self.view addSubview:self.fourBtnView];
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




-(void)forBtnClicked:(UIButton *)sender{
    sender.selected = YES;
    NSInteger theTag = sender.tag;

    for (UIButton *btn in self.fourBtnArray) {
        if (btn.tag != theTag) {
            btn.selected = NO;
        }
    }

    if (sender.selected && theTag == 13){
        _priceState = !_priceState;
        if (_priceState) {//升序
            [sender setImage:[UIImage imageNamed:@"pricejiantou_up.png"] forState:UIControlStateNormal];
        }else{//降序
            [sender setImage:[UIImage imageNamed:@"pricejiantou_down.png"] forState:UIControlStateNormal];
        }
        
    }
    
    [self fourBtnClicked:theTag isSelect:_priceState];
    
    
}


-(void)fourBtnClicked:(NSInteger)theIndex isSelect:(BOOL)state{
    if (theIndex == 13){//价格
        if (state) {//升序
        }else{//降序
        }
        _priceState = state;
    }
    
    [_rTab refreshNewData];
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
    self.searchTf.text = self.theSearchWorld;
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


-(void)myNavcRightBtnClicked{
    
    if (_searchState == 0) {
        [self.rightSideBar show];
    }else if (_searchState == 1){
        [self changeSearchViewAndKuangFrameAndTfWithState:0];
        [_searchTf resignFirstResponder];
        _mySearchView.hidden = YES;
    }
}


#pragma mark - 代理方法

-(void)shaixuanFinishWithDic:(NSDictionary *)dic{
    self.shaixuanDic = dic;
    [_rTab showRefreshHeader:YES];
}

-(void)therightSideBarDismiss{
    
    [self.rightSideBar dismiss];
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


#pragma mark - RefreshDelegate && UITableViewDataSource

- (void)loadNewDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = 1;
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    num = _productOneClassArray.count;
    return num;
}


- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    height = [GProductCellTableViewCell getCellHight];
    return height;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    return height;
}

-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    return height;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
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
    
    ProductModel *model = _rTab.dataArray[indexPath.row];
    
    [cell loadData:model];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}



- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    NSLog(@"%s",__FUNCTION__);
}

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%s",__FUNCTION__);
}



#pragma mark - 请求网络数据

-(void)prepareNetData{
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    
    NSMutableDictionary *temp_dic;
    
    if (self.shaixuanDic) {
        temp_dic = [NSMutableDictionary dictionaryWithDictionary:self.shaixuanDic];
    }else{
        temp_dic = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    
   
    [temp_dic safeSetString:[GMAPI getCurrentProvinceId] forKey:@"province_id"];
    [temp_dic safeSetString:[GMAPI getCurrentCityId] forKey:@"city_id"];
    [temp_dic safeSetString:NSStringFromInt(_rTab.pageNum)forKey:@"page"];
    [temp_dic safeSetString:NSStringFromInt(PAGESIZE_MID) forKey:@"per_page"];
    [temp_dic safeSetString:self.brand_id forKey:@"brand_id"];
    
    
    if (![LTools isEmpty:self.category_id]) {
        [temp_dic safeSetString:self.category_id forKey:@"category_id"];
    }
    
    if (![LTools isEmpty:self.searchTf.text]) {
        [temp_dic safeSetString:self.searchTf.text forKey:@"keywords"];
    }
    
    
    
    //四个按钮
    for (UIButton *btn in self.fourBtnArray) {
        if (btn.selected) {
            if (btn.tag == 10) {//推荐
                [temp_dic safeSetString:@"recommend" forKey:@"order_field"];
            }else if (btn.tag == 11){//热销
                [temp_dic safeSetString:@"sale_num" forKey:@"order_field"];
            }else if (btn.tag == 12){//新品
                [temp_dic safeSetString:@"new_product" forKey:@"order_field"];
            }else if (btn.tag == 13){//价格
                [temp_dic safeSetString:@"sale_price" forKey:@"order_field"];
                if (_priceState) {
                    [temp_dic safeSetString:@"asc" forKey:@"order_direct"];//升序
                }else{
                    [temp_dic safeSetString:@"desc" forKey:@"order_direct"];//降序
                }
                
            }
        }
    }

    
     [_request requestWithMethod:YJYRequstMethodGet api:StoreProductList parameters:temp_dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *arr = [result arrayValueForKey:@"data"];
        
        _productOneClassArray = [NSMutableArray arrayWithCapacity:1];
        
        for (NSDictionary *dic in arr) {
            ProductModel *model = [[ProductModel alloc]initWithDictionary:dic];
            [_productOneClassArray addObject:model];
        }
        
        [_rTab reloadData:_productOneClassArray pageSize:PAGESIZE_MID noDataView:[self resultViewWithType:PageResultType_nodata]];
        
        
    } failBlock:^(NSDictionary *result) {
        
        [_rTab reloadData:nil pageSize:PAGESIZE_MID noDataView:[self resultViewWithType:PageResultType_nodata]];
    }];
    
    
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
    
//    if (!isHot) {
//        if (![LTools isEmpty:self.searchTf.text]) {
//            [GMAPI setuserCommonlyUsedSearchWord:self.searchTf.text];
//        }
//    }
    if (![LTools isEmpty:self.searchTf.text]) {
        self.theSearchWorld = theWord;
        [_rTab showRefreshHeader:YES];
    }
    
//    BrandSearchViewController *cc = [[BrandSearchViewController alloc]init];
//    cc.brand_id = self.brand_id;
//    cc.brand_name = self.brand_name;
//    cc.theSearchWorld = theWord;
//    [self.navigationController pushViewController:cc animated:YES];
    
}




@end
