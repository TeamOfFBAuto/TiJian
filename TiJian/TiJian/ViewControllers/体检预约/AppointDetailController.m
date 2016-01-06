//
//  AppointDetailController.m
//  TiJian
//
//  Created by lichaowei on 15/11/17.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "AppointDetailController.h"
#import "AppointUpdateController.h"
#import "MapViewController.h"
#import "AppointModel.h"
#import "WebviewController.h"

#define kAlertTagPhone 100 //打电话
#define kAlertTagCancelAppoint 101 //取消预约

@interface AppointDetailController ()

@property(nonatomic,retain)UIScrollView *scroll;
@property(nonatomic,retain)UIView *bgView;//圆角背景
@property(nonatomic,retain)AppointModel *detailModel;

@end

@implementation AppointDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"预约详情";
//    self.rightImage = [UIImage imageNamed:@"personal_yuyue_xiugai"];
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    [self netWorkForList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actionForNotification:(NSNotification *)notify
{
    NSArray *subviews = [_scroll subviews];
    if (subviews.count > 0) {
        
        [subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [_scroll removeFromSuperview];
    _scroll = nil;
    
    [self netWorkForList];
}

#pragma mark - 视图创建

- (void)prepareView
{
    self.scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    _scroll.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT);
    [self.view addSubview:_scroll];
    
    //体检需知
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"yuyue_wenhao"] forState:UIControlStateNormal];
    [btn setTitle:@" 体检须知" forState:UIControlStateNormal];
    [btn setTitleColor:DEFAULT_TEXTCOLOR_TITLE_SUB forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    btn.frame = CGRectMake(DEVICE_WIDTH - 65 - 15, 20, 65, 13);
    [_scroll addSubview:btn];
    [btn addTarget:self action:@selector(clickToCare) forControlEvents:UIControlEventTouchUpInside];
    
    //距离体检时间
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.backgroundColor = [UIColor colorWithHexString:@"f88326"];
    btn2.frame = CGRectMake((DEVICE_WIDTH - 82)/2.f, btn.bottom, 82, 82);
    [btn2 addRoundCorner];
    btn2.clipsToBounds = YES;
    [_scroll addSubview:btn2];
    
    NSString *title1 = @"";
    NSString *title2 = @"";
    int expired = [_detailModel.expired intValue];
    if (expired == 1) {
        //过期
        title1 = [NSString stringWithFormat:@"已过期%@天",_detailModel.days];
        title2 = @"重新预约";
        [btn2 addTarget:self action:@selector(clickToAppointAgain) forControlEvents:UIControlEventTouchUpInside];
        
    }else
    {
        //未过期
        title1 = @"距体检";
        title2 = [NSString stringWithFormat:@"%@天",_detailModel.days];
        self.rightImage = [UIImage imageNamed:@"personal_yuyue_xiugai"];
        [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeOther];
    }
    if ([_detailModel.days intValue] > 0) {
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 82, 20) title:title1 font:12 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
        [btn2 addSubview:label1];
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, label1.bottom, 82, 20) title:title2 font:14 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
        [btn2 addSubview:label2];
    }else
    {
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 82, 20) title:title1 font:14 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
        label1.font = [UIFont boldSystemFontOfSize:14.f];
        [btn2 addSubview:label1];
        label1.text = @"今日体检";
    }
    
    //体检信息
    CGFloat left = 20.f;
    self.bgView = [[UIView alloc]initWithFrame:CGRectMake(left, btn2.centerY, DEVICE_WIDTH - left * 2, 300)];
    [_bgView addCornerRadius:5.f];
    _bgView.backgroundColor = [UIColor whiteColor];
    [_scroll addSubview:_bgView];
    
    [_scroll bringSubviewToFront:btn2];
    
    NSArray *titles = @[@"姓       名:",@"性       别:",@"年       龄:",@"身份证号:",@"体检时间:",@"体检分院:",@"分院电话:",@"体检内容:"];
    
    CGFloat bottom = 0.f;
    int count = (int)titles.count;
    for (int i = 0; i < count; i ++) {
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,50 + 45 * i, _bgView.width - 10 * 2, 45) title:titles[i] font:14 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE];
        [_bgView addSubview:contentLabel];
        
        NSString *title = titles[i];
        NSString *content = @"";
        if (i == 0) {
            
            content = self.detailModel.user_name;
            
        }else if (i == 1){
            content = [self.detailModel.gender intValue] == 1 ? @"男" : @"女";
            
        }else if (i == 2){
            
            content = self.detailModel.age;
            
        }else if (i == 3){
            
            content = self.detailModel.id_card;
            
        }else if (i == 4){
            
            content = [LTools timeString:_detailModel.appointment_exam_time withFormat:@"yyyy.MM.dd"];
            
        }else if (i == 5){
            content = self.detailModel.center_name;
        }else if (i == 6){
            
            content = self.detailModel.center_phone;
            
        }else if (i == 7){
            content = self.detailModel.setmeal_name;
        }
        
        NSString *sumString = [NSString stringWithFormat:@"%@  %@",title,content];
        
        [contentLabel setAttributedText:[LTools attributedString:sumString keyword:title color:DEFAULT_TEXTCOLOR_TITLE_THIRD]];
        
        /**
         *  加图标
         */
        
        if (i == 5 || i== 6) { //分院
            
            CGFloat width = [LTools widthForText:sumString font:14];
            CGFloat maxWidth = _bgView.width - 10 * 2 - 10 - 17;
            width = (width < maxWidth) ? width : maxWidth;
            contentLabel.width = width;
            
            UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(contentLabel.right + 10, contentLabel.top, 17, contentLabel.height)];
            icon.image = i == 5 ? [UIImage imageNamed:@"personal_yuyue_daohang"] : [UIImage imageNamed:@"personal_yuyue_dianhua"];
            icon.contentMode = UIViewContentModeCenter;
            [_bgView addSubview:icon];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(contentLabel.left, contentLabel.top, _bgView.width, contentLabel.height);
            if (i == 5) {
                [btn addTarget:self action:@selector(clickToMap) forControlEvents:UIControlEventTouchUpInside];
            }else
            {
                [btn addTarget:self action:@selector(clickToPhone) forControlEvents:UIControlEventTouchUpInside];
            }
            [_bgView addSubview:btn];
        }
        
        
        bottom = contentLabel.bottom;
    }
    
    _bgView.height = bottom + 20;
    
    bottom = _bgView.bottom + 15;
    
    if (expired != 1) {
        //未过期
        //取消预约
        UIButton *sender = [UIButton buttonWithType:UIButtonTypeCustom];
        [sender setTitle:@"取消预约" forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sender.titleLabel.font = [UIFont systemFontOfSize:14];
        sender.frame = CGRectMake(25, _bgView.bottom + 30, DEVICE_WIDTH - 50, 45);
        sender.backgroundColor = DEFAULT_TEXTCOLOR;
        [sender addTarget:self action:@selector(clickToCancelAppoint) forControlEvents:UIControlEventTouchUpInside];
        [_scroll addSubview:sender];
        
        bottom = sender.bottom + 15;
        
    }
    
    _scroll.contentSize = CGSizeMake(DEVICE_WIDTH, bottom > DEVICE_HEIGHT ? bottom : DEVICE_HEIGHT);
    
}

