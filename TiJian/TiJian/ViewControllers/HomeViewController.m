//
//  HomeViewController.m
//  TiJian
//jjklk
//  Created by lichaowei on 15/10/21.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "HomeViewController.h"
#import "PersonalCustomViewController.h"
#import "GStoreHomeViewController.h"
#import "RecommendMedicalCheckController.h"
#import "PhysicalTestResultController.h"
#import "AppointDirectController.h"//预约
#import "ArticleListController.h"//健康资讯列表
#import "WebviewController.h"
#import "ArticleModel.h"
#import "LocationChooseViewController.h"//定位地区选择vc
#import "VipAppointViewController.h"//转诊预约
#import "PeopleManageController.h"
#import "GoHealthProductlistController.h"//GO健康
#import "ActivityView.h"//活动view
#import "ActivityModel.h"
#import "DoctorModel.h"//对接专家医生model

#define kTagOrder 100 //体检预约
#define kTagMarket 101 //体检商城
#define kTagGoHealth 102 //go健康健康
#define kTagHealth 103 //健康资讯
#define kTagHealthList 104 //健康资讯列表

#define kTagGuahao 200 //挂号部分
#define kTagZiXun 201 //咨询台
#define kTagYueGuaHao 202 //约挂号
#define kTagKanZhuanJia 203 //看专家
#define kTagZhuanJiaWenZhen 204 //专家问诊

#define kTagDoctor 300 //专家
#define kTagRefreshDoctorlist 400 //刷新专家列表
#define kTagRefreshHealthInfolist 410 //刷新健康咨询列表

@interface HomeViewController ()<RefreshDelegate,UITableViewDataSource,LocationChooseDelegate>
{
    NSArray *_activityArray;//活动列表
    int _unreadActivityNum;//未读活动总数
    UIScrollView *_bgScrollView;//整个界面主容器
    RefreshTableView *_table;
    NSArray *_doctorList;//医生列表数据
    UIScrollView *_doctorScroll;//医生列表view
    
    NSDictionary *_needChangeLocationDic;//需要更改的用户定位信息
    
    UIImageView *_bannerCusImageView;//顶部个性化定制img view
}

@property(nonatomic,retain)UIView *healthView;//背景view
@property(nonatomic,retain)UIImageView *icon_health;//健康咨询图标
@property(nonatomic,retain)UILabel *title_health;//健康咨询标题
@property(nonatomic,retain)UILabel *subTitle_health;//监控咨询摘要
@property(nonatomic,retain)ArticleModel *articleModel;
@property(nonatomic,retain)UIView *redPoint;//未读活动红点
@property(nonatomic,retain)ActivityView *activityView;//活动view

@end

@implementation HomeViewController
{
    NSDictionary *_locationDic;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavigationStyle:NAVIGATIONSTYLE_WHITE title:@"海马医生"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.rightImage = [UIImage imageNamed:@"homepage_message"];
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeNull WithRightButtonType:MyViewControllerRightbuttonTypeOther];
    //默认活动按钮不显示,有活动再打开
    self.right_button.hidden = YES;
    
    //登录通知更新活动状态
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotification:) name:NOTIFICATION_LOGIN object:nil];
    //退出登录
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotification:) name:NOTIFICATION_LOGOUT object:nil];
    
    //更新左上角地区
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLeftUpLocationStr) name:NOTIFICATION_UPDATE_HOMEVCLEFTSTR object:nil];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
    
    //version 1.5及之前
//    [self prepareViewsVersionOne];
    //version 对接挂号
//    [self prepareViewsVersionTwo];
    //version 0425
    [self prepareRefreshTableView];
    [self prepareViewsVersionThree];

    //获取医生列表
    UIView *view = [self resultViewWithFrame:_doctorScroll.bounds title:nil tag:kTagRefreshDoctorlist];
    [_doctorScroll addSubview:view];
    [self loadDoctorListStartState:YES];
    [self getDoctorList];
    
    //获取健康咨询
    [self getHealthArticlelist];

    //定位相关
    [self creatNavcLeftLabel];
    [self getLocalLocation];
    
    //获取动态banner图片
    [self netWorkForHomeBanner];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 通知处理

- (void)actionForNotification:(NSNotification *)notification
{
    //登录通知
    if ([notification.name isEqualToString:NOTIFICATION_LOGIN] ||
        [notification.name isEqualToString:NOTIFICATION_LOGOUT]) {
        
        _activityArray = nil;
        [self getUnreadActivityNum];//更新活动未读状态
    }
}


#pragma mark - 定位相关 gm - start

//获取本地存储的位置信息
-(void)getLocalLocation
{
    //每次启动软件都会定位
    [self getjingweidu];

}


#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 25) {
        if (buttonIndex == 0) {
            
        }else if (buttonIndex == 1){
            NSDictionary *cachDic = _needChangeLocationDic;
            [GMAPI cache:cachDic ForKey:USERLocation];
            [self updateLeftUpLocationStr];
        }
    }else{
        
        //可以定位时,定位完再请求活动;不能定位时,点击取消或者设置时请求获取活动
        [self getUnreadActivityNum];
        
        if (buttonIndex == 0)
        {
            
        }else if (buttonIndex == 1){
            
            if (IOS8_OR_LATER) {
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: UIApplicationOpenSettingsURLString]];
            }else
            {
                NSString *title = [NSString stringWithFormat:@"定位服务开启"];
                NSString *mes = [NSString stringWithFormat:@"请在系统设置中开启定位服务\n设置->隐私->定位服务->%@",[LTools getAppName]];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:mes delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }
}


//获取经纬度
-(void)getjingweidu{
    
    //定位
    if ([GMAPI locationServiceEnabled]) {
        
        __weak typeof(self)weakSelf = self;
        
        [[GMAPI appDeledate]startDingweiWithBlock:^(NSDictionary *dic) {
            
            [weakSelf theLocationDictionary:dic];
        }];
        
    }else{
        NSString *title = [NSString stringWithFormat:@"打开\"定位服务\"来允许\"%@\"确定您的位置",[LTools getAppName]];
        NSString *mes = nil;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:mes delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    }
}
    


