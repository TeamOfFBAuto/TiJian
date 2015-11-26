//
//  GoneClassListViewController.m
//  TiJian
//
//  Created by gaomeng on 15/11/2.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GoneClassListViewController.h"
#import "RefreshTableView.h"
#import "NSDictionary+GJson.h"
#import "GProductCellTableViewCell.h"
#import "GproductDetailViewController.h"
#import "GTranslucentSideBar.h"
#import "GPushView.h"
#import "ProductModel.h"

@interface GoneClassListViewController ()<RefreshDelegate,UITableViewDataSource,GTranslucentSideBarDelegate,UITableViewDelegate>
{
    RefreshTableView *_table;
    YJYRequstManager *_request;
    AFHTTPRequestOperation *_request_ProductOneClass;
    
    NSMutableArray *_productOneClassArray;
    
    int _count;//网络请求个数
    
    
    
    
}

@property (nonatomic, strong) GTranslucentSideBar *rightSideBar;


@end

@implementation GoneClassListViewController


- (void)dealloc
{
    NSLog(@"dealloc %@",self);
    _table.refreshDelegate = nil;
    _table.dataSource = nil;
    _table = nil;
    [_request removeOperation:_request_ProductOneClass];
    [self removeObserver:self forKeyPath:@"_count"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addObserver:self forKeyPath:@"_count" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = self.className;
    
    
    [self creatTableView];
    [self creatRightTranslucentSideBar];
    [self creatFilterBtn];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建

-(void)creatTableView{
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];
    [_table showRefreshHeader:YES];
    
}

//创建侧滑栏
-(void)creatRightTranslucentSideBar{
    
    // Create Right SideBar
    self.rightSideBar = [[GTranslucentSideBar alloc] initWithDirection:YES];
    self.rightSideBar.delegate = self;
    self.rightSideBar.sideBarWidth = DEVICE_WIDTH*670.0/750;
    self.rightSideBar.translucentStyle = UIBarStyleBlack;
    self.rightSideBar.tag = 1;
    
    // Add PanGesture to Show SideBar by PanGesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGestureRecognizer];

    GPushView *pushView = [[GPushView alloc]initWithFrame:CGRectMake(0, 0, self.rightSideBar.sideBarWidth, self.rightSideBar.view.frame.size.height)gender:YES];
    pushView.delegate = self;
    [self.rightSideBar setContentViewInSideBar:pushView];

}

-(void)creatFilterBtn{
    UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    filterButton.frame = CGRectMake(17, 17, 38, 38);
    [filterButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [filterButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [filterButton setImage:[UIImage imageNamed:@"shaixuan"] forState:UIControlStateNormal];
    
    [self.view addSubview:filterButton];
    [filterButton addTarget:self action:@selector(clickToFilter:) forControlEvents:UIControlEventTouchUpInside];
    
}


#pragma mark - 逻辑处理

-(void)therightSideBarDismiss{
    [self.rightSideBar dismiss];
}


-(void)clickToFilter:(UIButton *)sender{
    [self.rightSideBar show];
}

#pragma mark - Gesture Handler
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        CGPoint startPoint = [recognizer locationInView:self.view];
            self.rightSideBar.isCurrentPanGestureTarget = YES;
    }
    
    [self.rightSideBar handlePanGestureToShow:recognizer inView:self.view];
    
}

#pragma mark - CDRTranslucentSideBarDelegate
- (void)sideBar:(GTranslucentSideBar *)sideBar didAppear:(BOOL)animated
{
    
    if (sideBar.tag == 1) {
        NSLog(@"Right SideBar did appear");
    }
}

- (void)sideBar:(GTranslucentSideBar *)sideBar willAppear:(BOOL)animated
{
    if (sideBar.tag == 1) {
        NSLog(@"Right SideBar will appear");
    }
}

- (void)sideBar:(GTranslucentSideBar *)sideBar didDisappear:(BOOL)animated
{
    
    if (sideBar.tag == 1) {
        NSLog(@"Right SideBar did disappear");
    }
}

- (void)sideBar:(GTranslucentSideBar *)sideBar willDisappear:(BOOL)animated
{
    if (sideBar.tag == 1) {
        NSLog(@"Right SideBar will disappear");
    }
}



#pragma mark - 请求网络数据

-(void)prepareNetData{
    
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    _count = 0;

    
    NSDictionary *dic = @{
                          @"category_id":[NSString stringWithFormat:@"%d",self.category_id]
                          };
    
    
    
    //首页精品推荐
    _request_ProductOneClass = [_request requestWithMethod:YJYRequstMethodGet api:StoreProductList parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *arr = [result arrayValueForKey:@"data"];
        
        _productOneClassArray = [NSMutableArray arrayWithCapacity:1];
        
        for (NSDictionary *dic in arr) {
            ProductModel *model = [[ProductModel alloc]initWithDictionary:dic];
            [_productOneClassArray addObject:model];
        }
        
        [self setValue:[NSNumber numberWithInt:_count + 1] forKeyPath:@"_count"];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
 
    
}


//网络请求完成
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        return;
    }
    
    NSNumber *num = [change objectForKey:@"new"];
    
    if ([num intValue] == 1) {
        
        [_table reloadData:_productOneClassArray pageSize:G_PER_PAGE];
        
    }
 
    
}



#pragma - mark RefreshDelegate


- (void)loadNewDataForTableView:(UITableView *)tableView{
    
    [_request removeOperation:_request_ProductOneClass];
    
    [self prepareNetData];
    
}
- (void)loadMoreDataForTableView:(UITableView *)tableView{
    
    [self prepareNetData];
    
}


- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    
    NSLog(@"%s",__FUNCTION__);
    GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
    ProductModel *model = _table.dataArray[indexPath.row];
    cc.productId = model.product_id;
    [self.navigationController pushViewController:cc animated:YES];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%s",__FUNCTION__);
    
}


- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    CGFloat imv_W = 255.0/750 *DEVICE_WIDTH;
    height = [GMAPI scaleWithHeight:0 width:imv_W theWHscale:255.0/160]+20;
    return height;
}
//将要显示
- (void)refreshTableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
    });
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger num = 0;
    if (tableView.tag ==1) {
        num = 4;
    }else{
        num = _table.dataArray.count;
    }
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 1) {
        static NSString *ident = @"ident";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
        }
        return cell;
    }else{
        static NSString *identifier = @"identifier";
        GProductCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[GProductCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        
        ProductModel *model = _table.dataArray[indexPath.row];
        
        [cell loadData:model];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    
    return [[UITableViewCell alloc]init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

@end
