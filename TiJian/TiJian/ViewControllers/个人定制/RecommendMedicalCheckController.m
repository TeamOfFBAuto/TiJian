//
//  RecommendMedicalCheckController.m
//  TiJian
//
//  Created by lichaowei on 15/11/3.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "RecommendMedicalCheckController.h"
#import "GProductCellTableViewCell.h"
#import "GproductDetailViewController.h"
#import "ProjectModel.h"
#import "ProductModel.h"
#import "LSuitableView.h"

@interface RecommendMedicalCheckController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    UITableView *_table;
    NSArray *_dataArray;
    NSArray *_projectsArray;//推荐项目
    NSString *_result_id;//个性化定制结果id
    NSString *_extention_result_id;//拓展问题结果id
    
    NSArray *_fiveStarArray;//五星
    NSArray *_fourStarArray;//四星
    NSArray *_threeStarArray;//三星
}

@end

@implementation RecommendMedicalCheckController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"推荐项目";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.view.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
        
    [self getCustomizationResult];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma - mark 创建视图

- (UILabel *)labelWithFrame:(CGRect)frame
                       text:(NSString *)text
{
    UIColor *textColor = [UIColor randomColorWithoutWhiteAndBlack];
    UILabel *label = [[UILabel alloc]initWithFrame:frame title:text font:15 align:NSTextAlignmentCenter textColor:textColor];
    [label setBorderWidth:1.f borderColor:textColor];
    [label addCornerRadius:3.f];
    label.backgroundColor = [UIColor whiteColor];
    return label;
}

- (void)createViewsWithDesc:(NSString *)desc
{
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.backgroundColor = [UIColor clearColor];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_table reloadData];
    
    UIView *headview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0)];
    headview.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, DEVICE_WIDTH - 20, 0) font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE title:desc];
    [headview addSubview:label];
    CGFloat height = [LTools heightForText:desc width:label.width font:13];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.height = height;
    
    //line
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, label.bottom + 10, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [headview addSubview:line];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"<<详细报告解读>>" forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, line.bottom, DEVICE_WIDTH, 35);
    btn.backgroundColor = [UIColor whiteColor];
    [btn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [headview addSubview:btn];
    
    //line
    UIImageView *space = [[UIImageView alloc]initWithFrame:CGRectMake(0, btn.bottom, 10, 35)];
    space.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [headview addSubview:space];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(space.right, btn.bottom, DEVICE_WIDTH - 10, 35) title:@"体检套餐推荐" font:15 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE];
    [headview addSubview:label2];
    label2.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    
    headview.height = label2.bottom;
    _table.tableHeaderView = headview;
    
}


- (void)createViewsWithProjects:(NSArray *)projects
{
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.backgroundColor = [UIColor clearColor];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;

    
    NSArray *items = projects;
    UIView *headview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0)];
    headview.backgroundColor = [UIColor clearColor];
    
    UIView *head_bg_view = [[UIView alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 0)];
    head_bg_view.backgroundColor = [UIColor whiteColor];
    [headview addSubview:head_bg_view];
    
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 25, 126, 14)];
    logo.image = [UIImage imageNamed:@"zhuanjiajianyi"];
    [head_bg_view addSubview:logo];
    logo.centerX = DEVICE_WIDTH/2.f;
    
    //下面开始体检项目
    CGFloat top = logo.bottom + 30;
    
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:items.count];
    
    for (int i = 0; i < items.count; i ++) {
        
        ProjectModel *p_model = items[i];
        NSString *title = p_model.project_name;
        [temp addObject:title];
    }
    
    LSuitableView *suitableView = [[LSuitableView alloc]initWithFrame:CGRectMake(0, top, DEVICE_WIDTH, 0) itemsArray:temp];
    [head_bg_view addSubview:suitableView];
    
    head_bg_view.height = suitableView.bottom + 10;
    headview.height = head_bg_view.height + 5 + 5;
    _table.tableHeaderView = headview;

}

#pragma - mark 网络请求
/**
 *  同步个性化定制结果
 */