- (void)theLocationDictionary:(NSDictionary *)dic{
    
    //定位完再请求活动
    [self getUnreadActivityNum];
    
    _locationDic = dic;
    
    NSString *theString;
    
    int cityId = 0;
    int procinceId = 0;
    if ([[dic stringValueForKey:@"province"]isEqualToString:@"北京市"] || [[dic stringValueForKey:@"province"]isEqualToString:@"上海市"] || [[dic stringValueForKey:@"province"]isEqualToString:@"天津市"] || [[dic stringValueForKey:@"province"]isEqualToString:@"重庆市"]) {
        theString = [dic stringValueForKey:@"province"];
        procinceId = [GMAPI cityIdForName:theString];
        cityId = 0;
    }else{
        theString = [dic stringValueForKey:@"city"];
        procinceId =[GMAPI cityIdForName:[dic stringValueForKey:@"province"]];
        cityId = [GMAPI cityIdForName:[dic stringValueForKey:@"city"]];
    }
    
    if ([LTools isEmpty:theString]) {//定位失败
        [GMAPI showAutoHiddenMBProgressWithText:@"获取当前位置失败" addToView:self.view];
        NSDictionary *lastDic = [GMAPI cacheForKey:USERLocation];//上次存储的位置信息
        if (lastDic) {//本地存储的有地区信息
            NSString *str;//存储的地区
            if ([[lastDic stringValueForKey:@"city"]intValue] == 0) {
                int theId = [[lastDic stringValueForKey:@"province"]intValue];
                str = [GMAPI cityNameForId:theId];
            }else{
                int theId = [[lastDic stringValueForKey:@"city"]intValue];
                str = [GMAPI getCityNameOf4CityWithCityId:theId];
            }
            self.leftLabel.text = str;
        }else{
            [GMAPI showAutoHiddenMBProgressWithText:@"定位失败，默认为北京" addToView:self.view];
            self.leftLabel.text = @"北京市";
            NSDictionary *cachDic = @{
                                      @"province":[NSString stringWithFormat:@"%d",1000],
                                      @"city":[NSString stringWithFormat:@"%d",1005]
                                      };
            [GMAPI cache:cachDic ForKey:USERLocation];
        }
        
    }else{//定位成功
        
        NSDictionary *lastDic = [GMAPI cacheForKey:USERLocation];//上次存储的位置信息
        if (lastDic) {//本地存储的有地区信息
            NSString *str;//存储的地区
            if ([[lastDic stringValueForKey:@"city"]intValue] == 0) {
                int theId = [[lastDic stringValueForKey:@"province"]intValue];
                str = [GMAPI cityNameForId:theId];
            }else{
                int theId = [[lastDic stringValueForKey:@"city"]intValue];
                str = [GMAPI getCityNameOf4CityWithCityId:theId];
            }
            
            if ([str isEqualToString:theString]) {//存储的城市和定位城市相同
                
            }else{
                NSString *alStr = [NSString stringWithFormat:@"是否切换到当前定位城市:%@",theString];
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:alStr delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                al.tag = 25;
                al.delegate = self;
                [al show];
                NSDictionary *cachDic = @{
                                          @"province":[NSString stringWithFormat:@"%d",procinceId],
                                          @"city":[NSString stringWithFormat:@"%d",cityId]
                                          };
                _needChangeLocationDic = cachDic;                
            }
        }else{//没有存储地区信息
            self.leftLabel.text = theString;
            NSDictionary *cachDic = @{
                                      @"province":[NSString stringWithFormat:@"%d",procinceId],
                                      @"city":[NSString stringWithFormat:@"%d",cityId]
                                      };
            [GMAPI cache:cachDic ForKey:USERLocation];
        }
        
        
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_HOMEVCLEFTSTR object:nil];
    
}




//创建navigation左边显示label
-(void)creatNavcLeftLabel{
    self.leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    NSDictionary *lastDic = [GMAPI cacheForKey:USERLocation];//上次存储的位置信息
    if (lastDic) {//有选择的地区
        NSString *str;
        if ([[lastDic stringValueForKey:@"city"]intValue] == 0) {
            int theId = [[lastDic stringValueForKey:@"province"]intValue];
            str = [GMAPI cityNameForId:theId];
        }else{
            int theId = [[lastDic stringValueForKey:@"city"]intValue];
            str = [GMAPI getCityNameOf4CityWithCityId:theId];
        }
        self.leftLabel.text = str;
    }else{
        self.leftLabel.text = @"正在定位...";
    }
    
    self.leftLabel.textColor = DEFAULT_TEXTCOLOR;
    self.leftLabel.font = [UIFont systemFontOfSize:15];
    [self.leftLabel addTaget:self action:@selector(pushToLocationChoose) tag:0];
    
    
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc]initWithCustomView:self.leftLabel];
    self.navigationItem.leftBarButtonItem = leftBar;
}

//跳转到定位区域选择vc
-(void)pushToLocationChoose{
    LocationChooseViewController *cc = [[LocationChooseViewController alloc]init];
    cc.delegate = self;
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
}


#pragma mark - LocationChooseDelegate

-(void)afterChooseCity:(NSString *)theCity province:(NSString *)theProvince{
    self.leftLabel.text = theCity;
    
    NSString *pStr = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:theProvince]];
    NSString *cStr = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:theCity]];
    
    if ([pStr isEqualToString:cStr]) {
        cStr = @"0";
    }
    
    NSDictionary *dic = @{
                          @"province":pStr,
                          @"city":cStr
                          };
    [GMAPI cache:dic ForKey:USERLocation];
}


/**
 *  更新左上角地区信息
 */
-(void)updateLeftUpLocationStr{
    NSDictionary *dic = [GMAPI cacheForKey:USERLocation];
    
    NSString *cityName;
    
    NSString *city_id = [dic stringValueForKey:@"city"];
    NSString *province_id = [dic stringValueForKey:@"province"];
    if ([city_id intValue] == 0) {
        cityName = [GMAPI cityNameForId:[province_id intValue]];
    }else{
        cityName = [GMAPI cityNameForId:[city_id intValue]];
    }
    
    if ([province_id intValue] == 1000 || [province_id intValue] == 1100 || [province_id intValue] == 1200 || [province_id intValue] == 1300) {
        cityName = [GMAPI cityNameForId:[province_id intValue]];
    }
    
    self.leftLabel.text = cityName;
    
}

#pragma mark - 网络请求

/**
 *  获取首页banner信息
 */
- (void)netWorkForHomeBanner
{
    NSString *api = Get_cus_img;
    
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        
        NSString *img_url = result[@"img_url"];
        [LTools setObject:img_url forKey:HomePage_cus_img];//缓存imageurl
        [_bannerCusImageView l_setImageWithURL:[NSURL URLWithString:img_url] placeholderImage:[weakSelf cacheBannerImage]];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        
    }];
}

/**
 *  获取活动列表
 *
 *  @param
 */
- (void)getActivity
{
    NSString *api = Get_Activity_list;
    
    NSDictionary *params = nil;
    NSString *authey = [UserInfo getAuthkey];
    if (authey.length > 0) {
        params = @{@"authcode":authey};
    }
    
    @WeakObj(self);
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *list = result[@"activity"];
        NSArray *temp = [ActivityModel modelsFromArray:list];
        _activityArray = [NSArray arrayWithArray:temp];
        if (_activityArray.count) {
            
            [Weakself.activityView show];
        }else
        {
            [LTools showMBProgressWithText:@"精彩活动敬请期待！" addToView:Weakself.view];
        }
        
    } failBlock:^(NSDictionary *result) {
        
    }];
}

/**
 *  获取未读活动数量
 *
 *  @param
 */
- (void)getUnreadActivityNum
{
    
    NSString *api = Get_Show_activity;
    
    NSDictionary *params = nil;
    NSString *authey = [UserInfo getAuthkey];
    if (authey.length > 0) {
        params = @{@"authcode":authey};
    }
    
    @WeakObj(self);
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet
                                                   api:api parameters:params
                                 constructingBodyBlock:nil
                                            completion:^(NSDictionary *result) {
                                                
                                                int num = [result[@"num"]intValue];
                                                int show = [result[@"show"]intValue];
                                                _unreadActivityNum = num;
                                                //首页未读活动数量
                                                [LTools setObject:[NSNumber numberWithInt:num] forKey:USER_Ac_Num];//未读消息个数
                                                Weakself.right_button.hidden =  show == 1 ? NO : YES;//打开活动按钮
                                                Weakself.redPoint.hidden = num > 0 ? NO : YES;
                                                
                                                //存储最新的msgId,用于判断是否需要自动弹出
                                                
                                                //上次的
                                                NSInteger lastActivityId = [[LTools objectForKey:USER_READED_NEWESTMSGID]integerValue];
                                                NSString *latest_activity_id = result[@"latest_activity_id"];
                                                //说明有比上次更新的活动
                                                if ([latest_activity_id integerValue] > lastActivityId) {
                                                    
                                                    [LTools setObject:latest_activity_id forKey:USER_READED_NEWESTMSGID];
                                                    
                                                    [Weakself getActivity];
                                                }
                                                
                                            } failBlock:^(NSDictionary *result) {
                                                
                                            }];
}

