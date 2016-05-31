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
#import "GBrandListViewController.h"

@implementation GPushView
{
    NSArray *_tab1TitleDataArray;
    NSMutableArray *_genderBtnArray;
    
    NSArray *_areaData;//地区数据
    
    int _isopen[35];
    
    NSArray *_priceArray;//价格区间
    
    UIView *_tab3Header;//价格选择的tabHeader
    
    UIImageView *_defaultPriceImv;
    
    UILabel *_locationCityLabel;//定位城市label
    
    CGSize _orig_tab_contentOffset;//原来的可偏移
    CGPoint _now_tab_contentOffset;//现在的偏移量
    UIView *_shouView;//用于收键盘的点击view
    
    
    //定位相关
    NSDictionary *_locationDic;
    
    
    //网络请求失败 无品牌数据时的提示view
    ResultView *_resultView;
    
    NSDictionary *_defaultShaixuanDic;
    
    
    NSArray *_GenderTitleArray;
    
    
}


-(id)initWithFrame:(CGRect)frame gender:(BOOL)theGender isHaveShaixuanDic:(NSDictionary *)theDic{
    self = [super initWithFrame:frame];
    
    self.isRightBtnClicked = NO;
    
    self.selectDic = [NSMutableDictionary dictionaryWithDictionary:theDic];
    
    self.tempDic = theDic;
    
    //数据部分
    self.isGender = theGender;
    _GenderTitleArray = @[@"全部",@"男",@"女"];
    
    _tab1TitleDataArray = @[@"城市",@"价格",@"体检品牌"];
    
    for (int i = 0; i<35; i++) {
        _isopen[i] = 0;
    }
    
    _orig_tab_contentOffset = CGSizeMake(0, 0);
    
    
    //地区数据
    NSString *path = [[NSBundle mainBundle]pathForResource:@"garea" ofType:@"plist"];
    _areaData = [NSArray arrayWithContentsOfFile:path];
    
    
    //价格筛选
    _priceArray = @[@"0 - 300",@"300 - 500",@"500 - 800",@"800 - 1000",@"1000 - 1500",@"1500 - 2000",@"2000以上"];
    
    
    //创建视图
    [self creatNavcView];
    [self creatTab];
    [self.tab4 reloadData];
    [self.tab1 reloadData];
    [self creatTab3Header];
    [self.tab3 reloadData];

    return self;
}


