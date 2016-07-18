//
//  VipAppointViewController.m
//  TiJian
//
//  Created by lichaowei on 16/4/28.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "VipAppointViewController.h"
#import "WebviewController.h"
#import "AddPeopleViewController.h"

@interface VipAppointViewController ()<RefreshDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
{
    BOOL _sliderOpen;
}

@property(nonatomic,retain)RefreshTableView *table;
@property(nonatomic,retain)UIView *sliderBgView;
@property(nonatomic,retain)UIView *footerView;
@property(nonatomic,retain)UIActivityIndicatorView *indicator;

@end

@implementation VipAppointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"专家号";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    imageView.backgroundColor = [UIColor orangeColor];
    imageView.image = [UIImage imageNamed:@"vip_bg"];
    imageView.userInteractionEnabled = YES;
    [self.view addSubview:imageView];
    
    UIButton *sender = [UIButton buttonWithType:UIButtonTypeCustom];
    sender.frame = CGRectMake(0, imageView.height - 80 - 40, DEVICE_WIDTH/2.f, 40.f);
    [sender.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [sender setTitle:@"选择就诊人" forState:UIControlStateNormal];
    [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sender setBackgroundImage:[UIImage imageNamed:@"vip_select2"] forState:UIControlStateNormal];
    [sender addCornerRadius:20.f];
    [imageView addSubview:sender];
    sender.centerX = imageView.width / 2.f;
    [sender addTarget:self action:@selector(clickToSelectPeople:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.sliderBgView];
    
    //初始化值
    _sliderOpen = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建

-(UIView *)footerView
{
    if (!_footerView) {

        CGFloat width = DEVICE_WIDTH * 2 / 5.f;
        _footerView = [[UIView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH, self.sliderBgView.height - 150, width,150)];
        _footerView.backgroundColor = [UIColor whiteColor];
        
        UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
        [add setTitle:@"添加就诊人" forState:UIControlStateNormal];
        add.frame = CGRectMake(20, _footerView.height - 80 - 30 - 30 - 5, width - 40, 30);
        [add addCornerRadius:15];
        add.backgroundColor = DEFAULT_TEXTCOLOR;
        [add.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [add addTarget:self action:@selector(clickToAddPeople) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:add];
        
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancel setTitle:@"取消" forState:UIControlStateNormal];
        cancel.frame = CGRectMake(20, add.bottom + 15 + 10, width - 40, 30);
        [cancel addCornerRadius:15];
        cancel.backgroundColor = [UIColor lightGrayColor];
        [cancel.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(hiddeSliderView) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:cancel];
    }
    return _footerView;
}

-(UIActivityIndicatorView *)indicator
{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicator.color = [UIColor grayColor];
        _indicator.frame = _table.bounds;
    }
    return _indicator;
}

-(UIView *)sliderBgView
{
    if (!_sliderBgView)
    {
        _sliderBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
        _sliderBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _sliderBgView.alpha = 0.f;
        [self.view addSubview:_sliderBgView];
        
        [_sliderBgView addSubview:self.table];
        [_sliderBgView addSubview:self.footerView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddeSliderView)];
        tap.delegate = self;
        [_sliderBgView addGestureRecognizer:tap];
    }
    return _sliderBgView;
}

-(RefreshTableView *)table
{
    if (!_table) {
        CGFloat width = DEVICE_WIDTH * 2 / 5.f;
        _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH, 0, width, self.sliderBgView.height - 150) style:UITableViewStylePlain refreshHeaderHidden:YES];
        _table.refreshDelegate = self;
        _table.backgroundColor = [UIColor whiteColor];
        _table.dataSource = self;
        [self.sliderBgView addSubview:_table];
        _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        
        UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 66)];
        _table.tableHeaderView = header;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 33, width, 33) font:14 align:NSTextAlignmentCenter textColor:[UIColor whiteColor] title:@"选择就诊人"];
        label.backgroundColor = DEFAULT_TEXTCOLOR;
        [header addSubview:label];
    }
    
    [_table addSubview:self.indicator];
    return _table;
}