/**
 *  获取咨询文章
 */
- (void)getHealthArticlelist
{
    NSDictionary *params = @{@"page":NSStringFromInt(_table.pageNum),@"per_page":@"5"};
    @WeakObj(_table);
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet
                                                   api:HEALTH_ACTICAL_LIST
                                            parameters:params
                                 constructingBodyBlock:nil
                                            completion:^(NSDictionary *result)
     {
         NSArray *temp = [ArticleModel modelsFromArray:result[@"article_list"]];
         UIView *resultView = [self resultViewWithFrame:_doctorScroll.bounds title:@"没有获取到健康资讯数据！" tag:kTagRefreshHealthInfolist];
         [Weak_table reloadData:temp pageSize:5 CustomNoDataView:resultView];
         [self loadHealthInfoStartState:NO];
         
         
     } failBlock:^(NSDictionary *result) {
         [Weak_table loadFailWithCustomView:[self resultViewWithFrame:_doctorScroll.bounds title:result[RESULT_INFO] tag:kTagRefreshHealthInfolist] pageSize:5];
         [self loadHealthInfoStartState:NO];
         
     }];
}

/**
 *  获取专家医生列表
 */
- (void)getDoctorList
{
    NSDictionary *params = @{@"page":NSStringFromInt(_table.pageNum),@"per_page":@"5"};
    @WeakObj(self);
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet
                                                   api:Guahao_doctorlist
                                            parameters:params
                                 constructingBodyBlock:nil
                                            completion:^(NSDictionary *result)
     {
         [Weakself createDoctorViewWithResult:result];
         [self loadDoctorListStartState:NO];
         
     } failBlock:^(NSDictionary *result) {
         
         [Weakself createDoctorViewWithResult:result];
         [self loadDoctorListStartState:NO];
         
     }];
}

#pragma mark - 视图创建

- (void)prepareRefreshTableView
{
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0  , DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 49)
                                              style:UITableViewStylePlain
                                refreshHeaderHidden:YES];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
}

