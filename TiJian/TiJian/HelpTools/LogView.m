//
//  LogView.m
//  TiJian
//
//  Created by lichaowei on 16/1/9.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "LogView.h"

@interface LogView ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain)UITableView *tableView;
@property(nonatomic,retain)NSMutableArray *dataArray;

@end

@implementation LogView

+ (id)logInstance
{
    static dispatch_once_t once_t;
    static LogView *loginView;
    dispatch_once(&once_t, ^{
        loginView = [[LogView alloc]init];
    });
    return loginView;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
        self.frame = CGRectMake(0, 20, DEVICE_WIDTH, 100);
        self.dataArray = [NSMutableArray array];
        self.tableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.backgroundColor = [UIColor clearColor];
        [self addSubview:_tableView];
        UIView *head = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _tableView.width, 5)];
        _tableView.tableHeaderView = head;
    }
    return self;
}

#pragma mark - 视图创建

#pragma mark - 数据解析处理

#pragma mark - 事件处理
/**
 *  添加记录
 *
 *  @param logString
 */
- (void)addLog:(NSString *)logString
{
    if ([logString isKindOfClass:[NSString class]]) {
        NSString *temp = [NSString stringWithFormat:@"[%@]:%@",[LTools timeDate:[NSDate date] withFormat:@"yyyy月MM月dd HH:mm:ss"],logString];
        [_dataArray addObject:temp];
        [_tableView reloadData];
    }
}

#pragma mark - 代理

#pragma - mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 10;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 40.f;
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 0.01f;
//}

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
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"identify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *string = _dataArray[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:9.f];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    if (string && [string isKindOfClass:[NSString class]]) {
        cell.textLabel.text = string;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
