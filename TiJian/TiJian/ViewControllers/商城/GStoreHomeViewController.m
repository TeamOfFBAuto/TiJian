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
#import "HospitalViewController.h"//分院
#import "GBrandListViewController.h"
#import "GBrandHomeViewController.h"
#import "GTranslucentSideBar.h"
#import "GPushView.h"
#import "GView.h"//分类自定义view
#import "WebviewController.h"

@interface GStoreHomeViewController ()<RefreshDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewDelegate,GsearchViewDelegate,GpushViewDelegate,GTranslucentSideBarDelegate,LocationChooseDelegate>
{
    LBannerView *_bannerView;//轮播图
    
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_adv;
    AFHTTPRequestOperation *_request_ProductClass;
    AFHTTPRequestOperation *_request_ProductRecommend;
    AFHTTPRequestOperation *_request_hotSearch;
    
    RefreshTableView *_table;
    
    NSDictionary *_StoreCycleAdvDic;//轮播图dic
    NSMutableArray *_StoreProductListArray;//tableview数据源
    NSMutableArray *_StoreProductListArray_cache;//缓存数据源
    
    UIView *_mySearchView;//点击搜索盖上的搜索浮层
    UIView *_searchView;//输入框下层view
    UIView *_downView;//底部工具栏
    UILabel *_shopCarNumLabel;//购物车数量label
    
    GSearchView *_theCustomSearchView;//自定义搜索view
    
    NSArray *_hotSearchArray;//热门搜索
    UIBarButtonItem *_rightItem1;
    UIView *_kuangView;
    
    //购物车数量
    AFHTTPRequestOperation *_request_GetShopCarNum;
    NSDictionary *_shopCarDic;
    int _gouwucheNum;//购物车里商品数量
    
    BOOL _isPresenting;//是否在模态
    
    UIButton *_myNavcRightBtn;
    int _editState;//0常态 1编辑状态
    
    UIView *_backBlackView;//筛选界面下面的黑色透明view
    
    //轻扫手势
    UIPanGestureRecognizer *_panGestureRecognizer;
    GPushView *_pushView;//筛选view
    BOOL _isShaixuan;//是否为筛选刷新数据
    
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
    
    _table.dataSource = nil;
    _table.refreshDelegate = nil;
    _table = nil;
}







- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self hiddenNavigationBar:YES animated:animated];
    _isPresenting = NO;
    [MobClick beginLogPageView:@"GStoreHomeViewController"];
    
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}
- (void)viewWillDisappear:(BOOL)animated
{
    //模态
    if (_isPresenting) {
        _isPresenting = NO;
        return;
    }
    
    [super viewWillDisappear:animated];
    
    
    [self hiddenNavigationBar:NO animated:animated];//不隐藏NavigationBar
    //还原下拉刷新之前的状态栏状态
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
    self.currentNavigationBar.alpha = 1;
    
    [MobClick endLogPageView:NSStringFromClass([self class])];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加通知
    [self setNotification];
    
    //初始化搜索状态
    [self setStateOfSearchIdentifier];
    
    //视图创建
    [self creatShaixuanBackBlackView];//只创建筛选界面下方的黑色透明view不添加到self.view上
    [self hiddenNavigationBar:YES animated:YES];//隐藏NavigationBar
    [self setupNavigation];//创建自定义navigation
    [self creatTableView];//创建RefreshTabelview
    [self creatRefreshHeader];//创建refresh头部
    [self creatDownBtnView];//创建下层四个按钮view
    [self creatMysearchView];//创建搜索界面
    [self creatRightTranslucentSideBar];//创建筛选侧滑栏
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化状态标识符
//初始化搜索状态
-(void)setStateOfSearchIdentifier{
    _editState = 0;
}

#pragma mark - 添加通知
-(void)setNotification{
    //更新购物车
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateShopCarNum) name:NOTIFICATION_UPDATE_TO_CART object:nil];
    //登录成功
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateIsFavorAndShopCarNum) name:NOTIFICATION_LOGIN object:nil];
}