/**
 *  请求结果 为空、等特殊情况
 */
-(ResultView *)resultView
{
    if (!_resultView) {
        _resultView = [[ResultView alloc]initWithImage:[UIImage imageNamed:@"hema_heart"]
                                                        title:@"温馨提示"
                                                      content:@"您还没有添加家人"];
    }
    
    return (ResultView *)_resultView;
}

#pragma mark - 事件处理

- (void)hiddeSliderView
{
    [self selectPeople:NO];
}

- (void)selectPeople:(BOOL)selected
{
    _sliderOpen = selected;

     @WeakObj(self);
    [UIView animateWithDuration:0.3 animations:^{
        
        if (selected) {
            Weakself.table.left = DEVICE_WIDTH * 3 / 5.f;
            Weakself.footerView.left = DEVICE_WIDTH * 3 / 5.f;
            Weakself.sliderBgView.alpha = 1;
        }else
        {
            Weakself.table.left = DEVICE_WIDTH;
            Weakself.footerView.left = DEVICE_WIDTH;
            Weakself.sliderBgView.alpha = 0;
        }
    }];
}

- (void)clickToSelectPeople:(UIButton *)sender
{
    [self selectPeople:YES];
    
    if (self.table.dataArray.count == 0) {
        
        [self getFamily];
    }
}

/**
 *  点击跳转至挂号网对接
 *
 *  @param btn
 */
- (void)pushToGuaHaoType:(int)type
               familyuid:(NSString *)familyuid
{
    WebviewController *web = [[WebviewController alloc]init];
    web.guaHao = YES;
    web.type = type;
    web.familyuid = familyuid;
    web.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];
}

- (void)clickToAddPeople
{
    AddPeopleViewController *add = [[AddPeopleViewController alloc]init];

     @WeakObj(self);
     @WeakObj(_table);
    [add setUpdateParamsBlock:^(NSDictionary *params){
        
        NSLog(@"params %@",params);
        Weak_table.isReloadData = YES;
        [Weakself getFamily];
    }];
    
    [self.navigationController pushViewController:add animated:YES];
}

#pragma mark - 网络请求

- (void)getFamily
{
    [self.indicator startAnimating];
    
    NSString *authkey = [UserInfo getAuthkey];
    __weak typeof(self)weakSelf = self;
//    __weak typeof(_table)weakTable = _table;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:GET_FAMILY parameters:@{@"authcode":authkey} constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *temp = [UserInfo modelsFromArray:result[@"family_list"]];
        UserInfo *selfUser = [UserInfo userInfoForCache];
        selfUser.appellation = @"本人";
        
        NSString *name = @"本人";
        if ([LTools isEmpty:selfUser.real_name]) {
            name = selfUser.user_name;
        }else
        {
            name = selfUser.real_name;
        }
        selfUser.family_user_name = name;
        
        NSMutableArray *arr = [NSMutableArray arrayWithObject:selfUser];
        [arr addObjectsFromArray:temp];
        
        [weakSelf.table reloadData:arr pageSize:1000 noDataView:weakSelf.resultView];
        
        [weakSelf.indicator stopAnimating];
        
    } failBlock:^(NSDictionary *result) {
        
        [weakSelf.table loadFailWithView:weakSelf.resultView pageSize:1000];
        [weakSelf.indicator stopAnimating];
    }];
}


#pragma mark - 数据解析处理

#pragma mark - 代理

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"];
}

#pragma - mark RefreshDelegate <NSObject>

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    
}
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    UserInfo *user = _table.dataArray[indexPath.row];
    [self pushToGuaHaoType:2 familyuid:user.family_uid];
    
    [self hiddeSliderView];
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    return 44.f;
}

#pragma - mark UITableViewDataSource

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return tableView.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"peopleManagerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UserInfo *aModel = _table.dataArray[indexPath.row];
    
    NSString *name = aModel.family_user_name;
//    NSString *alia = aModel.appellation;
//    NSString *temp = [NSString stringWithFormat:@"(%@)%@",alia,name];
    
    cell.textLabel.text = name;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
