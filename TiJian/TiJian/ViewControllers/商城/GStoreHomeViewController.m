//
//  GStoreHomeViewController.m
//  TiJian
//
//  Created by gaomeng on 15/10/27.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GStoreHomeViewController.h"
#import "NSDictionary+GJson.h"
#import "RefreshTableView.h"
#import "CycleAdvModel.h"
#import "GoneClassListViewController.h"
#import "GproductDetailViewController.h"
#import "GProductCellTableViewCell.h"
#import "PhysicalTestResultController.h"
#import "PersonalCustomViewController.h"
#import "LBannerView.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+ProgressView.h"
#import "GShopCarViewController.h"
#import "DLNavigationEffectKit.h"
#import "GSearchView.h"
#import "RCDChatViewController.h"
#import "ProductListViewController.h"
#import "StoreHomeOneBrandModel.h"
#import "LocationChooseViewController.h"
#import "GBrandListViewController.h"
#import "GBrandHomeViewController.h"

@interface GStoreHomeViewController ()<RefreshDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewDelegate,GsearchViewDelegate>
{
    
    LBannerView *_bannerView;//轮播图
    
    
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_adv;
    AFHTTPRequestOperation *_request_ProductClass;
    AFHTTPRequestOperation *_request_ProductRecommend;
    AFHTTPRequestOperation *_request_hotSearch;
    
    RefreshTableView *_table;
    
    
    int _count;//网络请求个数
    
    NSDictionary *_StoreCycleAdvDic;//轮播图dic
    NSDictionary *_StoreProductClassDic;
    NSMutableArray *_StoreProductListArray;
    
    
    UIView *_mySearchView;//点击搜索盖上的搜索浮层
    
    
    UIView *_searchView;//输入框下层view
    
    UIView *_downView;//底部工具栏
    
    UILabel *_shopCarNumLabel;//购物车数量label
    
    
    GSearchView *_theCustomSearchView;//自定义搜索view
    
    
    NSArray *_hotSearchArray;//热门搜索
    
    UIBarButtonItem *_rightItem1;
//    UILabel *_rightItem2Label;
    UIView *_kuangView;
    
    
    //购物车数量
    AFHTTPRequestOperation *_request_GetShopCarNum;
    NSDictionary *_shopCarDic;
    int _gouwucheNum;//购物车里商品数量
    
    
    BOOL _isPresenting;//是否在模态
    
    
    UIButton *_myNavcRightBtn;
    int _editState;//0常态 1编辑状态
    
    
}

@property(nonatomic,strong)NSMutableArray *upAdvArray;

@property(nonatomic,strong)UIView *theTopView;

@end

@implementation GStoreHomeViewController


- (void)dealloc
{
    NSLog(@"dealloc %@",self);
    
    [_request removeOperation:_request_adv];
    [_request removeOperation:_request_ProductClass];
    [_request removeOperation:_request_ProductRecommend];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_UPDATE_TO_CART object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_LOGIN object:nil];
    
    [self removeObserver:self forKeyPath:@"_count"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self hiddenNavigationBar:YES animated:animated];
    
    _isPresenting = NO;
}


- (void)viewWillDisappear:(BOOL)animated
{
    //模态
    if (_isPresenting) {
        _isPresenting = NO;
        return;
    }
    
    [super viewWillDisappear:animated];
    
    [self hiddenNavigationBar:NO animated:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeText WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    
    self.leftString = @" ";
    
    [self addObserver:self forKeyPath:@"_count" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self hiddenNavigationBar:YES animated:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateShopCarNum) name:NOTIFICATION_UPDATE_TO_CART object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateIsFavorAndShopCarNum) name:NOTIFICATION_LOGIN object:nil];
    
    _editState = 0;
    
    [self creatTableView];
    [self setupNavigation];
    [self creatDownBtnView];
    [self creatMysearchView];
    [self getHotSearch];
    [self getshopcarNum];//购物车数量
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"%s",__FUNCTION__);
    _mySearchView.hidden = NO;
    _theCustomSearchView.dataArray = [GMAPI cacheForKey:USERCOMMONLYUSEDSEARCHWORD];
    
    [_theCustomSearchView.tab reloadData];
    
    
    [self changeSearchViewAndKuangFrameAndTfWithState:1];
    
