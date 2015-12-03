//
//  GPushView.m
//  TiJian
//
//  Created by gaomeng on 15/11/4.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GPushView.h"
#import "GcustomNavcView.h"
#import "GoneClassListViewController.h"

@implementation GPushView
{
    NSArray *_tab1TitleDataArray;
    NSMutableArray *_genderBtnArray;
    
    NSArray *_areaData;//地区数据
    
    int _isopen[35];
    
    NSArray *_priceArray;//价格区间
    
    int _isMark_price[10];
    
    
    UIView *_tab3Header;//价格选择的tabHeader
    
    UIImageView *_defaultPriceImv;
    
    
}
-(id)initWithFrame:(CGRect)frame gender:(BOOL)theGender{
    self = [super initWithFrame:frame];
    
    
    //数据部分
    self.gender = theGender;
    _tab1TitleDataArray = @[@"城市",@"价格",@"体检品牌"];
    
    for (int i = 0; i<35; i++) {
        _isopen[i] = 0;
    }
    
    
    for (int i = 0; i<10; i++) {
        _isMark_price[i] = 0;
    }
    
    
    
    //地区数据
    NSString *path = [[NSBundle mainBundle]pathForResource:@"garea" ofType:@"plist"];
    _areaData = [NSArray arrayWithContentsOfFile:path];
    
    
    //价格筛选
    _priceArray = @[@"0—300",@"300—500",@"500—800",@"800—1000",@"1000—1500",@"1500—2000",@"2000以上"];
    
    
    
    
    //创建视图
    [self creatNavcView];
    [self creatTab];
    
    return self;
}


#pragma mark - 视图创建

//创建上方导航栏
-(void)creatNavcView{
    self.navigationView = [[GcustomNavcView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 64)];
    self.navigationView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.navigationView];
    
    //中
    self.navc_midelLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, self.navigationView.theMidelView.frame.size.width, self.navigationView.theMidelView.frame.size.height-20)];
    self.navc_midelLabel.textAlignment = NSTextAlignmentCenter;
    self.navc_midelLabel.text = @"筛选";
    self.navc_midelLabel.textColor = RGBCOLOR(62, 150, 205);
    self.navc_midelLabel.font = [UIFont systemFontOfSize:17];
    [self.navigationView.theMidelView addSubview:self.navc_midelLabel];
    
    //左
    self.navc_leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navc_leftBtn setFrame:CGRectMake(5, 15, 40, self.navigationView.theLeftView.frame.size.height-20)];
    [self.navc_leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.navc_leftBtn setTitleColor:RGBCOLOR(107, 108, 109) forState:UIControlStateNormal];
    self.navc_leftBtn.tag = -1;
    [self.navc_leftBtn addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navc_leftBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.navigationView.theLeftView addSubview:self.navc_leftBtn];
    
    //右
    self.navc_rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navc_rightBtn setFrame:CGRectMake(self.navigationView.theRightView.frame.size.width - 45, 15, 40, self.navigationView.theRightView.frame.size.height-20)];
    [self.navc_rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.navc_rightBtn setTitleColor:RGBCOLOR(107, 108, 109) forState:UIControlStateNormal];
    [self.navc_rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navc_rightBtn.tag = -11;
    self.navc_rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.navigationView.theRightView addSubview:self.navc_rightBtn];
    
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, self.navigationView.frame.size.height - 5, self.navigationView.frame.size.width, 5)];
    line.backgroundColor = RGBCOLOR(244, 245, 246);
    [self.navigationView addSubview:line];
}



//创建tab
-(void)creatTab{
    //主筛选
    self.tab1 = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.frame.size.width, self.frame.size.height-64) style:UITableViewStylePlain];
    self.tab1.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tab1.delegate = self;
    self.tab1.dataSource = self;
    self.tab1.tag = 1;
    
    //城市选择
    self.tab2 = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.frame.size.width, self.frame.size.height-64) style:UITableViewStyleGrouped];
    self.tab2.delegate = self;
    self.tab2.dataSource = self;
    self.tab2.tag = 2;
    [self creatTab2Header];
    
    
    
    
    //价格
    self.tab3 = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.frame.size.width, self.frame.size.height-64) style:UITableViewStyleGrouped];
    self.tab3.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tab3.delegate = self;
    self.tab3.dataSource = self;
    self.tab3.tag = 3;
    [self creatTab3Header];
    
    //体检品牌
    self.tab4 = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.frame.size.width, self.frame.size.height-64) style:UITableViewStylePlain];
    self.tab4.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tab4.delegate = self;
    self.tab4.dataSource = self;
    self.tab4.tag = 4;
    
    [self addSubview:self.tab1];
}

