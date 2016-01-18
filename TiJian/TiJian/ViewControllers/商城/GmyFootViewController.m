//
//  GmyFootViewController.m
//  TiJian
//
//  Created by gaomeng on 16/1/13.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GmyFootViewController.h"
#import "ProductModel.h"
#import "GProductCellTableViewCell.h"
#import "GproductDetailViewController.h"
#import "GCustomSearchViewController.h"

@interface GmyFootViewController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_rtab;
    
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_foot;
    
    //顶部工具栏
    UIView *_upToolView;
    
    UIView *_downToolBlackView;
    
    BOOL _toolShow;
    
    
}
@end

@implementation GmyFootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeOther];
    self.rightImage = [UIImage imageNamed:@"dian_three.png"];
    self.myTitle = @"足迹";
    
    [self creatRTab];
    
    [self creatUpToolView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 点击处理

-(void)rightButtonTap:(UIButton *)sender{
    
    _toolShow = !_toolShow;
    
    if (_toolShow) {
        
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
        } completion:^(BOOL finished) {
            if (!_downToolBlackView) {
                _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
                _downToolBlackView.backgroundColor = [UIColor blackColor];
                _downToolBlackView.alpha = 0.6;
                [self.view addSubview:_downToolBlackView];
                
                [_downToolBlackView addTapGestureTaget:self action:@selector(upToolShou) imageViewTag:0];
            }
            _downToolBlackView.hidden = NO;
        }];
        
        
    }else{
        if (!_downToolBlackView) {
            _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
            _downToolBlackView.backgroundColor = [UIColor blackColor];
            _downToolBlackView.alpha = 0.6;
            [self.view addSubview:_downToolBlackView];
        }
        _downToolBlackView.hidden = YES;
        
        
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, -50, DEVICE_WIDTH, 50)];
        }];
    }
    
    
}

-(void)upToolShou{
    
    if (_toolShow) {
        if (!_downToolBlackView) {
            _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
            _downToolBlackView.backgroundColor = [UIColor blackColor];
            _downToolBlackView.alpha = 0.6;
            [self.view addSubview:_downToolBlackView];
        }
        _downToolBlackView.hidden = YES;
        
        
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, -50, DEVICE_WIDTH, 50)];
        }];
        
        _toolShow = !_toolShow;
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            [_upToolView setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
        } completion:^(BOOL finished) {
            if (!_downToolBlackView) {
                _downToolBlackView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT)];
                _downToolBlackView.backgroundColor = [UIColor blackColor];
                _downToolBlackView.alpha = 0.6;
                [self.view addSubview:_downToolBlackView];
                
                [_downToolBlackView addTapGestureTaget:self action:@selector(upToolShou) imageViewTag:0];
            }
            _downToolBlackView.hidden = NO;
        }];
        _toolShow = !_toolShow;
    }
}



//工具栏按钮点击
-(void)upToolBtnClicked1:(NSInteger)index{
    if (index == 20) {//搜索
        GCustomSearchViewController *cc = [[GCustomSearchViewController alloc]init];
        [self.navigationController pushViewController:cc animated:YES];
        
    }else if (index == 21){//首页
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}




#pragma mark - 视图创建


-(void)creatUpToolView{
    GMAPI *gmapi = [GMAPI sharedManager];
    _upToolView = [gmapi creatTwoBtnUpToolView];
    [self.view addSubview:_upToolView];
    __weak typeof (self)bself = self;
    [gmapi setUpToolViewBlock1:^(NSInteger index) {
        [bself upToolBtnClicked1:index];
    }];
}


-(void)creatRTab{
    _rtab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _rtab.refreshDelegate = self;
    _rtab.dataSource = self;
    [self.view addSubview:_rtab];
    
    [_rtab showRefreshHeader:YES];
}



#pragma mark - RefreshDelegate && UITableViewDataSource

- (void)loadNewDataForTableView:(UITableView *)tableView{
    
    [self prepareNetData];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = 1;
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    num = _rtab.dataArray.count;
    return num;
}


- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    return [GProductCellTableViewCell getCellHight];
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    return height;
}

-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    return height;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}

-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    
    
    GProductCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GProductCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    ProductModel *model = _rtab.dataArray[indexPath.row];
    
    [cell loadData:model];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}



- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    
    GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
    ProductModel *model = _rtab.dataArray[indexPath.row];
    cc.productId = model.product_id;
    [self.navigationController pushViewController:cc animated:YES];
    
    
}

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
}


#pragma mark - 网络请求

-(void)prepareNetData{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSDictionary *dic = @{
                          @"authcode":[UserInfo getAuthkey],
                          @"page":[NSString stringWithFormat:@"%d",_rtab.pageNum],
                          @"per_page":[NSString stringWithFormat:@"%d",G_PER_PAGE]
                          };
    
    _request_foot = [_request requestWithMethod:YJYRequstMethodGet api:GetMyProductsFoot parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSArray *list = [result arrayValueForKey:@"list"];

    
        NSMutableArray *dataArray_net = [NSMutableArray arrayWithCapacity:1];
        
        for (NSDictionary *dic in list) {
            ProductModel *model = [[ProductModel alloc]initWithDictionary:dic];
            [dataArray_net addObject:model];
        }
        
        
        
        [_rtab reloadData:dataArray_net pageSize:G_PER_PAGE];
        
    } failBlock:^(NSDictionary *result) {
        [_rtab loadFail];
        
    }];
    
}

@end
