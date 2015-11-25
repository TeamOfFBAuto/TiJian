//
//  GPushView.m
//  TiJian
//
//  Created by gaomeng on 15/11/4.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GPushView.h"
#import "GcustomNavcView.h"

@implementation GPushView
{
    NSArray *_tab1TitleDataArray;
    NSMutableArray *_genderBtnArray;
    
    NSArray *_areaData;//地区数据
    
    int _isopen[35];
    
}
-(id)initWithFrame:(CGRect)frame gender:(BOOL)theGender{
    self = [super initWithFrame:frame];
    
    
    //数据部分
    self.gender = theGender;
    if (self.gender) {
        _tab1TitleDataArray = @[@"性别",@"城市",@"价格",@"体检品牌"];
    }else{
        _tab1TitleDataArray = @[@"城市",@"价格",@"体检品牌"];
    }
    
    for (int i = 0; i<35; i++) {
        _isopen[i] = 0;
    }
    
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"garea" ofType:@"plist"];
    _areaData = [NSArray arrayWithContentsOfFile:path];
    
    
    //视图相关
    
    
    self.navigationView = [[GcustomNavcView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 64)];
    self.navigationView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.navigationView];
    
    //中
    self.navc_midelLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.navigationView.theMidelView.frame.size.width, self.navigationView.theMidelView.frame.size.height)];
    self.navc_midelLabel.backgroundColor = [UIColor orangeColor];
    self.navc_midelLabel.textAlignment = NSTextAlignmentCenter;
    self.navc_midelLabel.text = @"筛选";
    self.navc_midelLabel.textColor = RGBCOLOR(62, 150, 205);
    [self.navigationView.theMidelView addSubview:self.navc_midelLabel];
    
    //左
    self.navc_leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navc_leftBtn setFrame:CGRectMake(0, 0, self.navigationView.theLeftView.frame.size.width, self.navigationView.theLeftView.frame.size.height)];
    [self.navc_leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.navc_leftBtn setTitleColor:RGBCOLOR(107, 108, 109) forState:UIControlStateNormal];
    [self.navigationView.theLeftView addSubview:self.navc_leftBtn];
    
    //右
    self.navc_rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navc_rightBtn setFrame:CGRectMake(0, 0, self.navigationView.theRightView.frame.size.width, self.navigationView.theRightView.frame.size.height)];
    [self.navc_rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.navc_rightBtn setTitleColor:RGBCOLOR(107, 108, 109) forState:UIControlStateNormal];
    [self.navigationView.theRightView addSubview:self.navc_rightBtn];
    
    
    
    
    
    
    
    
    
    
    self.tab1 = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    self.tab1.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tab1.delegate = self;
    self.tab1.dataSource = self;
    self.tab1.tag = 1;
    
    self.tab2 = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.frame.size.width, self.frame.size.height) style:UITableViewStyleGrouped];
    self.tab2.delegate = self;
    self.tab2.dataSource = self;
    self.tab2.tag = 2;
    
    self.tab3 = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    self.tab3.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tab3.delegate = self;
    self.tab3.dataSource = self;
    self.tab3.tag = 3;
    
    self.tab4 = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    self.tab4.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tab4.delegate = self;
    self.tab4.dataSource = self;
    self.tab4.tag = 4;
    
    
    
    [self addSubview:self.tab1];
    
    
    return self;
}


