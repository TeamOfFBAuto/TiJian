//
//  GHospitalsearchView.m
//  TiJian
//
//  Created by gaomeng on 16/7/23.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GHospitalsearchView.h"
#import "UILabel+GautoMatchedText.h"
#import "GDeptOfHospitalViewController.h"
#import "GHospitalOfProvinceTableViewCell.h"

@implementation GHospitalsearchView

-(void)setUpdateBlock:(updateBlock)updateBlock{
    _updateBlock = updateBlock;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.rTab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
        self.rTab.refreshDelegate = self;
        self.rTab.dataSource = self;
        self.rTab.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.rTab];
    }
    
    return self;
}

#pragma mark - 视图创建
//历史搜索view
-(UIView *)creatHistoryView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 60)];
    UIView *upLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5)];
    upLine.backgroundColor = RGBCOLOR(244, 245, 246);
    [view addSubview:upLine];
    
    UIScrollView *hotSearchScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(upLine.frame), DEVICE_WIDTH, 50)];
    hotSearchScrollView.showsHorizontalScrollIndicator = NO;
    [view addSubview:hotSearchScrollView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 12, 80, 27)];
    titleLabel.text = @"历史搜索:";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [hotSearchScrollView addSubview:titleLabel];
    
    NSArray *historyArray = [GMAPI cacheForKey:USERHistorySearch_hospital];
    
    CGFloat s_width = titleLabel.right;
    
    for (int i = 0; i<historyArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = RGBCOLOR(239, 240, 241);
        
        NSString *hotStr = historyArray[historyArray.count -1 - i];
        UILabel *l = [[UILabel alloc]init];
        l.font = [UIFont systemFontOfSize:12];
        l.text = hotStr;
        
        CGFloat l_w = [l getTextWidth];
        CGFloat btnWidth = l_w +20;
        CGFloat btnJianju = 10;
        
        [btn setFrame:CGRectMake(s_width +btnJianju, 12, btnWidth, 27)];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        s_width = btn.right;
        btn.layer.cornerRadius = 13.5;
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [RGBCOLOR(229, 230, 231)CGColor];
        [btn setTitle:[NSString stringWithFormat:@"%@",hotStr] forState:UIControlStateNormal];
        [btn setTitleColor:RGBCOLOR(80, 81, 82) forState:UIControlStateNormal];
        [hotSearchScrollView addSubview:btn];
        btn.tag = 1000+i;
        [btn addTarget:self action:@selector(hotSearchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (historyArray.count == 0) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(titleLabel.right+10, 12, 50, 27)];
        label.text = @"暂无";
        label.font = [UIFont boldSystemFontOfSize:12];
        label.textColor = [UIColor lightGrayColor];
        [hotSearchScrollView addSubview:label];
    }else if (historyArray.count>0){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(s_width+10, 14, 40, 22)];
        [btn setTitle:@"清空" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [RGBCOLOR(108, 163, 210)CGColor];
        btn.layer.cornerRadius = 5;
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        s_width = btn.right;
        [hotSearchScrollView addSubview:btn];
        [btn addTarget:self action:@selector(qingkongHistory) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [hotSearchScrollView setContentSize:CGSizeMake(s_width+10, 50)];
    
    UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(hotSearchScrollView.frame), DEVICE_WIDTH, 5)];
    downLine.backgroundColor = RGBCOLOR(244, 245, 246);
    [view addSubview:downLine];
    
    
    return view;
}

#pragma mark - 无数据默认view
-(ResultView *)resultViewWithType:(PageResultType)type
{
    NSString *content;
    if (type == PageResultType_nodata){
        
        content = @"暂无可用医院";
    }
    
    
    ResultView *result = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"]
                                                    title:@"温馨提示"
                                                  content:content];
    result.backgroundColor = [UIColor whiteColor];
    
    return result;
}


#pragma mark - RefreshDelegate && UITableViewDataSource

- (void)loadNewDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = 1;
    return num;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(RefreshTableView *)tableView{
    UIView *view = [self creatHistoryView];
    return view;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 60;
    return height;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    num = _rTab.dataArray.count;
    return num;
}


- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    CGFloat height = 50;
    return height;
}



-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    return height;
}



-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    GHospitalOfProvinceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GHospitalOfProvinceTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
   
    NSDictionary *dic = _rTab.dataArray[indexPath.row];
    
    cell.textLabel.text = [dic stringValueForKey:@"hospital_name"];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    
    
    NSString *str = [NSString stringWithFormat:@"%@ %@",[dic stringValueForKey:@"province_name"],[dic stringValueForKey:@"city_name"]];
    
    cell.detailTextLabel.text = str;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    cell.detailTextLabel.textColor = RGBCOLOR(108, 109, 110);
    
    return cell;
}



- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    NSDictionary *dic = _rTab.dataArray[indexPath.row];
    NSString *hospital_name = [dic stringValueForKey:@"hospital_name"];
    NSString *hospital_id = [dic stringValueForKey:@"hospital_id"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params safeSetString:hospital_name forKey:@"hospital_name"];
    [params safeSetString:hospital_id forKey:@"hospital_id"];
    
    if (self.updateBlock) {
        self.updateBlock(params);
    }
    
}

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.updateBlock) {
        self.updateBlock(nil);
    }
    
}


#pragma mark - 网络请求
-(void)prepareNetData{
    
    if (![LTools isEmpty:self.searchWorld]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
        [params safeSetString:NSStringFromInt(PAGESIZE_MID) forKey:@"per_page"];
        [params safeSetString:NSStringFromInt(_rTab.pageNum) forKey:@"page"];
        [params safeSetString:self.searchWorld forKey:@"hospital_name"];
        
        [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:NGuahao_getHospital parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
            
            NSArray *list = [result arrayValueForKey:@"list"];
            [_rTab reloadData:list pageSize:PAGESIZE_MID CustomNoDataView:[self resultViewWithType:PageResultType_nodata]];
            
        } failBlock:^(NSDictionary *result) {
            
        }];

    }else{
        [self.rTab reloadData:nil total:0];
    }
    
}


#pragma mark - UITableViewDelegate && UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CGFloat height = 0.01;
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    return height;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}



#pragma mark - 点击历史记录
-(void)hotSearchBtnClicked:(UIButton *)sender{
    self.searchWorld = sender.titleLabel.text;
    [self.rTab showRefreshHeader:YES];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic safeSetString:self.searchWorld forKey:@"searchWorld"];
    if (self.updateBlock) {
        self.updateBlock(dic);
    }
}

-(void)qingkongHistory{
    [GMAPI cache:nil ForKey:USERHistorySearch_hospital];
    [self.rTab reloadData];
}



@end