#pragma mark - 数据源取值添加值操作
//get
-(NSString *)getValueForKey:(NSString *)key
{
    NSString *result = @"全部";
    if ([key isEqualToString:Dic_gender]) {//性别
        NSString *gender = self.selectDic[key];
        if ([gender intValue] == Gender_Boy) {
            result = @"男";
        }else if ([gender intValue] == Gender_Girl)
        {
            result = @"女";
        }
    }else if ([key isEqualToString:Dic_city_name]){//城市
        NSString *cityId = [self.selectDic stringValueForKey:Dic_city_id];
        if ([LTools isEmpty:cityId]) {
            result = [GMAPI getCityNameOf4CityWithCityId:[[GMAPI getCurrentCityId] intValue]];
            if ([LTools isEmpty:result]) {
                result = @"北京市";
            }
        }else{
            result = [GMAPI getCityNameOf4CityWithCityId:[cityId intValue]];
        }
        
    }else if ([key isEqualToString:Dic_price]){//价格
        NSString *high_price = [self.selectDic stringValueForKey:Dic_high_price];
        NSString *low_price = [self.selectDic stringValueForKey:Dic_low_price];
        
        if ([low_price intValue]>=0 && [high_price intValue]>0) {//全有
            result = [NSString stringWithFormat:@"%@ - %@",low_price,high_price];
        }else if ([low_price intValue]>0){//有low
            result = [NSString stringWithFormat:@"%@以上",low_price];
        }else if ([high_price intValue]>0){//有high
            result = [NSString stringWithFormat:@"%@以下",high_price];
        }
    }else if ([key isEqualToString:Dic_brand_name]){//品牌
        NSString *brandName = [self.selectDic stringValueForKey:Dic_brand_name];
        if (![LTools isEmpty:brandName]) {
            result = brandName;
        }
    }
    
    return result;
}
//set
-(void)setSelectDicValue:(NSString *)value theKey:(NSString *)key{
    
    if ([key isEqualToString:Dic_gender]) {//性别
        if ([value isEqualToString:@"0"]) {
            value = @"99";
        }
        [self.selectDic safeSetString:value forKey:key];
    }else if ([key isEqualToString:Dic_city_name]){//城市
        NSString *city_name = value;
        NSString *city_id = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:city_name]];
        NSString *province_id = [GMAPI getProvineIdWithCityId:[city_id intValue]];
        [self.selectDic safeSetString:city_id forKey:Dic_city_id];
        [self.selectDic safeSetString:province_id forKey:Dic_province_id];
        
    }else if ([key isEqualToString:Dic_price]){//价钱
        NSString *price = value;
        NSString *low_price;
        NSString *high_price;
        
        if ([price isEqualToString:@"全部"]) {
            [self.selectDic removeObjectForKey:Dic_low_price];
            [self.selectDic removeObjectForKey:Dic_high_price];
        }else if ([price hasSuffix:@"以上"]){
            NSMutableString *p_m = [NSMutableString stringWithFormat:@"%@",price];
            [p_m replaceOccurrencesOfString:@"以上" withString:@"" options:0 range:NSMakeRange(0, p_m.length)];
            low_price = (NSString*)p_m;
            [self.selectDic removeObjectForKey:Dic_high_price];
            [self.selectDic safeSetString:low_price forKey:Dic_low_price];
        }else if ([price hasSuffix:@"以下"]){
            NSMutableString *p_m = [NSMutableString stringWithFormat:@"%@",price];
            [p_m replaceOccurrencesOfString:@"以下" withString:@"" options:0 range:NSMakeRange(0, p_m.length)];
            low_price = (NSString*)p_m;
            [self.selectDic removeObjectForKey:Dic_low_price];
            [self.selectDic safeSetString:high_price forKey:Dic_high_price];
        }else{
            NSArray *paa = [price componentsSeparatedByString:@" - "];
            low_price = paa[0];
            high_price = paa[1];
            [self.selectDic safeSetString:low_price forKey:Dic_low_price];
            [self.selectDic safeSetString:high_price forKey:Dic_high_price];
        }
        
        
    }else if ([key isEqualToString:Dic_brand_name]){//品牌名
        NSString *brand_Name = value;
        if ([brand_Name isEqualToString:@"全部"]) {
            [self.selectDic removeObjectForKey:Dic_brand_id];
        }
        [self.selectDic safeSetString:brand_Name forKey:Dic_brand_name];
        
    }else if ([key isEqualToString:Dic_brand_id]){//品牌id
        NSString *brand_id = value;
        [self.selectDic safeSetString:brand_id forKey:Dic_brand_id];
    }
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
    self.navc_midelLabel.font = [UIFont systemFontOfSize:15];
    [self.navigationView.theMidelView addSubview:self.navc_midelLabel];
    
    //左
    self.navc_leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navc_leftBtn setFrame:CGRectMake(0, 15, 60, self.navigationView.theLeftView.frame.size.height-20)];
    [self.navc_leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.navc_leftBtn setTitleColor:RGBCOLOR(107, 108, 109) forState:UIControlStateNormal];
    self.navc_leftBtn.tag = -1;
    [self.navc_leftBtn addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navc_leftBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.navigationView.theLeftView addSubview:self.navc_leftBtn];
    
    //右
    self.navc_rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navc_rightBtn setFrame:CGRectMake(self.navigationView.theRightView.frame.size.width - 65, 15, 60, self.navigationView.theRightView.frame.size.height-20)];
    [self.navc_rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.navc_rightBtn setTitleColor:RGBCOLOR(107, 108, 109) forState:UIControlStateNormal];
    [self.navc_rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navc_rightBtn.tag = -11;
    self.navc_rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.navigationView.theRightView addSubview:self.navc_rightBtn];
    
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, self.navigationView.frame.size.height - 5, self.navigationView.frame.size.width, 5)];
    line.backgroundColor = RGBCOLOR(244, 245, 246);
    [self.navigationView addSubview:line];
}



//创建tab
-(void)creatTab{
    
    
    NSString *defaultCityName;
    NSString *defaultCityId = [GMAPI getCurrentCityId];
    if ([defaultCityId intValue] == 0) {
        NSString *defaultPid = [GMAPI getCurrentProvinceId];
        defaultCityName = [GMAPI cityNameForId:[defaultPid intValue]];
    }else{
        defaultCityName = [GMAPI getCityNameOf4CityWithCityId:[defaultCityId intValue]];
    }
    
    
    //主筛选
    self.tab1 = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.frame.size.width, self.frame.size.height-64) style:UITableViewStylePlain];
    self.tab1.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tab1.delegate = self;
    self.tab1.dataSource = self;
    self.tab1.tag = 1;
    
    //城市选择
    self.tab2 = [[UITableView alloc]initWithFrame:CGRectMake(self.frame.size.width, 64, self.frame.size.width, self.frame.size.height-64) style:UITableViewStyleGrouped];
    self.tab2.delegate = self;
    self.tab2.dataSource = self;
    self.tab2.tag = 2;
    self.tab2.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self creatTab2Header];
    
    [self getjingweidu];
    
    
    //价格
    self.tab3 = [[UITableView alloc]initWithFrame:CGRectMake(self.frame.size.width, 64, self.frame.size.width, self.frame.size.height-64) style:UITableViewStyleGrouped];
    self.tab3.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tab3.delegate = self;
    self.tab3.dataSource = self;
    self.tab3.tag = 3;
    [self creatTab3Header];
    
    //体检品牌
    self.tab4 = [[UITableView alloc]initWithFrame:CGRectMake(self.frame.size.width, 64, self.frame.size.width, self.frame.size.height-64) style:UITableViewStylePlain];
    self.tab4.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tab4.delegate = self;
    self.tab4.dataSource = self;
    self.tab4.tag = 4;
    
    [self addSubview:self.tab1];
    [self addSubview:self.tab2];
    [self addSubview:self.tab3];
    [self addSubview:self.tab4];
}