//创建城市选择的tableHeader 展示默认定位城市
-(void)creatTab2Header{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 44)];
    view.backgroundColor = [UIColor whiteColor];
    self.tab2.tableHeaderView = view;
    
    UILabel *locationCityLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.frame.size.width-90, 44)];
    locationCityLabel.textColor = [UIColor grayColor];
    locationCityLabel.text = @"北京";
    locationCityLabel.font = [UIFont systemFontOfSize:14];
    [view addSubview:locationCityLabel];
    
    UILabel *tishiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(locationCityLabel.frame)+5, 0, 65, 44)];
    tishiLabel.font = [UIFont systemFontOfSize:10];
    tishiLabel.text = @"当前所在位置";
    tishiLabel.textColor = RGBCOLOR(134, 135, 136);
    [view addSubview:tishiLabel];
}

//创建价格选择的tabelHeader 显示默认全部
-(void)creatTab3Header{
    _tab3Header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
    _tab3Header.backgroundColor = [UIColor whiteColor];
    
    [_tab3Header addTaget:self action:@selector(tab3HeaderClicked) tag:0];
    
    self.tab3.tableHeaderView = _tab3Header;
    
    UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, 50, 44)];
    tLabel.font = [UIFont systemFontOfSize:14];
    tLabel.text = @"全部";
    tLabel.textColor = RGBCOLOR(237, 108, 22);
    [_tab3Header addSubview:tLabel];
    
    
    _defaultPriceImv = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 30, 15, 15, 15)];
    [_defaultPriceImv setImage:[UIImage imageNamed:@"duihao.png"]];
    [_tab3Header addSubview:_defaultPriceImv];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, self.frame.size.width, 0.5)];
    line.backgroundColor = RGBCOLOR(234, 235, 236);
    [_tab3Header addSubview:line];
    
    
    [self setDefaultPriceImvHidden];
    
}



#pragma mark - 逻辑处理


-(void)tab3HeaderClicked{
    for (int i = 0; i<10; i++) {
        _isMark_price[i] = 0;
    }
    self.userChoosePrice = nil;
    self.userChoosePrice_high = nil;
    self.userChoosePrice_low = nil;
    [self setDefaultPriceImvHidden];
    [self.tab3 reloadData];
}


/**
 *  设置默认价格后面的对勾是否显示
 */
-(void)setDefaultPriceImvHidden{
    BOOL hidden = NO;
    for (int i = 0; i<10; i++) {
        if (_isMark_price[i]) {
            hidden = YES;
        }
    }
    
    _defaultPriceImv.hidden = hidden;
}


/**
 *  navigationView leftBtn 点击
 *
 *  @param sender 自定义navcView左上角按钮
 */
