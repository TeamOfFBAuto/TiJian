//
//  GFapiaoViewController.m
//  TiJian
//
//  Created by gaomeng on 16/1/11.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GFapiaoViewController.h"
#import "ConfirmOrderViewController.h"

@interface GFapiaoViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tab;//主tableview
    NSArray *_dataArray;//数据源
    
    
    UITextField *_fapiaotaitoutf;//发票抬头textfield
}
@end

@implementation GFapiaoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"发票信息";
    
    self.view.backgroundColor = RGBCOLOR(244, 245, 246);
    
    [self.view addTapGestureTaget:self action:@selector(gshou) imageViewTag:0];
    
    
    
    [self creatTab];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 视图创建
-(void)creatTab{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT) style:UITableViewStylePlain];
    _tab.backgroundColor = RGBCOLOR(244, 245, 246);
    _tab.delegate = self;
    _tab.dataSource = self;
    _tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tab];
    
    
}


#pragma mark - 点击方法
//确定按钮点击
-(void)querenBtnClicked{
    
    self.fapiaotaitou = _fapiaotaitoutf.text;
    
    [self.delegate setUserSelectFapiaoWithStr:self.fapiaotaitou];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)gshou{
    [_fapiaotaitoutf resignFirstResponder];
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
    CGFloat height = 0;
    
    if (indexPath.row == 0) {
        height = 92;
    }else if (indexPath.row == 1){
        height = 80;
    }else if (indexPath.row == 2){
        height = 80;
    }
    
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
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
    
    
    
    if (indexPath.row == 0) {//发票抬头
        
        //上分割线
        UIView *upLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5)];
        upLine.backgroundColor = RGBCOLOR(244, 245, 246);
        [cell.contentView addSubview:upLine];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, DEVICE_WIDTH - 30, 35)];
        titleLabel.text = @"发票抬头";
        titleLabel.font = [UIFont systemFontOfSize:13];
        [cell.contentView addSubview:titleLabel];
        
        
        
        UIView *fapiaoBackView = [[UIView alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(titleLabel.frame)+5, DEVICE_WIDTH - 30, 40)];
        fapiaoBackView.layer.cornerRadius = 4;
        fapiaoBackView.layer.borderWidth = 0.5;
        fapiaoBackView.layer.masksToBounds = YES;
        fapiaoBackView.layer.borderColor = [RGBCOLOR(220, 221, 223)CGColor];
        
        _fapiaotaitoutf = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, fapiaoBackView.frame.size.width - 30, 40)];
        _fapiaotaitoutf.font = [UIFont systemFontOfSize:12];
        _fapiaotaitoutf.textColor = [UIColor blackColor];
        _fapiaotaitoutf.placeholder = @"可输入个人/单位名称";
        [fapiaoBackView addSubview:_fapiaotaitoutf];
       
        [cell.contentView addSubview:fapiaoBackView];
        
    }else if (indexPath.row == 1){//发票内容
        
        //上分割线
        UIView *upLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5)];
        upLine.backgroundColor = RGBCOLOR(244, 245, 246);
        [cell.contentView addSubview:upLine];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, DEVICE_WIDTH - 30, 35)];
        titleLabel.text = @"发票内容";
        titleLabel.font = [UIFont systemFontOfSize:13];
        [cell.contentView addSubview:titleLabel];
        
        UIView *fenLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), DEVICE_WIDTH, 0.5)];
        fenLine.backgroundColor = RGBCOLOR(220, 221, 223);
        [cell.contentView addSubview:fenLine];
        
        UILabel *c_label = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(fenLine.frame), DEVICE_WIDTH - 15, 35)];
        c_label.text = @"体检费";
        c_label.font = [UIFont systemFontOfSize:13];
        [cell.contentView addSubview:c_label];
        
    }else if (indexPath.row == 2){//确定按钮
        
        
        UIView *backv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 80)];
        backv.backgroundColor = RGBCOLOR(244, 245, 246);
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(25, 40, DEVICE_WIDTH - 50, 40)];
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.backgroundColor = RGBCOLOR(92, 146, 203);
        [btn addTarget:self action:@selector(querenBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [backv addSubview:btn];
        
        
        [cell.contentView addSubview:backv];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_fapiaotaitoutf resignFirstResponder];
}




@end
