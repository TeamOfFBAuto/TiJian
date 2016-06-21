//
//  GoHealthChooseCityViewController.m
//  TiJian
//
//  Created by gaomeng on 16/6/16.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GoHealthChooseCityViewController.h"
#import "RefreshTableView.h"

@interface GoHealthChooseCityViewController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_tab;
    
    YJYRequstManager *_request;
    
    NSArray *_provinceArray;
    NSMutableArray *_citiesArray;
    NSArray *_districtArray;
    int _isOpen[500];
}
@end

@implementation GoHealthChooseCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.myTitle = @"选择预约地址";
    
    [self creatTab];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUserSelectCityBlock:(userSelectCityBlock)userSelectCityBlock{
    _userSelectCityBlock = userSelectCityBlock;
}


#pragma mark - 请求网络数据
-(void)prepareNetData{
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *nonceStr = [LTools randomNum:32];//随机字符串
    [params safeSetValue:nonceStr forKey:@"nonceStr"];
    [params safeSetValue:GoHealthAppId forKey:@"appId"];
    
    NSString *sign = [MiddleTools goHealthSignWithParams:params];
    [params safeSetValue:sign forKey:@"sign"];
//    [params safeSetString:self.productId forKey:@"productionIds"];
    
    
    __weak typeof (self)bself = self;
    
    [_request requestWithMethod:YJYRequstMethodGet_goHealth api:GoHealth_citylist parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [bself setCityDataWithDic:result];

    } failBlock:^(NSDictionary *result) {
        _tab.tableHeaderView = nil;
        _tab.tableFooterView = [self resultViewWithType:PageResultType_requestFail];
        [_tab finishReloadingData];
    }];
}



#pragma mark - 视图创建
//创建tableview
-(void)creatTab{
    
    _tab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStyleGrouped];
    _tab.refreshDelegate = self;
    _tab.dataSource = self;
    [self.view addSubview:_tab];
    _tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tab.tableHeaderView = [self tableHeaderView];
    [_tab showRefreshHeader:YES];
}


-(UIView *)tableHeaderView{
    UIView *tabHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 44)];
    tabHeaderView.backgroundColor = RGBCOLOR(235, 235, 235);
    UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, DEVICE_WIDTH-30, 44)];
    tLabel.text = @"城市:";
    tLabel.textColor = [UIColor blackColor];
    tLabel.font = [UIFont systemFontOfSize:15];
    [tabHeaderView addSubview:tLabel];
    
    return tabHeaderView;
}


//无数据默认view
-(ResultView *)resultViewWithType:(PageResultType)type
{
    NSString *content;
    if (type == PageResultType_nodata){
        
        content = @"暂无可用城市";
    }else if (type == PageResultType_requestFail){
        content = @"网络异常，请重新下拉加载";
    }
    
    ResultView *result = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"]
                                                    title:@"温馨提示"
                                                  content:content];
    return result;
}


#pragma mark - UITableViewDataSouce && RefreshDelegate