-(void)leftBtnClicked:(UIButton*)sender{
    if (sender.tag == -1) {//主筛选界面侧边栏消失
        [self.delegate therightSideBarDismiss];
    }else if (sender.tag == -2){//选择地区 返回到主筛选界面
        [self.tab2 removeFromSuperview];
        [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
    }else if (sender.tag == -3){//选择价格 返回到主筛选界面
        [self.tab3 removeFromSuperview];
        self.userChoosePrice_low = nil;
        self.userChoosePrice_high = nil;
        [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
    }else if (sender.tag == -4){//选择品牌 返回到主筛选界面
        [self.tab4 removeFromSuperview];
        [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
    }
    
    
    [self.tab1 reloadData];
    
    
}

/**
 *  navigationView rightBtn 点击
 *
 *  @param sender navcview右边按钮
 */
-(void)rightBtnClicked:(UIButton*)sender{
    if (sender.tag == -11) {//主筛选界面侧边栏消失
        
        NSLog(@"%@",self.userChooseCity);
        NSLog(@"%@",self.userChoosePinpai);
        NSLog(@"%@",self.userChoosePinpai_id);
        NSLog(@"%@",self.userChoosePrice);
        NSLog(@"%@",self.userChoosePrice_high);
        NSLog(@"%@",self.userChoosePrice_low);
        

        
        
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
        
        //地区选择
        if (self.userChooseCity) {
            int cityId = [GMAPI cityIdForName:self.userChooseCity];
            NSString *province_id = [GMAPI getProvineIdWithCityId:cityId];
            [dic setValue:province_id forKey:@"province_id"];
            [dic setValue:[NSString stringWithFormat:@"%d",cityId] forKey:@"city_id"];
            
        }
        
        
        //品牌选择
        if (self.userChoosePinpai_id) {
            [dic setValue:self.userChoosePinpai_id forKey:@"brand_id"];
        }
        
        //价格选择
        if (self.userChoosePrice) {
            [dic setValue:self.userChoosePrice_low forKey:@"low_price"];
            [dic setValue:self.userChoosePrice_high forKey:@"high_price"];
        }
        
        
        //性别选择
        NSString *gender = nil;
        for (int i = 0; i<3; i++) {
            UIButton *btn = _genderBtnArray[i];
            if (btn.selected) {
                if (i == 1) {
                    gender = @"2";
                }else if (i == 2){
                    gender = @"1";
                }
            }
        }
        
        if (gender) {
            [dic setValue:gender forKey:@"gender"];
        }
        
        
        
        [self.delegate shaixuanFinishWithDic:dic];
        
        [self.delegate therightSideBarDismiss];
        
        
        
    }else if (sender.tag == -12){//选择地区 返回到主筛选界面
        [self.tab2 removeFromSuperview];
        [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
    }else if (sender.tag == -13){//选择价格 返回到主筛选界面
        [self.tab3 removeFromSuperview];
        [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
        [self.tab1 reloadData];
        
    }else if (sender.tag == -14){//选择品牌 返回到主筛选界面
        [self.tab4 removeFromSuperview];
        [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
    }
}


/**
 *  设置navigationview的leftBtn midelTitle rightBtn
 *
 *  @param theLTag   左边按钮tag
 *  @param theImage  左边按钮图
 *  @param theTitle  左边按钮标题
 *  @param theMtitle 中间标题
 *  @param theRTag   右边按钮tag
 */
-(void)setNavcLeftBtnTag:(NSInteger)theLTag image:(UIImage*)theImage leftTitle:(NSString*)theTitle midTitle:(NSString*)theMtitle rightBtnTag:(NSInteger)theRTag{
    
    self.navc_leftBtn.tag = theLTag;
    self.navc_rightBtn.tag = theRTag;
    [self.navc_leftBtn setTitle:theTitle forState:UIControlStateNormal];
    [self.navc_leftBtn setImage:theImage forState:UIControlStateNormal];
    
    self.navc_midelLabel.text = theMtitle;
    
}




//选择性别
-(void)genderBtnClicked:(UIButton *)sender{
    for (UIButton *btn in _genderBtnArray) {
        btn.layer.borderWidth = 0.5;
        [btn setTitleColor:RGBCOLOR(77, 78, 79) forState:UIControlStateNormal];
        btn.layer.borderColor = [RGBCOLOR(37, 38, 38)CGColor];
        btn.selected = NO;
    }
    
    sender.layer.borderWidth = 0.5;
    [sender setTitleColor:RGBCOLOR(237, 108, 22) forState:UIControlStateNormal];
    sender.layer.borderColor = [RGBCOLOR(237, 108, 22)CGColor];
    sender.selected = YES;
}


//选择价格tab 填写价格之后点击确认按钮
-(void)priceQuerenBtnClicked{
    [self.tab3 removeFromSuperview];
    [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
    
    self.userChoosePrice = [NSString stringWithFormat:@"%@——%@",self.tf_low.text,self.tf_high.text];
    
    [self.tab1 reloadData];
}


#pragma mark - UITableViewDataSource && UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = 1;
    if (tableView.tag == 2) {
        num = _areaData.count;
    }
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    if (tableView.tag == 1) {//主筛选
        num = 4;
        
    }else if (tableView.tag == 2){
        
        if (_isopen[section] == 0) {//地区选择
            num = 0;
        }else{
            NSArray * cities = _areaData[section][@"Cities"];
            num = cities.count;
        }
        
    }else if (tableView.tag == 3){//价格选择
        num = _priceArray.count;
    }else if (tableView.tag == 4){//体检品牌
        num = self.delegate.brand_city_list.count;
    }
    return num;
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    if (tableView.tag == 2) {
        
        [view setFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
        UILabel *provinceNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.frame.size.width, 44)];
        provinceNameLabel.textColor = [UIColor blackColor];
        provinceNameLabel.font = [UIFont systemFontOfSize:14];
        provinceNameLabel.text = _areaData[section][@"State"];
        view.tag = 10+section;
        [view addSubview:provinceNameLabel];
        [view addTaget:self action:@selector(viewForHeaderInSectionClicked:) tag:(int)view.tag];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, view.frame.size.width, 0.5)];
        line.backgroundColor = RGBCOLOR(225, 226, 228);
        [view addSubview:line];
        
        
    }
    
    
    return view;
    
}



-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    if (tableView.tag == 3) {//价格区间选择
        [view setFrame:CGRectMake(0, 0, self.frame.size.width, 60)];
        view.backgroundColor = [UIColor whiteColor];
        
        UIView *tf_low_backView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, 70, 30)];
        tf_low_backView.layer.borderColor = [RGBCOLOR(37, 38, 38)CGColor];
        tf_low_backView.layer.borderWidth = 0.5;
        tf_low_backView.layer.masksToBounds = YES;
        tf_low_backView.layer.cornerRadius = 4;
        [view addSubview:tf_low_backView];
        
        //最低价
        self.tf_low = [[UITextField alloc]initWithFrame:tf_low_backView.bounds];
        self.tf_low.textAlignment = NSTextAlignmentCenter;
        self.tf_low.delegate = self;
        [tf_low_backView addSubview:self.tf_low];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(tf_low_backView.frame)+5, 24, 20, 1)];
        line.backgroundColor = RGBCOLOR(37, 38, 38);
        [view addSubview:line];
        
        UIView *tf_high_backView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(tf_low_backView.frame)+30, tf_low_backView.frame.origin.y, tf_low_backView.frame.size.width, tf_low_backView.frame.size.height)];
        tf_high_backView.layer.borderWidth = 0.5;
        tf_high_backView.layer.cornerRadius = 4;
        tf_high_backView.layer.borderColor = [RGBCOLOR(37, 38, 38)CGColor];
        [view addSubview:tf_high_backView];
        
        //最高价
        self.tf_high = [[UITextField alloc]initWithFrame:tf_low_backView.bounds];
        self.tf_high.textAlignment = NSTextAlignmentCenter;
        self.tf_high.font = [UIFont systemFontOfSize:14];
        self.tf_high.delegate = self;
        [tf_high_backView addSubview:self.tf_high];
        
        
        
        //确定按钮
        UIButton *quedingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [quedingBtn setFrame:CGRectMake(CGRectGetMaxX(tf_high_backView.frame)+10, tf_high_backView.frame.origin.y, 55, tf_high_backView.frame.size.height)];
        [quedingBtn setTitle:@"确定" forState:UIControlStateNormal];
        quedingBtn.backgroundColor = RGBCOLOR(134, 135, 136);
        quedingBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [quedingBtn addTarget:self action:@selector(priceQuerenBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:quedingBtn];
        
        
        
        
        
        
    }
    
    return view;
}