//    if (!_rightItem2Label) {
//        _rightItem2Label = [[UILabel alloc]initWithFrame:CGRectMake(_searchView.frame.size.width - 45, 0, 45, 30)];
//        _rightItem2Label.text = @"取消";
//        _rightItem2Label.font = [UIFont systemFontOfSize:13];
//        _rightItem2Label.textColor = RGBCOLOR(134, 135, 136);
//        _rightItem2Label.textAlignment = NSTextAlignmentRight;
//        [_rightItem2Label addTaget:self action:@selector(myNavcRightBtnClicked) tag:0];
//    }
//    
//    [_searchView addSubview:_rightItem2Label];
    
    UIView *effectView = self.currentNavigationBar.effectContainerView;
    if (effectView) {
        UIView *alphaView = [effectView viewWithTag:10000];
        alphaView.alpha = 1;
    }
    
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    
//    [_searchView setWidth:DEVICE_WIDTH - 100];
    
    UIView *effectView = self.currentNavigationBar.effectContainerView;
    if (effectView) {
        UIView *alphaView = [effectView viewWithTag:10000];
        if (_table.contentOffset.y > 64) {
            CGFloat alpha = (_table.contentOffset.y -64)/200.0f;
            alpha = MIN(alpha, 1);
            alphaView.alpha = alpha;
        }else{
            alphaView.alpha = 0;
        }
    }
}




- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (![LTools isEmpty:self.searchTf.text]) {
        [self searchBtnClickedWithStr:self.searchTf.text isHotSearch:NO];
    }
    
    
    
    return YES;
}





-(void)searchBtnClickedWithStr:(NSString*)theWord isHotSearch:(BOOL)isHot{
    
    [self changeSearchViewAndKuangFrameAndTfWithState:0];
    
    [_searchTf resignFirstResponder];
    _mySearchView.hidden = YES;
    UIView *effectView = self.currentNavigationBar.effectContainerView;
    if (effectView) {
        UIView *alphaView = [effectView viewWithTag:10000];
        if (_table.contentOffset.y > 64) {
            CGFloat alpha = (_table.contentOffset.y -64)/200.0f;
            alpha = MIN(alpha, 1);
            alphaView.alpha = alpha;
        }else{
            alphaView.alpha = 0;
        }
    }
    
    if (!isHot) {
        if (![LTools isEmpty:self.searchTf.text]) {
            [GMAPI setuserCommonlyUsedSearchWord:self.searchTf.text];
        }
        
    }
    
    
    
    GoneClassListViewController *cc = [[GoneClassListViewController alloc]init];
    cc.theSearchWorld = theWord;
    [self.navigationController pushViewController:cc animated:YES];
    
    
}


#pragma mark - 返回上个界面
-(void)gogoback{
    [self.navigationController popViewControllerAnimated:YES];
}




#pragma mark - 缓存
-(void)loadCache{
    
    
    _StoreCycleAdvDic = [GMAPI cacheForKey:@"GStoreHomeVc_StoreCycleAdvDic"];
    
    _StoreProductClassDic = [GMAPI cacheForKey:@"GStoreHomeVc_StoreProductClassDic"];
    
    NSDictionary *storeProductListDic = [GMAPI cacheForKey:@"GStoreHomeVc_StoreProductListDic"];
    
    
    if (storeProductListDic && _StoreProductClassDic && _StoreCycleAdvDic) {
        
        //精品推荐数据
        _StoreProductListArray = [NSMutableArray arrayWithCapacity:1];
        
        
        NSArray *data = [storeProductListDic arrayValueForKey:@"data"];
        
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
        
        [self creatRefreshHeader];
        
    }
}

#pragma mark - 请求网络数据

