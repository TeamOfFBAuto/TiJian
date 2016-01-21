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

//test1

//    //下面开始体检项目
//    CGFloat top = logo.bottom + 30;
//    CGFloat dis = 5.f;//间距
//    CGFloat left = 15.f;
//    CGFloat labelRight = left - dis;
//    CGFloat labelBottom = 0.f;
//
//    for (int i = 0; i < items.count; i ++) {
//
//        ProjectModel *p_model = items[i];
//        NSString *title = p_model.project_name;
//        CGFloat width = [LTools widthForText:title font:15.f];//字本身宽度
//        width += 10*2;//左右各加10
//
//        if (labelRight + dis + width < DEVICE_WIDTH - 15) { //计算横着能否放下
//
//            left = labelRight + dis;
//        }else
//        {
//            top = labelBottom + 7;
//            left = 15.f;
//        }
//
//        UIColor *textColor = [UIColor randomColor];
//
//        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(left, top, width, 25) title:title font:15 align:NSTextAlignmentCenter textColor:textColor];
//        [label setBorderWidth:1.f borderColor:textColor];
//        [label addCornerRadius:3.f];
//        label.backgroundColor = [UIColor whiteColor];
//        [head_bg_view addSubview:label];
//        labelBottom = label.bottom;
//        labelRight = label.right;
//    }


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
    if (self.jsonString) {
        [params safeSetString:self.jsonString forKey:@"c_result"];
        [params safeSetString:self.extensionString forKey:@"e_result"];
        [params safeSetString:[GMAPI getCurrentProvinceId] forKey:@"province_id"];
        [params safeSetString:[GMAPI getCurrentCityId] forKey:@"city_id"];
        [params safeSetString:authey forKey:@"authcode"];
        [params safeSetString:self.vouchers_id forKey:@"vouchers_id"];
        
        api = GET_CUSTOMIZAITION_RESULT;
    }else
    {
        //获取最近体检结果
        [params safeSetString:[GMAPI getCurrentProvinceId] forKey:@"province_id"];
        [params safeSetString:[GMAPI getCurrentCityId] forKey:@"city_id"];
        [params safeSetString:authey forKey:@"authcode"];
        api = GET_LATEST_CUSTOMIZATION_RESULT;
    }
    
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [weakSelf parseDataWithResult:result];
        
    } failBlock:^(NSDictionary *result) {
        
        
    }];
}

- (void)parseDataWithResult:(NSDictionary *)result
{
    [UserInfo updateUserCustomed:@"1"];//记录已个性化定制过状态
    NSDictionary *data = result[@"data"];
    NSArray *setmeal_product_list = data[@"setmeal_product_list"];
    _dataArray = [ProductModel modelsFromArray:setmeal_product_list];
    
    NSArray *projects_data = data[@"projects_data"];
    _projectsArray = [ProjectModel modelsFromArray:projects_data];
    
    [self createViewsWithProjects:_projectsArray];
    [_table reloadData];
    
    NSString *result_id = data[@"result_id"];//未登录时个性化结果保存id
    _result_id = [NSString stringWithFormat:@"%@",result_id];
    
    if (![LoginManager isLogin] && _result_id) {
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
    return [GProductCellTableViewCell getCellHight];
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
    
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"GProductCellTableViewCell";
    GProductCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GProductCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ProductModel *product = _dataArray[indexPath.row];
    [cell loadData:product];
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *head = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
    head.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 40) title:@"推荐套餐" font:15 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [head addSubview:label];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [head addSubview:line];
    
    return head;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.f;
}

@end
