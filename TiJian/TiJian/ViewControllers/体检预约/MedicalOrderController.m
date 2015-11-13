//
//  MedicalOrderController.m
//  TiJian
//
//  Created by lichaowei on 15/11/11.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "MedicalOrderController.h"
#import "CompanyCell.h"
#import "PreViewCell.h"
#import "HospitalModel.h"
#import "ChooseHopitalController.h"

@interface MedicalOrderController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_table;
    NSArray *_testArray;
}

@end

@implementation MedicalOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"预约";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    //测试数据
    HospitalModel *aModel = [[HospitalModel alloc]init];
    aModel.name = @"上地分院";
    aModel.time = @"2015-11-05";
    aModel.usersArray = @[@"1.父亲 张木木 3685*******1234",@"2.父亲 张木木 3685*******1234"];
    
    HospitalModel *aModel1 = [[HospitalModel alloc]init];
    aModel1.name = @"回龙观分院";
    aModel1.time = @"2015-11-06";
    aModel1.usersArray = @[@"1.朋友 张木木 3685*******1234",@"2.朋友 张木木 3685*******1234",@"3.朋友 张木木 3685*******1234"];
    
    _testArray = @[aModel,aModel1];
    
    //没有套餐
//    UIView *view = [self noDataView];
//    [self.view addSubview:view];

    
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _table.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 创建视图
- (UIView *)noDataView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    
    CGFloat width = FitScreen(96);
    width = iPhone4 ? width * 0.8 : width;
    
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(38, 55, width, width)];
    icon.image = [UIImage imageNamed:@"hema"];
    [view addSubview:icon];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, icon.bottom - 5, DEVICE_WIDTH, 15) title:@"您还没有任何套餐可以预约" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"323232"]];
    [view addSubview:label];
    
    label = [[UILabel alloc]initWithFrame:CGRectMake(0, label.bottom + 5, DEVICE_WIDTH, 15) title:@"您可以先" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"323232"]];
    [view addSubview:label];
    
    width = DEVICE_WIDTH / 3.f;
    CGFloat aver = width / 5.f;
    for (int i = 0; i < 2; i ++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(aver * 2 + (width + aver) * i, label.bottom + 35, width, 35);
        [view addSubview:btn];
        [btn addCornerRadius:2.f];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        if (i == 0) {
            [btn setBorderWidth:0.5 borderColor:DEFAULT_TEXTCOLOR];
            [btn setTitle:@"购买套餐" forState:UIControlStateNormal];
            [btn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(clickToBuy) forControlEvents:UIControlEventTouchUpInside];
        }else
        {
            [btn setBorderWidth:0.5 borderColor:[UIColor colorWithHexString:@"ec7d24"]];
            [btn setTitle:@"定制专属套餐" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithHexString:@"ec7d24"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(clickToCustomizaiton) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    return view;
}

#pragma - mark 事件处理
- (void)clickToBuy
{
    NSLog(@"购买套餐");
}

- (void)clickToCustomizaiton
{
    NSLog(@"定制套餐");
}

- (void)clickToHospital
{
    NSLog(@"选择时间和分院");
    ChooseHopitalController *choose = [[ChooseHopitalController alloc]init];
    [self.navigationController pushViewController:choose animated:YES];
}

#pragma - mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 310;
    }
    return [PreViewCell heightForCellWithUsersCount:3 lastNum:1 hospitalArray:_testArray];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self clickToHospital];
}

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section == 0) {
        
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0) {
        
        static NSString *identify = @"companyCell";
        CompanyCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[CompanyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify companyPreType:COMPANYPRETYPE_TAOCAN];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    static NSString *identifier = @"PreViewCell";
    PreViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PreViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    
    [cell setCellWithModel:_testArray];
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *head = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40.f)];
    head.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
    NSString *title = section == 0 ? @"公司福利" : @"个人投资";
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 120, 40) title:title font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"989898"]];
    [head addSubview:label];
    return head;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}


@end