-(void)viewForHeaderInSectionClicked:(UIView*)sender{
    
    NSInteger tt = sender.tag - 10;
    
    int aa = _isopen[sender.tag-10];
    
    if (tt == 0 || tt == 1 || tt == 2 || tt == 3) {//4个直辖市
        [self.tab2 removeFromSuperview];
        
        [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
        
        NSDictionary *dic = _areaData[tt];
        NSString *provinceName = [dic stringValueForKey:@"State"];
        
        self.userChooseCity = provinceName;
        
        [self.tab1 reloadData];
        
        return;
        
    }
    
    
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
        height = 44;
    }
    
    return height;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    CGFloat height = 0.01;
    if (tableView.tag == 3) {//价格筛选
        height = 50;
    }
    
    return height;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    if (tableView.tag == 1) {//主筛选
        if (indexPath.row == 0 && self.gender){
            height = [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/125];//性别
        }else{
            height = [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/90];
        }
        
    }else if (tableView.tag ==2){//地区
        height = 44;
    }else if (tableView.tag ==3){//价格筛选
        height = 44;
    }else if (tableView.tag == 4){//体检品牌
        height = 44;
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
        
        if (self.gender){//有性别
            if (indexPath.row == 0) {
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
                cLabel.textAlignment = NSTextAlignmentRight;
                cLabel.font = [UIFont systemFontOfSize:14];
                if (indexPath.row == 1) {
                    cLabel.text = self.userChooseCity;
                }else if (indexPath.row == 2){
                    cLabel.text = self.userChoosePrice;
                }else if (indexPath.row == 3){
                    cLabel.text = self.userChoosePinpai;
                }
                
                [cell.contentView addSubview:cLabel];
                
                UIImageView *jiantouImv = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 20, cLabel.frame.size.height*0.5-8, 8, 16)];
                [jiantouImv setImage:[UIImage imageNamed:@"personal_jiantou_r.png"]];
                [cell.contentView addSubview:jiantouImv];
                
                
                UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/90] - 0.5, self.frame.size.width, 0.5)];
                line.backgroundColor = RGBCOLOR(244, 245, 246);
                [cell.contentView addSubview:line];
            }
            
  
            
        }else{//无性别
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 60, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/90])];
            titleLabel.text = _tab1TitleDataArray[indexPath.row-1];
            titleLabel.font = [UIFont systemFontOfSize:15];
            [cell.contentView addSubview:titleLabel];
            
            
            UILabel *cLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+5, 0, self.frame.size.width - titleLabel.frame.size.width - 15 - 5 - 30, titleLabel.frame.size.height)];
            cLabel.backgroundColor = [UIColor orangeColor];
            cLabel.font = [UIFont systemFontOfSize:14];
            cLabel.textAlignment = NSTextAlignmentCenter;
            
            if (indexPath.row == 0) {
                cLabel.text = self.userChooseCity;
            }else if (indexPath.row == 1){
                cLabel.text = self.userChoosePrice;
            }else if (indexPath.row == 2){
                cLabel.text = self.userChoosePinpai;
            }
            
            [cell.contentView addSubview:cLabel];
            
            UIImageView *jiantouImv = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 25, cLabel.frame.size.height*0.5-10, 20, 20)];
            jiantouImv.backgroundColor = [UIColor purpleColor];
            [cell.contentView addSubview:jiantouImv];
            
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/90] - 0.5, self.frame.size.width, 0.5)];
            line.backgroundColor = RGBCOLOR(244, 245, 246);
            [cell.contentView addSubview:line];
        
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        
        UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.frame.size.width-90, 44)];
        cityLabel.textColor = [UIColor grayColor];
        NSArray * cities = _areaData[indexPath.section][@"Cities"];
        cityLabel.text = cities[indexPath.row][@"city"];
        cityLabel.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:cityLabel];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (tableView.tag == 3){//价格选择
        static NSString *identi = @"ident3";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identi];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identi];
        }
        
        
        for (UIView*view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.text = _priceArray[indexPath.row];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, self.frame.size.width, 0.5)];
        line.backgroundColor = RGBCOLOR(234, 235, 236);
        [cell.contentView addSubview:line];
        
        if (_isMark_price[indexPath.row]) {
            UIImageView *mark_imv = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 30, 15, 15, 15)];
            [mark_imv setImage:[UIImage imageNamed:@"duihao.png"]];
            [cell.contentView addSubview:mark_imv];
        }
        
        
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (tableView.tag == 4){//体检品牌
        static NSString *identi = @"ident3";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identi];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identi];
        }
        
        
        for (UIView*view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        NSDictionary *dic = self.delegate.brand_city_list[indexPath.row];
        cell.textLabel.text = [dic stringValueForKey:@"brand_name"];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, self.frame.size.width, 0.5)];
        line.backgroundColor = RGBCOLOR(234, 235, 236);
        [cell.contentView addSubview:line];
        
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    
    
    return [[UITableViewCell alloc]init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (tableView.tag == 1) {//主筛选页面
        if (self.gender) {
            if (indexPath.row == 1) {//城市
                [self addSubview:self.tab2];
                [self setNavcLeftBtnTag:-2 image:[UIImage imageNamed:@"back.png"] leftTitle:nil midTitle:@"城市" rightBtnTag:-12];
            }else if (indexPath.row == 2){//价格
                [self addSubview:self.tab3];
                [self setNavcLeftBtnTag:-3 image:[UIImage imageNamed:@"back.png"] leftTitle:nil midTitle:@"价格" rightBtnTag:-13];
            }else if (indexPath.row == 3){//体检品牌
                [self addSubview:self.tab4];
                [self setNavcLeftBtnTag:-4 image:[UIImage imageNamed:@"back.png"] leftTitle:nil midTitle:@"体检品牌" rightBtnTag:-14];
            }
        }else{
            if (indexPath.row == 0) {//城市
                [self addSubview:self.tab2];
                [self setNavcLeftBtnTag:-2 image:[UIImage imageNamed:@"back.png"] leftTitle:nil midTitle:@"城市" rightBtnTag:-12];
            }else if (indexPath.row == 1){//价格
                [self addSubview:self.tab3];
                [self setNavcLeftBtnTag:-3 image:[UIImage imageNamed:@"back.png"] leftTitle:nil midTitle:@"价格" rightBtnTag:-13];
            }else if (indexPath.row == 2){//体检品牌
                [self addSubview:self.tab4];
                [self setNavcLeftBtnTag:-4 image:[UIImage imageNamed:@"back.png"] leftTitle:nil midTitle:@"体检品牌" rightBtnTag:-14];
            }
        }
    }else if (tableView.tag == 2){//选择地区
        
        
        NSArray * cities = _areaData[indexPath.section][@"Cities"];
        NSString *cityStr = cities[indexPath.row][@"city"];
        self.userChooseCity = cityStr;
        [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
        [self.tab2 removeFromSuperview];
        [self.tab1 reloadData];
        
    }else if (tableView.tag == 3){//价格
        for (int i = 0; i<10; i++) {
            _isMark_price[i] = 0;
        }
        
        _isMark_price[indexPath.row] = 1;
        
        [self.tf_high resignFirstResponder];
        [self.tf_low resignFirstResponder];
        
        self.userChoosePrice = _priceArray[indexPath.row];
        
        NSArray *paa = [self.userChoosePrice componentsSeparatedByString:@"—"];
        self.userChoosePrice_low = paa[0];
        self.userChoosePrice_high = paa[1];
        
        
        
        [self.tab3 reloadData];
        
        [self setDefaultPriceImvHidden];
        
        
        
    }else if (tableView.tag == 4){//体检品牌
        NSDictionary *dic = self.delegate.brand_city_list[indexPath.row];
        self.userChoosePinpai = [dic stringValueForKey:@"brand_name"];
        self.userChoosePinpai_id = [dic stringValueForKey:@"brand_id"];
        [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
        [self.tab4 removeFromSuperview];
        [self.tab1 reloadData];
    }
    
}




#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (DEVICE_HEIGHT>480) {
        [self.tab3 setContentSize:CGSizeMake(self.frame.size.width, self.frame.size.height)];
        [self.tab3 setContentOffset:CGPointMake(0, 50) animated:YES];
    }else{
        [self.tab3 setContentSize:CGSizeMake(self.frame.size.width, self.frame.size.height+200)];
        [self.tab3 setContentOffset:CGPointMake(0, 240) animated:YES];
    }
    
    
    
    
    return YES;
}





@end