-(void)prepareNetData{
    
    _request = [YJYRequstManager shareInstance];
    _count = 0;
    
    //轮播图
    _request_adv = [_request requestWithMethod:YJYRequstMethodGet api:StoreCycleAdv parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _StoreCycleAdvDic = result;
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
        [GMAPI cache:_StoreCycleAdvDic ForKey:@"GStoreHomeVc_StoreCycleAdvDic"];
        
        
    } failBlock:^(NSDictionary *result) {
        NSLog(@"%s",__FUNCTION__);
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];

    }];
    
    
    //商城套餐分类
    _request_ProductClass = [_request requestWithMethod:YJYRequstMethodGet api:StoreProductClass parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _StoreProductClassDic = result;
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
        [GMAPI cache:_StoreProductClassDic ForKey:@"GStoreHomeVc_StoreProductClassDic"];
        
        
        
    } failBlock:^(NSDictionary *result) {
        
    }];
    
    
    //首页精品推荐
    [self prepareProducts];
    
    
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



//首页精品推荐
-(void)prepareProducts{
    
    
    
    NSDictionary *listDic = @{
                              @"province_id":[GMAPI getCurrentProvinceId],
                              @"city_id":[GMAPI getCurrentCityId],
                              @"page":[NSString stringWithFormat:@"%d",_table.pageNum],
                              @"per_page":[NSString stringWithFormat:@"%d",5]
                              };
    
    _request_ProductRecommend = [_request requestWithMethod:YJYRequstMethodGet api:StoreJingpinTuijian parameters:listDic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
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
        
        
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
        [GMAPI cache:result ForKey:@"GStoreHomeVc_StoreProductListDic"];
        
    } failBlock:^(NSDictionary *result) {
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
    }];
}


//首页精品推荐
-(void)gotoPrepareProducts{
    
    
    
    NSDictionary *listDic = @{
                              @"province_id":[GMAPI getCurrentProvinceId],
                              @"city_id":[GMAPI getCurrentCityId],
                              @"page":[NSString stringWithFormat:@"%d",_table.pageNum],
                              @"per_page":[NSString stringWithFormat:@"%d",5]
                              };
    
    _request_ProductRecommend = [_request requestWithMethod:YJYRequstMethodGet api:StoreJingpinTuijian parameters:listDic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
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
        
        
        _table.tableFooterView = nil;
        
        
        
        [_table reloadData:_StoreProductListArray pageSize:5];
        
        [GMAPI cache:result ForKey:@"GStoreHomeVc_StoreProductListDic"];
        
    } failBlock:^(NSDictionary *result) {
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
    }];
}




//首页精品推荐上拉加载更多
-(void)prepareMoreProducts{
    //首页精品推荐
    NSDictionary *listDic = @{
                              @"province_id":[GMAPI getCurrentProvinceId],
                              @"city_id":[GMAPI getCurrentCityId],
                              @"page":[NSString stringWithFormat:@"%d",_table.pageNum],
                              @"per_page":[NSString stringWithFormat:@"%d",5]
                              };
    
    
    
    _request_ProductRecommend = [_request requestWithMethod:YJYRequstMethodGet api:StoreJingpinTuijian parameters:listDic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
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
        
        
        [_table reloadData:_StoreProductListArray pageSize:5];
        
        
    } failBlock:^(NSDictionary *result) {
        [_table loadFail];
        
    }];
}


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
    _request_GetShopCarNum = [_request requestWithMethod:YJYRequstMethodGet api:GET_SHOPPINGCAR_NUM parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
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





//三个网络请求完成
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        return;
    }
    
    NSNumber *num = [change objectForKey:@"new"];
    
    if ([num intValue] == 3) {
        
        [self creatRefreshHeader];

        
    }
    
}

