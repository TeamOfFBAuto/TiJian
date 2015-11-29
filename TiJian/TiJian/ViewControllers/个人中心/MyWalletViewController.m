//
//  MyWalletViewController.m
//  TiJian
//
//  Created by gaomeng on 15/11/29.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "MyWalletViewController.h"
#import "MyCouponViewController.h"

@interface MyWalletViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tab;
}
@end

@implementation MyWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"我的钱包";
    
    [self creatTab];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 视图创建

-(void)creatTab{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _tab.delegate = self;
    _tab.dataSource = self;
    _tab.backgroundColor = RGBCOLOR(244, 245, 246);
    [self.view addSubview:_tab];
    
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = 1;
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 3;
    return num;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = 0.01;
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
    
    UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 14, 16, 16)];
    [cell.contentView addSubview:imv];
    
    if (indexPath.row == 0) {
        [imv setImage:[UIImage imageNamed:@"personal_qianbao_jifen.png"]];
    }else if (indexPath.row == 1){
        [imv setImage:[UIImage imageNamed:@"personal_qianbao_youhuiquan.png"]];
    }else if (indexPath.row == 2){
        [imv setImage:[UIImage imageNamed:@"daijinquan.png"]];
    }
    
    
    
    
    UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imv.frame)+12, 0, 50, 44)];
    tLabel.font = [UIFont systemFontOfSize:15];
    [cell.contentView addSubview:tLabel];
    if (indexPath.row == 0) {
        tLabel.text = @"积分";
    }else if (indexPath.row == 1){
        tLabel.text = @"优惠券";
    }else if (indexPath.row == 2){
        tLabel.text = @"代金券";
    }
    
    //箭头
    UIImageView *jiantou_d = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 20, 14, 8, 16)];
    [jiantou_d setImage:[UIImage imageNamed:@"personal_jiantou_r.png"]];
    [cell.contentView addSubview:jiantou_d];
    
    UILabel *cLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(tLabel.frame)+10, 0, DEVICE_WIDTH - 10 - 16 - 50 - 10 - 5 - 8 - 12-16 - 10, 44)];
    cLabel.font = [UIFont systemFontOfSize:15];
    cLabel.textColor = RGBCOLOR(237, 107, 21);
    cLabel.textAlignment = NSTextAlignmentRight;
    [cell.contentView addSubview:cLabel];
    
    UILabel *danweiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(cLabel.frame), 0, 16, 44)];
    danweiLabel.font = [UIFont systemFontOfSize:15];
    danweiLabel.textColor = [UIColor blackColor];
    [cell.contentView addSubview:danweiLabel];

    if (indexPath.row == 0) {//积分
        danweiLabel.text = @"分";
        int score = 568;
        cLabel.text = [NSString stringWithFormat:@"%d",score];
    }else if (indexPath.row == 1){//优惠券
        danweiLabel.text = @"张";
        int num = 3;
        cLabel.text = [NSString stringWithFormat:@"%d",num];
        cLabel.hidden = YES;
        danweiLabel.hidden = YES;
    }else if (indexPath.row == 2){//代金券
        danweiLabel.text = @"张";
        int num = 2;
        cLabel.text = [NSString stringWithFormat:@"%d",num];
        cLabel.hidden = YES;
        danweiLabel.hidden = YES;
    }
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {//优惠券
        MyCouponViewController *cc = [[MyCouponViewController alloc]init];
        cc.type = GCouponType_youhuiquan;
        [self.navigationController pushViewController:cc animated:YES];
    }else if (indexPath.row == 2){//代金券
        MyCouponViewController *cc = [[MyCouponViewController alloc]init];
        cc.type = GCouponType_daijinquan;
        [self.navigationController pushViewController:cc animated:YES];
    }
    
}




@end
