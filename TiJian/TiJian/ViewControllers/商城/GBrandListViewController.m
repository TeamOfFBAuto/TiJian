//
//  GBrandListViewController.m
//  TiJian
//
//  Created by gaomeng on 16/1/26.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GBrandListViewController.h"
#import "ProductListViewController.h"
#import "GShopCarViewController.h"
#import "ProductModel.h"
#import "StoreHomeOneBrandModel.h"
#import "GUpToolView.h"
#import "GCustomSearchViewController.h"
#import "GmyFootViewController.h"
#import "GProductCellTableViewCell.h"
#import "GoneClassListViewController.h"
#import "GproductDetailViewController.h"
#import "GTranslucentSideBar.h"
#import "GPushView.h"
#import "GBrandHomeViewController.h"

@interface GBrandListViewController ()<RefreshDelegate,UITableViewDataSource,GTranslucentSideBarDelegate,GpushViewDelegate>
{
    RefreshTableView *_rTab;
    YJYRequstManager *_request;
    
    UIView *_downView;
    UILabel *_shopCarNumLabel;
    
    BOOL _isPresenting;//是否在模态
    
    NSMutableArray *_StoreProductListArray;
    
    BOOL _toolShow;
    
    //顶部工具栏
    GUpToolView *_upToolView;
    
    UIView *_downToolBlackView;
    
    //轻扫手势
    UIPanGestureRecognizer *_panGestureRecognizer;
    
    GPushView *_pushView;//筛选view
    UIView *_backBlackView;//筛选界面下面的黑色透明view
    
    NSDictionary *_shopCarDic;
    int _gouwucheNum;//购物车里商品数量
    
}

@property (nonatomic, strong) GTranslucentSideBar *rightSideBar;

@end


@implementation GBrandListViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_UPDATE_TO_CART object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_LOGIN object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeOther];
    self.myTitle = self.className;
    
    self.rightImage = [UIImage imageNamed:@"dian_three.png"];
    
    _backBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    _backBlackView.backgroundColor = [UIColor blackColor];
    _backBlackView.alpha = 0.5;
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateShopCarNum) name:NOTIFICATION_UPDATE_TO_CART object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateShopCarNum) name:NOTIFICATION_LOGIN object:nil];
    
    
    [self creatRtab];
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

//登录成功更新购物车数量
-(void)updateShopCarNum{
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey]
                          };
     [_request requestWithMethod:YJYRequstMethodGet api:GET_SHOPPINGCAR_NUM parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _shopCarDic = result;
        
        if (_shopCarNumLabel) {
            
            _shopCarNumLabel.text = [NSString stringWithFormat:@"%d",[_shopCarDic intValueForKey:@"num"]];
            _gouwucheNum = [_shopCarDic intValueForKey:@"num"];
            
            [self updateShopCarNumAndFrame];
        }
        
        
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
}



#pragma mark - 视图创建
-(void)creatRtab{
    _rTab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 50) style:UITableViewStyleGrouped];
    _rTab.refreshDelegate = self;
    _rTab.dataSource = self;
    [self.view addSubview:_rTab];
    _rTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_rTab showRefreshHeader:YES];
    
}

-(void)creatUpToolView{
    
    _upToolView = [[GUpToolView alloc]initWithFrame:CGRectZero count:3];
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
            _shopCarNumLabel.layer.cornerRadius = 7;
            _shopCarNumLabel.layer.borderColor = [[UIColor whiteColor]CGColor];
            _shopCarNumLabel.layer.borderWidth = 0.5f;
            _shopCarNumLabel.layer.masksToBounds = YES;
            _shopCarNumLabel.font = [UIFont systemFontOfSize:11];
            _shopCarNumLabel.textAlignment = NSTextAlignmentCenter;
            _shopCarNumLabel.text = [NSString stringWithFormat:@"0"];
            
            [oneBtn addSubview:_shopCarNumLabel];
            
            
        }
        
    }
    [self.view addSubview:_downView];
}