//- (void)prepareViewsVersionOne
//{
//    UIScrollView *bgScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 48 - 64)];
//    [self.view addSubview:bgScroll];
//    _bgScrollView = bgScroll;
//    
//    CGFloat width_sum = DEVICE_WIDTH - 10 * 2;
//    
//    UIImage *image = [UIImage imageNamed:@"homepage_1"];
//    
//    CGFloat radio = image.size.height / image.size.width;
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setBackgroundImage:image forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(pushToPersonalCustom) forControlEvents:UIControlEventTouchUpInside];
//    [bgScroll addSubview:btn];
//    CGFloat width = width_sum;
//    CGFloat height = width *radio;
//    btn.frame = CGRectMake(10, 0, width, height);
//    
//    NSArray *images = @[[UIImage imageNamed:@"homepage_2"],
//                        [UIImage imageNamed:@"homepage_3"],
//                        [UIImage imageNamed:@"homepage_4"]];
//    
//    
//    CGFloat bottom = btn.bottom;
//    for (int i = 0; i < 3; i ++) {
//        
//        UIImage *image = images[i];
//        radio = image.size.height / image.size.width;//高/宽
//        CGFloat width_small = (DEVICE_WIDTH - 10 * 4) / 3.f;
//        CGFloat height_small = radio * width_small;
//        
//        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
//        [btn1 setBackgroundImage:image forState:UIControlStateNormal];
//        [btn1 addTarget:self action:@selector(clickToPush:) forControlEvents:UIControlEventTouchUpInside];
//        btn1.frame = CGRectMake(10 + (width_small + 10) * i, btn.bottom + 10, width_small, height_small);
//        [bgScroll addSubview:btn1];
//        
//        btn1.tag = 100 + i;
//        bottom = btn1.bottom;
//    }
//    
//    //健康信息
//    UIView *view_health = [[UIView alloc]initWithFrame:CGRectMake(10, bottom + 15, DEVICE_WIDTH - 20, 77.5)];
//    view_health.backgroundColor = [UIColor whiteColor];
//    [bgScroll addSubview:view_health];
//    [view_health addTaget:self action:@selector(clickToPush:) tag:kTagHealth];
//    view_health.hidden = YES;//默认隐藏
//    self.healthView = view_health;
//    
//    //图标
//    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(20, 13.5, 50, 50)];
//    [icon addRoundCorner];
//    icon.backgroundColor = DEFAULT_TEXTCOLOR;
//    [view_health addSubview:icon];
//    self.icon_health = icon;
//    
//    //标题
//    CGFloat left = icon.right + 10;
//    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(left, 25, DEVICE_WIDTH - left - 20, 14) title:nil font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
//    [view_health addSubview:titleLabel];
//    self.title_health = titleLabel;
//    
//    UILabel *subLabel = [[UILabel alloc]initWithFrame:CGRectMake(left, titleLabel.bottom + 8, DEVICE_WIDTH - left - 20, 12) title:nil font:11 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
//    [view_health addSubview:subLabel];
//    self.subTitle_health = subLabel;
//    
//    bgScroll.contentSize = CGSizeMake(DEVICE_WIDTH, view_health.bottom + 15);
//    
//    
//    
//        //挂号网对接测试
//        //1~14
//        NSArray *items = @[@"预约挂号",
//                           @"转诊预约",
//                           @"健康顾问团",
//                           @"公立医院主治医生",
//                           @"公立医院权威专家",
//                           @"我的问诊",
//                           @"我的预约",
//                           @"我的转诊",
//                           @"我的关注",
//                           @"家庭联系人",
//                           @"家庭病例",
//                           @"我的申请",
//                           @"医生随访",
//                           @"购药订单"];
//    
//        int count = (int)items.count;
//        CGFloat width_btn = (DEVICE_WIDTH- 20) / 3.f ;
//        for (int i = 0; i < count; i ++) {
//    
//            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//            [btn setTitle:items[i] forState:UIControlStateNormal];
//            [bgScroll addSubview:btn];
//            [btn setTintColor:DEFAULT_TEXTCOLOR_TITLE];
//            btn.frame = CGRectMake(5 + (i % 3) * (width_btn + 5), view_health.bottom + 10 + 50 * (i / 3), width_btn, 45);
//            btn.backgroundColor = DEFAULT_TEXTCOLOR;
//            btn.titleLabel.font = [UIFont systemFontOfSize:12];
//            bottom = btn.bottom;
//            btn.tag = 500 + i + 1;//从1开始
//            [btn addTarget:self action:@selector(clickToGuaHao:) forControlEvents:UIControlEventTouchUpInside];
//        }
//        bgScroll.contentSize = CGSizeMake(DEVICE_WIDTH, bottom + 15);
//}
//
//- (void)prepareViewsVersionTwo
//{
//    UIScrollView *bgScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 48 - 64)];
//    [self.view addSubview:bgScroll];
//    _bgScrollView = bgScroll;
//    
//    CGFloat width_sum = DEVICE_WIDTH;
//    UIImage *image = [UIImage imageNamed:@"homepage_gexinghua"];
//    
//    CGFloat radio = image.size.height / image.size.width;
//    
//    //个性定制
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setBackgroundImage:image forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(pushToPersonalCustom) forControlEvents:UIControlEventTouchUpInside];
//    [bgScroll addSubview:btn];
//    CGFloat width = width_sum;
//    CGFloat height = width *radio;
//    btn.frame = CGRectMake(0, 0, width, height);
//    
//    //体检预约、体检商城入口
//    
//    NSArray *images = @[[UIImage imageNamed:@"homepage_tijianyuyue"],
//                        [UIImage imageNamed:@"homepage_shangcheng"]];
//    NSArray *titles = @[@" 体检预约",@" 体检商城"];
//    NSArray *titles_sub = @[@"足不出户 快速预约",@"体检套餐 任你挑选"];
//    
//    CGFloat bottom = btn.bottom;
//    for (int i = 0; i < images.count; i ++) {
//        
//        CGFloat width_small = DEVICE_WIDTH / 2.f;
//        CGFloat height_small = width_small / 2.f;
//        
//        UIButton *classBtn = [self classViewFrame:CGRectMake((width_small + 0.5) * i, btn.bottom + 10, width_small, height_small)
//                                            image:images[i]
//                                            title:titles[i]
//                                         subTitle:titles_sub[i]
//                                         imageTop:25
//                                         titleDis:5
//                                              tag:100 + i];
//        [bgScroll addSubview:classBtn];
//        
//        if (i == 0) {
//            //line
//            UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(classBtn.right, classBtn.top, 0.5, classBtn.height)];
//            line.backgroundColor = DEFAULT_LINECOLOR;
//            [bgScroll addSubview:line];
//        }
//        
//        bottom = classBtn.bottom;
//        
//    }
//    //预约商城底部line
//    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, bottom, DEVICE_WIDTH, 0.5)];
//    line.backgroundColor = DEFAULT_LINECOLOR;
//    [bgScroll addSubview:line];
//    
//    //挂号部分 就医服务
//    UIView *view_guhao = [[UIView alloc]initWithFrame:CGRectMake(0, bottom + 10, DEVICE_WIDTH, 150.f)];
//    view_guhao.backgroundColor = [UIColor whiteColor];
//    [bgScroll addSubview:view_guhao];
//    
//    //标题
//    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, DEVICE_WIDTH - 30, 40) font:15 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:@"就医服务"];
//    [view_guhao addSubview:textLabel];
//    
//    //标题底下line
//    line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 40, DEVICE_WIDTH, 0.5)];
//    line.backgroundColor = DEFAULT_LINECOLOR;
//    [view_guhao addSubview:line];
//    
//    //=====免费咨询、在线问诊、预约挂号、精准预约
////    CGFloat radio_w_h = 140.f / 110.f;//宽比高
//    CGFloat radio_section1 = 5.f/13.f;//第一部分宽度比例
////    CGFloat radio_section2 = 8.f/13.f;//第二部分宽度比例
//    
//    //免费咨询
//    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn1 addTarget:self action:@selector(clickToPush:) forControlEvents:UIControlEventTouchUpInside];
//    btn1.frame = CGRectMake(0, line.bottom, DEVICE_WIDTH * radio_section1, view_guhao.height - line.bottom - 0.5);
//    btn1.backgroundColor = [UIColor whiteColor];
//    btn1.tag = kTagGuahao;
//    [view_guhao addSubview:btn1];
//    
//    UIButton *btn_image = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn_image setImage:[UIImage imageNamed:@"homepage_mianfeizixun"] forState:UIControlStateNormal];
//    [btn1 addSubview:btn_image];
//    btn_image.frame = CGRectMake(0, 22, btn1.width, 25);
//    btn_image.userInteractionEnabled = NO;
//    [btn1 addSubview:btn_image];
//    
//    UILabel *textLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(0, btn_image.bottom + 12, btn_image.width, 15) font:14 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE title:@"免费咨询"];
//    [btn1 addSubview:textLabel1];
//    UILabel *textLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, textLabel1.bottom + 3, btn_image.width, 13) font:12 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:@"解决您的困惑"];
//    [btn1 addSubview:textLabel2];
//    
//    
//    
//    //竖分割line
//    line = [[UIImageView alloc]initWithFrame:CGRectMake(btn1.right, btn1.top, 0.5, btn1.height)];
//    line.backgroundColor = DEFAULT_LINECOLOR;
//    [view_guhao addSubview:line];
//    
//    //在线问诊、预约挂号、精准预约
//    images = @[[UIImage imageNamed:@"homepage__zaixianwenzhen"],
//               [UIImage imageNamed:@"homepage_yuyueguahao"],
//               [UIImage imageNamed:@"homepage_jingzhunyuyue"]];
//    titles = @[@" 在线问诊",@" 预约挂号",@" 精准预约"];
//    titles_sub = @[@"问题在这里解答",@"看病不用排队",@"找到好医生"];
//    
//    UIButton *tempBtn;
//    for (int i = 0; i < 3; i ++) {
//        
//        CGRect frame = CGRectZero;
//        if (i == 0) {
//            frame = CGRectMake(line.right, line.top, DEVICE_WIDTH - line.right, line.height/2.f);
//            //line
//            UIView *line_s = [[UIImageView alloc]initWithFrame:CGRectMake(line.right, line.top + line.height/2.f, DEVICE_WIDTH - line.right, 0.5)];
//            line_s.backgroundColor = DEFAULT_LINECOLOR;
//            [view_guhao addSubview:line_s];
//            
//        }else if (i == 1)
//        {
//            frame = CGRectMake(line.right, tempBtn.bottom + 0.5, tempBtn.width/2.f, tempBtn.height - 0.5);
//            //line
//            UIView *line_s = [[UIImageView alloc]initWithFrame:CGRectMake(line.right + tempBtn.width/2.f, tempBtn.bottom + 0.5, 0.5, tempBtn.height - 0.5)];
//            line_s.backgroundColor = DEFAULT_LINECOLOR;
//            [view_guhao addSubview:line_s];
//        }else
//        {
//            frame = CGRectMake(tempBtn.right + 0.5, tempBtn.top, tempBtn.width - 0.5, tempBtn.height);
//        }
//        UIButton *classBtn = [self classViewFrame:frame
//                                            image:images[i]
//                                            title:titles[i]
//                                         subTitle:titles_sub[i]
//                                         imageTop:6
//                                         titleDis:3
//                                              tag:kTagGuahao + i + 1];
//        [view_guhao addSubview:classBtn];
//        tempBtn = classBtn;
//
//    }
//    
//    //底部line
//    line = [[UIImageView alloc]initWithFrame:CGRectMake(0, view_guhao.height - 0.5, DEVICE_WIDTH, 0.5)];
//    line.backgroundColor = DEFAULT_LINECOLOR;
//    [view_guhao addSubview:line];
//    
//    //健康信息
//    UIView *view_health = [[UIView alloc]initWithFrame:CGRectMake(0, view_guhao.bottom + 10, DEVICE_WIDTH, 80.f)];
//    view_health.backgroundColor = [UIColor whiteColor];
//    [bgScroll addSubview:view_health];
//    [view_health addTaget:self action:@selector(clickToPush:) tag:kTagHealth];
//    view_health.hidden = YES;//默认隐藏
//    self.healthView = view_health;
//    
//    //图标
//    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 90, 60)];
//    [icon addRoundCorner];
//    icon.backgroundColor = DEFAULT_TEXTCOLOR;
//    [view_health addSubview:icon];
//    [icon addCornerRadius:4.f];
//    self.icon_health = icon;
//    
//    //标题
//    CGFloat left = icon.right + 10;
//    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(left, 25, DEVICE_WIDTH - left - 20, 14) title:nil font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
//    [view_health addSubview:titleLabel];
//    self.title_health = titleLabel;
//    
//    UILabel *subLabel = [[UILabel alloc]initWithFrame:CGRectMake(left, titleLabel.bottom + 8, DEVICE_WIDTH - left - 20, 12) title:nil font:11 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
//    [view_health addSubview:subLabel];
//    self.subTitle_health = subLabel;
//    
//    bgScroll.contentSize = CGSizeMake(DEVICE_WIDTH, view_health.bottom + 15);
//}

