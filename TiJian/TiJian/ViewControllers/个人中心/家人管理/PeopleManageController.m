//
//  PeopleManageController.m
//  TiJian
//
//  Created by lichaowei on 15/11/6.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "PeopleManageController.h"
#import "AddPeopleViewController.h"

@interface PeopleManageController ()<UITableViewDataSource,RefreshDelegate>
{
    RefreshTableView *_table;
    UIButton *_arrowBtn;
    BOOL _isOpen;//是否展开
    UIView *_view_tableHeader;
    BOOL _isEdit;//是否在编辑
}

@end

@implementation PeopleManageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitleLabel.text = @"家人管理";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.view.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [self createNavigationbarTools];
    
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH,DEVICE_HEIGHT - 64)];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];
    
    _isOpen = YES;//默认打开
    _isEdit = NO;//默认非编辑
    [_table.dataArray addObjectsFromArray:@[@"张木木",@"刘木木",@"张木木"]];
    _table.tableHeaderView = [self tableHeadView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 事件处理

/**
 *  点击打开或者关闭
 *
 *  @param sender
 */
- (void)clickToAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _arrowBtn.selected = sender.selected;
    
    _isOpen = !sender.selected;
    
    [_table reloadData];
    
}

/**
 *  添加新人
 */
- (void)clickToAdd:(UIButton *)sender
{
    AddPeopleViewController *add = [[AddPeopleViewController alloc]init];
    [self.navigationController pushViewController:add animated:YES];
}

/**
 *  编辑状态、可删除人
 *
 *  @param sender
 */
- (void)clickToEdit:(UIButton *)sender
{
    _isEdit = !_isEdit;
    [_table reloadData];
}

#pragma - mark 创建视图

- (void)createNavigationbarTools
{
    
    UIButton *rightView=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 88, 44)];
    rightView.backgroundColor=[UIColor clearColor];
    
    //添加
    UIButton *heartButton = [[UIButton alloc]initWithframe:CGRectMake(0, 0, 44, 44) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"personal_jiaren_tianjia"] selectedImage:nil target:self action:@selector(clickToAdd:)];
    [heartButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    
    
    //删除
    UIButton *collectButton = [[UIButton alloc]initWithframe:CGRectMake(44, 0, 44, 44) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"personal_jiaren_shanchu"] selectedImage:nil target:self action:@selector(clickToEdit:)];
    [collectButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    
    
    [rightView addSubview:heartButton];
    [rightView addSubview:collectButton];
    
    UIBarButtonItem *comment_item=[[UIBarButtonItem alloc]initWithCustomView:rightView];
    
    self.navigationItem.rightBarButtonItem = comment_item;
}

- (UIView *)tableHeadView
{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 67)];
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 6, DEVICE_WIDTH, 56)];
    bgView.backgroundColor = [UIColor whiteColor];
    [headView addSubview:bgView];
    //本人
    UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 35, bgView.height) title:@"本人" font:16 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
    [bgView addSubview:titleLable];
    
    NSString *name = [UserInfo userInfoForCache].user_name;
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleLable.right + 60, 0, 200, bgView.height) title:name font:15 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"313131"]];
    [bgView addSubview:nameLabel];
    
    UIImageView *editImage = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15 - 7, (67-14)/2.f, 7, 14)];
    editImage.image = [UIImage imageNamed:@"personal_jiantou_r"];
    [bgView addSubview:editImage];
    
    return headView;
}

#pragma - mark RefreshDelegate

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    
}
//新加
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    if (_isEdit) {//在编辑
        
        NSLog(@"删除");
    }
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    return 56.f;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView
{
    if (!_view_tableHeader) {
        _view_tableHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 56)];
        _view_tableHeader.backgroundColor = [UIColor whiteColor];
        //本人
        UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 35, _view_tableHeader.height) title:@"家人" font:16 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
        [_view_tableHeader addSubview:titleLable];
        
        NSString *name = [NSString stringWithFormat:@"%d位",(int)_table.dataArray.count];
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleLable.right + 60, 0, 200, _view_tableHeader.height) title:name font:15 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"313131"]];
        [_view_tableHeader addSubview:nameLabel];
        
        _arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _arrowBtn.frame = CGRectMake(DEVICE_WIDTH - 15 - 13, (67-7)/2.f, 13, 7);
        [_view_tableHeader addSubview:_arrowBtn];
        [_arrowBtn setImage:[UIImage imageNamed:@"personal_jiaren_jiantou_b"] forState:UIControlStateNormal];
        [_arrowBtn setImage:[UIImage imageNamed:@"personal_jiaren_jiantou_t"] forState:UIControlStateSelected];
        [_view_tableHeader addTaget:self action:@selector(clickToAction:) tag:0];
        
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, _view_tableHeader.height - 0.5, DEVICE_WIDTH, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [_view_tableHeader addSubview:line];
    }
    
    return _view_tableHeader;
}
- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView
{
    return 56.f;
}

////meng新加
//-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView
//{
//    return 0.01f;
//}
//
//-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView
//{
//    return [UIView new];
//}



#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (!_isOpen) {
        return 0.f;
    }
    return _table.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"GProductCellTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 56)];
        bgView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:bgView];
        
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15 - 7, (56-7-15)/2.f, 7, 14)];
        arrow.image = [UIImage imageNamed:@"personal_jiantou_r"];
        [bgView addSubview:arrow];
        
        //本人
        UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(15 * 2, 0, 35, bgView.height) title:nil font:16 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
        [bgView addSubview:titleLable];
        titleLable.tag = 100;
        
        NSString *name = nil;
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleLable.right + 60, 0, 200, bgView.height) title:name font:15 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"313131"]];
        [bgView addSubview:nameLabel];
        nameLabel.tag = 101;
        
        //line
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 56 - 0.5, DEVICE_WIDTH, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [cell.contentView addSubview:line];
        
        //删除按钮
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        deleteBtn.backgroundColor = [UIColor colorWithHexString:@"ed1f1f"];
        deleteBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        deleteBtn.frame = CGRectMake(DEVICE_WIDTH - 70, 0, 70, 56);
        [bgView addSubview:deleteBtn];
        deleteBtn.tag = 102;

    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    UILabel *title = [cell.contentView viewWithTag:100];
    UILabel *nameLabel = [cell.contentView viewWithTag:101];
    UIButton *deleteBtn = (UIButton *)[cell.contentView viewWithTag:102];
    deleteBtn.hidden = !_isEdit;
    
    title.text = @"称谓";
    nameLabel.text = _table.dataArray[indexPath.row];
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


@end
