//
//  GHospitalOfProvinceViewController.m
//  TiJian
//
//  Created by gaomeng on 16/7/21.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GHospitalOfProvinceViewController.h"
#import "GChooseProvinceViewController.h"
#import "GHospitalOfProvinceTableViewCell.h"
#import "GDeptOfHospitalViewController.h"
#import "GHospitalsearchView.h"
@interface GHospitalOfProvinceViewController ()<UITableViewDelegate,UITableViewDataSource,RefreshDelegate,UITextFieldDelegate>
{
    UITableView *_tab;
    NSInteger _selectRow;
    NSArray *_citiesArray;
    UIScrollView *_rightView;
    
    UIButton *_myNavcRightBtn;
    int _editState;//0常态 1编辑状态
    UITextField *_searchTF;//textfield
    
    BOOL _isPresenting;//是否在模态
    
    RefreshTableView *_rTab;//右边的tableView
    
    NSString *_theProvinceId;//省份id
    NSString *_theCityId;//城市id
    
    NSString *_hospital_count;//所有医院的数量
    
    GHospitalsearchView *_theCustomSearchView;//自定义搜索view
    
    int _isFirstSelect[50];
    
}
@end

@implementation GHospitalOfProvinceViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _selectRow = 0;
    
    self.view.backgroundColor = [UIColor whiteColor];
    _theProvinceId = [GMAPI getCurrentProvinceId];
    
    for (int i = 0; i<50; i++) {
        _isFirstSelect[i] = 0;
    }
    
    
    [self setupNavigation];
    [self creatTab];
    [self creatMysearchView];
    [self getCities];
    
    if (self.hospitalType == HospitalType_search) {
        [_searchTF becomeFirstResponder];
    }
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 视图创建

-(void)creatTab
{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,100, DEVICE_HEIGHT - 64) style:UITableViewStyleGrouped];
    _tab.delegate = self;
    _tab.dataSource = self;
    _tab.tag = 100;
    _tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tab.showsVerticalScrollIndicator = NO;
    _tab.backgroundColor = RGBCOLOR(222, 238, 248);
    [self.view addSubview:_tab];
    [self getCacheForCities];
    
    _rTab = [[RefreshTableView alloc]initWithFrame:CGRectMake(106, 0, DEVICE_WIDTH - 106, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _rTab.refreshDelegate = self;
    _rTab.dataSource = self;
    _rTab.tag = 101;
    _rTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_rTab];
    if ([self isHaveCacheForHospital]) {
        [self getCacheForHospital];
        [_rTab refreshNewDataDelay:0];
    }else{
        [_rTab showRefreshHeader:YES Delay:0];
    }
    
    
}

//创建自定义navigation
- (void)setupNavigation{
    
    self.navigationItem.titleView = [self searchTF];
    
    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [spaceButtonItem setWidth:-16];
    _myNavcRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_myNavcRightBtn setFrame:CGRectMake(0, 0, 60, 30)];
    [_myNavcRightBtn setTitle:@"切换城市" forState:UIControlStateNormal];
    _myNavcRightBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_myNavcRightBtn setTitleColor:RGBCOLOR(85, 145, 204) forState:UIControlStateNormal];
    [_myNavcRightBtn addTarget:self action:@selector(myNavcRightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:_myNavcRightBtn];
    
    self.navigationItem.rightBarButtonItems = @[spaceButtonItem,rightBtnItem];
}