//分类图片点击
-(void)classImvClicked:(UIImageView*)sender{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"%ld",(long)sender.tag);
    //数据数组
    NSArray *classData = [_StoreProductClassDic arrayValueForKey:@"data"];
    NSDictionary *dic = classData[sender.tag - 10];
    
    GBrandListViewController *cc = [[GBrandListViewController alloc]init];
    cc.class_Id = [dic stringValueForKey:@"category_id"];
    cc.className = [dic stringValueForKey:@"name"];
    if ([[dic stringValueForKey:@"gender"] intValue] == 1 || [[dic stringValueForKey:@"gender"] intValue] == 2) {
        cc.haveChooseGender = NO;
    }else if ([[dic stringValueForKey:@"gender"] intValue] == 99){
        cc.haveChooseGender = YES;
    }
    [self.navigationController pushViewController:cc animated:YES];
    
    
    
}


#pragma mark - 改变searchTf和框的大小
/**
 *  改变searchTf和框的大小
 *
 *  @param state 1 编辑状态 0常态
 */
-(void)changeSearchViewAndKuangFrameAndTfWithState:(int)state{
    
    _editState = state;
    
    if (state == 0) {//常态
        
//        [_myNavcRightBtn setTitle:@"分院" forState:UIControlStateNormal];
        [_myNavcRightBtn setTitle:nil forState:UIControlStateNormal];
        [_myNavcRightBtn setImage:[UIImage imageNamed:@"fenyuan_storehome.png"] forState:UIControlStateNormal];
        
        UIView *effectView = self.currentNavigationBar.effectContainerView;
        if (effectView) {
            for (UIView *view in effectView.subviews) {
                if (view.tag == 10000) {
                     view.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.8];
                }
            }
        };
        
        [_searchView setFrame:CGRectMake(0, 7, DEVICE_WIDTH - 90, 30)];
        [_kuangView setFrame:CGRectMake(0, 0, _searchView.frame.size.width, 30)];
        [self.searchTf setFrame:CGRectMake(30, 0, _kuangView.frame.size.width - 30, 30)];

    }else if (state == 1){//编辑状态
        [_myNavcRightBtn setImage:nil forState:UIControlStateNormal];
        [_myNavcRightBtn setTitle:@"取消" forState:UIControlStateNormal];
        
        UIView *effectView = self.currentNavigationBar.effectContainerView;
        if (effectView) {
            for (UIView *view in effectView.subviews) {
                if (view.tag == 10000) {
                    view.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:1];
                }
            }
        };
        
        [_searchView setWidth:DEVICE_WIDTH - 60];
        [_kuangView setWidth:_searchView.frame.size.width];
        [self.searchTf setFrame:CGRectMake(30, 0, _kuangView.frame.size.width-30, 30)];
        
        [self.navigationController.navigationBar bringSubviewToFront:_searchView];
        
    }
}


#pragma mark - 视图创建


