//
//  PhysicalTestResultController.m
//  TiJian
//
//  Created by lichaowei on 15/11/4.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "PhysicalTestResultController.h"
#import "RecommendMedicalCheckController.h"
#import "PersonalCustomViewController.h"

@interface PhysicalTestResultController ()<UIAlertViewDelegate>
{
    UIView *_bgView;
    Gender _gender;
    UIImageView *_genderImageView;//显示男女
    BOOL _isAddedObserver;//是否加过观察者
}

@property(nonatomic,retain)ResultView *result_View;
@property(nonatomic,retain)UIButton *leftBtn;
@property(nonatomic,retain)UIButton *rightBtn;

@end

@implementation PhysicalTestResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self setNavigationStyle:NAVIGATIONSTYLE_BLUE title:@"测试结果"];
    self.myTitle = @"测试结果";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    [self getCustomizationResult];
    
}

#pragma mark - 视图创建

- (void)creatNodataView
{
    ResultView *result = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"]
                                                    title:@""
                                                  content:nil];
    [self.view addSubview:result];
    self.result_View = result;
    
    result.centerY = self.view.height / 2.f - 50;
    
    CGFloat width = DEVICE_WIDTH / 3.f;
    CGFloat aver = width / 5.f;
    for (int i = 0; i < 2; i ++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(aver * 2 + (width + aver) * i, result.bottom + 35, width, 35);
        [self.view addSubview:btn];
        [btn addCornerRadius:2.f];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        if (i == 0) {
            [btn setBorderWidth:0.5 borderColor:DEFAULT_TEXTCOLOR];
            [btn setTitle:@"返回" forState:UIControlStateNormal];
            [btn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(leftButtonTap:) forControlEvents:UIControlEventTouchUpInside];
            self.leftBtn = btn;
        }else
        {
            [btn setBorderWidth:0.5 borderColor:[UIColor colorWithHexString:@"ec7d24"]];
            [btn setTitle:@"" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithHexString:@"ec7d24"] forState:UIControlStateNormal];
            self.rightBtn = btn;
        }
    }
}

/**
 *  正常结果界面
 */
