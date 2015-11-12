//
//  ChooseHopitalController.m
//  TiJian
//
//  Created by lichaowei on 15/11/12.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "ChooseHopitalController.h"
#import "SSLunarDate.h"

@interface ChooseHopitalController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIView *_calendar_bgView;
    UITableView *_table;
    int _selectRow;
}

@property (strong, nonatomic) NSCalendar *currentCalendar;
@property(nonatomic,retain)UIButton *closeButton;


@end

@implementation ChooseHopitalController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"选择时间、分院";
    self.rightString = @"确认";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
    
//    _calendar_bgView
    
    _currentCalendar = [NSCalendar currentCalendar];
    self.calendar = [[FSCalendar alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_WIDTH/1.6)];
    _calendar.delegate = self;
    _calendar.dataSource = self;
    [self.view addSubview:_calendar];
    _calendar.backgroundColor = [UIColor whiteColor];
    _calendar.clipsToBounds = YES;
    [_calendar setScope:FSCalendarScopeWeek];
//    _calendar.minimumDate = [NSDate date];
    [_calendar setCurrentPage:[NSDate date] animated:YES];
    
    _calendar.appearance.todayColor = [UIColor colorWithHexString:@"f88326"];
    _calendar.appearance.selectionColor = [UIColor colorWithHexString:@"f88326"];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.frame = CGRectMake(0, _calendar.bottom, DEVICE_WIDTH, 27);
    _closeButton.backgroundColor = [UIColor colorWithHexString:@"f7f7f7"];
    [_closeButton addTarget:self action:@selector(clickToCloseClendar:) forControlEvents:UIControlEventTouchUpInside];
    [_closeButton setImage:[UIImage imageNamed:@"yuyue_jiantou_up"] forState:UIControlStateNormal];
    [_closeButton setImage:[UIImage imageNamed:@"yuyue_jiantou_down"] forState:UIControlStateSelected];
    [self.view addSubview:_closeButton];
    
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - _closeButton.bottom) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _table.backgroundColor = [UIColor whiteColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([_table respondsToSelector:@selector(setSeparatorInset:)]) {
        [_table setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_table respondsToSelector:@selector(setLayoutMargins:)]) {
        [_table setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - 事件处理

- (void)clickToCloseClendar:(UIButton *)sender
{
    sender.selected = !sender.selected;
    FSCalendarScope selectedScope = sender.selected ? FSCalendarScopeMonth : FSCalendarScopeWeek;
    [_calendar setScope:selectedScope animated:YES];
    
}

#pragma mark - FSCalendarDelegate

- (void)calendarCurrentScopeWillChange:(FSCalendar *)calendar animated:(BOOL)animated
{
    CGSize size = [calendar sizeThatFits:calendar.frame.size];

    _calendar.height = size.height;
    _closeButton.top = _calendar.bottom;
    
    _table.top = _closeButton.bottom;
    _table.height = DEVICE_HEIGHT - 64 - _closeButton.bottom;
    
    NSLog(@"size %f",size.height);
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
    [calendar selectDate:[NSDate date] scrollToDate:YES];
    
    [calendar setCurrentPage:[NSDate date] animated:YES];
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date
{
    return YES;
}
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"did select date %@",[LTools timeDate:date withFormat:@"yyyy/MM/dd"]);
}

#pragma mark - FSCalendarDataSource
- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date
{
   SSLunarDate * _lunarDate = [[SSLunarDate alloc] initWithDate:date calendar:_currentCalendar];
    return _lunarDate.dayString;
}

#pragma - mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectRow = (int)indexPath.row + 1;
    
    [tableView reloadData];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    //按照作者最后的意思还要加上下面这一段
    
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        
        [cell setPreservesSuperviewLayoutMargins:NO];
        
    }
    
}

#pragma - mark UITableViewDataSource<NSObject>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    static NSString *identifier = @"PreViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 100 - 10, 0, 100, 50)];
        label.textColor = [UIColor colorWithHexString:@"323232"];
        label.font = [UIFont systemFontOfSize:13];
        label.textAlignment = NSTextAlignmentRight;
//        label.backgroundColor = [UIColor redColor];
        [cell.contentView addSubview:label];
        label.tag = 100;
        
        //图标 对号
        UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15 - 14.5, 0, 14.5, 50)];
        icon.image = [UIImage imageNamed:@"duihao"];
        icon.contentMode = UIViewContentModeCenter;
        [cell.contentView addSubview:icon];
        icon.tag = 101;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];

    cell.textLabel.textColor = [UIColor colorWithHexString:@"646464"];
    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"323232"];
    NSString *brand = @"慈铭体检";
    NSString *name = @"上地分院";
    NSString *text = [NSString stringWithFormat:@"%@  %@",brand,name];
    [cell.textLabel setAttributedText:[LTools attributedString:text keyword:name color:[UIColor colorWithHexString:@"323232"]]];
    
    UILabel *label = [cell.contentView viewWithTag:100];
    UIImageView *icon = [cell.contentView viewWithTag:101];
    NSString *numString = [NSString stringWithFormat:@"%d%%",76];
    NSString *d_text = [NSString stringWithFormat:@"已预约%@",numString];
    [label setAttributedText:[LTools attributedString:d_text keyword:numString color:[UIColor colorWithHexString:@"f88323"]]];
    
    if ((int)indexPath.row + 1 == _selectRow) {
        
        label.left = DEVICE_WIDTH - 100 - 10 - 35;
        icon.hidden = NO;
    }else
    {
        label.left = DEVICE_WIDTH - 100 - 10;
        icon.hidden = YES;
    }
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

@end
