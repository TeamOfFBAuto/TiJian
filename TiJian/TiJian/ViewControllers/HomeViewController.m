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
#import "AppointmentViewController.h"//预约
#import "ArticleListController.h"//健康资讯列表
#import "WebviewController.h"
#import "ArticleModel.h"
#import "LocationChooseViewController.h"//定位地区选择vc
#import "ActivityView.h"//活动view
#import "ActivityModel.h"
//#import "NSDate+Additons.h"

#define kTagOrder 100 //体检预约
#define kTagMarket 101 //体检商城
#define kTagHealth 103 //健康资讯
#define kTagHealthList 102 //健康资讯列表


@interface HomeViewController ()
{
    NSArray *_activityArray;//活动列表
    int _unreadActivityNum;//未读活动总数
    
    NSDictionary *_needChangeLocationDic;//需要更改的用户定位信息
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
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNavigationStyle:NAVIGATIONSTYLE_WHITE title:@"健康体检"];
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
    
    UIScrollView *bgScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 48 - 64)];
    [self.view addSubview:bgScroll];
    
    CGFloat width_sum = DEVICE_WIDTH - 10 * 2;
    
    UIImage *image = [UIImage imageNamed:@"homepage_1"];
    
    CGFloat radio = image.size.height / image.size.width;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(pushToPersonalCustom) forControlEvents:UIControlEventTouchUpInside];
    [bgScroll addSubview:btn];
    CGFloat width = width_sum;
    CGFloat height = width *radio;
    btn.frame = CGRectMake(10, 15, width, height);
    
    NSArray *images = @[[UIImage imageNamed:@"homepage_2"],
                        [UIImage imageNamed:@"homepage_3"],
                        [UIImage imageNamed:@"homepage_4"]];
    
    
    CGFloat bottom = btn.bottom;
    for (int i = 0; i < 3; i ++) {
        
        UIImage *image = images[i];
        radio = image.size.height / image.size.width;//高/宽
        CGFloat width_small = (DEVICE_WIDTH - 10 * 4) / 3.f;
        CGFloat height_small = radio * width_small;
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn1 setBackgroundImage:image forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(clickToPush:) forControlEvents:UIControlEventTouchUpInside];
        btn1.frame = CGRectMake(10 + (width_small + 10) * i, btn.bottom + 10, width_small, height_small);
        [bgScroll addSubview:btn1];

        btn1.tag = 100 + i;
        bottom = btn1.bottom;
    }
    
    //健康信息
    UIView *view_health = [[UIView alloc]initWithFrame:CGRectMake(10, bottom + 15, DEVICE_WIDTH - 20, 77.5)];
    view_health.backgroundColor = [UIColor whiteColor];
    [bgScroll addSubview:view_health];
    [view_health addTaget:self action:@selector(clickToPush:) tag:kTagHealth];
    view_health.hidden = YES;//默认隐藏
    self.healthView = view_health;
    
    //图标
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(20, 13.5, 50, 50)];
    [icon addRoundCorner];
    icon.backgroundColor = DEFAULT_TEXTCOLOR;
    [view_health addSubview:icon];
    self.icon_health = icon;
    
    //标题
    CGFloat left = icon.right + 10;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(left, 25, DEVICE_WIDTH - left - 20, 14) title:nil font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [view_health addSubview:titleLabel];
    self.title_health = titleLabel;
    
    UILabel *subLabel = [[UILabel alloc]initWithFrame:CGRectMake(left, titleLabel.bottom + 8, DEVICE_WIDTH - left - 20, 12) title:nil font:11 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [view_health addSubview:subLabel];
    self.subTitle_health = subLabel;
    
    bgScroll.contentSize = CGSizeMake(DEVICE_WIDTH, view_health.bottom + 15);
    
    //获取健康咨询
    [self getHealthArticlelist];

    
    //定位相关
    [self creatNavcLeftLabel];
    [self getLocalLocation];
    
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

//开启定位 如果定位城市和用户左上角选择城市不同的话 提示是否修改
-(void)getLocalLocation
{
    //每次启动软件都会定位
    [self getjingweidu];

//    if ([GMAPI cacheForKey:USERLocation]) {
//        NSDictionary *dic = [GMAPI cacheForKey:USERLocation];
//        NSString *str;
//        if ([[dic stringValueForKey:@"city"]intValue] == 0) {
//            int theId = [[dic stringValueForKey:@"province"]intValue];
//            str = [GMAPI cityNameForId:theId];
//        }else{
//            int theId = [[dic stringValueForKey:@"city"]intValue];
//            
//            str = [GMAPI getCityNameOf4CityWithCityId:theId];
//            
//        }
//        self.leftLabel.text = str;
//        
//        [self getUnreadActivityNum];//获取未读消息
//        
//    }else{
//        
//        [self getjingweidu];
//        
//    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 25) {//切换定位城市的alerView
        if (buttonIndex == 0) {
            
        }else if (buttonIndex == 1){
            NSDictionary *cachDic = _needChangeLocationDic;
            [GMAPI cache:cachDic ForKey:USERLocation];
            [self updateLeftUpLocationStr];
        }
        
        
    }else{
        if (buttonIndex == 0) {
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
    
    NSLog(@"%@",dic);
    _locationDic = dic;
    NSLog(@"%@",_locationDic);
    
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
    
    
    
//    NSDictionary *lastDic = [GMAPI cacheForKey:USERLocation];
//    NSString *str;//存储的地区
//    if ([[lastDic stringValueForKey:@"city"]intValue] == 0) {
//        int theId = [[lastDic stringValueForKey:@"province"]intValue];
//        str = [GMAPI cityNameForId:theId];
//    }else{
//        int theId = [[lastDic stringValueForKey:@"city"]intValue];
//        str = [GMAPI getCityNameOf4CityWithCityId:theId];
//        
//    }

    
    if ([LTools isEmpty:theString]) {//定位失败
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
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否切换到定位城市" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
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
    self.leftLabel.text = @"正在定位...";
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


-(void)setLocationDataWithCityStr:(NSString *)city provinceStr:(NSString *)province{
    self.leftLabel.text = city;
    
    NSString *pStr = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:province]];
    NSString *cStr = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:city]];
    
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


#pragma mark - 定位相关 gm - end


#pragma mark - 视图创建

/**
 *  活动视图getter
 *
 *  @return
 */
-(ActivityView *)activityView
{
    if (!_activityView && _activityArray.count) {
        _activityView = [[ActivityView alloc]initWithActivityArray:_activityArray actionBlock:^(ActionStyle style,NSInteger index) {
            
            if (style == ActionStyle_Select) {
                
                ActivityModel *aModel = _activityArray[index];
                WebviewController *web = [[WebviewController alloc]init];
                web.webUrl = aModel.url;
                web.navigationTitle = @"活动详情";
                web.hidesBottomBarWhenPushed = YES;
                @WeakObj(self);
                web.updateParamsBlock = ^(NSDictionary *params){
                    //更新未读状态
                    if ([params[@"result"]boolValue]) {
                        
                        [Weakself getUnreadActivityNum];
                    }
                };
                [self.navigationController pushViewController:web animated:YES];
            }
        }];
    }
    return _activityView;
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

#pragma - mark 网络请求

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
    NSDictionary *params = @{@"page":@"1",@"per_page":@"1"};
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet
                                                   api:HEALTH_ACTICAL_LIST
                                            parameters:params
                                 constructingBodyBlock:nil
                                            completion:^(NSDictionary *result) {
        
        NSArray *temp = [ArticleModel modelsFromArray:result[@"article_list"]];
        [weakSelf setHealthViewWithModel:[temp lastObject]];
        
    } failBlock:^(NSDictionary *result) {
        
        
    }];
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
    }else if (tag == kTagMarket){
        //商城
        [self pushToShangCheng];
    }else if (tag == kTagHealth){
        //健康资讯
        [self pushToHealthNews];
    }else if (tag == kTagHealthList){
        //健康资讯列表
        [self pushToHealthNewsList];
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
-(void)pushToShangCheng{
    GStoreHomeViewController *cc= [[GStoreHomeViewController alloc]init];
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
}

/**
 *  健康资讯
 */
- (void)pushToHealthNews
{
    [MiddleTools pushToWebFromViewController:self weburl:self.articleModel.url title:nil moreInfo:YES hiddenBottom:YES];
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
    AppointmentViewController *m_order = [[AppointmentViewController alloc]init];
    m_order.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:m_order animated:YES];
}

@end