- (void)createViews
{
    if (self.result_View) {
        [self.result_View removeFromSuperview];
        self.result_View = nil;
    }
    if (self.leftBtn) {
        [self.leftBtn removeFromSuperview];
        self.leftBtn = nil;
    }
    
    if (self.rightBtn) {
        [self.rightBtn removeFromSuperview];
        self.rightBtn = nil;
    }
    
    if (_bgView) {
        
        //只更新小人
        _genderImageView.image = _gender == Gender_Boy ? [UIImage imageNamed:@"result_nan"] : [UIImage imageNamed:@"result_nv"];
        return;
    }
    
    _bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    [self.view addSubview:_bgView];
    
    NSString *title = @"已经完成测试,快来看看结果吧";
    
    CGFloat top = 40;
    if (iPhone5 || iPhone4) {
        
        top =  10;
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, top, DEVICE_WIDTH, 35) title:title font:13 align:NSTextAlignmentCenter textColor:DEFAULT_TEXTCOLOR];
    [_bgView addSubview:label];
    
    //小手
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(0, label.bottom, 17.5, 25)];
    icon.image = [UIImage imageNamed:@"xiaoshou"];
    [_bgView addSubview:icon];
    icon.centerX = DEVICE_WIDTH / 2.f;
    
    //小人
    CGFloat width = FitScreen(138);
    CGFloat height = FitScreen(275);
    
    if (iPhone4) {
        
        width *= 0.6;
        height *= 0.6;
    }
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    imageView.image = _gender == Gender_Boy ? [UIImage imageNamed:@"result_nan"] : [UIImage imageNamed:@"result_nv"];
    [_bgView addSubview:imageView];
    imageView.centerY = _bgView.height/2.f;
    imageView.centerX = _bgView.width /2.f;
    _genderImageView = imageView;
    
    //是否按钮
    CGFloat left = FitScreen(40);
    CGFloat dis = FitScreen(14);
    CGFloat btn_width = DEVICE_WIDTH - left * 2 - dis;
    btn_width /= 2;
    UIButton *btn_no = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_no setTitle:@"否,再测一次" forState:UIControlStateNormal];
    [_bgView addSubview:btn_no];
    btn_no.frame = CGRectMake(left, imageView.bottom + 30, btn_width, 33);
    [btn_no setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_no setBackgroundColor:DEFAULT_TEXTCOLOR];
    [btn_no.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [btn_no addTarget:self action:@selector(clickToTest:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn_yes = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_yes setTitle:@"是,立即查看" forState:UIControlStateNormal];
    [_bgView addSubview:btn_yes];
    btn_yes.frame = CGRectMake(btn_no.right + dis, imageView.bottom + 30, btn_width, 33);
    [btn_yes setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_yes setBackgroundColor:[UIColor colorWithHexString:@"ec7d23"]];
    [btn_yes.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [btn_yes addTarget:self action:@selector(clickToQuestionResult) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取个性化基本信息

/**
 *  获取个性定制结果
 */
- (void)getCustomizationResult
{
    NSString *authey = [UserInfo getAuthkey];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *api;
    
    //获取最近体检结果
    [params safeSetString:[GMAPI getCurrentProvinceId] forKey:@"province_id"];
    [params safeSetString:[GMAPI getCurrentCityId] forKey:@"city_id"];
    [params safeSetString:authey forKey:@"authcode"];
    [params safeSetString:@"1" forKey:@"basic"];//获取基本数据
    api = GET_LATEST_CUSTOMIZATION_RESULT;
    
    __weak typeof(self)weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        NSDictionary *param = result[@"data"];
        if ([LTools isDictinary:param]) {
            _gender = [param[@"gender"]intValue];
            [self createViews];
        }
        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        //未进行个性化定制
        int tag = [result[RESULT_CODE]intValue];
        if ( tag == 2010) {
            
            [weakSelf actionForFailWithTag:tag msg:result[RESULT_INFO]];
        }
    }];
}


#pragma mark - 事件处理

- (void)actionForFailWithTag:(NSInteger)tag
                         msg:(NSString *)msg
{
    NSString *title = msg;
    NSString *right;
    
    if (_bgView) {
        for (UIView *view in _bgView.subviews) {
            [view removeFromSuperview];
        }
        [_bgView removeFromSuperview];
        _bgView = nil;
    }
    
    [self creatNodataView];
    self.result_View.title = title;

    if (tag == 2010) { //未个性化定制
        right = @"个性化定制";
        [self.rightBtn setTitle:@"个性化定制" forState:UIControlStateNormal];
        [self.rightBtn addTarget:self action:@selector(clickToTest:) forControlEvents:UIControlEventTouchUpInside];
    }else
    {
        right = @"刷新";
        [self.rightBtn setTitle:@"刷新" forState:UIControlStateNormal];
        [self.rightBtn addTarget:self action:@selector(getCustomizationResult) forControlEvents:UIControlEventTouchUpInside];
    }
}

//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 1) {
//        
//        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
//        if ([title isEqualToString:@"刷新"]) {
//            
//            [self getCustomizationResult];
//            
//        }else if ([title isEqualToString:@"个性化定制"]){
//            
//            [self clickToTest:nil];
//        }
//    }
//}


/**
 *  去个性化定制
 *
 *  @param btn
 */
- (void)clickToTest:(UIButton *)btn
{
    if (!_isAddedObserver) {
        
       [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotification:) name:NOTIFICATION_PersonalCustomization_SUCCESS object:nil];
        _isAddedObserver = YES;
    }
    
    PersonalCustomViewController *custom = [[PersonalCustomViewController alloc]init];
    custom.lastViewController = self;
    [self.navigationController pushViewController:custom animated:YES];
}

- (void)actionForNotification:(NSNotification *)notification
{
    //个性化定制
    if ([notification.name isEqualToString:NOTIFICATION_PersonalCustomization_SUCCESS]) {
        
        [self getCustomizationResult];
    }
}

/**
 *  去推荐项目
 */
- (void)clickToQuestionResult
{
    RecommendMedicalCheckController *recommend = [[RecommendMedicalCheckController alloc]init];
//    recommend.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:recommend animated:YES];
}

@end