#pragma mark - 视图创建
//创建筛选界面下方的黑色透明view
-(void)creatShaixuanBackBlackView{
    _backBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    _backBlackView.backgroundColor = [UIColor blackColor];
    _backBlackView.alpha = 0.5;
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
    
    _pushView = [[GPushView alloc]initWithFrame:CGRectMake(0, 0, self.rightSideBar.sideBarWidth, self.rightSideBar.view.frame.size.height)gender:YES isHaveShaixuanDic:self.shaixuanDic];
    _pushView.delegate = self;
    [self.rightSideBar setContentViewInSideBar:_pushView];
    
}

//创建refresh头部
-(void)creatRefreshHeader{
    
    if (!self.theTopView) {
        self.theTopView = [[UIView alloc]initWithFrame:CGRectZero];
        self.theTopView.backgroundColor = RGBCOLOR(244, 245, 246);
        
    }
    
    for (UIView *view in self.theTopView.subviews) {
        [view removeFromSuperview];
    }
    
    

    
    //设置轮播图
    [self creatUpCycleScrollView];
    
    //设置版块
    UIView *bankuaiView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_bannerView.frame), DEVICE_WIDTH, DEVICE_WIDTH*430/750)];
    bankuaiView.backgroundColor = RGBCOLOR(220, 221, 223);
    [self.theTopView addSubview:bankuaiView];
    
    //企业体检
    GView *classView1 = [[GView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH*0.5-0.5, (DEVICE_WIDTH*0.5-0.5)*255/375) tag:10 type:ClassViewType_qiyetijian];
    [classView1.logoImv setImage:[UIImage imageNamed:@"sh_qiyetijian.png"]];
    classView1.titleLabel_black.text = @"企业体检";
    classView1.titleLabel_gray.text = @"全面体检奢华享受";
    [bankuaiView addSubview:classView1];
    [classView1 addTapGestureTaget:self action:@selector(classGviewClicked:) imageViewTag:classView1.tag];
    
    //早期防癌
    GView *classView2 = [[GView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH * 0.5, 0, DEVICE_WIDTH * 0.5, classView1.frame.size.height * 0.5) tag:11 type:ClassViewType_youshang];
    [classView2.logoImv setImage:[UIImage imageNamed:@"sh_fangai.png"]];
    classView2.titleLabel_black.text = @"早期防癌";
    classView2.titleLabel_gray.text = @"预防比治疗更重要";
    [bankuaiView addSubview:classView2];
    [classView2 addTapGestureTaget:self action:@selector(classGviewClicked:) imageViewTag:classView2.tag];
    
    //心脑血管
    GView *classView3 = [[GView alloc]initWithFrame:CGRectMake(classView2.frame.origin.x, CGRectGetMaxY(classView2.frame)+0.5, classView2.frame.size.width, classView2.frame.size.height-0.5) tag:12 type:ClassViewType_youshang];
    [classView3.logoImv setImage:[UIImage imageNamed:@"sh_xinnaoxueguan.png"]];
    classView3.titleLabel_black.text = @"心脑血管";
    classView3.titleLabel_gray.text = @"及时发现很重要";
    [bankuaiView addSubview:classView3];
    [classView3 addTapGestureTaget:self action:@selector(classGviewClicked:) imageViewTag:classView3.tag];
    
    //关爱老人 职场白领 精英男士 都市丽人
    NSArray *littleClassNameArray = @[@"关爱老人",@"职场白领",@"精英男士",@"都市丽人"];
    NSArray *logoImNameArray = @[@"sh_guanailaoren.png",@"sh_zhichangbailing.png",@"sh_jingyingnanshi.png",@"sh_dushiliren.png"];
    for (int i = 0; i<4; i++) {
        GView *classView = [[GView alloc]initWithFrame:CGRectMake(i*(DEVICE_WIDTH * 0.25), CGRectGetMaxY(classView3.frame)+0.5, DEVICE_WIDTH*0.25-0.5, bankuaiView.frame.size.height - classView1.frame.size.height) tag:13+i type:ClassViewType_smallfenlei];
        NSString *logoImvStr = logoImNameArray[i];
        [classView.logoImv setImage:[UIImage imageNamed:logoImvStr]];
        classView.titleLabel_black.text = littleClassNameArray[i];
        classView.backgroundColor = [UIColor whiteColor];
        [bankuaiView addSubview:classView];
        [classView addTapGestureTaget:self action:@selector(classGviewClicked:) imageViewTag:classView.tag];
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
    
    [self.theTopView setFrame:CGRectMake(0, 0, DEVICE_WIDTH, jingpintuijian.bottom)];
    
    
    _table.tableHeaderView = self.theTopView;
    
}