#pragma mark - UITableViewDataSource && UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = 1;
    if (tableView.tag == 2) {
        num = _areaData.count+1;
    }
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    if (tableView.tag == 1) {
        if (self.gender) {
            num = 5;
        }else{
            num = 4;
        }
        
    }else if (tableView.tag == 2){
        if (section == 0) {
            num = 1;
        }else{
            
            if (_isopen[section - 1] == 0) {
                num = 0;
            }else{
                NSArray * cities = _areaData[section-1][@"Cities"];
                num = cities.count;
            }
            
            
        }
        
    }else if (tableView.tag == 3){
        
    }
    return num;
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    if (tableView.tag == 2) {
        if (section == 0) {
            UIButton *quxiaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [quxiaoBtn setImage:BACK_DEFAULT_IMAGE forState:UIControlStateNormal];
            [quxiaoBtn setTitleColor:RGBCOLOR(107, 108, 109) forState:UIControlStateNormal];
            [quxiaoBtn setFrame:CGRectMake(15, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/140] - 5 - 44 , 50, 44)];
            [view addSubview:quxiaoBtn];
            UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [titleBtn setTitle:@"城市" forState:UIControlStateNormal];
            [titleBtn setFrame:CGRectMake(CGRectGetMaxX(quxiaoBtn.frame), quxiaoBtn.frame.origin.y, self.frame.size.width- 30 - quxiaoBtn.frame.size.width*2, quxiaoBtn.frame.size.height)];
            [titleBtn setTitleColor:RGBCOLOR(62, 150, 205) forState:UIControlStateNormal];
            [view addSubview:titleBtn];
            
            UIButton *quedingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [quedingBtn setFrame:CGRectMake(self.frame.size.width - 15-50, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/140] - 5 - 44 , 50, 44)];
            [quedingBtn setTitle:@"确定" forState:UIControlStateNormal];
            [quedingBtn setTitleColor:RGBCOLOR(107, 108, 109) forState:UIControlStateNormal];
            [view addSubview:quedingBtn];
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/140] - 5, self.frame.size.width, 5)];
            line.backgroundColor = RGBCOLOR(244, 245, 246);
            [view addSubview:line];
            
            [view setFrame:CGRectMake(0, 0, self.frame.size.width, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/140])];
        }else{
            [view setFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
            UILabel *provinceNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.frame.size.width, 44)];
            provinceNameLabel.textColor = [UIColor blackColor];
            provinceNameLabel.font = [UIFont systemFontOfSize:14];
            provinceNameLabel.text = _areaData[section-1][@"State"];
            view.tag = 10+section-1;
            [view addSubview:provinceNameLabel];
            [view addTaget:self action:@selector(viewForHeaderInSectionClicked:) tag:(int)view.tag];
            
            
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, view.frame.size.width, 0.5)];
            line.backgroundColor = RGBCOLOR(225, 226, 228);
            [view addSubview:line];
            
        }
        
        
    }
    
    
    return view;
    
}


