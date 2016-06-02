//
//  SettingsViewController.m
//  WJXC
//
//  Created by lichaowei on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "SettingsViewController.h"
#import "UpdatePWDController.h"
#import "AboutUsController.h"
#import "FeedBackViewController.h"

//#import <RongIMKit/RongIMKit.h>

@interface SettingsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *_titlesArr;
    UITableView *_table;
}

@property(nonatomic,retain)UILabel *phoneLabel;

@end

@implementation SettingsViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:NSStringFromClass([self class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"设置";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    _titlesArr = @[@"手机号",@"修改密码",@"意见反馈",@"鼓励评价",@"关于我们"];
    
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    
    [self addLogoutButton];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([_table respondsToSelector:@selector(setSeparatorInset:)]) {
        [_table setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_table respondsToSelector:@selector(setLayoutMargins:)]) {
        [_table setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 创建视图

-(UILabel *)phoneLabel
{
    if (_phoneLabel) {
        return _phoneLabel;
    }
    _phoneLabel = [[UILabel alloc]init];
    return _phoneLabel;
}

- (void)addLogoutButton
{
    _table.contentSize = CGSizeMake(DEVICE_WIDTH, _table.height);
    
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, _table.height - 50 * _titlesArr.count)];
    
    UIButton *btn = [[UIButton alloc]initWithframe:CGRectMake(33, footer.height - 43 - 20, DEVICE_WIDTH - 66, 43) buttonType:UIButtonTypeCustom normalTitle:@"退出登录" selectedTitle:nil target:self action:@selector(clickToLogout:)];
    btn.backgroundColor = [UIColor colorWithHexString:@"ed1f1f"];
    [btn addCornerRadius:3.f];

    [footer addSubview:btn];
    
    _table.tableFooterView = footer;
}

#pragma mark - 事件处理

- (void)clickToLogout:(UIButton *)sender
{
    [self logout];
    
    //退出融云登录
    [[RCIM sharedRCIM] disconnect];
    [[RCIM sharedRCIM] logout];
    [LTools setObject:nil forKey:USER_RONGCLOUD_TOKEN];
    
    [self cleanUserInfo];
    
    //关闭友盟账号统计
    [MobClick profileSignOff];
}

/**
 *  退出登录清空用户信息
 */
- (void)cleanUserInfo
{
    /**
     *  归档的方式保存userInfo
     */
    [UserInfo cleanUserInfo];

    [LTools setObject:[NSNumber numberWithInt:0] forKey:USER_MSG_NUM];//未读消息
    //保存登录状态 yes
    [LTools setBool:NO forKey:LOGIN_SERVER_STATE];
    [LTools setObject:nil forKey:USER_AUTHOD];
    [[SDImageCache sharedImageCache]removeImageForKey:USER_NEWHEADIMAGE fromDisk:YES];//移除本地存储头像
    [LTools showMBProgressWithText:@"退出成功" addToView:self.view];
    
    [NSUserDefaults resetStandardUserDefaults];//重置
    /**
     *  退出登录通知
     */
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_LOGOUT object:nil];
    
    [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];
}

#pragma mark - 网络请求

/**
 *  退出登录 告知服务器
 */
- (void)logout
{
    NSString *authkey = [UserInfo userInfoForCache].authcode;
    if (authkey.length == 0) {
        return;
    }
    NSDictionary *params = @{@"authcode":authkey};
//    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:USER_LOGOUT_ACTION parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"completion %@ %@",result[Erro_Info],result);
    
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"failBlock %@",result[Erro_Info]);
        
    }];
}

#pragma mark - 代理

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titlesArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"settingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15 - 7, (55-7-15)/2.f, 7, 14)];
        arrow.image = [UIImage imageNamed:@"personal_jiantou_r"];
        [cell.contentView addSubview:arrow];
        arrow.tag = 100;
    }
    UIImageView *arrow = (UIImageView *)[cell.contentView viewWithTag:100];
    if (indexPath.row == 0) {
        //手机号
        self.phoneLabel.frame = CGRectMake(DEVICE_WIDTH - 100 - 7, 0, 100, 50);
        [cell.contentView addSubview:_phoneLabel];
        _phoneLabel.text = [UserInfo userInfoForCache].mobile;
        _phoneLabel.font = [UIFont systemFontOfSize:14];
        _phoneLabel.textColor = [UIColor colorWithHexString:@"646464"];
        
        arrow.hidden = YES;
    }else
    {
        arrow.hidden = NO;
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:15.f];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"646464"];
    cell.textLabel.text = _titlesArr[indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    //按照作者最后的意思还要加上下面这一段
    
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        
        [cell setPreservesSuperviewLayoutMargins:NO];
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.row) {
        case 0:
        {
            return;
        }
            break;
        case 1:
        {
            UpdatePWDController *updatePwd = [[UpdatePWDController alloc]init];
            [self.navigationController pushViewController:updatePwd animated:YES];
        }
            break;
        case 2:
        {
            FeedBackViewController *feedback = [[FeedBackViewController alloc]init];
            [self.navigationController pushViewController:feedback animated:YES];
        }
            break;
        case 3:
        {
            //去评价
            NSString *url = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",AppStore_Appid];
            if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
                url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8",AppStore_Appid];
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
            break;
        case 4:
        {
            AboutUsController *about = [[AboutUsController alloc]init];
            [self.navigationController pushViewController:about animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5;
}


@end