//创建自定义navigation
- (void)setupNavigation{
    [self resetShowCustomNavigationBar:YES];
    //调整与左边的间距
    UIBarButtonItem * spaceButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton1.width = -10;
    
    if (iPhone6PLUS) {
        spaceButton1.width = -15;
    };
    
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
    self.searchTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_kuangView addSubview:self.searchTf];
    
    
    _editState = 0;
    _rightItem1 = [[UIBarButtonItem alloc]initWithCustomView:_searchView];
    
    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
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
    
    
    if (_StoreCycleAdvDic) {//有轮播图缓存
        if (advertisements_data.count > 0) {//有轮播图
            
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
                        
                        [MiddleTools pushToProductDetailWithProductId:amodel.theme_id viewController:bself extendParams:nil];
                        
                    }else if ([amodel.adv_type_val intValue] == 2){//企业预约首页
                        
                    }
                    
                }
                
            }];
            
            [_bannerView setAutomicScrollingDuration:3];
            
            [self.theTopView addSubview:_bannerView];
        }else{//无轮播图
            [_table setFrame:CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT - 64- 50)];
            _bannerView = [[LBannerView alloc] initWithFrame:CGRectZero];
//            CGFloat height = self.theTopView.frame.size.height;
//            height -= [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/468];
//            [self.theTopView setHeight:height];
//            _table.tableHeaderView = self.theTopView;
        }
    }else{
        [_table setFrame:CGRectMake(0, 64, DEVICE_WIDTH, DEVICE_HEIGHT - 64- 50)];
        _bannerView = [[LBannerView alloc] initWithFrame:CGRectZero];
    }
    
    
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{

    _mySearchView.hidden = NO;
    _theCustomSearchView.dataArray = [GMAPI cacheForKey:USERCOMMONLYUSEDSEARCHWORD];
    
    [_theCustomSearchView.tab reloadData];
    
    [self changeSearchViewAndKuangFrameAndTfWithState:1];
    
    UIView *effectView = self.currentNavigationBar.effectContainerView;
    if (effectView) {
        UIView *alphaView = [effectView viewWithTag:10000];
        alphaView.alpha = 1;
    }
    
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    UIView *effectView = self.currentNavigationBar.effectContainerView;
    if (effectView) {
        UIView *alphaView = [effectView viewWithTag:10000];
        CGFloat alpha = (_table.contentOffset.y -64)/200.0f;
        alpha = MIN(alpha, 1);
        alphaView.alpha = alpha;

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
    
    self.searchTf.text = theWord;
    self.searchTf.text = nil;
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
    
    NSDictionary *storeProductListDic = [GMAPI cacheForKey:@"GStoreHomeVc_StoreProductListDic"];
    
    if (storeProductListDic && _StoreCycleAdvDic) {
        //精品推荐数据
        _StoreProductListArray_cache = [NSMutableArray arrayWithCapacity:1];
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
            [_StoreProductListArray_cache addObject:model_b];
        }
        
        [self creatRefreshHeader];
        
    }
}

#pragma mark - 请求网络数据

-(void)prepareNetData{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    
    if (_isShaixuan) {
        //首页精品推荐
        [self prepareProductsWithDic:self.shaixuanDic];
        _isShaixuan = NO;
        return;
    }
    
    //根据城市查询品牌列表
    [self prepareBrandListWithLocation];
    //获取热门搜索
    [self getHotSearch];
    //购物车数量
    [self getshopcarNum];
    //轮播图
    [self getAdvCycleNetData];
    //首页精品推荐
    [self prepareProductsWithDic:self.shaixuanDic];
}