-(UITextField *)searchTF
{
    if (!_searchTF) {
        UITextField *searchTF = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH - 100, 30)];
        [searchTF addCornerRadius:14.f];
        [searchTF setBorderWidth:0.5 borderColor:[UIColor colorWithHexString:@"dfe1e6"]];
        searchTF.placeholder = @"搜索医院";
        searchTF.font = [UIFont systemFontOfSize:12.f];
        searchTF.backgroundColor = [UIColor colorWithHexString:@"f6f9fb"];
        searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        searchTF.leftViewMode = UITextFieldViewModeAlways;
        searchTF.returnKeyType = UIReturnKeySearch;
        _searchTF = searchTF;
        
        UIImageView *leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 13 + 8 + 8, 28)];
        leftImage.contentMode = UIViewContentModeCenter;
        leftImage.image = [UIImage imageNamed:@"vip_fangdajing.png"];
        searchTF.leftView = leftImage;
    }
    
    _searchTF.delegate = self;
    return _searchTF;
}
//创建搜索界面
-(void)creatMysearchView{
    _theCustomSearchView = [[GHospitalsearchView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    _theCustomSearchView.hidden = YES;
    _theCustomSearchView.backgroundColor = [UIColor whiteColor];
    __weak typeof (UITextField*)bSearchTf = _searchTF;
    __weak typeof (self)bself = self;
    
    [_theCustomSearchView setUpdateBlock:^(NSDictionary *dic) {
        if (dic) {
            if (![LTools isEmpty:[dic stringValueForKey:@"searchWorld"]]) {//有关键字
                bSearchTf.text = [dic stringValueForKey:@"searchWorld"];
                [bSearchTf resignFirstResponder];
            }
            
            if (![LTools isEmpty:[dic stringValueForKey:@"hospital_name"]] &&
                ![LTools isEmpty:[dic stringValueForKey:@"hospital_id"]]){
                
                //选择备选医院
                if (bself.hospitalType == HospitalType_selectAlternative) {
                    
                    [bself selectAlternativeHospitalId:[dic stringValueForKey:@"hospital_id"] hospitalName:[dic stringValueForKey:@"hospital_name"]];
                }else
                {
                    [bself pushToDeptFromSearchViewWithDic:dic];

                }
                
            }
        }
    }];
    
    
    [self.view addSubview:_theCustomSearchView];
    
}


#pragma mark - 事件处理

/**
 *  选择备选医院
 *
 *  @param hospitalId   医院id
 *  @param hospitalName 医院name
 */
- (void)selectAlternativeHospitalId:(NSString *)hospitalId
                       hospitalName:(NSString *)hospitalName
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params safeSetString:hospitalId forKey:@"alternativeHospitalId"];
    [params safeSetString:hospitalName forKey:@"alternativeHospitalName"];
    
    if (self.updateParamsBlock) {
        self.updateParamsBlock(params);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 从搜索页跳转科室
-(void)pushToDeptFromSearchViewWithDic:(NSDictionary *)dic{
    GDeptOfHospitalViewController *cc = [[GDeptOfHospitalViewController alloc]init];
    cc.hospital_name = [dic stringValueForKey:@"hospital_name"];
    cc.hospital_id = [dic stringValueForKey:@"hospital_id"];
    cc.updateParamsBlock = self.updateParamsBlock;
    [self.navigationController pushViewController:cc animated:YES];
}


#pragma mark - 切换省份
-(void)myNavcRightBtnClicked:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"切换城市"]) {
        GChooseProvinceViewController *cc = [[GChooseProvinceViewController alloc]init];
        __weak typeof (self)bself = self;
        [cc setUpdateParamsBlock:^(NSDictionary *params) {
            [bself getNewCityAndHospitalWithDic:params];
        }];
        [self.navigationController pushViewController:cc animated:YES];
    }else if ([sender.titleLabel.text isEqualToString:@"取消"]){
        _theCustomSearchView.hidden = YES;
        [self hiddenKeyBord];
    }
    
}

-(void)getNewCityAndHospitalWithDic:(NSDictionary *)dic{
    _theProvinceId = [dic stringValueForKey:@"province_id"];
    _theCityId = nil;
    _selectRow = 0;
    
    [self getCacheForCities];
    [self getCities];
    
    [self getCacheForHospital];
    
    [_rTab showRefreshHeader:YES Delay:0];
}

#pragma mark - 网络请求