/**
 *  获取默认的首页个性化定制banner
 *
 *  @return
 */
- (UIImage *)cacheBannerImage
{
    NSString *imgUrl = [LTools objectForKey:HomePage_cus_img];
    UIImage *cacheImage;//
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    //存在换成图片
    if ([manager cachedImageExistsForURL:[NSURL URLWithString:imgUrl]]) {
        
        NSString *key = [manager cacheKeyForURL:[NSURL URLWithString:imgUrl]];
        cacheImage = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:key];
    }else
    {
        cacheImage = [UIImage imageNamed:@"homepage_banner"];
    }
    return cacheImage;
}

- (void)prepareViewsVersionThree
{
    UIView *bgScroll = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 49 - 64)];
    bgScroll.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgScroll];
    
    CGFloat width_sum = DEVICE_WIDTH;
    
    UIImage *cacheImage = [self cacheBannerImage];//缓存图片
    
    CGFloat radio = cacheImage.size.height / cacheImage.size.width;
    
    //个性定制
    UIImageView *btn = [[UIImageView alloc]init];
    btn.userInteractionEnabled = YES;
    btn.image = [self cacheBannerImage];
    [bgScroll addSubview:btn];
    
    btn.backgroundColor = [UIColor whiteColor];
    CGFloat width = width_sum;
    CGFloat height = width *radio;
    btn.frame = CGRectMake(0, 0, width, height);
    
    [btn addTaget:self action:@selector(pushToPersonalCustom) tag:0];
    
    _bannerCusImageView = btn;
    
    //体检预约、体检商城入口
    
    NSArray *images = @[[UIImage imageNamed:@"homepage_tijianyuyue"],
                        [UIImage imageNamed:@"homepage_shangcheng"],
                        [UIImage imageNamed:@"homepage_shangmen"]];
    NSArray *titles = @[@" 体检预约",@" 体检商城",@" 上门体检"];
//    NSArray *titles_sub = @[@"足不出户 快速预约",@"体检套餐 任你挑选"];
    
    CGFloat bottom = btn.bottom;
    
    CGFloat width_small = DEVICE_WIDTH / images.count;
    
    CGFloat radio_small = 250.f/150.f;//宽比高
    
    CGFloat height_small = width_small / radio_small;
    
    for (int i = 0; i < images.count; i ++) {
        
        UIButton *classBtn = [self classViewStyleOneFrame:CGRectMake((width_small + 0.5) * i, btn.bottom, width_small, height_small)
                                            image:images[i]
                                            title:titles[i]
                                         subTitle:nil
                                         imageTop:25
                                         titleDis:5
                                              tag:100 + i];
        [bgScroll addSubview:classBtn];
        if (i != images.count - 1) {
            //line
            UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(classBtn.right, classBtn.top, 0.5, classBtn.height)];
            line.backgroundColor = DEFAULT_LINECOLOR;
            [bgScroll addSubview:line];
        }
        
        bottom = classBtn.bottom;
        
    }
    //预约商城底部line
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, bottom, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [bgScroll addSubview:line];
    
    //挂号部分 就医服务
    UIView *view_guhao = [[UIView alloc]initWithFrame:CGRectMake(0, bottom + 10, DEVICE_WIDTH, 150.f)];
    view_guhao.backgroundColor = [UIColor whiteColor];
    [bgScroll addSubview:view_guhao];
    
    //标题
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, DEVICE_WIDTH - 15, 40) font:15 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:@"就医服务"];
    [view_guhao addSubview:textLabel];
    
    //标题底下line
    line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 40, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [view_guhao addSubview:line];
   
    
    //在线问诊、预约挂号、精准预约
    images = @[[UIImage imageNamed:@"homepage_kanzhuanjia"],
               [UIImage imageNamed:@"homepage_yueguahao"],
               [UIImage imageNamed:@"homepage_zixuntai"]
               ];
    titles = @[@"专家号",@"普通号",@"咨询台"];
    NSArray *titles_sub = @[@"全国专家 快速预约",@"足不出户 挂号看病",@"公立医院 免费问诊"];
    CGFloat width_section = (DEVICE_WIDTH - 1) / 3.f;
    CGFloat top = line.bottom;
    for (int i = 0; i < 3; i ++) {
        //免费咨询
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn1 addTarget:self action:@selector(clickToPush:) forControlEvents:UIControlEventTouchUpInside];
        btn1.frame = CGRectMake((width_section + 0.5) * i, top, width_section, view_guhao.height - top - 0.5);
        btn1.backgroundColor = [UIColor whiteColor];
        [view_guhao addSubview:btn1];
        if (i == 0) {
            btn1.tag = kTagKanZhuanJia;
        }else if (i == 1){
            btn1.tag = kTagYueGuaHao;
        }else if (i == 2){
            btn1.tag = kTagZiXun;
        }
        
        UIButton *btn_image = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn_image setImage:images[i] forState:UIControlStateNormal];
        [btn1 addSubview:btn_image];
        btn_image.frame = CGRectMake(0, 22, btn1.width, 25);
        btn_image.userInteractionEnabled = NO;
        [btn1 addSubview:btn_image];
        
        UILabel *textLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(0, btn_image.bottom + 12, btn_image.width, 15) font:14 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE title:titles[i]];
        [btn1 addSubview:textLabel1];
        UILabel *textLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, textLabel1.bottom + 3, btn_image.width, 13) font:12 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:titles_sub[i]];
        [btn1 addSubview:textLabel2];
        
        //竖分割line
        line = [[UIImageView alloc]initWithFrame:CGRectMake(btn1.right, btn1.top, 0.5, btn1.height)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [view_guhao addSubview:line];
    }
    
    //底部line
    line = [[UIImageView alloc]initWithFrame:CGRectMake(0, view_guhao.height - 0.5, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [view_guhao addSubview:line];
    
    //--------------专家问诊----------
    UIView *view_zhuanjia = [[UIView alloc]initWithFrame:CGRectMake(0, view_guhao.bottom, DEVICE_WIDTH, 150.f)];
    view_zhuanjia.backgroundColor = [UIColor whiteColor];
    [bgScroll addSubview:view_zhuanjia];
    
    //标题
    textLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, DEVICE_WIDTH - 15, 40) font:15 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:@"专家问诊"];
    [view_zhuanjia addSubview:textLabel];
    [textLabel addTaget:self action:@selector(clickToPush:) tag:kTagZhuanJiaWenZhen];

    //箭头
    UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 35, 0, 35, 40)];
    arrow.image = [UIImage imageNamed:@"personal_jiantou_r"];
    arrow.contentMode = UIViewContentModeCenter;
    [view_zhuanjia addSubview:arrow];
    
    //标题底下line
    line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 150 - 0.5, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [view_zhuanjia addSubview:line];
    
    //专家医生列表部分
    UIScrollView *docScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 40, view_zhuanjia.width, 90)];
    docScroll.backgroundColor = [UIColor whiteColor];
    docScroll.showsHorizontalScrollIndicator = NO;
    docScroll.bounces = NO;
    [view_zhuanjia addSubview:docScroll];
    _doctorScroll = docScroll;
    
    bgScroll.height = view_zhuanjia.bottom + 10;
    
    _table.tableHeaderView = bgScroll;
}