//轮播图
-(void)getAdvCycleNetData{
    //轮播图
    @WeakObj(_table);
    @WeakObj(self);
    _request_adv = [_request requestWithMethod:YJYRequstMethodGet api:StoreCycleAdv parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        _StoreCycleAdvDic = result;
        [GMAPI cache:_StoreCycleAdvDic ForKey:@"GStoreHomeVc_StoreCycleAdvDic"];
        Weak_table.tableHeaderView = nil;
        [Weakself creatRefreshHeader];
        
    } failBlock:^(NSDictionary *result) {
        [Weak_table loadFail];
    }];
}


//获取热门搜索
-(void)getHotSearch{
    _request_hotSearch = [_request requestWithMethod:YJYRequstMethodGet api:ProductHotSearch parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        _hotSearchArray = [result arrayValueForKey:@"list"];
        _theCustomSearchView.hotSearch = _hotSearchArray;
        [_theCustomSearchView.tab reloadData];
    } failBlock:^(NSDictionary *result) {
        [_table loadFail];
    }];
}



//首页精品推荐
-(void)prepareProductsWithDic:(NSDictionary *)theDic{
    NSDictionary *dic;
    if (theDic) {
        NSMutableDictionary *temp_dic = [NSMutableDictionary dictionaryWithDictionary:theDic];
        [temp_dic safeSetString:NSStringFromInt(_table.pageNum) forKey:@"page"];
        [temp_dic safeSetString:NSStringFromInt(5) forKey:@"per_page"];
        [temp_dic safeSetString:@"2" forKey:@"show_type"];
        dic = temp_dic;
    }else{
        dic = @{
                @"province_id":[GMAPI getCurrentProvinceId],
                @"city_id":[GMAPI getCurrentCityId],
                @"page":NSStringFromInt(_table.pageNum),
                @"per_page":NSStringFromInt(5)
                };
        
    }
    
     @WeakObj(_table);
     @WeakObj(self);
    _request_ProductRecommend = [_request requestWithMethod:YJYRequstMethodGet api:StoreJingpinTuijian parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
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
        
        
        if (Weak_table.pageNum == 1) {
            [GMAPI cache:result ForKey:@"GStoreHomeVc_StoreProductListDic"];
        }
        [Weak_table reloadData:_StoreProductListArray pageSize:5 CustomNoDataView:[Weakself resultViewWithT]];
        
    } failBlock:^(NSDictionary *result) {
        [Weak_table loadFail];
    }];
}


//选择完地区之后请求首页精品推荐
-(void)gotoPrepareProductsWithDic:(NSDictionary *)theDic{
    NSDictionary *dic;
    if (theDic) {
        NSMutableDictionary *temp_dic = [NSMutableDictionary dictionaryWithDictionary:theDic];
        [temp_dic setObject:NSStringFromInt(_table.pageNum) forKey:@"page"];
        [temp_dic setObject:NSStringFromInt(5) forKey:@"per_page"];
        [temp_dic setObject:@"2" forKey:@"show_type"];
        dic = temp_dic;
    }else{
        dic = @{
                @"province_id":[GMAPI getCurrentProvinceId],
                @"city_id":[GMAPI getCurrentCityId],
                @"page":NSStringFromInt(_table.pageNum),
                @"per_page":[NSString stringWithFormat:@"%d",5]
                };
        
    }
    @WeakObj(_table);
     @WeakObj(self);
    _request_ProductRecommend = [_request requestWithMethod:YJYRequstMethodGet api:StoreJingpinTuijian parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
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
        
        Weak_table.tableFooterView = nil;
        [Weak_table reloadData:_StoreProductListArray pageSize:5 CustomNoDataView:[Weakself resultViewWithT]];
        [GMAPI cache:result ForKey:@"GStoreHomeVc_StoreProductListDic"];
        
    } failBlock:^(NSDictionary *result) {
        [Weak_table loadFail];
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
    
     @WeakObj(self);
    @WeakObj(_table);
    _request_GetShopCarNum = [_request requestWithMethod:YJYRequstMethodGet api:GET_SHOPPINGCAR_NUM parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
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
            [Weakself updateShopCarNumAndFrame];
        }
        
    } failBlock:^(NSDictionary *result) {
        [Weak_table loadFail];
    }];
}