-(void)getCities{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params safeSetString:_theProvinceId forKey:@"province_id"];
    
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:NGuahao_getCity parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *list = [result arrayValueForKey:@"list"];
        _citiesArray = list;
        _hospital_count = [result stringValueForKey:@"hospital_count"];
        
        [self setCitiesCache];
        
        [_tab reloadData];
        
    } failBlock:^(NSDictionary *result) {
        [_tab reloadData];
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
        
        [self setHospitalCacheWithList:list];
        
        [_rTab reloadData:list pageSize:PAGESIZE_MID CustomNoDataView:[self resultViewWithType:PageResultType_nodata]];
        
    } failBlock:^(NSDictionary *result) {
        if (_rTab.dataArray <=0) {
            [_rTab reloadData:nil pageSize:PAGESIZE_MID CustomNoDataView:[self resultViewWithType:PageResultType_requestFail]];
        }
        
    }];
}

#pragma mark - 缓存相关
-(void)setCitiesCache{
    NSString *citiesKey = [GMAPI citiesKeyOfHostipalWithProvinceId:_theProvinceId];
    NSMutableDictionary *cacheDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [cacheDic safeSetValue:_citiesArray forKey:@"cities"];
    [cacheDic safeSetValue:_hospital_count forKey:@"count"];
    [GMAPI cache:cacheDic ForKey:citiesKey];
}

-(void)setHospitalCacheWithList:(NSArray *)list{
    NSString *citiesKey = [GMAPI hospitalKeyWithProvinceId:_theProvinceId cityId:_theCityId];
    [GMAPI cache:list ForKey:citiesKey];
    
}

-(void)getCacheForCities{
    NSString *citiesKey = [GMAPI citiesKeyOfHostipalWithProvinceId:_theProvinceId];
    NSDictionary *dic = [GMAPI cacheForKey:citiesKey];
    _citiesArray = [dic arrayValueForKey:@"cities"];
    _hospital_count = [dic stringValueForKey:@"count"];
    [_tab reloadData];
}

-(void)getCacheForHospital{
    NSString *citiesKey = [GMAPI hospitalKeyWithProvinceId:_theProvinceId cityId:_theCityId];
    NSArray *hospitalArray = [GMAPI cacheForKey:citiesKey];
    _rTab.isReloadData = YES;
    _rTab.pageNum = 1;
    [_rTab reloadData:hospitalArray pageSize:PAGESIZE_MID CustomNoDataView:[self resultViewWithType:PageResultType_nodata]];
}

-(BOOL)isHaveCacheForHospital{
    NSString *citiesKey = [GMAPI hospitalKeyWithProvinceId:_theProvinceId cityId:_theCityId];
    NSArray *hospitalArray = [GMAPI cacheForKey:citiesKey];
    if (hospitalArray.count>0) {//有缓存
        return YES;
    }
    return NO;
}


#pragma mark - RefreshDelegate

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    if ([_searchTF isFirstResponder]) {
        [self hiddenKeyBord];
    }
}