//创建refresh头部
-(void)creatRefreshHeader{
    //数据数组
    NSArray *classData = [_StoreProductClassDic arrayValueForKey:@"data"];
    
    //共几行
    int hang = (int)classData.count/2;
    if (hang<classData.count/2.0) {
        hang+=1;
    };
    //每行几列
    int lie = 2;
    
    
    if (!self.theTopView) {
        self.theTopView = [[UIView alloc]initWithFrame:CGRectZero];
        self.theTopView.backgroundColor = RGBCOLOR(244, 245, 246);
        
    }
    
    //refresh头部
    [self.theTopView setFrame:CGRectMake(0,
                                          0,
                                          DEVICE_WIDTH,
                                          [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/468]//轮播图高度
                                          +hang*[GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/280]//分类版块高度
                                          +5
                                          +[GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/150]//个性化定制图高度
                                          +[GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/80]//精品推荐标题
                                          )];
    
    
    //设置轮播图
    [self creatUpCycleScrollView];
    
    //设置版块
    UIView *bankuaiView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_bannerView.frame), DEVICE_WIDTH, hang*[GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/280])];
    bankuaiView.backgroundColor = [UIColor whiteColor];
    [self.theTopView addSubview:bankuaiView];
    
    
    
    //宽
    CGFloat kk = DEVICE_WIDTH*0.5;
    //高
    CGFloat hh = [GMAPI scaleWithHeight:0 width:kk theWHscale:375.0/280];
    
    
    for (int i = 0; i<classData.count; i++) {
        
        NSDictionary *dic = classData[i];
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(i%lie*kk, i/lie*hh, kk, hh)];
        [bankuaiView addSubview:view];
        view.backgroundColor = RGBCOLOR_ONE;
        
        
        //图片
        UIImageView *imv = [[UIImageView alloc]initWithFrame:view.bounds];
        [imv l_setImageWithURL:[NSURL URLWithString:[dic stringValueForKey:@"cover_pic"]] placeholderImage:nil];
        [view addSubview:imv];
        
        int imvTag = i+10;
        
        [imv addTaget:self action:@selector(classImvClicked:) tag:imvTag];
        
        
    }
    
    UIImageView *dingzhiImv = [[UIImageView alloc]initWithFrame:CGRectMake(0,
                                                                           CGRectGetMaxY(bankuaiView.frame)+5,
                                                                           DEVICE_WIDTH,
                                                                           [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/150]
                                                                           )];
    [dingzhiImv setImage:[UIImage imageNamed:@"gexingdingzhi.png"]];
    
    [dingzhiImv addTaget:self action:@selector(pushToPersonalCustom) tag:0];
    
    [self.theTopView addSubview:dingzhiImv];
    
    
    
    
    //设置精品推荐
    
    UIView *jingpintuijian = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                                     CGRectGetMaxY(dingzhiImv.frame),
                                                                     DEVICE_WIDTH,
                                                                     [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/80])];
    jingpintuijian.backgroundColor = RGBCOLOR(244, 245, 246);
    [self.theTopView addSubview:jingpintuijian];
    UILabel *ttl = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, jingpintuijian.frame.size.height)];
    ttl.font = [UIFont systemFontOfSize:15];
    [jingpintuijian addSubview:ttl];
    ttl.text = @"精品推荐";
    ttl.textColor = [UIColor blackColor];
    
    
    _table.tableHeaderView = self.theTopView;
    
    if (_StoreProductListArray.count > 0) {
        [_table reloadData:_StoreProductListArray pageSize:5];
    }else{
        [_table reloadData:_StoreProductListArray pageSize:5 CustomNoDataView:[self resultViewWithT]];
        
    }
    
    
    
    
}




//创建自定义navigation
- (void)setupNavigation{
    
    [self resetShowCustomNavigationBar:YES];
    
    //调整与左边的间距
    UIBarButtonItem * spaceButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton1.width = -10;
    
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 32, 32)];
    [leftBtn setImage:[UIImage imageNamed:@"back_storehome.png"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(gogoback) forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:leftBtn];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftView];
    
    self.currentNavigationItem.leftBarButtonItems = @[spaceButton1,leftItem];
    
    
    _searchView = [[UIView alloc]initWithFrame:CGRectZero];
    _searchView.layer.cornerRadius = 5;
    _searchView.backgroundColor = [UIColor whiteColor];
    
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
    self.searchTf.backgroundColor = [UIColor whiteColor];
    self.searchTf.layer.cornerRadius = 5;
    self.searchTf.placeholder = @"输入您要找的商品";
    self.searchTf.delegate = self;
    self.searchTf.returnKeyType = UIReturnKeySearch;
    [_kuangView addSubview:self.searchTf];
    
    
    _editState = 0;
    _rightItem1 = [[UIBarButtonItem alloc]initWithCustomView:_searchView];
    
    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:      UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [spaceButtonItem setWidth:-10];
    
    _myNavcRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_myNavcRightBtn setFrame:CGRectMake(0, 0, 30, 30)];
    _myNavcRightBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_myNavcRightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_myNavcRightBtn addTarget:self action:@selector(myNavcRightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:_myNavcRightBtn];
    
    
    self.currentNavigationItem.rightBarButtonItems = @[spaceButtonItem,rightBtnItem,_rightItem1];
    
    UIView *effectView = self.currentNavigationBar.effectContainerView;
    if (effectView) {
        UIView *alphaView = [[UIView alloc] initWithFrame:effectView.bounds];
        [effectView addSubview:alphaView];
        alphaView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.8];
        alphaView.tag = 10000;
    };
    
    [self setEffectViewAlpha:0];
    
    
    [self changeSearchViewAndKuangFrameAndTfWithState:0];
    
}


