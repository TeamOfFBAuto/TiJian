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
#import "MedicalOrderController.h"//预约体检
#import "AppointmentViewController.h"//预约
#import "ArticleListController.h"//健康资讯列表
#import "WebviewController.h"
#import "ArticleModel.h"
#import "LocationChooseViewController.h"//定位地区选择vc


#define kTagOrder 100 //体检预约
#define kTagMarket 101 //体检商城
#define kTagHealth 103 //健康资讯
#define kTagHealthList 102 //健康资讯列表


@interface HomeViewController ()

@property(nonatomic,retain)UIView *healthView;//背景view
@property(nonatomic,retain)UIImageView *icon_health;//健康咨询图标
@property(nonatomic,retain)UILabel *title_health;//健康咨询标题
@property(nonatomic,retain)UILabel *subTitle_health;//监控咨询摘要
@property(nonatomic,retain)ArticleModel *articleModel;

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
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
    
    UIScrollView *bgScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 48 - 64)];
    [self.view addSubview:bgScroll];
    
    UIImage *image = [UIImage imageNamed:@"homepage_1"];
    CGFloat radio = image.size.height / image.size.width;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(pushToPersonalCustom) forControlEvents:UIControlEventTouchUpInside];
    [bgScroll addSubview:btn];
    CGFloat width = DEVICE_WIDTH - 10 * 2;
    CGFloat height = width *radio;
    btn.frame = CGRectMake(10, 15, width, height);
    
    NSArray *images = @[[UIImage imageNamed:@"homepage_2"],
                        [UIImage imageNamed:@"homepage_3"],
                        [UIImage imageNamed:@"homepage_4"]];
    
    radio = 200.f / 120.f;//高/宽
    CGFloat width_small = (DEVICE_WIDTH - 10 * 4) / 3.f;
    CGFloat height_small = radio * width_small;
    CGFloat bottom = btn.bottom;
    for (int i = 0; i < 3; i ++) {
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn1 setImage:images[i] forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(clickToPush:) forControlEvents:UIControlEventTouchUpInside];
        btn1.frame = CGRectMake(10 + (width_small + 10) * i, btn.bottom, width_small, height_small);
        [bgScroll addSubview:btn1];
        btn1.tag = 100 + i;
        bottom = btn1.bottom;
    }
    
    //健康信息
    UIView *view_health = [[UIView alloc]initWithFrame:CGRectMake(0, bottom + 15, DEVICE_WIDTH, 77.5)];
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


#pragma mark - 定位相关 gm - start

//获取本地存储的位置信息
-(void)getLocalLocation{
    if ([GMAPI cacheForKey:USERLocation]) {
        NSDictionary *dic = [GMAPI cacheForKey:USERLocation];
        NSString *str;
        if ([[dic stringValueForKey:@"city"]intValue] == 0) {
            int theId = [[dic stringValueForKey:@"province"]intValue];
            str = [GMAPI cityNameForId:theId];
        }else{
            int theId = [[dic stringValueForKey:@"city"]intValue];
            str = [GMAPI cityNameForId:theId];
        }
        self.leftLabel.text = str;
        
//        [self creatTableView];
    }else{
        
        [self getjingweidu];
        
    }
}


//获取经纬度
-(void)getjingweidu{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusRestricted == status) {
        NSLog(@"kCLAuthorizationStatusRestricted 开启定位失败");
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"开启定位失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
        return;
    }else if (kCLAuthorizationStatusDenied == status){
        NSLog(@"请允许河马医生使用定位服务");
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请允许河马医生使用定位服务" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    
    [[GMAPI appDeledate]startDingweiWithBlock:^(NSDictionary *dic) {
        
        [weakSelf theLocationDictionary:dic];
    }];
    
}

- (void)theLocationDictionary:(NSDictionary *)dic{
    
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
    
    self.leftLabel.text = theString;
    int city_id = [GMAPI cityIdForName:theString];
    NSLog(@"city_id : %d",city_id);
    
    
    
    NSDictionary *cachDic = @{
                              @"province":[NSString stringWithFormat:@"%d",procinceId],
                              @"city":[NSString stringWithFormat:@"%d",cityId]
                              };
    [GMAPI cache:cachDic ForKey:USERLocation];
    
    
}




//创建navigation左边显示label
-(void)creatNavcLeftLabel{
    self.leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    self.leftLabel.textColor = DEFAULT_TEXTCOLOR;
    self.leftLabel.font = [UIFont systemFontOfSize:15];
    [self.leftLabel addTaget:self action:@selector(pushToLocationChoose) tag:0];
    self.leftLabel.text = @"北京";
    
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
#pragma mark - 定位相关 gm - end




#pragma - mark 网络请求

/**
 *  获取咨询文章
 */
- (void)getHealthArticlelist
{
    NSDictionary *params = @{@"page":@"1",@"per_page":@"1"};
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:HEALTH_ACTICAL_LIST parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
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
    [self.icon_health sd_setImageWithURL:[NSURL URLWithString:aModel.cover_pic] placeholderImage:DEFAULT_HEADIMAGE];
    self.title_health.text = aModel.title;
    self.subTitle_health.text = aModel.summary;
}

#pragma - mark 事件处理

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
    __weak typeof(self)weakSelf = self;
    BOOL isLogin = [LoginViewController isLogin:self loginBlock:^(BOOL success) {
       
        if (success) {
            [weakSelf pushToPhysicaResult];
        }else
        {
            NSLog(@"没登陆成功");
        }
    }];
    //登录成功
    if (isLogin) {
        
        [weakSelf pushToPhysicaResult];
    }
}

/**
 *  跳转至个性化定制页 或者 结果页
 */
- (void)pushToPhysicaResult
{
    //先判断是否个性化定制过
    BOOL isOver = [LTools cacheBoolForKey:USER_CUSTOMIZATON_RESULT];
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
    WebviewController *web = [[WebviewController alloc]init];
    web.webUrl = self.articleModel.url;
    web.moreInfo = YES;
    web.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];
}
/**
 *  监控资讯列表
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
        
    [LoginViewController loginToDoWithViewController:self loginBlock:^(BOOL success) {
        if (success) {
            [weakSelf loginToAppoint];
        }
    }];
    
//    MedicalOrderController *m_order = [[MedicalOrderController alloc]init];
//    m_order.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:m_order animated:YES];
}

- (void)loginToAppoint
{
    AppointmentViewController *m_order = [[AppointmentViewController alloc]init];
    m_order.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:m_order animated:YES];
}

@end