- (void)updateCustomization
{
    NSDictionary *params = @{@"authcode":[UserInfo getAuthkey],
                             @"result_id":_result_id};
    NSString *api = UPDATE_CUSTOMIZATION_RESULT;
    
    __weak typeof(self)weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"success result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        [LTools showMBProgressWithText:@"保存成功" addToView:weakSelf.view];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"fail result %@",result);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

/**
 *  获取个性定制结果
 */
- (void)getCustomizationResult
{
    NSString *authey = [UserInfo getAuthkey];
    authey = authey.length ? authey : @"";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *api;
    YJYRequstMethod method = YJYRequstMethodPost;
    BOOL custom = NO;
    if (self.jsonString) {
        [params safeSetString:self.jsonString forKey:@"c_result"];
        [params safeSetString:self.extensionString forKey:@"e_result"];
        [params safeSetString:[GMAPI getCurrentProvinceId] forKey:@"province_id"];
        [params safeSetString:[GMAPI getCurrentCityId] forKey:@"city_id"];
        [params safeSetString:authey forKey:@"authcode"];
        [params safeSetString:self.vouchers_id forKey:@"vouchers_id"];
        
        api = GET_CUSTOMIZAITION_RESULT;
        custom = YES;
        
    }else
    {
        //获取最近体检结果
        [params safeSetString:[GMAPI getCurrentProvinceId] forKey:@"province_id"];
        [params safeSetString:[GMAPI getCurrentCityId] forKey:@"city_id"];
        [params safeSetString:authey forKey:@"authcode"];
        api = GET_LATEST_CUSTOMIZATION_RESULT;
        method = YJYRequstMethodGet;
        custom = NO;
    }
    
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:method api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [weakSelf parseDataWithResult:result];
        if (custom) {
            //发送个性化定制成功通知
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_PersonalCustomization_SUCCESS object:nil];
        }
        
    } failBlock:^(NSDictionary *result) {
        
        
    }];
}

- (void)parseDataWithResult:(NSDictionary *)result
{
    [UserInfo updateUserCustomed:@"1"];//记录已个性化定制过状态
    
    NSDictionary *data = result[@"data"];
    
    NSString *combination_desc = data[@"combination_desc"];//简单解读
    
    NSDictionary *attention_project_data = data[@"attention_project_data"];
    
    _threeStarArray = attention_project_data[@"three_star_level"];
    _fourStarArray = attention_project_data[@"four_star_level"];
    _fiveStarArray = attention_project_data[@"five_star_level"];
    
    [self createViewsWithDesc:combination_desc];
    
    NSString *result_id = data[@"result_id"];//未登录时个性化结果保存id
    _result_id = [NSString stringWithFormat:@"%@",result_id];
    NSString *extention_result_id = data[@"extention_result_id"];
    _extention_result_id = [NSString stringWithFormat:@"%@",extention_result_id];
    
    if (![LoginManager isLogin] && (_result_id || _extention_result_id)) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"是否登录保存个性化定制结果？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        [alert show];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
         @WeakObj(self);
        [LoginManager isLogin:self loginBlock:^(BOOL success) {
           
            if (success) {
                
                [Weakself updateCustomization];
            }
            
        }];
    }
}

#pragma - mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"跳转至体检套餐购买页面");
    
    GproductDetailViewController *cc = [[GproductDetailViewController alloc]init];
    ProductModel *aModel = _dataArray[indexPath.row];
    cc.productId = aModel.product_id;
    if ([self.vouchers_id intValue] > 0) {
//        cc.isVoucherPush = YES;
        cc.VoucherId = self.vouchers_id;
    }
    [self.navigationController pushViewController:cc animated:YES];
}

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    
    return 1.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"GProductCellTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        UILabel *concernLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 50, 13) font:12 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:@"关  注 度"];
        [cell.contentView addSubview:concernLabel];
        
        UILabel *projectLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, concernLabel.bottom + 5, 50, 13) font:12 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE_SUB title:@"体检项目"];
        [cell.contentView addSubview:projectLabel];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *head = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
    head.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, 40) title:@"" font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR_TITLE];
    [head addSubview:label];
    
    if (section == 0) {
        label.text = @"基础套餐";
    }else if (section == 1){
        label.text = @"标准套餐";
    }else if (section == 2){
        label.text = @"专业套餐";
    }
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(15, 39.5, DEVICE_WIDTH - 30, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [head addSubview:line];
    
    //箭头
    UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 35, 0, 35, head.height)];
    arrow.image = [UIImage imageNamed:@"personal_jiantou_r"];
    arrow.contentMode = UIViewContentModeCenter;
    [head addSubview:arrow];
    
    return head;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.f;
}

@end