//创建搜索界面
-(void)creatMysearchView{
    
    _mySearchView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
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


//创建下层四个按钮view
-(void)creatDownBtnView{
    
    
    _downView = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 50, DEVICE_WIDTH, 50)];
    _downView.backgroundColor = RGBCOLOR(38, 51, 62);
    
    
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





//创建tabelview
-(void)creatTableView{
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 50) style:UITableViewStyleGrouped];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    _table.showsVerticalScrollIndicator = NO;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];
    [self loadCache];
    
    
    [_table refreshNewData];
    
    
}

//创建循环滚动广告图
-(void)creatUpCycleScrollView{
    
    
    self.upAdvArray = [NSMutableArray arrayWithCapacity:1];
    
    NSArray *advertisements_data = [NSMutableArray arrayWithArray:[_StoreCycleAdvDic objectForKey:@"advertisements_data"]];
    
    NSMutableArray *urls = [NSMutableArray arrayWithCapacity:1];
    
    if (advertisements_data.count > 0) {
        
        for (NSDictionary *dic in advertisements_data) {
            CycleAdvModel *model = [[CycleAdvModel alloc]initWithDictionary:dic];
            [self.upAdvArray addObject:model];
        }
        
        
        for (CycleAdvModel *model in self.upAdvArray) {
            [urls addObject:model.img_url];
        }
        
        
        NSMutableArray *views = [NSMutableArray arrayWithCapacity:urls.count];
        for (int i = 0; i < urls.count; i ++) {
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 468/750.0*DEVICE_WIDTH)];
            [imageView l_setImageWithURL:[NSURL URLWithString:urls[i]] placeholderImage:nil];
            [views addObject:imageView];
            
        }

        _bannerView = [[LBannerView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 468/750.0*DEVICE_WIDTH)];
        [_bannerView setContentViews:views];
        [_bannerView showPageControl];
        [_bannerView setBackgroundColor:DEFAULT_VIEW_BACKGROUNDCOLOR];
        
        __weak typeof(self)bself = self;
        [_bannerView setTapActionBlock:^(NSInteger index) {
            NSLog(@"--tap index %ld",(long)index);
            
            if (index >= bself.upAdvArray.count) {
                return ;
            }
            
            CycleAdvModel *amodel = bself.upAdvArray[index];
            if ([amodel.redirect_type intValue] == 1) {//外链
                
                [MiddleTools pushToWebFromViewController:bself weburl:amodel.redirect_url title:nil moreInfo:NO hiddenBottom:YES];
                
            }else if ([amodel.redirect_type intValue] == 0){//应用内
                if ([amodel.adv_type_val intValue] == 1) {//套餐 单品详情
                    GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
                    cc.productId = amodel.theme_id;
                    [bself.navigationController pushViewController:cc animated:YES];
                }else if ([amodel.adv_type_val intValue] == 2){//企业预约首页
                    
                }
                
            }
            
        }];
        
        [_bannerView setAutomicScrollingDuration:3];
        
        [self.theTopView addSubview:_bannerView];
    }else{
        
        [_table setFrame:CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT - 64- 50)];
        
        CGFloat height = self.theTopView.frame.size.height;
        height -= [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/468];
        [self.theTopView setHeight:height];
        _table.tableHeaderView = self.theTopView;
        
    }
}


#pragma mark - 点击方法

