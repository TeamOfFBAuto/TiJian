//
//  GPushView.m
//  TiJian
//
//  Created by gaomeng on 15/11/4.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GPushView.h"

@implementation GPushView
{
    NSArray *_tab1TitleDataArray;
}
-(id)initWithFrame:(CGRect)frame noGender:(BOOL)theGender{
    self = [super initWithFrame:frame];
    
    self.noGender = theGender;
    _tab1TitleDataArray = @[@"城市",@"价格",@"体检品牌"];
    
    self.viewsArray = [NSMutableArray arrayWithCapacity:3];
    
    self.tab1 = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    self.tab1.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tab1.delegate = self;
    self.tab1.dataSource = self;
    self.tab1.tag = 1;
    [self.viewsArray addObject:self.tab1];
    
    self.tab2 = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    self.tab2.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tab2.delegate = self;
    self.tab2.dataSource = self;
    self.tab2.tag = 2;
    [self.viewsArray addObject:self.tab2];
    
    self.tab3 = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    self.tab3.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tab3.delegate = self;
    self.tab3.dataSource = self;
    self.tab3.tag = 3;
    [self.viewsArray addObject:self.tab3];
    
    
    [self addSubview:self.tab1];
    
    
    return self;
}


#pragma mark - UITableViewDataSource && UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    if (tableView.tag == 1) {
        if (self.noGender) {
            num = 4;
        }else{
            num = 5;
        }
        
    }else if (tableView.tag == 2){
        
    }else if (tableView.tag == 3){
        
    }
    return num;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    if (tableView.tag == 1) {
        if (indexPath.row == 0) {
            height = [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/140];
        }else if (indexPath.row == 1 && !self.noGender){
            height = [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/125];
        }else{
            height = [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/90];
        }
    }else if (tableView.tag ==2){
        
    }else if (tableView.tag ==3){
        
    }
    return height;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 1) {
        static NSString *identi = @"ident1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identi];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identi];
        }
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        if (indexPath.row == 0) {
            UIButton *quxiaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [quxiaoBtn setTitle:@"取消" forState:UIControlStateNormal];
            [quxiaoBtn setTitleColor:RGBCOLOR(107, 108, 109) forState:UIControlStateNormal];
            [quxiaoBtn setFrame:CGRectMake(15, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/140] - 5 - 44 , 50, 44)];
            [cell.contentView addSubview:quxiaoBtn];
            
            
            UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [titleBtn setTitle:@"筛选" forState:UIControlStateNormal];
            [titleBtn setFrame:CGRectMake(CGRectGetMaxX(quxiaoBtn.frame), quxiaoBtn.frame.origin.y, self.frame.size.width- 30 - quxiaoBtn.frame.size.width*2, quxiaoBtn.frame.size.height)];
            [titleBtn setTitleColor:RGBCOLOR(62, 150, 205) forState:UIControlStateNormal];
            [cell.contentView addSubview:titleBtn];
            
            UIButton *quedingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [quedingBtn setFrame:CGRectMake(self.frame.size.width - 15-50, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/140] - 5 - 44 , 50, 44)];
            [quedingBtn setTitle:@"确定" forState:UIControlStateNormal];
            [quedingBtn setTitleColor:RGBCOLOR(107, 108, 109) forState:UIControlStateNormal];
            [cell.contentView addSubview:quedingBtn];
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/140] - 5, self.frame.size.width, 5)];
            line.backgroundColor = RGBCOLOR(244, 245, 246);

            [cell.contentView addSubview:line];
            
        }else if (indexPath.row == 1){
            if (self.noGender) {
                UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 40, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/125])];
                titleLabel.text = _tab1TitleDataArray[indexPath.row-1];
                titleLabel.font = [UIFont systemFontOfSize:15];
                [cell.contentView addSubview:titleLabel];
                
//                UILabel *contentLabel = [UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(contentLabel.frame)+5, 0, self.frame.size.width - 15, <#CGFloat height#>)
                
                UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/140] - 0.5, self.frame.size.width, 0.5)];
                line.backgroundColor = RGBCOLOR(244, 245, 246);
                [cell.contentView addSubview:line];
            }else{
                UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 40, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/125])];
                titleLabel.text = @"性别";
                titleLabel.font = [UIFont systemFontOfSize:15];
                [cell.contentView addSubview:titleLabel];
                
                UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/140] - 5, self.frame.size.width, 5)];
                line.backgroundColor = RGBCOLOR(244, 245, 246);
                [cell.contentView addSubview:line];
            }
            
            
            
            
        }else{
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 40, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/125])];
            titleLabel.text = _tab1TitleDataArray[indexPath.row-1];
            titleLabel.font = [UIFont systemFontOfSize:15];
            [cell.contentView addSubview:titleLabel];
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/140] - 0.5, self.frame.size.width, 0.5)];
            line.backgroundColor = RGBCOLOR(244, 245, 246);
            [cell.contentView addSubview:line];
        }
        
        
        return cell;
    }else if (tableView.tag == 2){
        static NSString *identi = @"ident2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identi];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identi];
        }
        return cell;
    }else if (tableView.tag == 3){
        static NSString *identi = @"ident3";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identi];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identi];
        }
        return cell;
    }
    
    
    return [[UITableViewCell alloc]init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    [UIView animateWithDuration:1 animations:^{
        [self.tab1 removeFromSuperview];
        [self addSubview:self.tab2];
    }];
    
}






@end
