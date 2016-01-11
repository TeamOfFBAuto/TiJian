//
//  GSearchView.m
//  TiJian
//
//  Created by gaomeng on 16/1/7.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "GSearchView.h"
#import "GStoreHomeViewController.h"

@implementation GSearchView



-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
        self.tab.delegate = self;
        self.tab.dataSource = self;
        [self addSubview:self.tab];
        
    }
    return self;
}


//热搜按钮点击
-(void)hotSearchBtnClicked:(UIButton *)sender{
    
}


#pragma mark - UITableViewDelegate && UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = 60;
    return height;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CGFloat height = 50;
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
    view.backgroundColor = [UIColor orangeColor];
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
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 12, 50, 27)];
    titleLabel.text = @"热搜";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:15];
    [hotSearchScrollView addSubview:titleLabel];
    
    CGFloat s_width = 0;
    for (int i = 0; i<10; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = RGBCOLOR(239, 240, 241);
        [btn setFrame:CGRectMake(s_width + 75, 12, 70, 27)];
        s_width += 75;
        btn.layer.cornerRadius = 5;
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [RGBCOLOR(229, 230, 231)CGColor];
        [btn setTitle:[NSString stringWithFormat:@"%d",i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [hotSearchScrollView addSubview:btn];
        btn.tag = 1000+i;
        [btn addTarget:self action:@selector(hotSearchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    [hotSearchScrollView setContentSize:CGSizeMake(s_width, 50)];

    UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(hotSearchScrollView.frame), DEVICE_WIDTH, 5)];
    downLine.backgroundColor = RGBCOLOR(244, 245, 246);
    [view addSubview:downLine];
    
    
    return view;
    
}



-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%s",__FUNCTION__);
    
    [self.d1.searchTf resignFirstResponder];
    
    [self.d1 setEffectViewAlpha:1];
    
    
//    UIView *effectView = self.d1.currentNavigationBar.effectContainerView;
//    if (effectView) {
//        UIView *alphaView = [effectView viewWithTag:10000];
//        
//        if (_searchTf.isFirstResponder) {
//            alphaView.alpha = 1;
//        }else{
//            if (scrollView.contentOffset.y > 64) {
//                CGFloat alpha = (scrollView.contentOffset.y -64)/200.0f;
//                alpha = MIN(alpha, 1);
//                alphaView.alpha = alpha;
//            }else{
//                alphaView.alpha = 0;
//            }
//        }
//        
//        
//    }
    
    
    
}






@end
