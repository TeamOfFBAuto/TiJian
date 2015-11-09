//
//  GShopCarViewController.m
//  TiJian
//
//  Created by gaomeng on 15/11/6.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GShopCarViewController.h"
#import "GshopCarTableViewCell.h"

@interface GShopCarViewController ()<UITableViewDataSource,RefreshDelegate>
{
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_shopCarDetail;
    
    RefreshTableView *_rtab;
    int _page;
    int _per_page;
    
}
@end

@implementation GShopCarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"购物车";
    
    _request = [YJYRequstManager shareInstance];
    _page = 1;
    _per_page = 20;
    
    
    [self creaTab];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)creaTab{
    _rtab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStyleGrouped];
    _rtab.refreshDelegate = self;
    _rtab.dataSource = self;
    [self.view addSubview:_rtab];
    
    [_rtab showRefreshHeader:YES];
    
    
}


#pragma mark - 请求网络数据
-(void)prepareNetData{
    
    NSDictionary *dic = @{
                          @"authcode":[GMAPI testAuth],
                          @"page":[NSString stringWithFormat:@"%d",_page],
                          @"per_page":[NSString stringWithFormat:@"%d",_per_page]
                          };
    
    _request_shopCarDetail = [_request requestWithMethod:YJYRequstMethodGet api:ORDER_GET_CART_PRODCUTS parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"-------%@",result);
        
        NSArray *dataArray = [result arrayValueForKey:@"list"];
        
        [_rtab reloadData:dataArray pageSize:_per_page];
        
        
    } failBlock:^(NSDictionary *result) {
        NSLog(@"aa");
    }];
}


-(void)loadNewDataForTableView:(UITableView *)tableView{
    
    [_request removeOperation:_request_shopCarDetail];
    
    _page = 1;
    _per_page = 20;
    
    [self prepareNetData];
}

-(void)loadMoreDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}



#pragma mark - RefreshDelegate && UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = _rtab.dataArray.count;
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    
    NSDictionary *oneArray = _rtab.dataArray[section];
    NSArray *list = [oneArray arrayValueForKey:@"list"];
    
    num = list.count;
    
    return num;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/90];
    return height;
}



-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    return height;
}

- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    CGFloat height = 0;
    height = [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/250];
    return height;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/10])];
    line.backgroundColor = RGBCOLOR(244, 245, 246);
    [view addSubview:line];
    
    UIButton *chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [chooseBtn setFrame:CGRectMake(0, CGRectGetMaxY(line.frame), [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/90] -line.frame.size.height, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/90]-line.frame.size.height)];
    
    chooseBtn.backgroundColor = [UIColor orangeColor];
    [view addSubview:chooseBtn];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(chooseBtn.frame)+10, chooseBtn.frame.origin.y, DEVICE_WIDTH - 50, chooseBtn.frame.size.height)];
    titleLabel.text = @"爱康国宾体检";
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor blackColor];
    [view addSubview:titleLabel];
    
    [view setFrame:CGRectMake(0, 0, DEVICE_WIDTH, [GMAPI scaleWithHeight:0 width:DEVICE_WIDTH theWHscale:750.0/90])];
    view.backgroundColor = [UIColor whiteColor];
    
    return view;
}







-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    GshopCarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GshopCarTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    [cell loadCustomViewWithIndex:indexPath data:nil];
    
    return cell;
}


- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    NSLog(@"%s",__FUNCTION__);
}


@end
