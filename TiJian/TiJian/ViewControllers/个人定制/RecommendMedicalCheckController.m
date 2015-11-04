//
//  RecommendMedicalCheckController.m
//  TiJian
//
//  Created by lichaowei on 15/11/3.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "RecommendMedicalCheckController.h"

@interface RecommendMedicalCheckController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_table;
}

@end

@implementation RecommendMedicalCheckController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitleLabel.text = @"推荐项目";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.view.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
    
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    
    NSArray *items = @[@"总胆固醇",@"胸镜要透视内科",@"内科",@"心电图",@"甘油内科内科三酯",@"尿常规",@"内科",@"心电图",@"甘油三酯",@"尿常规",@"胸镜透视",@"内科",@"心电图"];
    UIView *headview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0)];
    headview.backgroundColor = [UIColor clearColor];
    _table.tableHeaderView = headview;
    
    UIView *head_bg_view = [[UIView alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 0)];
    head_bg_view.backgroundColor = [UIColor whiteColor];
    [headview addSubview:head_bg_view];
    
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 25, 126, 14)];
    logo.image = [UIImage imageNamed:@"zhuanjiajianyi"];
    [head_bg_view addSubview:logo];
    logo.centerX = DEVICE_WIDTH/2.f;
    
    //下面开始体检项目
    CGFloat top = logo.bottom + 30;
    CGFloat dis = 5.f;//间距
    CGFloat left = 15.f;
    CGFloat labelRight = left - dis;
    CGFloat labelBottom = 0.f;

    for (int i = 0; i < items.count; i ++) {
        
        NSString *title = items[i];
        CGFloat width = [LTools widthForText:title font:15.f];//字本身宽度
        width += 10*2;//左右各加10
        
        if (labelRight + dis + width < DEVICE_WIDTH - 15) { //计算横着能否放下
            
            left = labelRight + dis;
        }else
        {
            top = labelBottom + 7;
            left = 15.f;
        }
    
        UIColor *textColor = [UIColor randomColor];

        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(left, top, width, 25) title:title font:15 align:NSTextAlignmentCenter textColor:textColor];
        [label setBorderWidth:1.f borderColor:textColor];
        [label addCornerRadius:3.f];
        label.backgroundColor = [UIColor whiteColor];
        [head_bg_view addSubview:label];
        labelBottom = label.bottom;
        labelRight = label.right;
    }
    
    head_bg_view.height = labelBottom + 10;
    headview.height = head_bg_view.height + 5;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    cell.textLabel.text = @"这里是套餐";
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
