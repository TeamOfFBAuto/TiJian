//
//  GcommentViewController.m
//  TiJian
//
//  Created by gaomeng on 15/11/13.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GcommentViewController.h"
#import "ProductCommentModel.h"
#import "GcommentTableViewCell.h"

@interface GcommentViewController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_rTab;
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_GetProductComment;
    
    GcommentTableViewCell *_tmpCell;
    
    
}
@end

@implementation GcommentViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.myTitle = @"评论";
    
    [self creatRtab];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)creatRtab{
    _rTab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _rTab.refreshDelegate = self;
    _rTab.dataSource = self;
    [self.view addSubview:_rTab];
    [_rTab showRefreshHeader:YES];
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
    NSInteger num = _rTab.dataArray.count;
    return num;
}


- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    CGFloat height = 30;
    
    if (!_tmpCell) {
        _tmpCell = [[GcommentTableViewCell alloc]init];
    }
    
    for (UIView *view in _tmpCell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    height = [_tmpCell loadCustomViewWithModel:_rTab.dataArray[indexPath.row]];
    
    return height;
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
    GcommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GcommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    [cell loadCustomViewWithModel:_rTab.dataArray[indexPath.row]];
    
    return cell;
}



- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    NSLog(@"%s",__FUNCTION__);
}

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%s",__FUNCTION__);
}


#pragma mark - 网络请求
-(void)prepareNetData{
    _request = [YJYRequstManager shareInstance];
    NSDictionary *dic = @{
                          @"product_id":self.productId,
                          @"page":@"1",
                          @"per_page":@"3"
                          };
    _request_GetProductComment = [_request requestWithMethod:YJYRequstMethodGet api:GET_PRODUCT_COMMENT parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSArray *arr = [result arrayValueForKey:@"list"];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in arr) {
            ProductCommentModel *model = [[ProductCommentModel alloc]initWithDictionary:dic];
            [array addObject:model];
        }
        [_rTab reloadData:array pageSize:G_PER_PAGE];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
}





@end
