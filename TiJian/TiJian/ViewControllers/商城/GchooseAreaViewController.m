//
//  GchooseAreaViewController.m
//  TiJian
//
//  Created by gaomeng on 15/11/17.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GchooseAreaViewController.h"

@interface GchooseAreaViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tab;
    NSArray *_areaData;
    int _isopen[35];
}
@end

@implementation GchooseAreaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"选择地址";
    
    
    for (int i = 0; i<35; i++) {
        _isopen[i] = 0;
    }
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"garea" ofType:@"plist"];
    _areaData = [NSArray arrayWithContentsOfFile:path];
    
    
    [self creatTab];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)creatTab{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStyleGrouped];
    _tab.delegate =self;
    _tab.dataSource = self;
    [self.view addSubview:_tab];
}



#pragma mark - UITableViewDelegate && UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = _areaData.count;
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    
    if (_isopen[section] == 0) {
        num = 0;
    }else{
        NSArray * cities = _areaData[section][@"Cities"];
        num = cities.count;
    }
    
    return num;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = 0.01;
    height = 44;
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CGFloat height = 0.01;
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 44;
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    
    [view setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 44)];
    UILabel *provinceNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, DEVICE_WIDTH, 44)];
    provinceNameLabel.textColor = [UIColor blackColor];
    provinceNameLabel.font = [UIFont systemFontOfSize:14];
    provinceNameLabel.text = _areaData[section][@"State"];
    view.tag = section+10;
    [view addSubview:provinceNameLabel];
    [view addTaget:self action:@selector(viewForHeaderInSectionClicked:) tag:(int)view.tag];
    
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, view.frame.size.width, 0.5)];
    line.backgroundColor = RGBCOLOR(225, 226, 228);
    [view addSubview:line];
    
    
    
    return view;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    
    UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, DEVICE_WIDTH-90, 44)];
    cityLabel.textColor = [UIColor grayColor];
    NSArray * cities = _areaData[indexPath.section][@"Cities"];
    cityLabel.text = cities[indexPath.row][@"city"];
    cityLabel.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:cityLabel];
    
    
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"%s",__FUNCTION__);
    
    NSDictionary *provinceDic = _areaData[indexPath.section];
    NSString *provinceName = [provinceDic stringValueForKey:@"State"];
    int p_id = [GMAPI cityIdForName:provinceName];
    
    
    NSArray *citiesArray = [provinceDic arrayValueForKey:@"Cities"];
    NSDictionary *cityDic = citiesArray[indexPath.row];
    NSString *cityName = [cityDic stringValueForKey:@"city"];
    int c_id = [GMAPI cityIdForName:cityName];
    
    
    NSLog(@"p_name:%@ c_name:%@ p_id:%d c_id:%d",provinceName,cityName,p_id,c_id);
    

    NSDictionary *params = @{
                             @"provinceId":[NSString stringWithFormat:@"%d",p_id],
                             @"provinceName":provinceName,
                             @"cityId":[NSString stringWithFormat:@"%d",c_id],
                             @"cityName":cityName
                             };
    if (self.updateParamsBlock) {
        self.updateParamsBlock(params);
    }
    
    [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.3];
}


-(void)viewForHeaderInSectionClicked:(UIView*)sender{
    
    int aa = _isopen[sender.tag-10];
    if (aa == 0) {
        _isopen[sender.tag-10] = 1;
    }else{
        _isopen[sender.tag-10] = 0;
    }
    
    [_tab reloadData];
}



@end