//创建侧滑栏
-(void)creatRightTranslucentSideBar{
    
    // Create Right SideBar
    self.rightSideBar = [[GTranslucentSideBar alloc] initWithDirection:YES];
    self.rightSideBar.delegate = self;
    self.rightSideBar.sideBarWidth = DEVICE_WIDTH*670.0/750;
    self.rightSideBar.translucentStyle = UIBarStyleBlack;
    self.rightSideBar.tag = 1;
    
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:_panGestureRecognizer];
    
    //避免滑动返回手势与此冲突
    [_panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    
    
    
    _pushView = [[GPushView alloc]initWithFrame:CGRectMake(0, 0, self.rightSideBar.sideBarWidth, self.rightSideBar.view.frame.size.height)gender:self.haveChooseGender isHaveShaixuanDic:self.shaixuanDic];
    _pushView.delegate = self;
    [self.rightSideBar setContentViewInSideBar:_pushView];
    
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




#pragma mark - 点击处理

-(void)rightButtonTap:(UIButton *)sender{
    
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



//工具栏按钮点击
-(void)upToolBtnClicked:(NSInteger)index{
    if (index == 10) {//足迹
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
        
    }else if (index == 11){//搜索
        GCustomSearchViewController *cc = [[GCustomSearchViewController alloc]init];
        [self.navigationController pushViewController:cc animated:YES];
    }else if (index == 12){//首页
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
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




-(void)viewForHeaderClicked:(UIButton*)sender{
    
    NSInteger index = sender.tag - 20000;
    StoreHomeOneBrandModel *model_b = _rTab.dataArray[index];
    
    GBrandHomeViewController *cc = [[GBrandHomeViewController alloc]init];
    cc.brand_name = model_b.brand_name;
    cc.brand_id = model_b.brand_id;
    [self.navigationController pushViewController:cc animated:YES];
    

    
    
}


#pragma mark - RefreshDelegate && UITableViewDataSource

- (void)loadNewDataForTableView:(UITableView *)tableView{
    [self prepareNetDataWithDic:self.shaixuanDic];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView{
    [self prepareNetDataWithDic:self.shaixuanDic];
}


- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self controlTopButtonWithScrollView:scrollView];
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = 0;
    num = _rTab.dataArray.count;
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    StoreHomeOneBrandModel *model = _rTab.dataArray[section];
    num = model.list.count;
    return num;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(RefreshTableView *)tableView{
    
    CGFloat height = 0;
    if (section == 0) {
        height = 40;
    }else{
        height = 45;
    }
    
    return height;
}

- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    height = [GProductCellTableViewCell getCellHight];
    return height;
}

-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    return height;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(RefreshTableView *)tableView{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 45)];
    if (section == 0) {
        [view setHeight:40];
    }
    view.backgroundColor = [UIColor whiteColor];
    
    if (section != 0) {
        UIView *upLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5)];
        upLine.backgroundColor = RGBCOLOR(244, 245, 246);
        [view addSubview:upLine];
    }
    
    
    
    //数据源
    StoreHomeOneBrandModel *model_b = _rTab.dataArray[section];
    
    UIImageView *logoImv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 15, 20, 20)];
    if (section == 0) {
        [logoImv setFrame:CGRectMake(10, 10, 20, 20)];
    }
    [logoImv l_setImageWithURL:[NSURL URLWithString:model_b.brand_logo] placeholderImage:nil];
    logoImv.layer.cornerRadius = 10;
    [view addSubview:logoImv];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(logoImv.right + 5, logoImv.frame.origin.y, DEVICE_WIDTH - 10 - 20 - 5 - 10 - 8 - 5, 20)];
    titleLabel.font = [UIFont systemFontOfSize:12];
    
    [view addSubview:titleLabel];
    
    //向右箭头
    if (model_b.list.count>0) {
        UIImageView *jiantouImv = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 18, 17, 8, 15)];
        
        if (section == 0) {
            [jiantouImv setFrame:CGRectMake(DEVICE_WIDTH - 18, 12, 8, 15)];
        }
        
        [jiantouImv setImage:[UIImage imageNamed:@"personal_jiantou_small.png"]];
        [view addSubview:jiantouImv];
        
        titleLabel.text = model_b.brand_name;
        
        [view addTaget:self action:@selector(viewForHeaderClicked:) tag:section+20000];
        
    }else{
        NSString *str1 = model_b.brand_name;
        NSString *str2 = @"(暂无更多套餐)";
        NSString *str = [NSString stringWithFormat:@"%@ %@",str1,str2];
        
        NSMutableAttributedString *str_a = [[NSMutableAttributedString alloc] initWithString:str];
        
        [str_a addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,str1.length)];
        [str_a addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(str1.length+1,str2.length)];
        [str_a addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, str1.length)];
        [str_a addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(str1.length+1, str2.length)];
        
        titleLabel.attributedText = str_a;
    }

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
    
    StoreHomeOneBrandModel *brandModel = _rTab.dataArray[indexPath.section];
    
    ProductModel *model = brandModel.list[indexPath.row];
    
    [cell loadData:model];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}



- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    NSLog(@"%s",__FUNCTION__);
    GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
    
    StoreHomeOneBrandModel *model_b = _rTab.dataArray[indexPath.section];
    ProductModel *aModel = model_b.list[indexPath.row];
    cc.productId = aModel.product_id;
    [self.navigationController pushViewController:cc animated:YES];
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
            
            _shopCarNumLabel.text = [NSString stringWithFormat:@"%d",[_shopCarDic intValueForKey:@"num"]];
            
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
        [_shopCarNumLabel setMatchedFrame4LabelWithOrigin:CGPointMake(0, 0) height:11 limitMaxWidth:45];
        CGFloat with = _shopCarNumLabel.frame.size.width + 5;
        UIButton *oneBtn = (UIButton*)[_downView viewWithTag:103];
        [_shopCarNumLabel setFrame:CGRectMake(oneBtn.bounds.size.width - with-20, -2, with+5, 15)];
        
    }
    
}



-(void)prepareNetDataWithDic:(NSDictionary *)theDic{
    
    NSDictionary *dic = [NSDictionary dictionary];
    
    if (theDic) {
        NSMutableDictionary *temp_dic = [NSMutableDictionary dictionaryWithDictionary:theDic];
        [temp_dic setObject:[NSString stringWithFormat:@"%d",_rTab.pageNum] forKey:@"page"];
        [temp_dic setObject:@"5" forKey:@"per_page"];
        [temp_dic setObject:@"2" forKey:@"show_type"];
        [temp_dic setObject:self.class_Id forKey:@"category_id"];
        dic = temp_dic;
        
    }else{
        dic = @{
                @"province_id":[GMAPI getCurrentProvinceId],
                @"city_id":[GMAPI getCurrentCityId],
                @"page":[NSString stringWithFormat:@"%d",_rTab.pageNum],
                @"per_page":@"5",
                @"show_type":@"2",
                @"category_id":self.class_Id
                };
    }
    
    
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
     [_request requestWithMethod:YJYRequstMethodGet api:StoreProductList parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _StoreProductListArray = [NSMutableArray arrayWithCapacity:1];
        NSArray *data = [result arrayValueForKey:@"data"];
        
        for (NSDictionary *dic in data) {
            NSArray *list = [dic arrayValueForKey:@"list"];
            NSMutableArray *model_listArray = [NSMutableArray arrayWithCapacity:1];
            for (NSDictionary *dic in list) {
                ProductModel *model = [[ProductModel alloc]initWithDictionary:dic];
                [model_listArray addObject:model];
            }
            StoreHomeOneBrandModel *model_b = [[StoreHomeOneBrandModel alloc]initWithDictionary:dic];
            model_b.list = model_listArray;
            [_StoreProductListArray addObject:model_b];
        }
        
         
         
         [_rTab reloadData:_StoreProductListArray pageSize:5 noDataView:[self resultViewWithType:PageResultType_nodata]];
        
        
    } failBlock:^(NSDictionary *result) {
        [_rTab reloadData:nil pageSize:5 noDataView:[self resultViewWithType:PageResultType_nodata]];
        
    }];
    
}


//根据城市查询品牌列表
-(void)prepareBrandListWithLocation{
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    [_request requestWithMethod:YJYRequstMethodGet api:BrandList_oneClass parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *arr = [result arrayValueForKey:@"data"];
        self.brand_city_list = [NSArray arrayWithArray:arr];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
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


#pragma mark - gpushview代理方法
-(void)therightSideBarDismiss{
    
    [self.rightSideBar dismiss];
}

-(void)shaixuanFinishWithDic:(NSDictionary *)dic{
    self.shaixuanDic = dic;
    
    GoneClassListViewController *cc = [[GoneClassListViewController alloc]init];
    cc.isShowShaixuanData = YES;
    cc.shaixuanDic = self.shaixuanDic;
    [self.navigationController pushViewController:cc animated:YES];
}




@end