- (void)loadNewDataForTableView:(RefreshTableView *)tableView{
    [self prepareNetData];
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(RefreshTableView *)tableView{
    
    NSDictionary *cityDic = _citiesArray[indexPath.section];
    NSArray *geos = [cityDic arrayValueForKey:@"geos"];
    NSDictionary *districtDic = geos[indexPath.row];
    
    NSString *provinceName = [cityDic stringValueForKey:@"provinceName"];
    NSString *provinceId = [cityDic stringValueForKey:@"provinceId"];
    NSString *cityName = [cityDic stringValueForKey:@"name"];
    NSString *cityId = [cityDic stringValueForKey:@"id"];
    NSString *districtName = [districtDic stringValueForKey:@"name"];
    NSString *districtId = [districtDic stringValueForKey:@"id"];
    
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [resultDic safeSetString:provinceName forKey:@"provinceName"];
    [resultDic safeSetString:provinceId forKey:@"provinceId"];
    [resultDic safeSetString:cityName forKey:@"cityName"];
    [resultDic safeSetString:cityId forKey:@"cityId"];
    [resultDic safeSetString:districtName forKey:@"districtName"];
    [resultDic safeSetString:districtId forKey:@"districtId"];
    
    
    if (self.userSelectCityBlock) {
        self.userSelectCityBlock(resultDic);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(RefreshTableView *)tableView{
    return 44;
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _citiesArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger num = 0;
    
    NSDictionary *cityDic = _citiesArray[section];
    NSArray *geos = [cityDic arrayValueForKey:@"geos"];
    
    if (!_isOpen[section]) {
        num=0;
    }else{
        num = geos.count;
    }
    
    return num;
}


- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(RefreshTableView *)tableView{
    UIView *view;
    
    view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 44)];
    view.backgroundColor = [UIColor whiteColor];
    view.tag = section +10;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 100, 44)];
    titleLabel.font = [UIFont systemFontOfSize:13];
    [view addSubview:titleLabel];
    
    NSDictionary *cityDic = _citiesArray[section];
    
    NSString *provinceStr = [cityDic stringValueForKey:@"name"];
    titleLabel.text = provinceStr;
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ggShouFang:)];
    [view addGestureRecognizer:tap];
    
    UIButton *jiantouBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jiantouBtn setFrame:CGRectMake(DEVICE_WIDTH-44, 0, 44, 44)];
    jiantouBtn.userInteractionEnabled = NO;
    [view addSubview:jiantouBtn];
    
    if ( !_isOpen[view.tag-10]) {
        [jiantouBtn setImage:[UIImage imageNamed:@"jiantou_down.png"] forState:UIControlStateNormal];
    }else{
        [jiantouBtn setImage:[UIImage imageNamed:@"jiantou_up.png"] forState:UIControlStateNormal];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(20, 43.5, DEVICE_WIDTH-30, 0.5)];
        line.backgroundColor = RGBCOLOR(244, 245, 246);
        [view addSubview:line];
    }
    
    return view;
}
- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(RefreshTableView *)tableView{
    return 44;
}





- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}



-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *str = @"dddd";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    cell.backgroundColor= [UIColor whiteColor];
    
    UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, DEVICE_WIDTH-20, 44)];
    tLabel.font = [UIFont systemFontOfSize:12];
    [cell.contentView addSubview:tLabel];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(30, 43.5, DEVICE_WIDTH-30, 0.5)];
    line.backgroundColor = RGBCOLOR(244, 245, 246);
    [cell.contentView addSubview:line];
    
    
    NSDictionary *cityDic = _citiesArray[indexPath.section];
    NSArray *geos = [cityDic arrayValueForKey:@"geos"];
    NSDictionary *districtDic = geos[indexPath.row];
    
    tLabel.text = [districtDic stringValueForKey:@"name"];
    
    
    return cell;
}



-(void)ggShouFang:(UIGestureRecognizer*)ges{
    
    _isOpen[ges.view.tag-10]=!_isOpen[ges.view.tag-10];
    
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:ges.view.tag-10];
    [_tab reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    
}




#pragma mark - 处理城市数据
-(void)setCityDataWithDic:(NSDictionary *)result{
    NSDictionary *dataDic = [result dictionaryValueForKey:@"data"];
    NSArray *provinceArray = [dataDic arrayValueForKey:@"geos"];
    
    //省份
    _provinceArray = provinceArray;
    
    //城市
    _citiesArray = [NSMutableArray arrayWithCapacity:1];
    
    for (NSDictionary *dic in provinceArray) {
        NSArray *geos = [dic arrayValueForKey:@"geos"];
        for (NSDictionary *cityDic in geos) {
            NSMutableDictionary *city_p = [NSMutableDictionary dictionaryWithDictionary:cityDic];
            NSString *provinceName = [dic stringValueForKey:@"name"];
            NSString *provinceId = [dic stringValueForKey:@"id"];
            [city_p safeSetString:provinceName forKey:@"provinceName"];
            [city_p safeSetString:provinceId forKey:@"provinceId"];
            [_citiesArray addObject:city_p];
        }
        
    }
    
    
    if (_citiesArray.count ==0) {
        _tab.tableHeaderView = nil;
        _tab.tableFooterView = [self resultViewWithType:PageResultType_nodata];
    }else{
        _tab.tableHeaderView = [self tableHeaderView];
        _tab.tableFooterView = nil;
    }
    
    [_tab finishReloadingData];
}






@end
