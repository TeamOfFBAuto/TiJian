//
//  DiseaseDetailController.m
//  TiJian
//
//  Created by gaomeng on 16/8/19.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "DiseaseDetailController.h"
#import "UILabel+GautoMatchedText.h"
#import "VipAppointViewController.h"
#import "RecommendMedicalCheckController.h"

@interface DiseaseDetailController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_rTab;
    YJYRequstManager *_request;
    UILabel *_tmpLabel;
    __block NSMutableArray *_isOpenArray;
}
@end

@implementation DiseaseDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.myTitle = self.disease_name;
    
    [self creatTab];
    [self creatDownView];
    [_rTab showRefreshHeader:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建

-(void)creatTab{
    _rTab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-64-50) style:UITableViewStyleGrouped];
    _rTab.refreshDelegate = self;
    _rTab.dataSource = self;
    _rTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_rTab];
}

-(void)creatDownView{
    UIView *downView = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 64 - 50, DEVICE_WIDTH, 50)];
    
    for (int i = 0; i<3; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 100 + i;
        [btn addTarget:self action:@selector(downViewBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        if (i == 0) {
            [btn setFrame:CGRectMake(0, 0, DEVICE_WIDTH*0.5, downView.height)];
            [btn setTitle:@"推荐套餐" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor whiteColor]];
        }else if (i == 1){
            [btn setFrame:CGRectMake(DEVICE_WIDTH *0.5, 0, DEVICE_WIDTH*0.25, downView.height)];
            [btn setTitle:@"问医生" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:RGBCOLOR(99, 180, 22)];
        }else if (i == 2){
            [btn setFrame:CGRectMake(DEVICE_WIDTH *0.75, 0, DEVICE_WIDTH*0.25, downView.height)];
            [btn setTitle:@"看医生" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:RGBCOLOR(234, 134, 36)];
        }
        
        [downView addSubview:btn];
    }
    
    UIView *upline = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.5)];
    upline.backgroundColor = RGBCOLOR(162, 163, 164);
    [downView addSubview:upline];
    
    [self.view addSubview:downView];
}

#pragma mark - RefreshDelegate && UITableViewDataSource

- (void)loadNewDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView{
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = _rTab.dataArray.count;
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 1;
    NSNumber *boo = _isOpenArray[section];
    if (boo.boolValue) {
        num = 1;
    }else{
        num = 0;
    }
    return num;
}


- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    
    if (!_tmpLabel) {
        _tmpLabel = [[UILabel alloc]init];
    }
    _tmpLabel.font = [UIFont systemFontOfSize:13];
    NSDictionary *dic = _rTab.dataArray[indexPath.row];
    NSString *str = [dic stringValueForKey:@"content"];
    _tmpLabel.text = str;
    [_tmpLabel setMatchedFrame4LabelWithOrigin:CGPointMake(15, 0) width:DEVICE_WIDTH - 30];
    height = _tmpLabel.height +10;

    return height;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    if (!_tmpLabel) {
        _tmpLabel = [[UILabel alloc]init];
    }
    _tmpLabel.font = [UIFont systemFontOfSize:16];
    NSDictionary *dic = _rTab.dataArray[section];
    NSString *str = [dic stringValueForKey:@"title"];
    _tmpLabel.text = str;
    [_tmpLabel setMatchedFrame4LabelWithOrigin:CGPointMake(44, 0) width:DEVICE_WIDTH - 32 - 12 - 35];
    
    if (_tmpLabel.height +24 < 40) {
        height = 40;
    }else{
        height = _tmpLabel.height +24;
    }
    
    return height;
}