- (UIButton *)classViewFrame:(CGRect)frame
                     image:(UIImage *)image
                     title:(NSString *)title
                  subTitle:(NSString *)subTitle
                    imageTop:(CGFloat)imageTop
                    titleDis:(CGFloat)titleDis
                       tag:(int)tag
{
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 addTarget:self action:@selector(clickToPush:) forControlEvents:UIControlEventTouchUpInside];
    btn1.frame = frame;
    btn1.backgroundColor = [UIColor whiteColor];
    
    btn1.tag = tag;
    
    UIButton *btn_class = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_class setImage:image forState:UIControlStateNormal];
    [btn_class setTitle:title forState:UIControlStateNormal];
    [btn1 addSubview:btn_class];
    
    btn_class.frame = CGRectMake(0, imageTop, btn1.width, 25);
    [btn_class.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [btn_class setTitleColor:DEFAULT_TEXTCOLOR_TITLE forState:UIControlStateNormal];
    btn_class.userInteractionEnabled = NO;
    
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, btn_class.bottom + titleDis, btn_class.width, 14) font:13 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:subTitle];
    [btn1 addSubview:textLabel];
    
    return btn1;
}

/**
 *  左image右title
 *
 *  @param frame
 *  @param image
 *  @param title
 */
- (UIButton *)classViewStyleOneFrame:(CGRect)frame
                       image:(UIImage *)image
                       title:(NSString *)title
                    subTitle:(NSString *)subTitle
                    imageTop:(CGFloat)imageTop
                    titleDis:(CGFloat)titleDis
                         tag:(int)tag
{
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 addTarget:self action:@selector(clickToPush:) forControlEvents:UIControlEventTouchUpInside];
    btn1.frame = frame;
    btn1.backgroundColor = [UIColor whiteColor];
    
    btn1.tag = tag;
    
    UIButton *btn_class = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_class setImage:image forState:UIControlStateNormal];
    [btn_class setTitle:title forState:UIControlStateNormal];
    [btn1 addSubview:btn_class];
    
    btn_class.frame = CGRectMake(0, imageTop, btn1.width, 25);
    [btn_class.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [btn_class setTitleColor:DEFAULT_TEXTCOLOR_TITLE forState:UIControlStateNormal];
    btn_class.userInteractionEnabled = NO;
    
    return btn1;
}

/**
 *  专家列表view
 *
 *
 *  @return View
 */
- (UIView *)doctorViewWithIndex:(int)index
                    doctorModel:(DoctorModel *)dModel
                            width:(CGFloat)width
{
    NSString *imageUrl = dModel.photo;
    NSString *docName = dModel.name;
    NSString *className = dModel.hospDeptNameHL;
    
    UIView *docView = [[UIView alloc]initWithFrame:CGRectMake(width * index, 5, width, 90)];
    docView.backgroundColor = [UIColor whiteColor];
    [docView addTaget:self action:@selector(clickToDoctorDetail:) tag:kTagDoctor + index];
    //头像
    UIImageView *iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 8, 37, 37)];
    [iconImage addRoundCorner];
    iconImage.backgroundColor = [UIColor orangeColor];
    [iconImage l_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:DEFAULT_HEADIMAGE];
    iconImage.centerX = docView.width / 2.f;
    [docView addSubview:iconImage];
    //名字
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, iconImage.bottom + 5, docView.width, 14) font:13 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE title:docName];
    [docView addSubview:nameLabel];
    
    //科室
    UILabel *classLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, nameLabel.bottom + 5, docView.width, 13) font:12 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:className];
    [docView addSubview:classLabel];
    return docView;
}

/**
 *  创建医生列表view
 *
 *  @param result
 */
- (void)createDoctorViewWithResult:(NSDictionary *)result
{
    [self removeDoctorlistResultView];

    int erroCode = [result[RESULT_CODE]intValue];
    if (erroCode == 0) {
        NSArray *temp = [DoctorModel modelsFromArray:result[@"doctor_list"]];
        if (temp.count == 0) {
            
            NSString *errInfo = @"没有获取到可用专家医生";
            DDLOG(@"%@",errInfo);
            UIView *view = [self resultViewWithFrame:_doctorScroll.bounds title:errInfo tag:kTagRefreshDoctorlist];
            [_doctorScroll addSubview:view];
            return;
        }
        
        _doctorList = [NSArray arrayWithArray:temp];
        int sum = (int)_doctorList.count;
        CGFloat width_d = DEVICE_WIDTH / 5.f;
        for (int i = 0; i < sum; i ++) {
            DoctorModel *dModel = _doctorList[i];
            UIView *dView = [self doctorViewWithIndex:i doctorModel:dModel width:width_d];
            [_doctorScroll addSubview:dView];
        }
        _doctorScroll.contentSize = CGSizeMake(width_d * sum, 90);
    }else
    {
        NSString *errInfo = result[RESULT_INFO];
        UIView *view = [self resultViewWithFrame:_doctorScroll.bounds title:errInfo tag:kTagRefreshDoctorlist];
        [_doctorScroll addSubview:view];
    }
}

/**
 *  医生列表、健康咨询列表 异常情况处理页面
 *
 *  @param frame
 *  @param title
 *  @param tag
 *
 *  @return
 */
- (UIView *)resultViewWithFrame:(CGRect)frame
                          title:(NSString *)title
                            tag:(int)tag
{
    UIView *view = [[UIView alloc]initWithFrame:_doctorScroll.bounds];
    
    UIView *contentView = [[UIView alloc]initWithFrame:view.bounds];
    [view addSubview:contentView];
    contentView.tag = tag + 1;
    [contentView addTaget:self action:@selector(clickToRefreshData:) tag:tag];

    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 25,DEVICE_WIDTH, 20) font:14 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:title];
    [contentView addSubview:label];
    
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(0, label.bottom + 10, 25, 25)];
    icon.image = [UIImage imageNamed:@"refresh"];
    [contentView addSubview:icon];
    icon.centerX = view.width / 2.f;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithFrame:view.frame];
    [view addSubview:indicator];
    indicator.hidden = YES;
    indicator.color = DEFAULT_TEXTCOLOR_TITLE;
    indicator.tag = tag + 2;
    
    return view;
}

