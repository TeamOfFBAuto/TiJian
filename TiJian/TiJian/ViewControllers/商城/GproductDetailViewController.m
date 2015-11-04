//
//  GproductDetailViewController.m
//  TiJian
//
//  Created by gaomeng on 15/11/2.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GproductDetailViewController.h"
#import "GproductDetailTableViewCell.h"

@interface GproductDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_productDetail;
    int _count;
    
    UITableView *_tab;
    
    NSDictionary *_dataDic;
    
    GproductDetailTableViewCell *_tmpCell;
    
}

@end

@implementation GproductDetailViewController


- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
    _tab.delegate = nil;
    _tab.dataSource = nil;
    _tab = nil;
    
    [self removeObserver:self forKeyPath:@"_count"];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.myTitle = @"产品详情";
    
    
    [self addObserver:self forKeyPath:@"_count" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    
    [self prepareNetData];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentSize"]) {
        return;
    }
    
    NSNumber *num = [change objectForKey:@"new"];
    
    if ([num intValue] == 1) {
        
    }
    
}


#pragma mark - 网络请求
-(void)prepareNetData{
    
    _request = [YJYRequstManager shareInstance];
    _count = 0;
    
    NSDictionary *parameters = @{
                                 @"product_id":self.productId
                                 };
    
    
    [_request requestWithMethod:YJYRequstMethodGet api:StoreProductDetail parameters:parameters constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        _dataDic = [result dictionaryValueForKey:@"data"];
        
        [self creatTab];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
    
}

#pragma mark - 视图创建
-(void)creatTab{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStyleGrouped];
    _tab.delegate = self;
    _tab.dataSource = self;
    [self.view addSubview:_tab];
}


#pragma mark - UITableViewDelegate && UITableViewDataSource
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    GproductDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GproductDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    [cell loadCustomViewWithDic:_dataDic index:indexPath];
    
    
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //6个section
    //0     logo图 套餐名 描述 价钱
    //1     优惠券
    //2     主要参数
    //3     评价
    //4     看了又看
    //5     上拉显示体检项目详情
    return 6;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    if (section == 0) {
        num = 1;
    }else if (section == 1){
        num = 1;
    }else if (section == 2){
        num = 1;
    }else if (section == 3){
        num = 1;//1为暂无平路
    }else if (section == 4){
        num = 1;
    }else if (section == 5){
        num = 1;
    }
    
    
    return num;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger height = 0;
    
    
    if (!_tmpCell) {
        _tmpCell = [[GproductDetailTableViewCell alloc]init];
    }
    for (UIView *view in _tmpCell.contentView.subviews) {
        [view removeFromSuperview];
    }
    height = [_tmpCell loadCustomViewWithDic:_dataDic index:indexPath];
    
    
    
    
    
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    
    if (section == 3) {
        [view setFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/80])];
        UILabel *tLabel = [[UILabel alloc]initWithFrame:view.bounds];
        tLabel.text = @"评价";
        [view addSubview:tLabel];
        
        UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreBtn setFrame:CGRectMake(view.frame.size.width - 100, 0, 100, view.frame.size.height)];
        [moreBtn setTitle:@"更多" forState:UIControlStateNormal];
        [view addSubview:moreBtn];
        
    }
    
    return view;
}






@end
