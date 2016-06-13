//
//  GoHealthBugController.m
//  TiJian
//
//  Created by lichaowei on 16/6/12.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GoHealthBugController.h"

@interface GoHealthBugController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_table;
    UILabel *_numLabel;
    NSArray *_itemsArray;//体检项目
    UILabel *_priceLabel;
}

@end

@implementation GoHealthBugController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"结算";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    [self prepareRefreshTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 视图创建

- (void)prepareRefreshTableView
{
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self tableViewHeaderViewWithModel:self.productModel];
    
    //底部view
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 49, DEVICE_WIDTH, 49)];
    footer.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];
    
    UIButton *sender = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 12 - 75, (49 - 30)/ 2.f, 75, 30) buttonType:UIButtonTypeCustom normalTitle:@"确定" selectedTitle:nil target:self action:@selector(clickToSure:)];
    [sender.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [sender setBackgroundColor:DEFAULT_TEXTCOLOR];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [footer addSubview:sender];

    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(sender.left - 50 - 150, 0, 150, 49) font:14 align:NSTextAlignmentRight textColor:DEFAULT_TEXTCOLOR_TITLE title:nil];
    [footer addSubview:priceLabel];
    
    NSString *title = @"";
}

- (void)tableViewHeaderViewWithModel:(ThirdProductModel *)model
{
    _itemsArray = [NSArray arrayWithArray:model.items];
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 115)];
    
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 10, DEVICE_WIDTH - 12 * 2, 20)];
    contentLabel.font = [UIFont systemFontOfSize:16];
    [header addSubview:contentLabel];
    contentLabel.text = model.name;
    
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(contentLabel.left, contentLabel.bottom + 5, 100, 25)];
    priceLabel.font = [UIFont systemFontOfSize:13];
    priceLabel.textColor = RGBCOLOR(237, 108, 22);
    [header addSubview:priceLabel];
    priceLabel.text = [NSString stringWithFormat:@"¥%.2f",[model.discountPrice floatValue]];
    
    //加减
    UIImageView *numImv = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 12 - 80, priceLabel.top, 80, 25)];
    [numImv setImage:[UIImage imageNamed:@"shuliang.png"]];
    numImv.userInteractionEnabled = YES;
    [header addSubview:numImv];
    
    UIButton *jianBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jianBtn setFrame:CGRectMake(0, 0, numImv.frame.size.height, numImv.frame.size.height)];
    [jianBtn setImage:[UIImage imageNamed:@"shuliang-.png"] forState:UIControlStateNormal];
    [jianBtn addTarget:self action:@selector(clickToReduce:) forControlEvents:UIControlEventTouchUpInside];
    [numImv addSubview:jianBtn];
    
    UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(jianBtn.frame), 0, numImv.frame.size.width/3, numImv.frame.size.height)];
    numLabel.font = [UIFont systemFontOfSize:12];
    numLabel.textColor = [UIColor blackColor];
    numLabel.textAlignment = NSTextAlignmentCenter;
    [numImv addSubview:numLabel];
    numLabel.text = @"1";
    _numLabel = numLabel;
    
    UIButton *jiaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jiaBtn setFrame:CGRectMake(CGRectGetMaxX(numLabel.frame), 0, numImv.frame.size.width/3, numImv.frame.size.height)];
    [jiaBtn setImage:[UIImage imageNamed:@"shuliang+.png"] forState:UIControlStateNormal];
    [jiaBtn addTarget:self action:@selector(clickToAdd:) forControlEvents:UIControlEventTouchUpInside];
    [numImv addSubview:jiaBtn];
    
    
    //line
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, numImv.bottom + 20, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [header addSubview:line];
    
    //检测详情
    UIButton *sender = [UIButton buttonWithType:UIButtonTypeCustom];
    sender.frame = CGRectMake(12, line.bottom, DEVICE_WIDTH - 12 * 2, header.height - line.bottom);
    [sender setImage:[UIImage imageNamed:@"jiantou_up"] forState:UIControlStateNormal];
    [sender setImage:[UIImage imageNamed:@"jiantou_down"] forState:UIControlStateSelected];
    [sender setTitle:@"检测详情" forState:UIControlStateNormal];
    [sender setTitle:@"检测详情" forState:UIControlStateSelected];
    [sender setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -55)];
    [sender setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
    [sender setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    [sender setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [sender.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [header addSubview:sender];
    
    _table.tableHeaderView = header;

}

#pragma mark - 网络请求

- (void)netWorkForList
{
    NSDictionary *params = @{@"page":@"1",
                             @"per_page":@"10"};;
    NSString *api = nil;
    
    __weak typeof(self)weakSelf = self;
    __weak typeof(_table)weakTable = _table;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        NSArray *temp = [BaseModel modelsFromArray:result[@"data"]];
        //        [weakTable reloadData:temp pageSize:10];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

#pragma mark - 数据解析处理

#pragma mark - 事件处理

- (void)clickToSure:(UIButton *)sender
{
    
}

- (void)clickToAdd:(UIButton *)sender
{
    _numLabel.text = NSStringFromInt([_numLabel.text intValue] + 1);
}

- (void)clickToReduce:(UIButton *)sender
{
    int num = [_numLabel.text intValue];
    if (num > 1) {
        num -= 1;
    }else
    {
        
    }
    _numLabel.text = NSStringFromInt(num);

}

/**
 *  控制检测详情显示
 *
 *  @param sender
 */
- (void)clickToDetail:(UIButton *)sender
{
    
}

- (void)updateSumPrice
{
    CGFloat sum = [self.productModel.discountPrice floatValue] * [_numLabel.text intValue];
    
    NSString *text = [NSString stringWithFormat:@"共"];
}

#pragma mark - 代理

#pragma - mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40.f)];
    return view;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return [UIView new];
}

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _itemsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"identify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(12, 35 - 0.5, DEVICE_WIDTH - 12 * 2, 0.5)];
        line.image = [UIImage imageNamed:@"goHealth_line"];
        [cell.contentView addSubview:line];
        
        cell.textLabel.font = [UIFont systemFontOfSize:14.f];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *item = _itemsArray[indexPath.row];
    NSString *itemName = item[@"name"];
    cell.textLabel.text = itemName;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