- (void)loadNewDataForTableView:(RefreshTableView *)tableView{
    [self getHospitals];
}
- (void)loadMoreDataForTableView:(RefreshTableView *)tableView{
    [self getHospitals];
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(RefreshTableView *)tableView{
    NSLog(@"%s",__FUNCTION__);
    
    [self hiddenKeyBord];
    
    if (self.hospitalType == HospitalType_selectNormal || //选择主医院
        self.hospitalType == HospitalType_search) {
        NSDictionary *dic = _rTab.dataArray[indexPath.row];
        
        GDeptOfHospitalViewController *cc = [[GDeptOfHospitalViewController alloc]init];
        cc.hospital_name = [dic stringValueForKey:@"hospital_name"];
        cc.hospital_id = [dic stringValueForKey:@"hospital_id"];
        cc.updateParamsBlock = self.updateParamsBlock;
        [self.navigationController pushViewController:cc animated:YES];

    }else if (self.hospitalType == HospitalType_selectAlternative){//选择备选医院
        
        #pragma mark - 返回上个界面及参数回传
        NSDictionary *dic = _rTab.dataArray[indexPath.row];
        [self selectAlternativeHospitalId:[dic stringValueForKey:@"hospital_id"] hospitalName:[dic stringValueForKey:@"hospital_name"]];
    }
    
}


- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(RefreshTableView *)tableView{
    CGFloat height = 0;
    height = 50;
    return height;
}


#pragma mark - UITableViewDelegate && UITableViewDatasource

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self hiddenKeyBord];
}

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
            if (![LTools isEmpty:_hospital_count]) {
                title = [NSString stringWithFormat:@"全%@(%@)",[GMAPI cityNameForId:[_theProvinceId intValue]],_hospital_count];
            }
            
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
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:RGBCOLOR(85, 145, 205) forState:UIControlStateSelected];
        [btn setTitle:title forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        btn.titleLabel.numberOfLines = 2;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
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
        GHospitalOfProvinceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[GHospitalOfProvinceTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
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

#pragma mark - 切换城市
-(void)classClicked:(UIButton *)sender{
    
    [self hiddenKeyBord];
    
    NSInteger index = sender.tag - 10;
    if (index == _selectRow) {
        
    }else{
        _selectRow = index;
        sender.selected = YES;
        
        if (index == 0) {
            _theCityId = nil;
            
            BOOL isHaveCache = [self isHaveCacheForHospital];
            
            if (isHaveCache && _isFirstSelect[sender.tag - 10] == 1) {//有缓存并更新过
                [self getCacheForHospital];
            }else if (isHaveCache){
                [self getCacheForHospital];
                [_rTab refreshNewDataDelay:0];
            }else{
                [_rTab showRefreshHeader:YES Delay:0];//有偏移刷新
            }
            
        }else{
            NSDictionary *cityDic = _citiesArray[index-1];
            _theProvinceId = [cityDic stringValueForKey:@"province_id"];
            _theCityId = [cityDic stringValueForKey:@"city_id"];
            
            BOOL isHaveCache = [self isHaveCacheForHospital];
            
            if (isHaveCache && _isFirstSelect[sender.tag - 10] == 1) {//有缓存并更新过
                [self getCacheForHospital];
            }else if (isHaveCache) {
                [self getCacheForHospital];
                [_rTab refreshNewDataDelay:0];
                
            }else{
                [_rTab showRefreshHeader:YES Delay:0];//有偏移刷新
            }
            
        }
        [_tab reloadData];
    }
    
    
    _isFirstSelect[sender.tag - 10] = 1;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self changeSearchViewAndKuangFrameAndTfWithState:1];
    
    _theCustomSearchView.hidden = NO;
    
    [self changeSearchViewAndKuangFrameAndTfWithState:1];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"%s",__FUNCTION__);
    if (![LTools isEmpty:_searchTF.text]) {
        _theCustomSearchView.searchWorld = _searchTF.text;
        [_theCustomSearchView.rTab showRefreshHeader:YES Delay:0];
        [_searchTF resignFirstResponder];
        
        [GMAPI setUserSearchHospital:_searchTF.text];
    }
    return YES;
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
        
        [_myNavcRightBtn setTitle:@"切换城市" forState:UIControlStateNormal];
        [_searchTF setFrame:CGRectMake(0, 7, DEVICE_WIDTH - 118, 30)];
 
    }else if (state == 1){//编辑状态
        [_myNavcRightBtn setTitle:@"取消" forState:UIControlStateNormal];
        
        [_searchTF setWidth:DEVICE_WIDTH];
        
        [self.navigationController.navigationBar bringSubviewToFront:_searchTF];
        
    }
}

#pragma mark - 收键盘
-(void)hiddenKeyBord{
    [_searchTF resignFirstResponder];
    [self changeSearchViewAndKuangFrameAndTfWithState:0];
}

#pragma mark - 无数据默认view
-(ResultView *)resultViewWithType:(PageResultType)type
{
    NSString *content;
    if (type == PageResultType_nodata){
        
        content = @"暂无可选医院";
    }else if (type == PageResultType_requestFail){
        content = @"网络连接失败";
    }


    ResultView *result = [[ResultView alloc]initWithNoHospitalImage:[UIImage imageNamed:@"hema_heart"] title:@"温馨提示" content:content width:DEVICE_WIDTH - 106];
    
    
    return result;
}


@end
