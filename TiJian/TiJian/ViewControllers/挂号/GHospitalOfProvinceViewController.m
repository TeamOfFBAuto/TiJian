//
//  GHospitalOfProvinceViewController.m
//  TiJian
//
//  Created by gaomeng on 16/7/21.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GHospitalOfProvinceViewController.h"
#import "GChooseProvinceViewController.h"
@interface GHospitalOfProvinceViewController ()<UITableViewDelegate,UITableViewDataSource,RefreshDelegate>
{
    UITableView *_tab;
    NSInteger _selectRow;
    NSArray *_citiesArray;
    UIScrollView *_rightView;
    
    UIButton *_myNavcRightBtn;
    int _editState;//0常态 1编辑状态
    UIView *_searchView;//输入框下层view
    UITextField *_searchTF;//textfield
    UIBarButtonItem *_rightItem1;
    
    BOOL _isPresenting;//是否在模态
    
    
    RefreshTableView *_rTab;//右边的tableView
    
    
    NSString *_theProvinceId;//省份id
    NSString *_theCityId;//城市id
    
    NSString *_hospital_count;//所有医院的数量
}
@end

@implementation GHospitalOfProvinceViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _selectRow = 0;
    
    _theProvinceId = [GMAPI getCurrentProvinceId];
    
    [self setupNavigation];
    [self creatTab];
    [self prepareNetData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 视图创建
-(void)creatTab{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,100, DEVICE_HEIGHT - 64) style:UITableViewStyleGrouped];
    _tab.delegate = self;
    _tab.dataSource = self;
    _tab.tag = 100;
    _tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tab.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tab];
    
    _rTab = [[RefreshTableView alloc]initWithFrame:CGRectMake(100, 0, DEVICE_WIDTH - 100, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _rTab.refreshDelegate = self;
    _rTab.dataSource = self;
    _rTab.tag = 101;
    [_rTab refreshNewData];
    [self.view addSubview:_rTab];
    
}

//创建自定义navigation
- (void)setupNavigation{
    //调整与左边的间距
    UIBarButtonItem * spaceButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton1.width = -10;
    
    if (iPhone6PLUS) {
        spaceButton1.width = -15;
    };

    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 32, 32)];
    [leftBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(gogoback) forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:leftBtn];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftView];
    self.navigationItem.leftBarButtonItems = @[spaceButton1,leftItem];
    
    
    _rightItem1 = [[UIBarButtonItem alloc]initWithCustomView:[self searchTF]];
    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [spaceButtonItem setWidth:-16];
    _myNavcRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_myNavcRightBtn setFrame:CGRectMake(0, 0, 60, 30)];
    [_myNavcRightBtn setTitle:@"切换城市" forState:UIControlStateNormal];
    _myNavcRightBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_myNavcRightBtn setTitleColor:RGBCOLOR(85, 145, 204) forState:UIControlStateNormal];
    [_myNavcRightBtn addTarget:self action:@selector(myNavcRightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:_myNavcRightBtn];
    
    self.navigationItem.rightBarButtonItems = @[spaceButtonItem,rightBtnItem,_rightItem1];
    
    
}



-(UITextField *)searchTF
{
    if (!_searchTF) {
        UITextField *searchTF = [[UITextField alloc]initWithFrame:CGRectMake(0, 7, DEVICE_WIDTH - 118, 30)];
        [searchTF addCornerRadius:14.f];
        [searchTF setBorderWidth:0.5 borderColor:[UIColor colorWithHexString:@"dfe1e6"]];
        searchTF.placeholder = @"搜索医院";
        searchTF.font = [UIFont systemFontOfSize:12.f];
        searchTF.backgroundColor = [UIColor colorWithHexString:@"f6f9fb"];
        searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        searchTF.leftViewMode = UITextFieldViewModeAlways;
        _searchTF = searchTF;
        
        UIImageView *leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 13 + 8 + 8, 28)];
        leftImage.contentMode = UIViewContentModeCenter;
        leftImage.image = [UIImage imageNamed:@"vip_fangdajing"];
        searchTF.leftView = leftImage;
    }
    return _searchTF;
}

