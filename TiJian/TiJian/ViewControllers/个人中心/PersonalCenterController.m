//
//  PersonalCenterController.m
//  TiJian
//
//  Created by lichaowei on 15/11/5.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "PersonalCenterController.h"
#import "UserInfo.h"

@interface PersonalCenterController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_table;
    NSArray *_dataArray;
    NSArray *_projectsArray;//推荐项目
    UserInfo *_userInfo;
}

@end

@implementation PersonalCenterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitleLabel.text = @"个人中心";
    self.rightImageName = @"personal_message";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeNull WithRightButtonType:MyViewControllerRightbuttonTypeOther];
    
    _userInfo = [UserInfo cacheResultForKey:USERINFO_MODEL];
    
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.backgroundColor = [UIColor clearColor];
//    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self createViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createViews
{
    UIView *headview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 80)];
    headview.backgroundColor = [UIColor whiteColor];
    
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 60, 60)];
    [logo sd_setImageWithURL:[NSURL URLWithString:_userInfo.avatar] placeholderImage:DEFAULT_HEADIMAGE];
    [logo addRoundCorner];
    [headview addSubview:logo];
    logo.backgroundColor = DEFAULT_TEXTCOLOR;
    
    NSString *name = [NSString stringWithFormat:@"用户名:%@",_userInfo.user_name];
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(logo.right + 10, 22.5, 200, 15) title:name font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [headview addSubview:nameLabel];
    
    UILabel *sexLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameLabel.left, nameLabel.bottom + 7, 35, 15) title:@"性别:" font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [headview addSubview:sexLabel];
    
    int sex = [_userInfo.gender intValue];
    
    UIImageView *sexImage = [[UIImageView alloc]initWithFrame:CGRectMake(sexLabel.right + 5, sexLabel.top + 1, 12, 12)];
    sexImage.image = sex == 2 ? [UIImage imageNamed:@"sex_nan"] : [UIImage imageNamed:@"sex_nv"];
    [headview addSubview:sexImage];
    
    NSString *sexString = sex == 2 ? @"男" : @"女";
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(sexImage.right + 6, sexLabel.top, 15, 15) title:sexString font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [headview addSubview:label];
    
    UIImageView *editImage = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15 - 23, (80-23)/2.f, 23, 23)];
    editImage.image = [UIImage imageNamed:@"bianji"];
    [headview addSubview:editImage];
    
    _table.tableHeaderView = headview;
    
}


#pragma - mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"跳转至体检套餐购买页面");
}

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    
    if (section == 0) {
        
        return 3;
    }else if (section == 1){
        
        return 2;
    }else if (section == 2){
        
        return 1;
    }else if (section == 3){
        
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"GProductCellTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 54.5, DEVICE_WIDTH - 20, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
//        [cell.contentView addSubview:line];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"我的订单";
            cell.imageView.image = [UIImage imageNamed:@"personal_dingdan"];
            
        }else if (indexPath.row == 1){
            
            cell.textLabel.text = @"我的购物车";
            cell.imageView.image = [UIImage imageNamed:@"personal_gouwuche"];
            
        }else if (indexPath.row == 2){
            
            cell.textLabel.text = @"我的套餐";
            cell.imageView.image = [UIImage imageNamed:@"personal_yuyue"];
        }
    }else if (indexPath.section == 1){
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"我的钱包";
            cell.imageView.image = [UIImage imageNamed:@"personal_qianbao"];
            
        }else if (indexPath.row == 1){
            
            cell.textLabel.text = @"我的收藏";
            cell.imageView.image = [UIImage imageNamed:@"personal_shoucang"];
        }
    }else if (indexPath.section == 2){
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"家人管理";
            cell.imageView.image = [UIImage imageNamed:@"personal_jiaren"];
        }
    }else if (indexPath.section == 3){
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"设置";
            cell.imageView.image = [UIImage imageNamed:@"personal_shezhi"];
        }
    }
    
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *head = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5.f)];
    head.backgroundColor = [UIColor clearColor];
    return head;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.f;
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