-(void)viewForHeaderClicked:(UIButton*)sender{
    NSInteger index = sender.tag - 20000;
    StoreHomeOneBrandModel *model_b = _table.dataArray[index];
    
    GBrandHomeViewController *cc = [[GBrandHomeViewController alloc]init];
    cc.brand_id = model_b.brand_id;
    cc.brand_name = model_b.brand_name;
    [self.navigationController pushViewController:cc animated:YES];
    
//    GoneClassListViewController *cc = [[GoneClassListViewController alloc]init];
//    cc.className = model_b.brand_name;
//    cc.brand_name = model_b.brand_name;
//    cc.brand_id = model_b.brand_id;
//    [self.navigationController pushViewController:cc animated:YES];
    
    
}


-(void)myNavcRightBtnClicked{
    
    
    if (_editState == 0) {//常态 跳转分院
        [self pushToFenyuan];
    }else if (_editState == 1){//编辑态 取消搜索
        [self changeSearchViewAndKuangFrameAndTfWithState:0];
    }
    
    
//    [_rightItem2Label removeFromSuperview];
    [_searchTf resignFirstResponder];
    _mySearchView.hidden = YES;
    UIView *effectView = self.currentNavigationBar.effectContainerView;
    if (effectView) {
        UIView *alphaView = [effectView viewWithTag:10000];
        if (_table.contentOffset.y > 64) {
            CGFloat alpha = (_table.contentOffset.y -64)/200.0f;
            alpha = MIN(alpha, 1);
            alphaView.alpha = alpha;
        }else{
            alphaView.alpha = 0;
        }
    }
}

//跳转分院
-(void)pushToFenyuan{
    
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
        
        GoneClassListViewController *cc = [[GoneClassListViewController alloc]init];
        cc.className = @"精品推荐";
        cc.isShowShaixuanAuto = YES;
        cc.haveChooseGender = YES;
        [self.navigationController pushViewController:cc animated:YES];
        
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



#pragma - mark RefreshDelegate


- (void)loadNewDataForTableView:(UITableView *)tableView{
    
    [_request removeOperation:_request_adv];
    [_request removeOperation:_request_ProductClass];
    [_request removeOperation:_request_ProductRecommend];
    
    [self prepareNetData];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView{
    
    [self prepareMoreProducts];

}


- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    
    UIView *effectView = self.currentNavigationBar.effectContainerView;
    if (effectView) {
        UIView *alphaView = [effectView viewWithTag:10000];
        
        if (_searchTf.isFirstResponder) {
            alphaView.alpha = 1;
        }else{
            if (scrollView.contentOffset.y > 64) {
                CGFloat alpha = (scrollView.contentOffset.y -64)/200.0f;
                alpha = MIN(alpha, 1);
                alphaView.alpha = alpha;
            }else{
                alphaView.alpha = 0;
            }
        }
        
    }
    
    [self controlTopButtonWithScrollView:scrollView];
    
    
    
//    // 去掉UItableview headerview黏性(sticky)
//    CGFloat sectionHeaderHeight = 40;
//    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//    }
//    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//    }
    
    
}

-(void)setEffectViewAlpha:(CGFloat)theAlpha{
    UIView *effectView = self.currentNavigationBar.effectContainerView;
    if (effectView) {
        UIView *alphaView = [effectView viewWithTag:10000];
        alphaView.alpha = theAlpha;
    }
}




- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    NSLog(@"%s",__FUNCTION__);
    GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
    
    StoreHomeOneBrandModel *model_b = _table.dataArray[indexPath.section];
    ProductModel *aModel = model_b.list[indexPath.row];
    cc.productId = aModel.product_id;
    [self.navigationController pushViewController:cc animated:YES];
}

- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    
    CGFloat height = 0.01;
    height = [GProductCellTableViewCell getCellHight];
    return height;
}
//将要显示
- (void)refreshTableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
    });
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    StoreHomeOneBrandModel *model = _table.dataArray[section];
    num = model.list.count;
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    GProductCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GProductCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    StoreHomeOneBrandModel *brandModel = _table.dataArray[indexPath.section];
    
    
    ProductModel *model = brandModel.list[indexPath.row];
    
    [cell loadData:model];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = 0;
    num = _table.dataArray.count;
    return num;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
    
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
    StoreHomeOneBrandModel *model_b = _table.dataArray[section];
    
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
- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(RefreshTableView *)tableView{
    CGFloat height = 0.01;
    if (section == 0) {
        height = 40;
    }else{
        height = 45;
    }
    return height;
}





