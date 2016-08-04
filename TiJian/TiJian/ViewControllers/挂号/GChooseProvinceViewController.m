//
//  GChooseProvinceViewController.m
//  TiJian
//
//  Created by gaomeng on 16/7/20.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GChooseProvinceViewController.h"

@interface GChooseProvinceViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_provinceArray;
    NSMutableArray *_citiesArray;
    
    UITableView *_tab;
    
    NSDictionary *_locationDic;
    
    NSArray *_hotCityArray;
    
}
@end

@implementation GChooseProvinceViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"选择地区";
    
    [self creatTab];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建
//创建tableview
-(void)creatTab{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"garea" ofType:@"plist"];
    NSArray *arr = [NSArray arrayWithContentsOfFile:path];
    
    _provinceArray = [NSMutableArray arrayWithCapacity:1];//省份数组
    _citiesArray = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dic in arr) {
        NSString *province = [dic stringValueForKey:@"State"];
        if ([province isEqualToString:@"省份"]) {
            continue;
        }
        [_provinceArray addObject:province];
        
        NSArray *cityArray = [dic arrayValueForKey:@"Cities"];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *citydic in cityArray) {
            NSString *city = [citydic stringValueForKey:@"city"];
            if ([city isEqualToString:@"市区县"]) {
                continue;
            }
            [array addObject:city];
        }
        
        [_citiesArray addObject:array];
        
    }
    
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-64) style:UITableViewStyleGrouped];
    _tab.delegate = self;
    _tab.dataSource = self;
    _tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tab];
    
    
    _tab.tableHeaderView = [self creatTabHeaderView];
    
    
}