/**
 *  控制
 *
 *  @param start
 */
- (void)loadHealthInfoStartState:(BOOL)start
{
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self.view viewWithTag:kTagRefreshHealthInfolist + 2];
    UIView *refreshView = (UIView *)[self.view viewWithTag:kTagRefreshHealthInfolist + 1];
    if (start) {
        
        [indicator startAnimating];
        indicator.hidden = NO;
        refreshView.hidden = YES;
//        DDLOG(@"start");
        
    }else
    {
        [indicator stopAnimating];
        indicator.hidden = YES;
        refreshView.hidden = NO;
//        DDLOG(@"end");

    }
}

/**
 *  控制
 *
 *  @param start
 */
- (void)loadDoctorListStartState:(BOOL)start
{
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[_doctorScroll viewWithTag:kTagRefreshDoctorlist + 2];
    UIView *refreshView = (UIView *)[_doctorScroll viewWithTag:kTagRefreshDoctorlist + 1];
    if (start) {
        
        [indicator startAnimating];
        indicator.hidden = NO;
        refreshView.hidden = YES;
        
    }else
    {
        [indicator stopAnimating];
        indicator.hidden = YES;
        refreshView.hidden = NO;
    }
}

- (void)removeDoctorlistResultView
{
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[_doctorScroll viewWithTag:kTagRefreshDoctorlist + 2];
    if (indicator) {
        [indicator removeFromSuperview];
        indicator = nil;
    }
    UIView *refreshView = (UIView *)[_doctorScroll viewWithTag:kTagRefreshDoctorlist + 1];
    if (refreshView) {
        [refreshView removeFromSuperview];
        refreshView = nil;
    }
}

/**
 *  刷新医生列表或者健康资讯
 *
 *  @param sender
 */
- (void)clickToRefreshData:(UIButton *)sender
{
    int tag = (int)sender.tag;
    if (tag == kTagRefreshHealthInfolist) { //健康资讯
        
        [self loadHealthInfoStartState:YES];
        [self getHealthArticlelist];
        
    }else if (tag == kTagRefreshDoctorlist){ //医生列表
        [self loadDoctorListStartState:YES];
        [self getDoctorList];
    }
}

/**
 *  活动视图getter
 *
 *  @return
 */
-(ActivityView *)activityView
{
    if (!_activityView && _activityArray.count) {
        
         @WeakObj(self);
        _activityView = [[ActivityView alloc]initWithActivityArray:_activityArray actionBlock:^(ActionStyle style,NSInteger index) {
            
            if (style == ActionStyle_Select) {
                
                ActivityModel *aModel = _activityArray[index];
                [Weakself pushToActivityModel:aModel];
            }
        }];
    }
    return _activityView;
}

/**
 *  跳转至活动详情
 *
 *  @param aModel
 */
- (void)pushToActivityModel:(ActivityModel *)aModel
{
    NSString *shareImageUrl = aModel.cover_pic;
    NSString *shareTitle = aModel.title;
    NSString *shareContent = aModel.summary;
    NSDictionary *params = @{Share_imageUrl:shareImageUrl ? : @"",
                             Share_title:shareTitle,
                             Share_content:shareContent};
    @WeakObj(self);
    [MiddleTools pushToWebFromViewController:self weburl:aModel.url extensionParams:params moreInfo:YES hiddenBottom:YES updateParamsBlock:^(NSDictionary *params) {
        //更新未读状态
        if ([params[@"result"]boolValue]) {
            
            [Weakself getUnreadActivityNum];
        }
    }];
}

/**
 *  未读消息红点
 *
 *  @return
 */
-(UIView *)redPoint
{
    if (!_redPoint) {
        
        CGFloat width = 10.f;
        UIView *point = [[UIView alloc]initWithFrame:CGRectMake(self.right_button.width - width/2.f, -width/2.f, width, width)];
        [self.right_button addSubview:point];
        _redPoint = point;
        point.backgroundColor = [UIColor colorWithHexString:@"ec2120"];
        [point setBorderWidth:1.5f borderColor:[UIColor whiteColor]];
        [point addRoundCorner];
    }
    return _redPoint;
}


/**
 *  健康资讯赋值
 *
 *  @param aModel
 */
- (void)setHealthViewWithModel:(ArticleModel *)aModel
{
    self.healthView.hidden = NO;
    self.articleModel = aModel;
    [self.icon_health l_setImageWithURL:[NSURL URLWithString:aModel.cover_pic] placeholderImage:DEFAULT_HEADIMAGE];
    self.title_health.text = aModel.title;
    self.subTitle_health.text = aModel.summary;
}

#pragma - mark 事件处理

-(void)rightButtonTap:(UIButton *)sender
{
    if (_activityArray.count) {
        
        [self.activityView show];
        
    }else
    {
        [self getActivity];//为空时请求活动
    }
    
//    [MiddleTools pushToWebFromViewController:self weburl:@"htttp://www.open-open.com/lib/view/open1408609311366.html" title:@"企业体检" moreInfo:NO hiddenBottom:YES];
}

- (void)clickToPush:(UIButton *)sender
{
    int tag = (int)sender.tag;
    if (tag == kTagOrder) {
        //预约
        [self pushToOrder];
    }else if (tag == kTagMarket)
    {
        //商城
        [self pushToShangCheng];
        
    }else if (tag == kTagGoHealth)
    {
        //上门体检
        [self clickToGoHealth];
        
    }else if (tag == kTagHealth)
    {
        //健康资讯
        [self pushToHealthNews];
        
    }else if (tag == kTagHealthList)
    {
        //健康资讯列表
        [self pushToHealthNewsList];
        
    }else if (tag == kTagZiXun)
    {
        //咨询台 对应 公立医院主治医生 target 4
        [self clickToGuaHaoType:4];
        
    }else if (tag == kTagYueGuaHao)
    {
        //约挂号：预约挂号 target 1
        [self clickToGuaHaoType:1];
        
    }else if (tag == kTagKanZhuanJia)
    {
        //看专家：转诊预约 target 2 需要先选择家属联系人
        
         @WeakObj(self);
        [LoginManager isLogin:self loginBlock:^(BOOL success) {
            if (success) {
                [Weakself pushToVipAppoint];
            }
        }];
        
    }else if (tag == kTagZhuanJiaWenZhen)
    {
        //专家问诊： 公立医院权威专家  target 5
        [self clickToGuaHaoType:5];
    }
}



/**
 *  个性化定制
 */
- (void)pushToPersonalCustom
{
//    __weak typeof(self)weakSelf = self;
//    [LoginViewController isLogin:self loginBlock:^(BOOL success) {
//
//        if (success) {
//            [weakSelf pushToPhysicaResult];
//        }else
//        {
//            NSLog(@"没登陆成功");
//        }
//    }];
    
    [self pushToPhysicaResult];//个性化定制不需要登录,登录之后选择是否同步
}

/**
 *  跳转至个性化定制页 或者 结果页
 */
- (void)pushToPhysicaResult
{
    //友盟统计
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic safeSetValue:@"首页" forKey:@"fromPage"];
    [[MiddleTools shareInstance]umengEvent:@"Customization" attributes:dic number:[NSNumber numberWithInt:1]];
    
    //先判断是否个性化定制过
    BOOL isOver = [UserInfo getCustomState];
    if (isOver) {
        //已经个性化定制过
        PhysicalTestResultController *physical = [[PhysicalTestResultController alloc]init];
        physical.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:physical animated:YES];
    }else
    {
        PersonalCustomViewController *custom = [[PersonalCustomViewController alloc]init];
        custom.lastViewController = self;
        custom.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:custom animated:YES];
    }
}