-(void)viewForHeaderInSectionClicked:(UIView*)sender{
    
    int aa = _isopen[sender.tag-10];
    if (aa == 0) {
        _isopen[sender.tag-10] = 1;
    }else{
        _isopen[sender.tag-10] = 0;
    }
    
    [self.tab2 reloadData];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    CGFloat height = 0.01;
    if (tableView.tag == 2) {
        if (section == 0) {
            height = [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/140];
        }else{
            height = 44;
        }
    }
    
    return height;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    if (tableView.tag == 1) {//主筛选
        if (indexPath.row == 0) {
            height = [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/140];
        }else if (indexPath.row == 1 && self.gender){
            height = [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/125];//性别
        }else{
            height = [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/90];
        }
        
    }else if (tableView.tag ==2){//地区
        height = 44;
    }else if (tableView.tag ==3){
        
    }
    return height;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 1) {//主筛选
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
            
        }else if (indexPath.row == 1 && self.gender){//有性别

            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 60, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/125])];
            titleLabel.text = @"性别";
            titleLabel.font = [UIFont systemFontOfSize:15];
            [cell.contentView addSubview:titleLabel];
            
            UIView *cView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+5, 0, self.frame.size.width - titleLabel.frame.size.width - 15 - 5 - 20, titleLabel.frame.size.height)];
            [cell.contentView addSubview:cView];
            
            CGFloat jianju = 5;
            CGFloat btnW = (cView.frame.size.width - 5*2)/3;
            CGFloat btnH = [GMAPI scaleWithHeight:0 width:btnW theWHscale:166.0/60];
            
            NSArray *titleArray = @[@"全部",@"女",@"男"];
            
            _genderBtnArray = [NSMutableArray arrayWithCapacity:3];
            
            for (int i = 0; i<3; i++) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:CGRectMake(i*(btnW+jianju), (cView.frame.size.height - btnH)*0.5, btnW, btnH)];
                btn.layer.cornerRadius = 3;
                btn.titleLabel.font = [UIFont systemFontOfSize:15];
                [btn setTitle:titleArray[i] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(genderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                if (i == 0) {
                    btn.layer.borderWidth = 0.5;
                    [btn setTitleColor:RGBCOLOR(237, 108, 22) forState:UIControlStateNormal];
                    btn.layer.borderColor = [RGBCOLOR(237, 108, 22)CGColor];
                }else{
                    btn.layer.borderWidth = 0.5;
                    [btn setTitleColor:RGBCOLOR(77, 78, 79) forState:UIControlStateNormal];
                    btn.layer.borderColor = [RGBCOLOR(37, 38, 38)CGColor];
                }
                [cView addSubview:btn];
                
                [_genderBtnArray addObject:btn];
            }
                
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/125] - 5, self.frame.size.width, 5)];
            line.backgroundColor = RGBCOLOR(244, 245, 246);
            [cell.contentView addSubview:line];
  
            
        }else{
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 60, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/90])];
            titleLabel.text = _tab1TitleDataArray[indexPath.row-1];
            titleLabel.font = [UIFont systemFontOfSize:15];
            [cell.contentView addSubview:titleLabel];
            
            
            UILabel *cLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+5, 0, self.frame.size.width - titleLabel.frame.size.width - 15 - 5 - 30, titleLabel.frame.size.height)];
            cLabel.backgroundColor = [UIColor orangeColor];
            cLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:cLabel];
            
            UIImageView *jiantouImv = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 25, cLabel.frame.size.height*0.5-10, 20, 20)];
            jiantouImv.backgroundColor = [UIColor purpleColor];
            [cell.contentView addSubview:jiantouImv];
            
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/90] - 0.5, self.frame.size.width, 0.5)];
            line.backgroundColor = RGBCOLOR(244, 245, 246);
            [cell.contentView addSubview:line];
        }
        
        
        return cell;
    }else if (tableView.tag == 2){//地区筛选
        static NSString *identi = @"ident2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identi];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identi];
        }
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            UILabel *locationCityLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.frame.size.width-90, 44)];
            locationCityLabel.textColor = [UIColor grayColor];
            locationCityLabel.text = @"北京";
            locationCityLabel.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:locationCityLabel];
            
            UILabel *tishiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(locationCityLabel.frame)+5, 0, 65, 44)];
            tishiLabel.font = [UIFont systemFontOfSize:10];
            tishiLabel.text = @"当前所在位置";
            tishiLabel.textColor = RGBCOLOR(134, 135, 136);
            [cell.contentView addSubview:tishiLabel];
            
        }else{
            UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.frame.size.width-90, 44)];
            cityLabel.textColor = [UIColor grayColor];
            NSArray * cities = _areaData[indexPath.section][@"Cities"];
            cityLabel.text = cities[indexPath.row][@"city"];
            cityLabel.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:cityLabel];
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
    
    [self addSubview:self.tab2];
    
    
    if (tableView.tag == 1) {
        if (self.gender) {
            if (indexPath.row == 2) {//城市
                [self addSubview:self.tab2];
            }else if (indexPath.row == 3){//价格
                [self addSubview:self.tab3];
            }else if (indexPath.row == 4){//体检品牌
                [self addSubview:self.tab4];
            }
        }else{
            if (indexPath.row == 1) {//城市
                [self addSubview:self.tab2];
            }else if (indexPath.row == 2){//价格
                [self addSubview:self.tab3];
            }else if (indexPath.row == 3){//体检品牌
                [self addSubview:self.tab4];
            }
        }
    }
    
}



#pragma mark - MyMethod
-(void)genderBtnClicked:(UIButton *)sender{
    for (UIButton *btn in _genderBtnArray) {
        btn.layer.borderWidth = 0.5;
        [btn setTitleColor:RGBCOLOR(77, 78, 79) forState:UIControlStateNormal];
        btn.layer.borderColor = [RGBCOLOR(37, 38, 38)CGColor];
    }
    
    sender.layer.borderWidth = 0.5;
    [sender setTitleColor:RGBCOLOR(237, 108, 22) forState:UIControlStateNormal];
    sender.layer.borderColor = [RGBCOLOR(237, 108, 22)CGColor];
}




@end
