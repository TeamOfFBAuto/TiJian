//
//  GFapiaoViewController.m
//  TiJian
//
//  Created by gaomeng on 16/1/11.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GFapiaoViewController.h"
#import "ConfirmOrderViewController.h"

@interface GFapiaoViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    UITableView *_tab;//主tableview
    
    UITextField *_fapiaotaitoutf;//发票抬头textfield
    
    YJYRequstManager *_request;
    
    //最近使用的发票tableview
    UITableView *_tab_fapiao;
    NSArray *_dataArray;//数据源
    
}
@end

@implementation GFapiaoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"发票信息";
    
    self.view.backgroundColor = RGBCOLOR(244, 245, 246);
    
//    [self.view addTapGestureTaget:self action:@selector(gAllShou) imageViewTag:0];
    
    
    
    [self creatTab];
    [self getFapiaoList];
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求
-(void)getFapiaoList{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey],
                          @"page":@"1",
                          @"per_page":@"10"
                          };
    
    [_request requestWithMethod:YJYRequstMethodGet api:FAPIAO_MYNEAR parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *list = [result arrayValueForKey:@"list"];
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in list) {
            NSString *title = [dic stringValueForKey:@"title"];
            [arr addObject:title];
        }
        _dataArray = arr;
        
        CGFloat maxHeight = 120;
        CGFloat height = _dataArray.count *35;
        if (height > maxHeight) {
            height = maxHeight;
        }
        
        [_tab_fapiao setHeight:height];
        
        NSLog(@"%f",_tab_fapiao.frame.size.height);
        
        
        [_tab_fapiao reloadData];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
    
}




#pragma mark - 视图创建
-(void)creatTab{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT) style:UITableViewStylePlain];
    _tab.tag = 1;
    _tab.scrollEnabled = NO;
    _tab.backgroundColor = RGBCOLOR(244, 245, 246);
    _tab.delegate = self;
    _tab.dataSource = self;
    _tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *tabFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    tabFooterView.backgroundColor = RGBCOLOR(244, 245, 246);
    [tabFooterView addTaget:self action:@selector(gAllShou) tag:0];
    _tab.tableFooterView = tabFooterView;
    
    
    [self.view addSubview:_tab];
    
    
    _tab_fapiao = [[UITableView alloc]initWithFrame:CGRectMake(15, 84, DEVICE_WIDTH - 30, 0) style:UITableViewStylePlain];
    _tab_fapiao.tag = 2;
    _tab_fapiao.delegate = self;
    _tab_fapiao.dataSource = self;
    _tab_fapiao.hidden = YES;
    _tab_fapiao.layer.borderWidth = 0.5;
    _tab_fapiao.layer.borderColor = [RGBCOLOR(220, 221, 223)CGColor];
    [self.view addSubview:_tab_fapiao];
    
    
    
    
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

-(void)gAllShou{
    [_fapiaotaitoutf resignFirstResponder];
    _tab_fapiao.hidden = YES;
}


#pragma mark - UITableViewDelegate && UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = 1;
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    if (tableView.tag == 1) {
        num = 3;
    }else if (tableView.tag == 2){
        num = _dataArray.count;
    }
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
    
    if (tableView.tag == 1) {
        if (indexPath.row == 0) {
            height = 92;
        }else if (indexPath.row == 1){
            height = 80;
        }else if (indexPath.row == 2){
            height = 80;
        }
    }else if (tableView.tag == 2){//最近使用的发票信息
        height = 35;
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
    
    
    if (tableView.tag == 1) {
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
            fapiaoBackView.layer.borderWidth = 0.5;
            fapiaoBackView.layer.masksToBounds = YES;
            fapiaoBackView.layer.borderColor = [RGBCOLOR(220, 221, 223)CGColor];
            
            _fapiaotaitoutf = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, fapiaoBackView.frame.size.width - 30, 40)];
            _fapiaotaitoutf.font = [UIFont systemFontOfSize:12];
            _fapiaotaitoutf.textColor = [UIColor blackColor];
            _fapiaotaitoutf.placeholder = @"可输入个人/单位名称(最多50个字)";
            _fapiaotaitoutf.delegate = self;
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
            c_label.textColor = [UIColor grayColor];
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
        
    }else if (tableView.tag == 2){//最近使用的发票信息
        cell.textLabel.text = _dataArray[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 34.5, DEVICE_WIDTH - 30, 0.5)];
        line.backgroundColor = RGBCOLOR(220, 221, 223);
        [cell.contentView addSubview:line];
        
        UIView *line_left = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0.5, 34.5)];
        line_left.backgroundColor = RGBCOLOR(220, 221, 223);
        [cell.contentView addSubview:line_left];
        
        UIView *line_right = [[UIView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-30.5, 0, 0.5, 34.5)];
        line_right.backgroundColor = RGBCOLOR(220, 221, 223);
        [cell.contentView addSubview:line_right];
        
    }
    
    
    
    
    
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 1) {
        [self gAllShou];
    }else if (tableView.tag == 2){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self gAllShou];
        _fapiaotaitoutf.text = _dataArray[indexPath.row];
            
    }
    
    
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.tag == 2) {
        [self gshou];
    }
}



#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (_dataArray.count>0) {
        _tab_fapiao.hidden = NO;
    }
    
    return YES;
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (string.length == 0) {//删除
        
    }else{//新输入
        
        NSString *str = [NSString stringWithFormat:@"%@%@",textField.text,string];
        if (str.length>50) {
            return NO;
        }
        
    }
    
    return YES;
}


@end