-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    return height;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
    
    UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(15, 12, 17, 17)];
    [imv setImage:[UIImage imageNamed:@"report_detail_title.png"]];
    [view addSubview:imv];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(imv.right + 12, 12, DEVICE_WIDTH - imv.right - 12 - 35, 0)];
    titleLabel.font = [UIFont systemFontOfSize:16];
    NSDictionary *dic = _rTab.dataArray[section];
    titleLabel.text = [dic stringValueForKey:@"title"];
    [titleLabel setMatchedFrame4LabelWithOrigin:CGPointMake(imv.right + 12, imv.frame.origin.y) width:DEVICE_WIDTH - imv.right - 12 - 35];
    [view addSubview:titleLabel];
    
    
    if (titleLabel.height +24 < 40) {
        [view setHeight:40];
    }else{
        [view setHeight:titleLabel.height +24];
    }
    
    [imv setFrame:CGRectMake(15, view.height*0.5-17*0.5, 17, 17)];
    UIButton *jiantouBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jiantouBtn setFrame:CGRectMake(DEVICE_WIDTH-35, 0, 35, view.height)];
    jiantouBtn.userInteractionEnabled = NO;
    [view addSubview:jiantouBtn];
    
    NSNumber *num = _isOpenArray[section];
    if (num.boolValue) {
        view.backgroundColor = [UIColor whiteColor];
        
        [jiantouBtn setImage:[UIImage imageNamed:@"jiantou_blue_up.png"] forState:UIControlStateNormal];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(20, view.height - 0.5, DEVICE_WIDTH-30, 0.5)];
        line.backgroundColor = RGBCOLOR(244, 245, 246);
        [view addSubview:line];
        
    }else{
        view.backgroundColor = RGBCOLOR(245, 245, 245);
        if (section<_isOpenArray.count-1) {
            UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(0, view.height - 0.5, DEVICE_WIDTH, 0.5)];
            downLine.backgroundColor = RGBCOLOR(213, 214, 215);
            [view addSubview:downLine];
        }
        
        [jiantouBtn setImage:[UIImage imageNamed:@"jiantou_down.png"] forState:UIControlStateNormal];
    }
    
    
    [view addTapGestureTaget:self action:@selector(viewForHeaderClicked:) imageViewTag:section +10];
    
    
    return view;
}

-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UILabel *theCLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, DEVICE_WIDTH-30, 0)];
        theCLabel.tag = 300;
        [cell.contentView addSubview:theCLabel];
    }
    
    NSDictionary *dic = _rTab.dataArray[indexPath.section];
    UILabel *label = [cell.contentView viewWithTag:300];
    
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor grayColor];
    label.text = [dic stringValueForKey:@"content"];
    [label setMatchedFrame4LabelWithOrigin:CGPointMake(15, 5) width:DEVICE_WIDTH-30];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}



- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    NSLog(@"%s",__FUNCTION__);
}

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%s",__FUNCTION__);
}


#pragma mark - 网络请求
-(void)prepareNetData{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSMutableDictionary *parms = [[NSMutableDictionary alloc]initWithCapacity:1];
    [parms safeSetString:self.disease_id forKey:@"ailment_id"];
    
    __weak typeof (RefreshTableView*)brtab = _rTab;
//    __weak typeof (NSMutableArray *)barray = _isOpenArray;
    
//    __block NSMutableArray *barray = _isOpenArray;
    
    [_request requestWithMethod:YJYRequstMethodGet api:Disease_Detail parameters:parms constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *dataArray = [result arrayValueForKey:@"data"];
        
        _isOpenArray = [NSMutableArray arrayWithCapacity:dataArray.count];
        for (int i = 0; i<dataArray.count; i++) {
            NSNumber *num;
            if (i == 0) {
                num = [NSNumber numberWithBool:YES];
            }else{
                num = [NSNumber numberWithBool:NO];
            }
            [_isOpenArray addObject:num];
        }
        
        
        [brtab reloadData:dataArray isHaveMore:NO];
        
    } failBlock:^(NSDictionary *result) {
        [brtab reloadData:nil pageSize:PAGESIZE_MID noDataView:[self resultViewWithType:PageResultType_nodata]];
    }];
}


#pragma mark - headerClicked
-(void)viewForHeaderClicked:(UITapGestureRecognizer*)sender{
    NSNumber *boo = _isOpenArray[sender.view.tag - 10];
    NSNumber *boo1 = [NSNumber numberWithBool:!boo.boolValue];
    _isOpenArray[sender.view.tag - 10] = boo1;
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sender.view.tag - 10];
    [_rTab reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

#pragma mark - downBtnClicked
-(void)downViewBtnClicked:(UIButton *)sender{
    DDLOG(@"---->%ld",(long)sender.tag);
    if (sender.tag == 100) {//推荐套餐
       
        RecommendMedicalCheckController *recommend = [[RecommendMedicalCheckController alloc]init];
        recommend.recommendType = RecommentType_sickness;
        recommend.diseaseId = self.disease_id;
        [self.navigationController pushViewController:recommend animated:YES];
        
    }else if (sender.tag == 101){//问医生 咨询
        [MiddleTools pushToGuaHaoType:4 familyuid:nil viewController:self hiddenBottom:YES updateParamsBlock:nil extendParams:nil];
        
    }else if (sender.tag == 102){//看医生 挂号
        
        VipAppointViewController *vip = [[VipAppointViewController alloc]init];
        [self.navigationController pushViewController:vip animated:YES];
    }
}


#pragma mark - 无数据默认view
-(ResultView *)resultViewWithType:(PageResultType)type
{
    NSString *content;
    if (type == PageResultType_nodata){
        
        content = @"获取数据失败,请下拉重新加载";
    }
    
    
    ResultView *result = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"]
                                                    title:@"温馨提示"
                                                  content:content];
    
    return result;
}

@end
