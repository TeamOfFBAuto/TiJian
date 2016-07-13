//
//  GSearchView.m
//  TiJian
//
//  Created by gaomeng on 16/1/7.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GSearchView.h"
#import "GStoreHomeViewController.h"
#import "UILabel+GautoMatchedText.h"
#import "GCustomSearchViewController.h"
#import "GoneClassListViewController.h"

@implementation GSearchView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = RGBCOLOR(244, 245, 246);
        
        self.tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStyleGrouped];
        self.tab.backgroundColor = RGBCOLOR(244, 245, 246);
        self.tab.delegate = self;
        self.tab.dataSource = self;
        [self addSubview:self.tab];
        
        
    }
    return self;
}



#pragma mark - 点击逻辑
//热搜按钮点击
-(void)hotSearchBtnClicked:(UIButton *)sender{
    [GMAPI setuserCommonlyUsedSearchWord:sender.titleLabel.text];
    [self.delegate searchBtnClickedWithStr:sender.titleLabel.text isHotSearch:YES];
}

//清空历史搜索
-(void)qingkongBtnClicked{
    
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定清空历史记录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    al.delegate = self;
    [al show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        
    }else if (buttonIndex == 1){
        [GMAPI cache:nil ForKey:USERCOMMONLYUSEDSEARCHWORD];
        
        self.dataArray = [GMAPI cacheForKey:USERCOMMONLYUSEDSEARCHWORD];
        
        [self.tab reloadData];
    }
}




#pragma mark - UITableViewDelegate && UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = 95;
    return height;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CGFloat height = 60;
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 60)];
    view.backgroundColor = RGBCOLOR(244, 245, 246);
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.layer.borderColor = [RGBCOLOR(238, 239, 240)CGColor];
    btn.layer.borderWidth = 0.5;
    btn.layer.cornerRadius = 4;
    btn.layer.masksToBounds = YES;
    [btn setFrame:CGRectMake(60, 20, DEVICE_WIDTH - 120, 30)];
    [btn setTitle:@"清空历史搜索" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    btn.backgroundColor = [UIColor whiteColor];
    [btn addTarget:self action:@selector(qingkongBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    if (self.dataArray.count == 0) {
        btn.hidden = YES;
    }
    
    
    return view;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 60)];
    view.backgroundColor = [UIColor orangeColor];
    
    UIView *upLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5)];
    upLine.backgroundColor = RGBCOLOR(244, 245, 246);
    [view addSubview:upLine];
    
    UIScrollView *hotSearchScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(upLine.frame), DEVICE_WIDTH, 50)];
    hotSearchScrollView.showsHorizontalScrollIndicator = NO;
    hotSearchScrollView.backgroundColor = [UIColor whiteColor];
    [view addSubview:hotSearchScrollView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 12, 50, 27)];
    titleLabel.text = @"热搜";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [hotSearchScrollView addSubview:titleLabel];
    
    CGFloat s_width = titleLabel.right;
    for (int i = 0; i<self.hotSearch.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = RGBCOLOR(239, 240, 241);
        
        NSString *hotStr = self.hotSearch[i];
        UILabel *l = [[UILabel alloc]init];
        l.font = [UIFont systemFontOfSize:12];
        l.text = hotStr;
        
        CGFloat l_w = [l getTextWidth];
        CGFloat btnWidth = l_w +20;
        CGFloat btnJianju = 10;
        
        [btn setFrame:CGRectMake(s_width +btnJianju, 12, btnWidth, 27)];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        s_width = btn.right;
        btn.layer.cornerRadius = 13.5;
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [RGBCOLOR(229, 230, 231)CGColor];
        [btn setTitle:[NSString stringWithFormat:@"%@",hotStr] forState:UIControlStateNormal];
        [btn setTitleColor:RGBCOLOR(80, 81, 82) forState:UIControlStateNormal];
        [hotSearchScrollView addSubview:btn];
        btn.tag = 1000+i;
        [btn addTarget:self action:@selector(hotSearchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    [hotSearchScrollView setContentSize:CGSizeMake(s_width+10, 50)];

    UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(hotSearchScrollView.frame), DEVICE_WIDTH, 5)];
    downLine.backgroundColor = RGBCOLOR(244, 245, 246);
    [view addSubview:downLine];
    
    
    
    //历史搜索title
    UIView *hostoryTitleView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(downLine.frame), DEVICE_WIDTH, 35)];
    hostoryTitleView.backgroundColor = [UIColor whiteColor];
    [view addSubview:hostoryTitleView];
    
    
    UILabel *historyTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, 35)];
    historyTitleLabel.text = @"历史搜索";
    historyTitleLabel.font = [UIFont boldSystemFontOfSize:14];
    historyTitleLabel.textColor = [UIColor blackColor];
    [hostoryTitleView addSubview:historyTitleLabel];
    
    UIView *lishi_line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(historyTitleLabel.frame), DEVICE_WIDTH, 0.5)];
    lishi_line.backgroundColor = RGBCOLOR(199, 200, 202);
    [hostoryTitleView addSubview:lishi_line];
    

    return view;
    
}



-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = self.dataArray[self.dataArray.count - indexPath.row - 1];
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.textColor = RGBCOLOR(38, 38, 39);
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *str = self.dataArray[self.dataArray.count - indexPath.row - 1];
    self.kuangBlock(str);
}


//block的set方法
-(void)setKuangBlock:(kuangBlock)kuangBlock{
    _kuangBlock = kuangBlock;
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%s",__FUNCTION__);
    
    [self.delegate.searchTf resignFirstResponder];
    [self.delegate setEffectViewAlpha:1];

    
    
}








@end