//创建城市选择的tableHeader 展示默认定位城市
-(void)creatTab2Header{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 44)];
    view.backgroundColor = [UIColor whiteColor];
    [view addTaget:self action:@selector(tab2HeaderClicked) tag:0];
    self.tab2.tableHeaderView = view;
    
    //定位城市label
    _locationCityLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, self.frame.size.width-150, 44)];
    _locationCityLabel.textColor = RGBCOLOR(236, 108, 20);
    _locationCityLabel.text = @"正在定位...";
    _locationCityLabel.font = [UIFont systemFontOfSize:13];
    [view addSubview:_locationCityLabel];
    
    //提示信息label
    UILabel *tishiLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 70, 0, 65, 44)];
    tishiLabel.textAlignment = NSTextAlignmentRight;
    tishiLabel.font = [UIFont systemFontOfSize:10];
    tishiLabel.textColor = RGBCOLOR(134, 135, 136);
    tishiLabel.text = @"当前所在位置";
    
    
    
    UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, self.frame.size.width, 0.5)];
    downLine.backgroundColor = RGBCOLOR(222, 223, 224);
    [view addSubview:downLine];
    
    
    
    [view addSubview:tishiLabel];
}


-(void)tab2HeaderClicked{
    
    if ([_locationCityLabel.text isEqualToString:@"正在定位..."] || [_locationCityLabel.text isEqualToString:@"定位失败"]) {
        return;
    }
    
    [self.tab2 reloadData];
    [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
    [self hiddenTab:self.tab2];
    [self.tab1 reloadData];
    
    
}




-(void)reloadTab2Header{
    for (UIView *view in self.tab2.tableHeaderView.subviews) {
        [view removeFromSuperview];
    }
    
    [self creatTab2Header];
    
    
}

//创建价格选择的tabelHeader 显示默认全部
-(void)creatTab3Header{
    
    if (!_tab3Header) {
         _tab3Header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
        
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, 50, 44)];
        tLabel.font = [UIFont systemFontOfSize:14];
        tLabel.text = @"全部";
        tLabel.textColor = RGBCOLOR(237, 108, 22);
        [_tab3Header addSubview:tLabel];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, self.frame.size.width, 0.5)];
        line.backgroundColor = RGBCOLOR(234, 235, 236);
        [_tab3Header addSubview:line];
    }
   
    _tab3Header.backgroundColor = [UIColor whiteColor];
    
    [_tab3Header addTaget:self action:@selector(tab3HeaderClicked) tag:0];
    
    self.tab3.tableHeaderView = _tab3Header;
    
    
    
    
    if (!_defaultPriceImv) {
         _defaultPriceImv = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 30, 15, 15, 15)];
        [_tab3Header addSubview:_defaultPriceImv];
    }
    [_defaultPriceImv setImage:[UIImage imageNamed:@"duihao.png"]];
    
    [self setDefaultPriceImvShow];
    
}



#pragma mark - 逻辑处理