#pragma mark - 返回上个界面
-(void)gogoback{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 切换城市
-(void)myNavcRightBtnClicked{
    GChooseProvinceViewController *cc = [[GChooseProvinceViewController alloc]init];
    __weak typeof (self)bself = self;
    [cc setUpdateParamsBlock:^(NSDictionary *params) {
        [bself getNewCityAndHospitalWithDic:params];
    }];
    [self.navigationController pushViewController:cc animated:YES];
}


-(void)getNewCityAndHospitalWithDic:(NSDictionary *)dic{
    _theProvinceId = [dic stringValueForKey:@"province_id"];
    _theCityId = nil;
    _selectRow = 0;
    _rTab.pageNum = 1;
    [_rTab.dataArray removeAllObjects];
    [self getCities];
    [_rTab refreshNewData];
}

#pragma mark - 网络请求
-(void)prepareNetData{
    
    [self getCities];
}

-(void)getCities{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params safeSetString:_theProvinceId forKey:@"province_id"];
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:NGuahao_getCity parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *list = [result arrayValueForKey:@"list"];
        _citiesArray = list;
        _hospital_count = [result stringValueForKey:@"hospital_count"];
        [_tab reloadData];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
}

-(void)getHospitals{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params safeSetString:_theProvinceId forKey:@"province_id"];
    [params safeSetString:_theCityId forKey:@"city_id"];
    [params safeSetString:NSStringFromInt(PAGESIZE_MID) forKey:@"per_page"];
    [params safeSetString:NSStringFromInt(_rTab.pageNum) forKey:@"page"];
    
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:NGuahao_getHospital parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *list = [result arrayValueForKey:@"list"];
        [_rTab reloadData:list pageSize:PAGESIZE_MID CustomNoDataView:nil];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
}




-(void)reloadRightViewWithTag:(NSInteger)theTag{
    
    
}



- (void)loadNewDataForTableView:(RefreshTableView *)tableView{
    [self getHospitals];
}
- (void)loadMoreDataForTableView:(RefreshTableView *)tableView{
    [self getHospitals];
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(RefreshTableView *)tableView{
    
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(RefreshTableView *)tableView{
    CGFloat height = 0;
    height = 50;
    return height;
}


#pragma mark - UITableViewDelegate && UITableViewDatasource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (tableView.tag == 100) {//城市选择
        static NSString *identifier = @"identifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        
        NSDictionary *dic;
        NSString *title;
        if (indexPath.row == 0) {
            title = [NSString stringWithFormat:@"全%@(%@)",[GMAPI cityNameForId:[_theProvinceId intValue]],_hospital_count];
        }else{
            dic = _citiesArray[indexPath.row-1];
            title = [NSString stringWithFormat:@"%@(%@)",[dic stringValueForKey:@"city_name"],[dic stringValueForKey:@"hospital_count"]];
        }
        
        
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0, 0, 100, 50)];
        [btn setBackgroundImage:[UIImage imageNamed:@"gbtnLightBlue.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"gbtnWhite.png"] forState:UIControlStateSelected];
        [btn setTitle:title forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.tag = indexPath.row+10;
        [btn addTarget:self action:@selector(classClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
        
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(99.5, 0, 0.5, 50)];
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 49.5, 100, 0.5)];
        line1.backgroundColor = RGBCOLOR(226, 226, 226);
        line2.backgroundColor = RGBCOLOR(226, 226, 226);
        
        [cell.contentView addSubview:line1];
        [cell.contentView addSubview:line2];
        
        
        if (indexPath.row == _selectRow) {
            line1.hidden = YES;
            btn.selected = YES;
        }else{
            line1.hidden = NO;
            btn.selected = NO;
        }
        
        return cell;
    }else if (tableView.tag == 101){//医院选择
        static NSString *identifier = @"identifierd";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }
        
        NSDictionary *dic = _rTab.dataArray[indexPath.row];
        cell.textLabel.text = [dic stringValueForKey:@"hospital_name"];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        
        cell.detailTextLabel.text = [dic stringValueForKey:@"level_desc"];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
        cell.detailTextLabel.textColor = RGBCOLOR(108, 109, 110);
        
        
        return cell;
    }
    
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = 0.01;
    return height;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    if (tableView.tag == 100) {
        num = _citiesArray.count+1;
    }else if (tableView.tag == 101){
        num = _rTab.dataArray.count;
    }
    return num;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    if (tableView.tag == 100) {
        height = 50;
    }else if (tableView.tag == 101){
        height = 50;
    }
    return height;
}




-(void)classClicked:(UIButton *)sender{
    
    NSInteger index = sender.tag - 10;
    if (index == _selectRow) {
        
    }else{
        _selectRow = index;
        sender.selected = YES;
        [self reloadRightViewWithTag:_selectRow];
        if (index == 0) {
            _theCityId = nil;
            [_rTab refreshNewData];
        }else{
            NSDictionary *cityDic = _citiesArray[index-1];
            _theProvinceId = [cityDic stringValueForKey:@"local_province_id"];
            _theCityId = [cityDic stringValueForKey:@"local_city_id"];
            [_rTab refreshNewData];
        }
        
        
        [_tab reloadData];
    }
    
}


@end