//创建tableHeaderView
-(UIView*)creatTabHeaderView{
    
    CGFloat height = 0.0f;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
    
    
    //定位城市
    UIView *locationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
    locationView.backgroundColor = RGBCOLOR(239, 244, 245);
    [view addSubview:locationView];
    UILabel *ttl1 = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, DEVICE_WIDTH-20, 40)];
    ttl1.textColor = [UIColor blackColor];
    ttl1.text = @"定位城市";
    ttl1.font = [UIFont systemFontOfSize:13];
    [locationView addSubview:ttl1];
    
    //定位城市内容
    UIView *locationView_c = [[UIView alloc]initWithFrame:CGRectMake(0, locationView.bottom, DEVICE_WIDTH, 50)];
    locationView_c.backgroundColor = [UIColor whiteColor];
    [view addSubview:locationView_c];
    self.nowLocationBtn_c = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nowLocationBtn_c setFrame:CGRectMake(20, 12, 85, 25)];
    self.nowLocationBtn_c.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.nowLocationBtn_c setTitleColor:RGBCOLOR(92, 146, 203) forState:UIControlStateNormal];
    self.nowLocationBtn_c.layer.borderWidth = 0.5;
    self.nowLocationBtn_c.layer.borderColor = [RGBCOLOR(92, 146, 203)CGColor];
    self.nowLocationBtn_c.layer.masksToBounds = YES;
    [self.nowLocationBtn_c setTitle:@"正在定位..." forState:UIControlStateNormal];
    self.nowLocationBtn_c.userInteractionEnabled = NO;
    
    [locationView_c addSubview:self.nowLocationBtn_c];
    
    __weak typeof (self)bself = self;
    [[GMAPI appDeledate]startDingweiWithBlock:^(NSDictionary *dic) {
        
        [bself theLocationDictionary:dic];
    }];
    
    
    
    
    //最近访问城市
    UIView *zuijinfangwenCity = [[UIView alloc]initWithFrame:CGRectMake(0, locationView_c.bottom, DEVICE_WIDTH, 40)];
    zuijinfangwenCity.backgroundColor = RGBCOLOR(239, 244, 245);
    [view addSubview:zuijinfangwenCity];
    UILabel *ttl2 = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, DEVICE_WIDTH-20, 40)];
    ttl2.textColor = [UIColor blackColor];
    ttl2.text = @"最近访问城市";
    ttl2.font = [UIFont systemFontOfSize:13];
    [zuijinfangwenCity addSubview:ttl2];
    
    //最近访问城市内容
    UIView *zuijinfangwenCity_c = [[UIView alloc]initWithFrame:CGRectMake(0, zuijinfangwenCity.bottom, DEVICE_WIDTH, 40)];
    zuijinfangwenCity_c.backgroundColor = [UIColor whiteColor];
    [view addSubview:zuijinfangwenCity_c];
    
    NSMutableArray *userCommonlyAdressArray = [GMAPI cacheForKey:USERCOMMONLYUSEDADDRESS_P];
    CGFloat jianju = 10;//间距
    int sumOneRow = 5;//每行几个
    int btnHeight = 25;//按钮高
    CGFloat theWidth = (DEVICE_WIDTH - 60 - sumOneRow * jianju)*1.0f/sumOneRow;//按钮宽度
    NSInteger ddddc = (userCommonlyAdressArray.count >5)?5:userCommonlyAdressArray.count;
    if (userCommonlyAdressArray.count>0) {
        for (int i = 0; i<ddddc; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:userCommonlyAdressArray[ddddc - 1 - i] forState:UIControlStateNormal];
            btn.layer.borderColor = [RGBCOLOR(80, 81, 82) CGColor];
            [btn setTitleColor:RGBCOLOR(80, 81, 82) forState:UIControlStateNormal];
            btn.layer.borderWidth = 0.5;
            btn.layer.cornerRadius = 4;
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            btn.layer.masksToBounds = YES;
            btn.tag = i+10000;
            
            [btn setFrame:CGRectMake(30+i%sumOneRow*(jianju +theWidth), 10 +i/sumOneRow*(25+jianju) ,theWidth, btnHeight)];
            
            [zuijinfangwenCity_c addSubview:btn];
            
            [btn addTarget:self action:@selector(zuijinfangwenBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }else{
        UILabel *ll = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 50, 40)];
        ll.font = [UIFont systemFontOfSize:12];
        ll.textColor = [UIColor grayColor];
        ll.text = @"暂无";
        [zuijinfangwenCity_c addSubview:ll];
    }
    
    
    
    
    UIView *hotDownLine = [[UIView alloc]initWithFrame:CGRectMake(0, zuijinfangwenCity_c.bottom, DEVICE_WIDTH, 5)];
    hotDownLine.backgroundColor = RGBCOLOR(244, 245, 246);
    [view addSubview:hotDownLine];
    
    
    height = hotDownLine.bottom;
    
    
    [view setHeight:height];
    
    return view;
    
}


#pragma mark - 点击section选择地区
-(void)chooseTheStr:(UIGestureRecognizer*)ges{
    NSLog(@"%s",__FUNCTION__);
    
    NSString *str = _provinceArray[ges.view.tag - 10];
    
    int provinceId = [GMAPI cityIdForName:str];
    
    NSDictionary *params = @{
                             @"province_id":NSStringFromInt(provinceId),
                             @"province_name":str
                             };
    
    if (self.updateParamsBlock) {
        self.updateParamsBlock(params);
    }
    
    [self setuserCommonlyUsedCityWithStr:str];
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

#pragma mark - 最近访问点击
-(void)zuijinfangwenBtnClicked:(UIButton *)sender{
    NSString *str = [NSString stringWithFormat:@"%@",sender.titleLabel.text];
    int provinceId = [GMAPI cityIdForName:str];
    NSDictionary *params = @{
                         @"province_id": NSStringFromInt(provinceId),
                         @"province_name":str
                         };
    
    if (self.updateParamsBlock) {
        self.updateParamsBlock(params);
    }
    
    [self setuserCommonlyUsedCityWithStr:str];
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - UITableViewDataSouce && UITableViewDelegate


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _provinceArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger num = 0;
    
    return num;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view;
    
    view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 44)];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 100, 44)];
    titleLabel.font = [UIFont systemFontOfSize:13];
    NSString*provinceStr = _provinceArray[section];
    titleLabel.text = provinceStr;
    [view addSubview:titleLabel];
    view.backgroundColor = [UIColor whiteColor];
    view.tag = section +10;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chooseTheStr:)];
    [view addGestureRecognizer:tap];
    
    
    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = 0;
    
    height = 44;
    return height;
    
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
    
    
    NSArray *citiesArray = _citiesArray[indexPath.section];
    NSString *cityName = citiesArray[indexPath.row];
    
    tLabel.text = cityName;
    
    [cell.contentView addSubview:tLabel];
    
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(30, 43.5, DEVICE_WIDTH-30, 0.5)];
    line.backgroundColor = RGBCOLOR(244, 245, 246);
    [cell.contentView addSubview:line];
    
    
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}