//价格
-(void)tab3HeaderClicked{

    [self setSelectDicValue:@"全部" theKey:Dic_price];
    
    self.tf_high.text = nil;
    self.tf_low.text = nil;
    [self setDefaultPriceImvShow];
    [self.tab3 reloadData];
    [self hiddenTab:self.tab3];
    [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
    [self.tab1 reloadData];
}


/**
 *  设置默认价格后面的对勾隐藏
 */
-(void)setDefaultPriceImvHidden{

    _defaultPriceImv.hidden = YES;
}

/**
 *  设置默认价格后面的对勾显示
 */
-(void)setDefaultPriceImvShow{
    _defaultPriceImv.hidden = NO;
}



-(void)leftBtnClicked{
    
    self.selectDic = nil;
    self.selectDic = [NSMutableDictionary dictionaryWithDictionary:self.tempDic];//把备份的数据还原
    self.tf_high.text = nil;
    self.tf_low.text = nil;
    
    [self.tab1 reloadData];
    [self.tab2 reloadData];
    [self.tab3 reloadData];
    [self.tab4 reloadData];
    
}


/**
 *  navigationView leftBtn 点击
 *
 *  @param sender 自定义navcView左上角按钮
 */
-(void)leftBtnClicked:(UIButton*)sender{
    
    
    if (sender.tag == -1) {//主筛选界面侧边栏消失
        [self.delegate therightSideBarDismiss];
        
        self.selectDic = nil;
        self.selectDic = [NSMutableDictionary dictionaryWithDictionary:self.tempDic];//把备份的数据还原
        self.delegate.shaixuanDic = (NSDictionary*)self.selectDic;
        self.tf_high.text = nil;
        self.tf_low.text = nil;
        
        [self.tab1 reloadData];
        [self.tab2 reloadData];
        [self.tab3 reloadData];
        [self.tab4 reloadData];
        
    }else if (sender.tag == -2){//选择地区 返回到主筛选界面
        [self hiddenTab:self.tab2];
        [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
    }else if (sender.tag == -3){//选择价格 返回到主筛选界面
        [self hiddenTab:self.tab3];
        [self.tf_low resignFirstResponder];
        [self.tf_high resignFirstResponder];
        [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
    }else if (sender.tag == -4){//选择品牌 返回到主筛选界面
        [self hiddenTab:self.tab4];
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
        self.isRightBtnClicked = YES;
        self.tempDic = nil;
        self.tempDic = [NSDictionary dictionaryWithDictionary:(NSDictionary*)self.selectDic];
        
        [self.delegate shaixuanFinishWithDic:self.selectDic];
        
        [self.delegate therightSideBarDismiss];
        
        
        
    }else if (sender.tag == -12){//选择地区 返回到主筛选界面
    }else if (sender.tag == -13){//选择价格 返回到主筛选界面
    }else if (sender.tag == -14){//选择品牌 返回到主筛选界面
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
    
    NSLog(@"%@",sender.titleLabel.text);
    
    //存储到selectDic
    NSString *genderStr = sender.titleLabel.text;
    int flag = (int)[_GenderTitleArray indexOfObject:genderStr];
    [self setSelectDicValue:[NSString stringWithFormat:@"%d",flag] theKey:Dic_gender];
    
}


//选择价格tab 填写价格之后点击确认按钮
-(void)priceQuerenBtnClicked{
    
    NSString *str_low = self.tf_low.text;
    NSString *str_high = self.tf_high.text;
    
    
    if (![LTools isEmpty:str_low] && ![LTools isEmpty:str_high]) {//最高价 最低价都有
        if ([str_high floatValue]<[str_low floatValue]) {
            [GMAPI showAutoHiddenMBProgressWithText:@"请输入正确的价格区间" addToView:self];
        }else{
            
            [self.tf_high resignFirstResponder];
            [self.tf_low resignFirstResponder];
            
            [self setDefaultPriceImvHidden];
            
            NSString *price = [NSString stringWithFormat:@"%@ - %@",self.tf_low.text,self.tf_high.text];
            
            [self setSelectDicValue:price theKey:Dic_price];
            
            [self.tab3 reloadData];
            [self hiddenTab:self.tab3];
            [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
            
            [self.tab1 reloadData];
        }
    }else if (![LTools isEmpty:str_low]){//有最低价

        
        [self.tf_high resignFirstResponder];
        [self.tf_low resignFirstResponder];
        
        [self setDefaultPriceImvHidden];
        
        NSString *price = [NSString stringWithFormat:@"%@以上",self.tf_low.text];
        [self setSelectDicValue:price theKey:Dic_price];
        
        [self.tab3 reloadData];
        [self hiddenTab:self.tab3];
        [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
        
        [self.tab1 reloadData];
        
        
        
    }else if (![LTools isEmpty:str_high]){//有最高价

        
        [self.tf_high resignFirstResponder];
        [self.tf_low resignFirstResponder];
        
        _defaultPriceImv.hidden = YES;
        
        NSString *price = [NSString stringWithFormat:@"%@以下",self.tf_high.text];
        [self setSelectDicValue:price theKey:Dic_price];
        
        [self.tab3 reloadData];
        [self hiddenTab:self.tab3];
        [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
        
        [self.tab1 reloadData];
    }
   
}



//把需要的tabview从右边划过来

-(void)showTab:(UITableView *)theTab{
    [UIView animateWithDuration:0.2 animations:^{
        [theTab setFrame:CGRectMake(0, 64, self.frame.size.width, self.frame.size.height-64)];
    }];
    
}

-(void)hiddenTab:(UITableView *)theTab{
    
    self.navc_rightBtn.hidden = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        [theTab setFrame:CGRectMake(self.frame.size.width, 64, self.frame.size.width, self.frame.size.height-64)];
    }];
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
        if (self.isGender) {
            num = 4;
        }else{
            num = 3;
        }
        
        
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
        
        if (self.delegate.brand_city_list.count == 0) {//没有获取到品牌信息
            num = 0;
            if (!self.noBrandView) {
                [self creatNoBrandView];
            }
        }else{
            num = self.delegate.brand_city_list.count+1;
        }
    }
    return num;
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    if (tableView.tag == 2) {
        
        [view setFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 100, 44)];
        titleLabel.font = [UIFont systemFontOfSize:13];
        NSString *provinceStr = _areaData[section][@"State"];
        titleLabel.text = provinceStr;
        [view addSubview:titleLabel];
        view.backgroundColor = [UIColor whiteColor];
        view.tag = section +10;
        [view addTaget:self action:@selector(viewForHeaderInSectionClicked:) tag:(int)view.tag];
        
        if ([provinceStr isEqualToString:@"北京市"] || [provinceStr isEqualToString:@"上海市"] || [provinceStr isEqualToString:@"天津市"] || [provinceStr isEqualToString:@"重庆市"]){
            
            NSString *cityName = [self getValueForKey:Dic_city_name];
            if ([cityName isEqualToString:provinceStr]) {
                UIImageView *mark_imv = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 30, 15, 15, 15)];
                [mark_imv setImage:[UIImage imageNamed:@"duihao.png"]];
                [view addSubview:mark_imv];
            }
 
        }else{
            UIButton *jiantouBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [jiantouBtn setFrame:CGRectMake(self.frame.size.width-44, 0, 44, 44)];
            jiantouBtn.userInteractionEnabled = NO;
            [view addSubview:jiantouBtn];
            
            if ( !_isopen[view.tag-10]) {
                [jiantouBtn setImage:[UIImage imageNamed:@"jiantou_down.png"] forState:UIControlStateNormal];
            }else{
                [jiantouBtn setImage:[UIImage imageNamed:@"jiantou_up.png"] forState:UIControlStateNormal];
                
            }
        }
        
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(20, 43.5, self.frame.size.width-30, 0.5)];
        line.backgroundColor = RGBCOLOR(244, 245, 246);
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
        if (!self.tf_low) {
            self.tf_low = [[UITextField alloc]init];
            [self.tf_low setFrame:tf_low_backView.bounds];
            
        }else{
            [self.tf_low setFrame:tf_low_backView.bounds];
        }
        
        self.tf_low.textAlignment = NSTextAlignmentCenter;
        self.tf_low.font = [UIFont systemFontOfSize:13];
        self.tf_low.delegate = self;
        self.tf_low.keyboardType = UIKeyboardTypeNumberPad;
        [tf_low_backView addSubview:self.tf_low];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(tf_low_backView.frame)+5, 24, 10, 1)];
        line.backgroundColor = RGBCOLOR(37, 38, 38);
        [view addSubview:line];
        
        UIView *tf_high_backView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(tf_low_backView.frame)+20, tf_low_backView.frame.origin.y, tf_low_backView.frame.size.width, tf_low_backView.frame.size.height)];
        tf_high_backView.layer.borderWidth = 0.5;
        tf_high_backView.layer.cornerRadius = 4;
        tf_high_backView.layer.borderColor = [RGBCOLOR(37, 38, 38)CGColor];
        [view addSubview:tf_high_backView];
        
        //最高价
        if (!self.tf_high) {
            self.tf_high = [[UITextField alloc]init];
            [self.tf_high setFrame:tf_low_backView.bounds];
        }else{
            [self.tf_high setFrame:tf_low_backView.bounds];
        }
        
        self.tf_high.textAlignment = NSTextAlignmentCenter;
        self.tf_high.font = [UIFont systemFontOfSize:13];
        self.tf_high.delegate = self;
        self.tf_high.keyboardType = UIKeyboardTypeNumberPad;
        [tf_high_backView addSubview:self.tf_high];
        
        
        
        //确定按钮
        UIButton *quedingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [quedingBtn setFrame:CGRectMake(CGRectGetMaxX(tf_high_backView.frame)+15, tf_high_backView.frame.origin.y, 60, tf_high_backView.frame.size.height)];
        [quedingBtn setTitle:@"确定" forState:UIControlStateNormal];
        quedingBtn.backgroundColor = RGBCOLOR(125, 163, 208);
        quedingBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        quedingBtn.titleLabel.textColor = [UIColor whiteColor];
        quedingBtn.layer.cornerRadius = 4;
        [quedingBtn addTarget:self action:@selector(priceQuerenBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:quedingBtn];
        
        
    }if (tableView.tag == 1) {//主筛选
        [view setFrame:CGRectMake(0, 0, self.frame.size.width, 60)];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"清除筛选" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [RGBCOLOR(37, 38, 38) CGColor];
        btn.layer.cornerRadius = 4;
        btn.layer.masksToBounds = YES;
        [btn setFrame:CGRectMake(self.frame.size.width*0.5-50, 15, 100, 30)];
        [btn setTitleColor:RGBCOLOR(37, 38, 38) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(qingkongshaixuanBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
    }
    
    return view;
}

-(void)qingkongshaixuanBtnClicked{

    self.selectDic = nil;
    self.selectDic = [NSMutableDictionary dictionaryWithCapacity:1];
    self.tf_low.text = nil;
    self.tf_high.text = nil;
    
    [self.tab1 reloadData];
    [self.tab2 reloadData];
    [self.tab3 reloadData];
    [self.tab4 reloadData];
}


-(void)viewForHeaderInSectionClicked:(UIView*)sender{
    
    NSInteger tt = sender.tag - 10;
    
    int aa = _isopen[sender.tag-10];
    
    if (tt == 0 || tt == 1 || tt == 2 || tt == 3) {//4个直辖市
        NSDictionary *dic = _areaData[tt];
        NSString *city_Name = [dic stringValueForKey:@"State"];
        
        [self setSelectDicValue:city_Name theKey:Dic_city_name];
        
        [self.tab2 reloadData];
        [self hiddenTab:self.tab2];
        [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
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
    }else if (tableView.tag == 1){//主筛选
        height = 60;
    }
    
    return height;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    if (tableView.tag == 1) {//主筛选
        if (indexPath.row == 0 && self.isGender){
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
        
        if (self.isGender){//有性别
            if (indexPath.row == 0) {
                UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 60, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/125])];
                titleLabel.text = @"性别";
                titleLabel.font = [UIFont systemFontOfSize:13];
                [cell.contentView addSubview:titleLabel];
                
                UIView *cView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+5, 0, self.frame.size.width - titleLabel.frame.size.width - 15 - 5 - 20, titleLabel.frame.size.height)];
                [cell.contentView addSubview:cView];
                
                CGFloat jianju = 5;
                CGFloat btnW = (cView.frame.size.width - 5*2)/3;
                CGFloat btnH = [GMAPI scaleWithHeight:0 width:btnW theWHscale:166.0/60];
                
                _genderBtnArray = [NSMutableArray arrayWithCapacity:3];
                
                for (int i = 0; i<3; i++) {
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [btn setFrame:CGRectMake(i*(btnW+jianju), (cView.frame.size.height - btnH)*0.5, btnW, btnH)];
                    btn.layer.cornerRadius = 3;
                    btn.titleLabel.font = [UIFont systemFontOfSize:13];
                    [btn setTitle:_GenderTitleArray[i] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(genderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                    if (i == 0) {
                        btn.layer.borderWidth = 0.5;
                        [btn setTitleColor:RGBCOLOR(237, 108, 22) forState:UIControlStateNormal];
                        btn.layer.borderColor = [RGBCOLOR(237, 108, 22)CGColor];
                    }else{
                        btn.layer.borderWidth = 0.5;

                        if (i == 1) {
                            [btn setImage:[UIImage imageNamed:@"nan_saixuan.png"] forState:UIControlStateNormal];
                        }else{
                            [btn setImage:[UIImage imageNamed:@"nv_saixuan.png"] forState:UIControlStateNormal];
                        }
                        [btn setTitleColor:RGBCOLOR(77, 78, 79) forState:UIControlStateNormal];
                        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
                        btn.layer.borderColor = [RGBCOLOR(37, 38, 38)CGColor];
                    }
                    [cView addSubview:btn];
                    
                    [_genderBtnArray addObject:btn];
                }
                
                int flag = 0;
                NSString *sex = [self getValueForKey:Dic_gender];
                flag = (int)[_GenderTitleArray indexOfObject:sex];

                UIButton *btn = _genderBtnArray[flag];
                [self genderBtnClicked:btn];
                
                
                UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/125] - 5, self.frame.size.width, 5)];
                line.backgroundColor = RGBCOLOR(244, 245, 246);
                [cell.contentView addSubview:line];
            }else{
                UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 60, [GMAPI scaleWithHeight:0 width:self.frame.size.width theWHscale:670.0/90])];
                titleLabel.text = _tab1TitleDataArray[indexPath.row-1];
                titleLabel.font = [UIFont systemFontOfSize:13];
                [cell.contentView addSubview:titleLabel];
                
                
                UILabel *cLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+5, 0, self.frame.size.width - titleLabel.frame.size.width - 15 - 5 - 30, titleLabel.frame.size.height)];
                cLabel.textAlignment = NSTextAlignmentRight;
                cLabel.font = [UIFont systemFontOfSize:13];

                if (indexPath.row == 1) {//城市
                    NSString *result = [self getValueForKey:Dic_city_name];
                    cLabel.text = result;
                    
                }else if (indexPath.row == 2){//价钱

                    cLabel.text = [self getValueForKey:Dic_price];
                    
                }else if (indexPath.row == 3){//品牌
                    
                    cLabel.text = [self getValueForKey:Dic_brand_name];
                    
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
            titleLabel.text = _tab1TitleDataArray[indexPath.row];
            titleLabel.font = [UIFont systemFontOfSize:13];
            [cell.contentView addSubview:titleLabel];
            
            
            UILabel *cLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+5, 0, self.frame.size.width - titleLabel.frame.size.width - 15 - 5 - 30, titleLabel.frame.size.height)];
            cLabel.font = [UIFont systemFontOfSize:13];
            cLabel.textAlignment = NSTextAlignmentRight;
            
        
            if (indexPath.row == 0) {//城市
                cLabel.text = [self getValueForKey:Dic_city_name];
                
            }else if (indexPath.row == 1){//价钱
                cLabel.text = [self getValueForKey:Dic_price];
                
            }else if (indexPath.row == 2){//品牌
                cLabel.text = [self getValueForKey:Dic_brand_name];
            }

            
            [cell.contentView addSubview:cLabel];
            
            UIImageView *jiantouImv = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 20, cLabel.frame.size.height*0.5-8, 8, 16)];
            [jiantouImv setImage:[UIImage imageNamed:@"personal_jiantou_r.png"]];
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
        
        cell.backgroundColor= [UIColor whiteColor];
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, DEVICE_WIDTH-20, 44)];
        tLabel.font = [UIFont systemFontOfSize:12];
        NSArray * cities = _areaData[indexPath.section][@"Cities"];
        tLabel.text = cities[indexPath.row][@"city"];
        [cell.contentView addSubview:tLabel];
        
        
        NSString *cityName = [self getValueForKey:Dic_city_name];
        if ([tLabel.text isEqualToString:cityName]) {
            UIImageView *mark_imv = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 30, 15, 15, 15)];
            [mark_imv setImage:[UIImage imageNamed:@"duihao.png"]];
            [cell.contentView addSubview:mark_imv];
        }
        
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(30, 43.5, DEVICE_WIDTH-30, 0.5)];
        line.backgroundColor = RGBCOLOR(244, 245, 246);
        [cell.contentView addSubview:line];
        
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
        
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.textLabel.text = _priceArray[indexPath.row];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, self.frame.size.width, 0.5)];
        line.backgroundColor = RGBCOLOR(234, 235, 236);
        [cell.contentView addSubview:line];
        
        NSString *price = [self getValueForKey:Dic_price];
        if ([price isEqualToString:@"全部"]) {
            [self setDefaultPriceImvShow];
        }else{
            
            if (![LTools isEmpty:[self.selectDic stringValueForKey:Dic_low_price]] && ![LTools isEmpty:[self.selectDic stringValueForKey:Dic_high_price]]) {//是选择的价钱 和 低价高价都填写
                if ([cell.textLabel.text isEqualToString:price]) {//是选择的价钱
                    UIImageView *mark_imv = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 30, 15, 15, 15)];
                    [mark_imv setImage:[UIImage imageNamed:@"duihao.png"]];
                    [cell.contentView addSubview:mark_imv];
                    [self setDefaultPriceImvHidden];
                }else{
                    [self setDefaultPriceImvHidden];
                    if (![LTools isEmpty:[self.selectDic stringValueForKey:Dic_low_price]]) {
                        if (!self.tf_low) {
                            self.tf_low = [[UITextField alloc]init];
                        }
                        self.tf_low.text = [self.selectDic stringValueForKey:Dic_low_price];
                    }
                    if (![LTools isEmpty:[self.selectDic stringValueForKey:Dic_high_price]]) {
                        if (!self.tf_high) {
                            self.tf_high = [[UITextField alloc]init];
                        }
                        self.tf_high.text = [self.selectDic stringValueForKey:Dic_high_price];
                    }
                }
            }else if (![LTools isEmpty:[self.selectDic stringValueForKey:Dic_low_price]] && [self.selectDic stringValueForKey:Dic_high_price] && [[self.selectDic stringValueForKey:Dic_low_price] isEqualToString:@"2000"]){//选择的 2000以上
                if ([cell.textLabel.text isEqualToString:price]) {
                    UIImageView *mark_imv = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 30, 15, 15, 15)];
                    [mark_imv setImage:[UIImage imageNamed:@"duihao.png"]];
                    [cell.contentView addSubview:mark_imv];
                    [self setDefaultPriceImvHidden];
                    if (![LTools isEmpty:[self.selectDic stringValueForKey:Dic_low_price]]) {
                        if (!self.tf_low) {
                            self.tf_low = [[UITextField alloc]init];
                        }
                        self.tf_low.text = [self.selectDic stringValueForKey:Dic_low_price];
                    }
                }
            }else{//自己填写的
                
                [self setDefaultPriceImvHidden];
                if (![LTools isEmpty:[self.selectDic stringValueForKey:Dic_low_price]]) {
                    if (!self.tf_low) {
                        self.tf_low = [[UITextField alloc]init];
                    }
                    self.tf_low.text = [self.selectDic stringValueForKey:Dic_low_price];
                    
                }
                if (![LTools isEmpty:[self.selectDic stringValueForKey:Dic_high_price]]) {
                    if (!self.tf_high) {
                        self.tf_high = [[UITextField alloc]init];
                    }
                    self.tf_high.text = [self.selectDic stringValueForKey:Dic_high_price];
                }
                
            }
            
            
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
        
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"全部";
        }else{
            NSDictionary *dic = self.delegate.brand_city_list[indexPath.row - 1];
            cell.textLabel.text = [dic stringValueForKey:@"brand_name"];
        }
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, self.frame.size.width, 0.5)];
        line.backgroundColor = RGBCOLOR(234, 235, 236);
        [cell.contentView addSubview:line];
        
        NSString *brandName = [self getValueForKey:Dic_brand_name];
        if ([cell.textLabel.text isEqualToString:brandName]) {
            UIImageView *mark_imv = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 30, 15, 15, 15)];
            [mark_imv setImage:[UIImage imageNamed:@"duihao.png"]];
            [cell.contentView addSubview:mark_imv];
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    }
    
    return [[UITableViewCell alloc]init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (tableView.tag == 1) {//主筛选页面
        
        self.navc_rightBtn.hidden = YES;
        
        if (self.isGender) {
            if (indexPath.row == 1) {//城市
                [self showTab:self.tab2];
                [self setNavcLeftBtnTag:-2 image:[UIImage imageNamed:@"back.png"] leftTitle:nil midTitle:@"城市" rightBtnTag:-12];
            }else if (indexPath.row == 2){//价格
                [self showTab:self.tab3];
                [self setNavcLeftBtnTag:-3 image:[UIImage imageNamed:@"back.png"] leftTitle:nil midTitle:@"价格" rightBtnTag:-13];
            }else if (indexPath.row == 3){//体检品牌
                [self showTab:self.tab4];
                [self setNavcLeftBtnTag:-4 image:[UIImage imageNamed:@"back.png"] leftTitle:nil midTitle:@"体检品牌" rightBtnTag:-14];
            }
        }else{
            if (indexPath.row == 0) {//城市
                [self showTab:self.tab2];
                [self setNavcLeftBtnTag:-2 image:[UIImage imageNamed:@"back.png"] leftTitle:nil midTitle:@"城市" rightBtnTag:-12];
            }else if (indexPath.row == 1){//价格
                [self showTab:self.tab3];
                [self setNavcLeftBtnTag:-3 image:[UIImage imageNamed:@"back.png"] leftTitle:nil midTitle:@"价格" rightBtnTag:-13];
            }else if (indexPath.row == 2){//体检品牌
                [self showTab:self.tab4];
                [self setNavcLeftBtnTag:-4 image:[UIImage imageNamed:@"back.png"] leftTitle:nil midTitle:@"体检品牌" rightBtnTag:-14];
            }
        }
    }else if (tableView.tag == 2){//选择地区
        
        NSArray * cities = _areaData[indexPath.section][@"Cities"];
        NSString *cityStr = cities[indexPath.row][@"city"];
        
        [self setSelectDicValue:cityStr theKey:Dic_city_name];
        
        [self.tab2 reloadData];
        [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
        [self hiddenTab:self.tab2];
        [self.tab1 reloadData];
        
    }else if (tableView.tag == 3){//价格
        

        
        [self.tf_high resignFirstResponder];
        [self.tf_low resignFirstResponder];
        self.tf_low.text = nil;
        self.tf_high.text = nil;
        
        
        NSString *price = _priceArray[indexPath.row];
        
        [self setSelectDicValue:price theKey:Dic_price];

        
        [self.tab3 reloadData];
        
        [self setDefaultPriceImvHidden];
        
        [self.tf_low resignFirstResponder];
        [self.tf_high resignFirstResponder];

        [self hiddenTab:self.tab3];
        [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
        [self.tab1 reloadData];
        
        
        
        
    }else if (tableView.tag == 4){//体检品牌
        
        if (indexPath.row == 0) {
            NSString *brand_Name = @"全部";
            [self setSelectDicValue:brand_Name theKey:Dic_brand_name];
        }else{
            NSDictionary *dic = self.delegate.brand_city_list[indexPath.row - 1];
            NSString *brand_id = [dic stringValueForKey:@"brand_id"];
            NSString *brand_name = [dic stringValueForKey:@"brand_name"];
            
            [self setSelectDicValue:brand_id theKey:Dic_brand_id];
            [self setSelectDicValue:brand_name theKey:Dic_brand_name];
            
        }
        
        [self.tab4 reloadData];
        
        [self setNavcLeftBtnTag:-1 image:nil leftTitle:@"取消" midTitle:@"筛选" rightBtnTag:-11];
        [self hiddenTab:self.tab4];
        [self.tab1 reloadData];
        
    }
    
}




#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (DEVICE_HEIGHT>480) {
        [self.tab3 setContentSize:CGSizeMake(self.frame.size.width, self.frame.size.height+90)];
        [self.tab3 setContentOffset:CGPointMake(0, 90) animated:YES];
    }else{
        [self.tab3 setContentSize:CGSizeMake(self.frame.size.width, self.frame.size.height+200)];
        [self.tab3 setContentOffset:CGPointMake(0, 240) animated:YES];
    }
    return YES;
}




- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
        if (string.length == 0) {//删除
            
        }else{//新输入
            
            if (![GMAPI isPureNum:string]) {
                return NO;
            }
            
            
        }
        
    
    return YES;
}

#pragma mark - 定位相关

-(void)getjingweidu{
    
    __weak typeof(self)weakSelf = self;
    
    [[GMAPI appDeledate]startDingweiWithBlock:^(NSDictionary *dic) {
        
        [weakSelf theLocationDictionary:dic];
    }];
}


- (void)theLocationDictionary:(NSDictionary *)dic{
    
    NSLog(@"%@",dic);
    _locationDic = dic;
    NSLog(@"%@",_locationDic);
    
    NSString *theString;
    
    if ([[dic stringValueForKey:@"province"]isEqualToString:@"北京市"] || [[dic stringValueForKey:@"province"]isEqualToString:@"上海市"] || [[dic stringValueForKey:@"province"]isEqualToString:@"天津市"] || [[dic stringValueForKey:@"province"]isEqualToString:@"重庆市"]) {
        theString = [dic stringValueForKey:@"province"];
    }else{
        theString = [dic stringValueForKey:@"city"];
    }
    
    if ([LTools isEmpty:theString]) {
        _locationCityLabel.text = @"定位失败";
    }else{
        _locationCityLabel.text = theString;
    }
    
}


#pragma mark - 创建品牌无数据默认view
-(void)creatNoBrandView{
    self.noBrandView = [self resultView];
    self.tab4.tableFooterView = self.noBrandView;
}

-(ResultView *)resultView
{
    NSString *content;
    NSString *btnTitle = @"重新加载";
    
    _resultView = [[ResultView alloc]initWithNoBrandImage:[UIImage imageNamed:@"hema_heart.png"]
                                                           title:@"加载品牌信息失败" content:content
                                                           width:self.frame.size.width];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 200, 36);
    [btn addCornerRadius:5.f];
    btn.backgroundColor = DEFAULT_TEXTCOLOR;
    [btn setTitle:btnTitle forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btn addTarget:self action:@selector(requestBrandInfo) forControlEvents:UIControlEventTouchUpInside];
    [_resultView setBottomView:btn];
    return _resultView;
}


-(void)requestBrandInfo{
    NSLog(@"%s",__FUNCTION__);
    
    [_resultView.activityIndicationVeiw startAnimating];
    
    [self.delegate prepareBrandListWithLocation];
    
}


@end