#pragma mark - 网络请求

- (void)netWorkForList
{
    NSString *authkey = [UserInfo getAuthkey];
    NSDictionary *params = @{@"authcode":authkey,
                             @"appoint_id":self.appoint_id};
    NSString *api = GET_APPOINT_DETAIL;
    
    __weak typeof(self)weakSelf = self;
//    __weak typeof(RefreshTableView *)weakTable = _table;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        [weakSelf parseDateWithResult:result];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

/**
 *  取消预约
 */
- (void)netWorkForCancelAppoint
{
    NSString *authkey = [UserInfo getAuthkey];
    NSDictionary *params = @{@"authcode":authkey,
                             @"appoint_id":self.appoint_id};
    NSString *api = CANCEL_APPOINT;
    
    __weak typeof(self)weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_APPOINT_CANCEL_SUCCESS object:nil];
        
        [LTools showMBProgressWithText:result[RESULT_INFO] addToView:weakSelf.view];
        
        [weakSelf performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}


#pragma mark - 数据解析处理

- (void)parseDateWithResult:(NSDictionary *)result
{
    self.detailModel = [[AppointModel alloc]initWithDictionary:result[@"appoint_info"]];
    [self prepareView];
}

#pragma mark - 事件处理

-(void)rightButtonTap:(UIButton *)sender
{
    [self clickToAppointAgain];
}

/**
 *  分院位置
 */
- (void)clickToMap
{
    NSLog(@"当前地址 %@ %@",_detailModel.center_latitude,_detailModel.center_longitude);
    MapViewController *map = [[MapViewController alloc]init];
    map.coordinate = CLLocationCoordinate2DMake([_detailModel.center_latitude floatValue], [_detailModel.center_longitude floatValue]);
    map.titleName = _detailModel.center_name;
//    UINavigationController *unVc = [[UINavigationController alloc]initWithRootViewController:map];
    [self presentViewController:map animated:YES completion:^{
//
    }];
    
//    [self.navigationController pushViewController:map animated:YES];
}

/**
 *  拨打电话
 *
 *  @param sender
 */
- (void)clickToPhone
{
    NSString *msg = [NSString stringWithFormat:@"拨打:%@",_detailModel.center_phone];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = kAlertTagPhone;
    [alert show];
}

- (void)clickToAppointAgain
{
    NSLog(@"重新预约");
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionForNotification:) name:NOTIFICATION_APPOINT_UPDATE_SUCCESS object:nil];
    
    AppointUpdateController *again = [[AppointUpdateController alloc]init];
    [again setParamsWithModel:_detailModel isAppointAgain:YES];
    [self.navigationController pushViewController:again animated:YES];
}

- (void)clickToCare
{
    NSLog(@"体检须知");
    
    WebviewController *web = [[WebviewController alloc]init];
    web.webUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,URL_TIJIANXUZHI];
    web.navigationTitle = @"体检须知";
    [self.navigationController pushViewController:web animated:YES];
}

/**
 *  取消预约
 */
- (void)clickToCancelAppoint
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"是否取消该体检预约" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    alert.tag = kAlertTagCancelAppoint;
    [alert show];
}

#pragma mark - 代理

#pragma - mark UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        
        if (alertView.tag == kAlertTagPhone) {
            
            NSString *msg = [NSString stringWithFormat:@"%@",_detailModel.center_phone];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",msg]]];
        }else if (alertView.tag == kAlertTagCancelAppoint){
            [self netWorkForCancelAppoint];
        }
    }
}


#pragma - mark RefreshDelegate <NSObject>

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    
}
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    return 44.f;
}

#pragma - mark UITableViewDataSource

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return tableView.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"identify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