//根据城市查询品牌列表
-(void)prepareBrandListWithLocation{
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
     @WeakObj(self);
     @WeakObj(_table);
    [_request requestWithMethod:YJYRequstMethodGet api:BrandList_oneClass parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *arr = [result arrayValueForKey:@"data"];
        Weakself.brand_city_list = [NSArray arrayWithArray:arr];
        if (_pushView) {
            _pushView.tab4.tableFooterView = nil;
            [_pushView.tab4 reloadData];
        }
        
    } failBlock:^(NSDictionary *result) {
        [Weak_table loadFail];
    }];
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

        if (!_panGestureRecognizer) {
            _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        }
        [self.view addGestureRecognizer:_panGestureRecognizer];
        
        
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
        
        [self.view removeGestureRecognizer:_panGestureRecognizer];
    }
}



#pragma mark - 点击方法

-(void)classGviewClicked:(UITapGestureRecognizer*)sender{
    
    if (sender.view.tag == 10) {//企业体检
        WebviewController *cc = [[WebviewController alloc]init];
        cc.webUrl = @"http://www.hippodr.com/index.php?d=wap&c=company_consult&m=consult";
        cc.navigationTitle = @"企业体检";
        [self.navigationController pushViewController:cc animated:YES];
    }else{
        
        GBrandListViewController *cc = [[GBrandListViewController alloc]init];
        
        if (sender.view.tag == 11){//早期防癌
            cc.class_Id = @"3";
            cc.className = @"早期防癌";
            cc.haveChooseGender = YES;
        }else if (sender.view.tag == 12){//心脑血管
            cc.class_Id = @"5";
            cc.className = @"心脑血管";
            cc.haveChooseGender = YES;
        }else if (sender.view.tag == 13){//关爱老人
            cc.class_Id = @"1";
            cc.className = @"关爱老人";
            cc.haveChooseGender = YES;
        }else if (sender.view.tag == 14){//职场白领
            cc.class_Id = @"2";
            cc.className = @"职场白领";
            cc.haveChooseGender = YES;
        }else if (sender.view.tag == 15){//精英男士
            cc.class_Id = @"6";
            cc.className = @"精英男士";
            cc.haveChooseGender = NO;
        }else if (sender.view.tag == 16){//都市丽人
            cc.class_Id = @"4";
            cc.className = @"都市丽人";
            cc.haveChooseGender = NO;
        }
        
        [self.navigationController pushViewController:cc animated:YES];
    }
}


-(void)viewForHeaderClicked:(UIButton*)sender{
    NSInteger index = sender.tag - 20000;
    StoreHomeOneBrandModel *model_b = _table.dataArray[index];
    GBrandHomeViewController *cc = [[GBrandHomeViewController alloc]init];
    cc.brand_id = model_b.brand_id;
    cc.brand_name = model_b.brand_name;
    [self.navigationController pushViewController:cc animated:YES];
}


-(void)myNavcRightBtnClicked{
    
    if (_editState == 0) {//常态 跳转分院
        [self pushToFenyuan];
    }else if (_editState == 1){//编辑态 取消搜索
        [self changeSearchViewAndKuangFrameAndTfWithState:0];
        self.searchTf.text = nil;
    }
    
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
    HospitalViewController *hospital = [[HospitalViewController alloc]init];
    [self.navigationController pushViewController:hospital animated:YES];
}


-(void)hotSearchBtnClicked:(UIButton *)sender{
    DDLOG(@"%d",(int)sender.tag);
}


