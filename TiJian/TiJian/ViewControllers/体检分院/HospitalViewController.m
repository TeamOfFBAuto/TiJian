//
//  HospitalViewController.m
//  TiJian
//
//  Created by lichaowei on 16/1/26.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "HospitalViewController.h"
#import "HospitalDetailViewController.h"
#import "HospitalModel.h"

@interface HospitalViewController ()<RefreshDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    RefreshTableView *_table;
}
@property(nonatomic,retain)ResultView *result_view;
@property(nonatomic,retain)ResultView *fail_view;//失败view

@end

@implementation HospitalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"附近";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    //创建视图
    [self prepareRefreshTableView];
    //定位
    if ([GMAPI locationServiceEnabled]) {
        
//        [self getjingweidu];
        [_table showRefreshHeader:YES];
        
    }else
    {
        [self.result_view setContent:@"无法获取当前地址"];
        [_table reloadData:nil pageSize:10 noDataView:self.result_view];
        
        NSString *title = [NSString stringWithFormat:@"打开\"定位服务\"来允许\"%@\"确定您的位置",[LTools getAppName]];
        NSString *mes = @"以便获取附近分院信息";
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:mes delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建

-(ResultView *)fail_view
{
    if (_fail_view) {
        return _fail_view;
    }
        
    NSString *content = @"获取数据异常,点击重新加载";
    NSString *btnTitle = @"重新加载";
    SEL selector = @selector(clickToResfresh);
        
    
    ResultView *result = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"]
                                                    title:@"温馨提示"
                                                  content:content];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 140, 36);
    [btn addCornerRadius:5.f];
    btn.backgroundColor = DEFAULT_TEXTCOLOR;
    [btn setTitle:btnTitle forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [result setBottomView:btn];
    
    _fail_view = result;
    
    return result;
}


-(ResultView *)result_view
{
    if (!_result_view) {
        _result_view = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"]
                                                        title:@"温馨提示"
                                                      content:@"没有找到附近的分院!"];
    }
    return _result_view;
}

- (void)prepareRefreshTableView
{
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - HMFitIphoneX_navcBarHeight) style:UITableViewStylePlain];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
}

#pragma mark - 网络请求

//获取经纬度
-(void)getjingweidu
{
    __weak typeof(self)weakSelf = self;
    
    [[GMAPI appDeledate]startDingweiWithBlock:^(NSDictionary *dic) {
        
        [weakSelf theLocationDictionary:dic];
    }];
    
}

- (void)theLocationDictionary:(NSDictionary *)dic{
    
    NSLog(@"%@",dic);
    NSString *lat = [dic stringValueForKey:@"lat"];
    NSString *lon = [dic stringValueForKey:@"long"];
    
    [self netWorkForListWithLong:lon lat:lat];
}


- (void)netWorkForListWithLong:(NSString *)lon
                           lat:(NSString *)lat
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safeSetString:[GMAPI getCurrentProvinceId] forKey:@"province_id"];
    [params safeSetString:[GMAPI getCurrentCityId] forKey:@"city_id"];
    [params safeSetString:self.brand_id forKey:@"brand_id"];//品牌
    [params safeSetString:lon forKey:@"longitude"];
    [params safeSetString:lat forKey:@"latitude"];
    [params safeSetInt:_table.pageNum forKey:@"page"];
    [params safeSetInt:20 forKey:@"per_page"];
    
    NSString *api = Get_hospital_list;
    
    __weak typeof(self)weakSelf = self;
    __weak typeof(_table)weakTable = _table;
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        
        NSArray *temp = [HospitalModel modelsFromArray:result[@"list"]];
        [weakSelf.result_view setContent:@"没有找到附近的分院!"];
        [weakTable reloadData:temp pageSize:20 noDataView:self.result_view];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [weakTable reloadData:nil pageSize:20 noDataView:self.fail_view];
        
    }];
}

#pragma mark - 数据解析处理

#pragma mark - 事件处理

- (void)clickToResfresh
{
    DDLOG(@"refresh");
    [_table showRefreshHeader:YES];
}

#pragma mark - 代理

#pragma - mark RefreshDelegate <NSObject>

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    [self getjingweidu];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    [self getjingweidu];
}
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(RefreshTableView *)tableView
{
    HospitalModel *aModel = tableView.dataArray[indexPath.row];
    HospitalDetailViewController *hospital = [[HospitalDetailViewController alloc]init];
    hospital.centerId = aModel.exam_center_id;
    [self.navigationController pushViewController:hospital animated:YES];
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

- (UITableViewCell *)tableView:(RefreshTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"identify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    HospitalModel *aModel = tableView.dataArray[indexPath.row];
    NSString *centerName = aModel.center_name;
    NSString *title = [NSString stringWithFormat:@"%@(%@) %@",aModel.brand_name,centerName,[LTools distanceString:aModel.distance]];
    [cell.textLabel setAttributedText:[LTools attributedString:title keyword:centerName color:DEFAULT_TEXTCOLOR_TITLE_SUB]];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
