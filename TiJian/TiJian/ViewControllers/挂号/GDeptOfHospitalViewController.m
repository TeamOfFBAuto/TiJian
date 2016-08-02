//
//  GDeptOfHospitalViewController.m
//  TiJian
//
//  Created by gaomeng on 16/7/23.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GDeptOfHospitalViewController.h"

@interface GDeptOfHospitalViewController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_rTab;
    NSArray *_dataArray;
}
@end

@implementation GDeptOfHospitalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = self.hospital_name;
    
    [self creatTab];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建
-(void)creatTab{
    _rTab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-64) style:UITableViewStylePlain];
    _rTab.refreshDelegate = self;
    _rTab.dataSource = self;
    [self.view addSubview:_rTab];
    [_rTab showRefreshHeader:YES];
    
}

#pragma mark - 网络请求
-(void)getDeptData{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params safeSetString:self.hospital_id forKey:@"hospital_id"];
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:NGuahao_getDept parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _dataArray = [result arrayValueForKey:@"list"];
        
        [_rTab reloadData:nil total:0];
        
    } failBlock:^(NSDictionary *result) {
        [_rTab loadFail];
    }];
    
}


#pragma mark - RefreshDelegate && UITableViewDataSource
- (void)loadNewDataForTableView:(RefreshTableView *)tableView{
    [self getDeptData];
}
- (void)loadMoreDataForTableView:(RefreshTableView *)tableView{
    [self getDeptData];
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(RefreshTableView *)tableView{
    
    NSLog(@"%s",__FUNCTION__);
    
    NSDictionary *dic = _dataArray[indexPath.section];
    NSArray *children = [dic arrayValueForKey:@"children"];
    NSDictionary *child = children[indexPath.row];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params safeSetString:self.hospital_id forKey:@"hospitalId"];
    [params safeSetString:self.hospital_name forKey:@"hospitalName"];
    [params safeSetString:[child stringValueForKey:@"dept_id"] forKey:@"deptId"];
    [params safeSetString:[child stringValueForKey:@"dept_name"] forKey:@"deptName"];
    
    #pragma mark - 返回上个界面及参数回传
    if (self.updateParamsBlock) {
        self.updateParamsBlock(params);
    }
    int count = (int)self.navigationController.viewControllers.count;
    if (count > 3) {
        UIViewController *vc = self.navigationController.viewControllers[count - 3];
        
        [self.navigationController popToViewController:vc animated:YES];
    }else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(RefreshTableView *)tableView{
    CGFloat height = 44;
    return height;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(RefreshTableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 44)];
    view.backgroundColor = RGBCOLOR(222, 238, 248);
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH, 44)];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textColor = RGBCOLOR(87, 138, 189);
    NSDictionary *dic = _dataArray[section];
    NSString *dept_name = [dic stringValueForKey:@"dept_name"];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.text = dept_name;
    [view addSubview:titleLabel];
    
    return view;
}
- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(RefreshTableView *)tableView{
    CGFloat height = 44;
    return height;
}


-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(RefreshTableView *)tableView{
    CGFloat height = 0.01;
    return height;
}
-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(RefreshTableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSDictionary *dic = _dataArray[indexPath.section];
    NSArray *children = [dic arrayValueForKey:@"children"];
    NSDictionary *child = children[indexPath.row];
    NSString *dept_name = [child stringValueForKey:@"dept_name"];
    
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.text = dept_name;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = 0;
    num = _dataArray.count;
    return num;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    NSDictionary *dic = _dataArray[section];
    NSArray *children = [dic arrayValueForKey:@"children"];
    num = children.count;
    return num;
}



@end
