//
//  GHospitalOfProvinceViewController.m
//  TiJian
//
//  Created by gaomeng on 16/7/21.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GHospitalOfProvinceViewController.h"
#import "UIViewController+NavigationBar.h"

@interface GHospitalOfProvinceViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tab;
    NSInteger _selectRow;
    NSArray *_citiesArray;
    UIScrollView *_rightView;
    
    UIView *_searchView;//输入框下层view
}
@end

@implementation GHospitalOfProvinceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _selectRow = 0;
    
    [self setupNavigation];
    
    [self creatTab];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 视图创建
-(void)creatTab{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 64,80, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _tab.backgroundColor = RGBCOLOR(241, 240, 245);
    _tab.delegate = self;
    _tab.dataSource = self;
    _tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tab];
    
}

//创建自定义navigation
- (void)setupNavigation{
    [self resetShowCustomNavigationBar:YES];
    //调整与左边的间距
    UIBarButtonItem * spaceButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton1.width = -10;
    
    if (iPhone6PLUS) {
        spaceButton1.width = -15;
    };

    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 32, 32)];
    [leftBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(gogoback) forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:leftBtn];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftView];

    self.currentNavigationItem.leftBarButtonItems = @[spaceButton1,leftItem];
    
    _searchView = [[UIView alloc]initWithFrame:CGRectZero];
    _searchView.layer.cornerRadius = 5;
    _searchView.backgroundColor = [UIColor whiteColor];
//
//    //带框的view
//    _kuangView = [[UIView alloc]initWithFrame:CGRectZero];
//    _kuangView.layer.cornerRadius = 5;
//    _kuangView.layer.borderColor = [RGBCOLOR(192, 193, 194)CGColor];
//    _kuangView.layer.borderWidth = 0.5;
//    [_searchView addSubview:_kuangView];
//    
//    
//    UIImageView *fdjImv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 13, 13)];
//    [fdjImv setImage:[UIImage imageNamed:@"search_fangdajing.png"]];
//    [_searchView addSubview:fdjImv];
//    
//    self.searchTf = [[UITextField alloc]initWithFrame:CGRectZero];
//    self.searchTf.font = [UIFont systemFontOfSize:13];
//    self.searchTf.backgroundColor = [UIColor whiteColor];
//    self.searchTf.layer.cornerRadius = 5;
//    self.searchTf.placeholder = @"输入您要找的商品";
//    self.searchTf.delegate = self;
//    self.searchTf.returnKeyType = UIReturnKeySearch;
//    self.searchTf.clearButtonMode = UITextFieldViewModeWhileEditing;
//    [_kuangView addSubview:self.searchTf];
//    
//    
//    _editState = 0;
//    _rightItem1 = [[UIBarButtonItem alloc]initWithCustomView:_searchView];
//    
//    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    [spaceButtonItem setWidth:-10];
//    
//    _myNavcRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_myNavcRightBtn setFrame:CGRectMake(0, 0, 30, 30)];
//    _myNavcRightBtn.titleLabel.font = [UIFont systemFontOfSize:12];
//    [_myNavcRightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    [_myNavcRightBtn addTarget:self action:@selector(myNavcRightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:_myNavcRightBtn];
//    self.currentNavigationItem.rightBarButtonItems = @[spaceButtonItem,rightBtnItem,_rightItem1];
//    UIView *effectView = self.currentNavigationBar.effectContainerView;
//    
//    if (effectView) {
//        UIView *alphaView = [[UIView alloc] initWithFrame:effectView.bounds];
//        [effectView addSubview:alphaView];
//        alphaView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.8];
//        alphaView.tag = 10000;
//    };
//    
//    [self setEffectViewAlpha:0];
//    [self changeSearchViewAndKuangFrameAndTfWithState:0];
    
}

#pragma mark - 返回上个界面
-(void)gogoback{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 网络请求
-(void)prepareNetData{
    
    NSDictionary *parameters = @{
                                 
                                 };
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_PRODUCT_CLASS parameters:parameters constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        DDLOG(@"%@",result);
        
        NSArray *list = [result arrayValueForKey:@"list"];
        _citiesArray = list;
        
        _rightView = [[UIScrollView alloc]initWithFrame:CGRectMake(80, 0, DEVICE_WIDTH - 80, DEVICE_HEIGHT - 64- 44)];
        _rightView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_rightView];
        
        [self reloadRightViewWithTag:0];
        
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

-(void)reloadRightViewWithTag:(NSInteger)theTag{
    
    
}


#pragma mark - UITableViewDelegate && UITableViewDatasource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    NSDictionary *dic = _citiesArray[indexPath.row];
    
    NSString *title = [dic stringValueForKey:@"category_name"];
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 80, 50)];
    [btn setBackgroundImage:[UIImage imageNamed:@"gbtnLightBlue.png"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"gbtnWhite.png"] forState:UIControlStateSelected];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.tag = indexPath.row+10;
    [btn addTarget:self action:@selector(classClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btn];
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(79.5, 0, 0.5, 50)];
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 49.5, 80, 0.5)];
    line1.backgroundColor = RGBCOLOR(226, 226, 226);
    line2.backgroundColor = RGBCOLOR(226, 226, 226);
    
    [cell.contentView addSubview:line1];
    [cell.contentView addSubview:line2];
    
    
    if (indexPath.row == _selectRow) {
        line1.hidden = YES;
        btn.selected = YES;
    }else{
        line1.hidden = NO;
        btn.selected = NO;
    }
    
    
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _citiesArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


-(void)classClicked:(UIButton *)sender{
    
    NSInteger index = sender.tag - 10;
    if (index == _selectRow) {
        
    }else{
        _selectRow = index;
        sender.selected = YES;
        [self reloadRightViewWithTag:_selectRow];
        [_tab reloadData];
    }
    
}


@end