/**
 *  个性化定制
 */
- (void)pushToPersonalCustom
{
    __weak typeof(self)weakSelf = self;
    [LoginViewController isLogin:self loginBlock:^(BOOL success) {
        
        if (success) {
            [weakSelf pushToPhysicaResult];
        }else
        {
            NSLog(@"没登陆成功");
            _isPresenting = YES;
        }
    }];
}

/**
 *  跳转至个性化定制页 或者 结果页
 */
- (void)pushToPhysicaResult
{
    //先判断是否个性化定制过
    BOOL isOver = [UserInfo getCustomState];
    if (isOver) {
        //已经个性化定制过
        PhysicalTestResultController *physical = [[PhysicalTestResultController alloc]init];
        physical.lastPageNavigationHidden = YES;
        [self.navigationController pushViewController:physical animated:YES];
    }else
    {
        PersonalCustomViewController *custom = [[PersonalCustomViewController alloc]init];
        custom.lastViewController = self;
        [self.navigationController pushViewController:custom animated:YES];
    }
}


#pragma mark - 购物车数量
//登录成功更新购物车数量
-(void)updateShopCarNum{
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey]
                          };
      _request_GetShopCarNum = [_request requestWithMethod:YJYRequstMethodGet api:GET_SHOPPINGCAR_NUM parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
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

//登录成功更新商品收藏和购物车数量
-(void)updateIsFavorAndShopCarNum{
    [self updateShopCarNum];
    
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





#pragma mark - 无数据默认view
-(UIView *)resultViewWithT
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 150)];
    view.backgroundColor = RGBCOLOR(240, 245, 246);
    
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 85)];
    view1.backgroundColor = [UIColor whiteColor];
    [view addSubview:view1];
    
    
    UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(200.0/830*DEVICE_WIDTH, 85*0.5 - 36*0.5, 36, 36)];
    [imv setImage:[UIImage imageNamed:@"storehomeNodatatixing.png"]];
    [view1 addSubview:imv];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(imv.right + 10, imv.frame.origin.y, 270.0/830*DEVICE_WIDTH,imv.frame.size.height)];
    titleLabel.textColor = RGBCOLOR(130, 133, 133);
    titleLabel.font = [UIFont systemFontOfSize:10];
    titleLabel.numberOfLines = 2;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"该城市还没有相应套餐先去其他城市逛逛吧";
    [view1 addSubview:titleLabel];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor whiteColor];
    btn.layer.borderWidth = 0.5;
    btn.layer.borderColor = [RGBCOLOR(236, 237, 240)CGColor];
    [btn setFrame:CGRectMake(40, CGRectGetMaxY(view1.frame)+17, DEVICE_WIDTH - 80, 32)];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:@"切换城市" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(changeCityBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    
    
    
    
    return view;
}


-(void)changeCityBtnClicked{
    LocationChooseViewController *cc = [[LocationChooseViewController alloc]init];
    cc.delegate1 = self;
    [self.navigationController pushViewController:cc animated:YES];
    
    
}




#pragma mark - 代理回调
-(void)afterChangeCityUpdateTableWithCstr:(NSString *)cStr Pstr:(NSString *)pStr{
    
    NSString *provinceStr = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:pStr]];
    NSString *cityStr = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:cStr]];
    
    if ([provinceStr isEqualToString:cityStr]) {
        cityStr = @"0";
    }
    
    NSDictionary *dic = @{
                          @"province":provinceStr,
                          @"city":cityStr
                          };
    
    
    [GMAPI cache:dic ForKey:USERLocation];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_HOMEVCLEFTSTR object:nil];
    
    _table.pageNum = 1;
    _table.isReloadData = YES;
    [self gotoPrepareProducts];
    
    
    
    
}



@end