-(void)downBtnClicked:(UIButton *)sender{
    
    if (sender.tag == 100) {//客服
        
        if ([LoginManager isLogin]) {
            
            [self clickToChat];
            
        }else
        {
            _isPresenting = YES;
            [LoginManager isLogin:self];
        }
        
    }else if (sender.tag == 101){//收藏
        
        if ([LoginManager isLogin]) {
            
            ProductListViewController *cc = [[ProductListViewController alloc]init];
            [self.navigationController pushViewController:cc animated:YES];
        }else
        {
            _isPresenting = YES;

            [LoginManager isLogin:self];
        }
        
    }else if (sender.tag == 102){//筛选
        
        [self.rightSideBar show];
        
    }else if (sender.tag == 103){//购物车
        
        if ([LoginManager isLogin]) {
            
            GShopCarViewController *cc = [[GShopCarViewController alloc]init];
            [self.navigationController pushViewController:cc animated:YES];
        }else
        {
            _isPresenting = YES;
            [LoginManager isLogin:self];
        }
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
    
    [self prepareProductsWithDic:self.shaixuanDic];

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
    
    
    
    if (_StoreCycleAdvDic) {
        NSArray *advertisements_data = [NSMutableArray arrayWithArray:[_StoreCycleAdvDic objectForKey:@"advertisements_data"]];
        if (advertisements_data.count > 0) {//有轮播图
            if (scrollView.contentOffset.y<-10) {
                [[UIApplication sharedApplication] setStatusBarHidden:TRUE withAnimation:UIStatusBarAnimationSlide];
                [UIView animateWithDuration:0.2 animations:^{
                    self.currentNavigationBar.alpha = 0;
                }];
                
            }else{
                [[UIApplication sharedApplication] setStatusBarHidden:FALSE withAnimation:UIStatusBarAnimationSlide];
                [UIView animateWithDuration:0.2 animations:^{
                    self.currentNavigationBar.alpha = 1;
                }];
            }
        }else{
            
        }
    }else{
        
    }
    
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
//    StoreHomeOneBrandModel *model_b = _table.dataArray[indexPath.section];
//    ProductModel *aModel = model_b.list[indexPath.row];
//    [MiddleTools pushToProductDetailWithProductId:aModel.product_id viewController:self extendParams:nil];
    
    GoHealthAppointViewController *cc = [[GoHealthAppointViewController alloc]init];
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
    //友盟统计
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic safeSetValue:@"商城首页" forKey:@"fromPage"];
    [[MiddleTools shareInstance]umengEvent:@"Customization" attributes:dic number:[NSNumber numberWithInt:1]];
    
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

//登录成功更新商品收藏和购物车数量
-(void)updateIsFavorAndShopCarNum{
    [self updateShopCarNum];
    
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
    cc.delegate = self;
    [self.navigationController pushViewController:cc animated:YES];
    
    
}




#pragma mark - LocationChooseDelegate

-(void)afterChooseCity:(NSString *)theCity province:(NSString *)theProvince{
    
    NSString *provinceStr = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:theProvince]];
    NSString *cityStr = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:theCity]];
    
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
    [self gotoPrepareProductsWithDic:self.shaixuanDic];
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
    [MobClick beginLogPageView:@"GpushView"];
    
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
        }else
        {
            _pushView.isRightBtnClicked = NO;

        }
    }
}

- (void)sideBar:(GTranslucentSideBar *)sideBar willDisappear:(BOOL)animated
{
    
    
     [MobClick endLogPageView:@"GpushView"];
    
    if (sideBar.tag == 1) {
        NSLog(@"Right SideBar will disappear");
        
    }
}



-(void)shaixuanFinishWithDic:(NSDictionary *)dic{
    self.shaixuanDic = dic;
    _isShaixuan = YES;
    
    GoneClassListViewController *cc = [[GoneClassListViewController alloc]init];
    cc.className = @"精品推荐";
    cc.isShowShaixuanData = YES;
    cc.haveChooseGender = YES;
    cc.shaixuanDic = self.shaixuanDic;
    [self.navigationController pushViewController:cc animated:YES];
}

-(void)therightSideBarDismiss{
    
    [self.rightSideBar dismiss];
}


@end