/**
 *  商城
 */
-(void)pushToShangCheng
{
//    NSString *mobile = [UserInfo userInfoForCache].mobile;
//    NSString *name = [UserInfo userInfoForCache].real_name;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic safeSetValue:@"HomeViewController" forKey:@"style"];
//    [dic safeSetValue:mobile forKey:@"mobile"];
//    [dic safeSetValue:name forKey:@"name"];
    [[MiddleTools shareInstance]umengEvent:@"Store_home" attributes:dic number:[NSNumber numberWithInt:1]];
    
    GStoreHomeViewController *cc= [[GStoreHomeViewController alloc]init];
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
}


/**
 *  健康资讯
 */
- (void)pushToHealthNews
{
    [MiddleTools pushToWebFromViewController:self weburl:self.articleModel.url title:nil moreInfo:NO hiddenBottom:YES];
}
/**
 *  资讯列表
 */
- (void)pushToHealthNewsList
{
    ArticleListController *list = [[ArticleListController alloc]init];
    list.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:list animated:YES];
}

/**
 *  预约体检
 */
- (void)pushToOrder
{
    __weak typeof(self)weakSelf = self;
        
    [LoginViewController isLogin:self loginBlock:^(BOOL success) {
        if (success) {
            [weakSelf loginToAppoint];
        }
    }];
}

- (void)loginToAppoint
{
    AppointDirectController *m_order = [[AppointDirectController alloc]init];
    m_order.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:m_order animated:YES];
}

/**
 *  点击跳转至挂号网对接
 *
 *  @param btn
 */
- (void)clickToGuaHao:(UIButton *)btn
{
    int type = (int)btn.tag - 500;
    WebviewController *web = [[WebviewController alloc]init];
    web.guaHao = YES;
    web.type = type;
    web.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];

}

#pragma - mark 挂号对接处理

- (void)loginToGunHaoType:(int)type
{
    __weak typeof(self)weakSelf = self;
    [LoginViewController isLogin:self loginBlock:^(BOOL success) {
        if (success) {
            [weakSelf clickToGuaHaoType:type];
        }
    }];
}
/**
 *  点击跳转至挂号网对接
 *
 *  @param btn
 */
- (void)clickToGuaHaoType:(int)type
{
    
    [LoginManager isLogin:self loginBlock:^(BOOL success) {
        if (success) {
            [self pushToGuaHaoType:type familyuid:nil];
        }
    }];
}

/**
 *  点击跳转至挂号网对接
 *
 *  @param btn
 */
- (void)pushToGuaHaoType:(int)type
               familyuid:(NSString *)familyuid
{
    WebviewController *web = [[WebviewController alloc]init];
    web.guaHao = YES;
    web.type = type;
    web.familyuid = familyuid;
    web.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];
}

/**
 *  跳转至专家医生详情
 *
 *  @param
 */
- (void)clickToDoctorDetail:(UIButton *)sender
{
    int index = (int)sender.tag - kTagDoctor;
    __weak typeof(self)weakSelf = self;
    [LoginViewController isLogin:self loginBlock:^(BOOL success) {
        if (success) {
            [weakSelf pushToDoctorDetailWithIndex:index];
        }
    }];
}

- (void)pushToDoctorDetailWithIndex:(int)index
{
    DoctorModel *dModel = _doctorList[index];
    WebviewController *web = [[WebviewController alloc]init];
    web.guaHao = YES;
    web.type = 20;
    web.detail_url = dModel.detail_url;
    web.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];
}

/**
 *  跳转至转诊预约(VIP) 专家号
 */
- (void)pushToVipAppoint
{
    VipAppointViewController *vip = [[VipAppointViewController alloc]init];
    vip.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vip animated:YES];
}

#pragma mark - GO健康

/**
 *  GO健康
 */
- (void)clickToGoHealth
{
    GoHealthProductlistController *goHealth = [[GoHealthProductlistController alloc]init];
    goHealth.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:goHealth animated:YES];
}

#pragma mark - 代理

#pragma - mark RefreshDelegate <NSObject>

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    [self getHealthArticlelist];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    [self getHealthArticlelist];
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    ArticleModel *article = _table.dataArray[indexPath.row];
    
    NSString *shareImageUrl = article.cover_pic;
    NSString *shareTitle = article.title;
    NSString *shareContent = article.summary;
    NSDictionary *params = @{Share_imageUrl:shareImageUrl ? : @"",
                             Share_title:shareTitle,
                             Share_content:shareContent};
    [MiddleTools pushToWebFromViewController:self weburl:article.url extensionParams:params moreInfo:YES hiddenBottom:YES updateParamsBlock:nil];
}

- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    return 76.f;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(RefreshTableView *)tableView
{
    UIView *view_zhuanjia = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
    view_zhuanjia.backgroundColor = [UIColor whiteColor];
    [view_zhuanjia addTaget:self action:@selector(clickToPush:) tag:kTagHealthList];
    
    //标题
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, DEVICE_WIDTH - 30, 40) font:15 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:@"健康资讯"];
    [view_zhuanjia addSubview:textLabel];
    
    //箭头
    UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 35, 0, 35, 40)];
    arrow.image = [UIImage imageNamed:@"personal_jiantou_r"];
    arrow.contentMode = UIViewContentModeCenter;
    [view_zhuanjia addSubview:arrow];
    return view_zhuanjia;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(RefreshTableView *)tableView
{
    return 40.f;
}


#pragma - mark UITableViewDataSource

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return tableView.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"healthInfo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 76.f)];
        view.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:view];
        
        //图
        UIImageView *iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 8, 90, 60)];
        iconImage.image = [UIImage imageNamed:@"report_b"];
        iconImage.contentMode = UIViewContentModeCenter;
        iconImage.backgroundColor = [UIColor redColor];
        [iconImage addCornerRadius:4.f];
        [view addSubview:iconImage];
        iconImage.tag = 300;
        
        //标题
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(iconImage.right + 10, 11, DEVICE_WIDTH - iconImage.right - 10 - 15, 16) title:nil font:15 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE];
        [view addSubview:titleLabel];
        titleLabel.tag = 301;
        
        //摘要
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(iconImage.right + 10, titleLabel.bottom + 5, titleLabel.width, 30) title:nil font:12 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB];
        [view addSubview:contentLabel];
//        contentLabel.numberOfLines = 2.f;
        contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        contentLabel.tag = 302;
        
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(15, 76 - 0.5, DEVICE_WIDTH - 15, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [cell.contentView addSubview:line];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    
    UIImageView *iconImage = [cell.contentView viewWithTag:300];
    UILabel *titleLabel = [cell.contentView viewWithTag:301];
    UILabel *contentLabel = [cell.contentView viewWithTag:302];
    
    ArticleModel *aModel = [_table.dataArray objectAtIndex:indexPath.row];
    titleLabel.text = aModel.title;
    contentLabel.text = aModel.summary;
    [iconImage l_setImageWithURL:[NSURL URLWithString:aModel.cover_pic] placeholderImage:DEFAULT_HEADIMAGE];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