#pragma mark - 获取经纬度
-(void)getjingweidu{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusRestricted == status) {
        NSLog(@"kCLAuthorizationStatusRestricted 开启定位失败");
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"开启定位失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
        return;
    }else if (kCLAuthorizationStatusDenied == status){
        NSLog(@"请允许衣加衣使用定位服务");
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请允许衣加衣使用定位服务" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
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
        theString = [dic stringValueForKey:@"province"];
        
        procinceId =[GMAPI cityIdForName:[dic stringValueForKey:@"province"]];
        cityId = [GMAPI cityIdForName:[dic stringValueForKey:@"city"]];
    }
    
    self.nowLocationBtn_cityid = [GMAPI cityIdForName:theString];
    if ([LTools isEmpty:theString]) {
        [self.nowLocationBtn_c setTitle:@"定位失败默认城市为北京" forState:UIControlStateNormal];
        [self.nowLocationBtn_c setWidth:145];
    }else{
        [self.nowLocationBtn_c setTitle:theString forState:UIControlStateNormal];
        [self.nowLocationBtn_c setWidth:85];
        
    }
    
    
    self.nowLocationBtn_c.userInteractionEnabled = YES;
    [self.nowLocationBtn_c addTarget:self action:@selector(nowLocationBtnClicked) forControlEvents:UIControlEventTouchUpInside];
}


//定位城市选择
-(void)nowLocationBtnClicked{
    
    NSString *str;
    
    if (self.nowLocationBtn_cityid == 0) {
        str = [NSString stringWithFormat:@"%@市",@"北京"];
    }else{
        str = self.nowLocationBtn_c.titleLabel.text;
    }
    
    
    int provinceId = [GMAPI cityIdForName:str];
    
    NSDictionary *params = @{
                             @"province_id":NSStringFromInt(provinceId),
                             @"province_name":str
                             };
    
    if (self.updateParamsBlock) {
        self.updateParamsBlock(params);
    }
    
    
    [self setuserCommonlyUsedCityWithStr:str];
    [self.navigationController popViewControllerAnimated:YES];
    
}


//设置最近访问城市
-(void)setuserCommonlyUsedCityWithStr:(NSString*)cityName{
    
    
    NSArray *arr = [GMAPI cacheForKey:USERCOMMONLYUSEDADDRESS_P];
    if (!arr) {
        NSMutableArray *adressArray = [[NSMutableArray alloc]initWithCapacity:5];
        [adressArray addObject:cityName];
        [GMAPI cache:(NSArray*)adressArray ForKey:USERCOMMONLYUSEDADDRESS_P];
    }else{
        BOOL isHave = NO;
        for (NSString*str in arr) {
            if ([str isEqualToString:cityName]) {
                isHave = YES;
                continue;
            }
        }
        
        NSMutableArray *adressMutabelArray = [NSMutableArray arrayWithArray:arr];
        
        if (isHave) {//有
            
        }else{//没有
            if (arr.count<5) {
                [adressMutabelArray addObject:cityName];
                
            }else{
                [adressMutabelArray removeObjectAtIndex:0];
                [adressMutabelArray addObject:cityName];
            }
            
            [GMAPI cache:(NSArray*)adressMutabelArray ForKey:USERCOMMONLYUSEDADDRESS_P];
            
            
        }
        
    }
}



@end
