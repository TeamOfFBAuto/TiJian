//
//  BrandDetailViewController.m
//  TiJian
//
//  Created by gaomeng on 16/2/1.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import "BrandDetailViewController.h"
#import "HospitalDetailViewController.h"

@interface BrandDetailViewController ()<UITableViewDataSource,RefreshDelegate>
{
    YJYRequstManager *_request;
    RefreshTableView *_tab;
    NSDictionary *_dataDic;//详情
    
    NSDictionary *_locationDic;
    
    NSArray *_fenyuanList;//分院列表
    
    UILabel *_tmpLabel;
    
    NSString *_phoneNum;
}


@end

@implementation BrandDetailViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:NSStringFromClass([self class])];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"店铺详情";
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self creatTab];
    [self prepareDetail];
    [self getjingweidu];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - 视图创建

-(void)creatTab{
    _tab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-64) style:UITableViewStyleGrouped];
    _tab.refreshDelegate = self;
    _tab.dataSource = self;
    _tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tab];
}


#pragma mark - RefreshDelegate && UITableViewDataSource

- (void)loadNewDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger num = 2;
    return num;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    if (section == 0) {
        if (_dataDic) {
            num = 4;
        }else{
            num = 0;
        }
    }else if (section == 1){
        num = _fenyuanList.count;
    }
    return num;
}


- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    CGFloat height = 0;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            height = 230.0/750*DEVICE_WIDTH+5;
        }else if (indexPath.row == 1){
            
            if (!_tmpLabel) {
                _tmpLabel = [[UILabel alloc]init];
                _tmpLabel.font = [UIFont systemFontOfSize:12];
            }
            
            NSDictionary *data = [_dataDic dictionaryValueForKey:@"data"];
            _tmpLabel.text = [data stringValueForKey:@"brand_desc"];
            [_tmpLabel setMatchedFrame4LabelWithOrigin:CGPointMake(60+15, 0) width:DEVICE_WIDTH - 10 - 60 - 15 - 25];
            height = _tmpLabel.frame.size.height +20;
            
        }else if (indexPath.row == 2){
            height = 45;
        }else if (indexPath.row == 3){
            height = 50;
        }
        
    }else if (indexPath.section == 1){
        height = 40;
    }
    return height;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    return height;
}

-(CGFloat)heightForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0.01;
    return height;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}

-(UIView *)viewForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {//banner
            UIImageView *brandBannerImv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 230.0/750*DEVICE_WIDTH)];
            brandBannerImv.backgroundColor = [UIColor orangeColor];
            [cell.contentView addSubview:brandBannerImv];
            
            
            //logo
            UIImageView *logoImv = [[UIImageView alloc]initWithFrame:CGRectMake(15, brandBannerImv.frame.size.height - 15 - 185.0/750*DEVICE_WIDTH*63/185, 185.0/750*DEVICE_WIDTH*63/185, 185.0/750*DEVICE_WIDTH*63/185)];
            logoImv.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:logoImv];
            
            UILabel *brandName = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(logoImv.frame)+5, logoImv.frame.origin.y, DEVICE_WIDTH - 15 - 5 - logoImv.frame.size.width - 15, logoImv.frame.size.height*0.5)];
            brandName.font = [UIFont systemFontOfSize:14];
            brandName.textColor = [UIColor whiteColor];
            [brandBannerImv addSubview:brandName];
            
            UILabel *liulanNum = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(logoImv.frame)+5, CGRectGetMaxY(brandName.frame), brandName.frame.size.width, brandName.frame.size.height)];
            liulanNum.font = [UIFont systemFontOfSize:13];
            liulanNum.textColor = [UIColor whiteColor];
            [brandBannerImv addSubview:liulanNum];
            
            
            NSDictionary *data = [_dataDic dictionaryValueForKey:@"data"];
            
            NSString *bannerUrl = [data stringValueForKey:@"banner"];
            [brandBannerImv l_setImageWithURL:[NSURL URLWithString:bannerUrl] placeholderImage:nil];
            
            NSString *logoUrl = [data stringValueForKey:@"logo"];
            [logoImv l_setImageWithURL:[NSURL URLWithString:logoUrl] placeholderImage:nil];
            
            NSString *brandName_str = [data stringValueForKey:@"brand_name"];
            brandName.text = brandName_str;
            
            NSString *liulanNum_str = [data stringValueForKey:@"view_num"];
            liulanNum.text = [NSString stringWithFormat:@"%@人浏览",liulanNum_str];
            
            
            
            
            
            UIView *fenline = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(brandBannerImv.frame), DEVICE_WIDTH, 5)];
            fenline.backgroundColor = RGBCOLOR(244, 245, 246);
            [cell.contentView addSubview:fenline];
            
        }else if (indexPath.row == 1){//品牌介绍
            UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 60, 40)];
            tLabel.font = [UIFont systemFontOfSize:13];
            tLabel.textColor = RGBCOLOR(37, 38, 38);
            tLabel.text = @"品牌介绍";
            [cell.contentView addSubview:tLabel];
            UILabel *c_label = [[UILabel alloc]initWithFrame:CGRectMake(60 +16, 0, DEVICE_WIDTH - 10 - 60 - 15 - 25 , 40)];
            c_label.font = [UIFont systemFontOfSize:12];
            c_label.textColor = RGBCOLOR(107, 108, 109);
            NSDictionary *data = [_dataDic dictionaryValueForKey:@"data"];
            c_label.text = [data stringValueForKey:@"brand_desc"];
            [c_label setMatchedFrame4LabelWithOrigin:CGPointMake(60+16, 10) width:DEVICE_WIDTH - 10 - 60 - 15 - 25];
            [cell.contentView addSubview:c_label];
            
            UIView *fenLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(c_label.frame)+5, DEVICE_WIDTH, 5)];
            fenLine.backgroundColor = RGBCOLOR(244, 245, 246);
            [cell.contentView addSubview:fenLine];
        }else if (indexPath.row == 2){//在线客服
            UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 60, 40)];
            tLabel.font = [UIFont systemFontOfSize:13];
            tLabel.textColor = RGBCOLOR(37, 38, 38);
            tLabel.text = @"在线客服";
            [cell.contentView addSubview:tLabel];
            
            UIImageView *jiantouImv = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 32, 12, 16, 16)];
            [jiantouImv setImage:[UIImage imageNamed:@"brand_kefu.png"]];
            [cell.contentView addSubview:jiantouImv];
            
            UIView *fenLine = [[UIView alloc]initWithFrame:CGRectMake(0, 44.5, DEVICE_WIDTH, 0.5)];
            fenLine.backgroundColor = RGBCOLOR(244, 245, 246);
            [cell.contentView addSubview:fenLine];
        }else if (indexPath.row == 3){//联系电话
            UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 60, 40)];
            tLabel.font = [UIFont systemFontOfSize:13];
            tLabel.textColor = RGBCOLOR(37, 38, 38);
            tLabel.text = @"联系电话";
            [cell.contentView addSubview:tLabel];
            
            UILabel *c_label = [[UILabel alloc]initWithFrame:CGRectMake(60 +15, 0, DEVICE_WIDTH - 10 - 60 - 15 - 25 , 40)];
            c_label.font = [UIFont systemFontOfSize:12];
            c_label.textColor = RGBCOLOR(107, 108, 109);
            NSDictionary *data = [_dataDic dictionaryValueForKey:@"data"];
            c_label.text = [data stringValueForKey:@"brand_phone"];
            [cell.contentView addSubview:c_label];
            
            UIImageView *jiantouImv = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 32, 12, 16, 16)];
            [jiantouImv setImage:[UIImage imageNamed:@"brand_phone.png"]];
            [cell.contentView addSubview:jiantouImv];
            
            UIView *fenLine = [[UIView alloc]initWithFrame:CGRectMake(0, 45, DEVICE_WIDTH, 5)];
            fenLine.backgroundColor = RGBCOLOR(244, 245, 246);
            [cell.contentView addSubview:fenLine];
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 60, 40)];
            tLabel.font = [UIFont systemFontOfSize:13];
            tLabel.textColor = RGBCOLOR(37, 38, 38);
            tLabel.text = @"体检分院";
            [cell.contentView addSubview:tLabel];
            
        }
        
        UILabel *c_label = [[UILabel alloc]initWithFrame:CGRectMake(60 +15, 0, DEVICE_WIDTH - 10 - 60 - 15 - 15 , 40)];
        c_label.font = [UIFont systemFontOfSize:12];
        c_label.textColor = RGBCOLOR(107, 108, 109);
        c_label.numberOfLines = 2;
        NSDictionary *onedic = _fenyuanList[indexPath.row];
        NSString *fenyuan_Name = [onedic stringValueForKey:@"center_name"];
        NSString *juli = [onedic stringValueForKey:@"distance"];
        NSString *juli_str = [NSString stringWithFormat:@"%@m",juli];
        if ([juli floatValue]>=1000) {
            juli_str = [NSString stringWithFormat:@"%.2fkm",[juli floatValue]*0.001];
        }
        c_label.text = [NSString stringWithFormat:@"%@ %@",fenyuan_Name,juli_str];
        if ([[_locationDic stringValueForKey:@"isSuccess"]isEqualToString:@"NO"]) {
            c_label.text = [NSString stringWithFormat:@"%@",fenyuan_Name];
        }
        [cell.contentView addSubview:c_label];
        
        
        //箭头
        UIImageView *jiantouImv = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 18, 12, 8, 15)];
        [jiantouImv setImage:[UIImage imageNamed:@"personal_jiantou_r.png"]];
        [cell.contentView addSubview:jiantouImv];
        
        //分割线
        UIView *fenLine = [[UIView alloc]initWithFrame:CGRectMake(c_label.frame.origin.x, 39.5, DEVICE_WIDTH - c_label.frame.origin.x, 0.5)];
        fenLine.backgroundColor = RGBCOLOR(220, 221, 223);
        [cell.contentView addSubview:fenLine];
        
        
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


- (void)clickToChat
{
    [MiddleTools pushToChatWithSourceType:SourceType_Normal fromViewController:self model:nil];
}


- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    if (indexPath.section == 0) {
        
        if (indexPath.row == 2){//在线客服
            [LoginManager isLogin:self loginBlock:^(BOOL success) {
                if (success) {
                    [self clickToChat];
                }
            }];
        }else if (indexPath.row == 3){//联系电话
            NSDictionary *data = [_dataDic dictionaryValueForKey:@"data"];
            NSString *phoneNum = [data stringValueForKey:@"brand_phone"];
            NSMutableString *temp = [NSMutableString stringWithString:phoneNum];
            [temp replaceOccurrencesOfString:@"－" withString:@"-" options:0 range:NSMakeRange(0, temp.length)];
            _phoneNum = [NSString stringWithFormat:@"%@",temp];

            [self clickToPhone];
        }
    }else if (indexPath.section == 1){
        NSDictionary *dic = _fenyuanList[indexPath.row];
        NSString *exam_center_id = [dic stringValueForKey:@"exam_center_id"];
        
        HospitalDetailViewController *hospital = [[HospitalDetailViewController alloc]init];
        hospital.centerId = exam_center_id;
        [self.navigationController pushViewController:hospital animated:YES];
        
    }
}

/**
 *  打电话
 */
- (void)clickToPhone
{
    NSString *msg = [NSString stringWithFormat:@"拨打:%@",_phoneNum];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        
        NSString *msg = [NSString stringWithFormat:@"%@",_phoneNum];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",msg]]];
    }
}


- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    
}


#pragma mark - 网络请求
-(void)prepareNetData{
    [self getCenterList];
}
-(void)prepareDetail{
    if (!_request) {
        _request = [YJYRequstManager shareInstance];
    }
    
    NSDictionary *dic = @{
                          @"brand_id":self.brand_id
                          };
    
    [_request requestWithMethod:YJYRequstMethodGet api:StoreHomeDetail parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        _dataDic = result;
        [_tab reloadData];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } failBlock:^(NSDictionary *result) {
        
    }];
    
}


-(void)getCenterList{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic safeSetValue:[GMAPI getCurrentProvinceId] forKey:@"province_id"];
    [dic safeSetValue:[GMAPI getCurrentCityId] forKey:@"city_id"];
    [dic safeSetValue:self.brand_id forKey:@"brand_id"];
    [dic safeSetValue:[_locationDic stringValueForKey:@"lat"] forKey:@"latitude"];
    [dic safeSetValue:[_locationDic stringValueForKey:@"long"] forKey:@"longitude"];
    [dic safeSetValue:[NSString stringWithFormat:@"%d",_tab.pageNum] forKey:@"page"];
    [dic safeSetValue:[NSString stringWithFormat:@"%d",G_PER_PAGE] forKey:@"per_page"];
    
    
    [_request requestWithMethod:YJYRequstMethodGet api:GET_CENTER_LIST parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        _fenyuanList = [result arrayValueForKey:@"list"];
        [_tab reloadData:_fenyuanList pageSize:G_PER_PAGE];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
}



#pragma mark - 获取经纬度
-(void)getjingweidu{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusRestricted == status) {
        NSLog(@"kCLAuthorizationStatusRestricted 开启定位失败");
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"开启定位失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
        return;
    }else if (kCLAuthorizationStatusDenied == status){
        NSLog(@"请允许衣加衣使用定位服务");
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请允许衣加衣使用定位服务" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    
    [[GMAPI appDeledate]startDingweiWithBlock:^(NSDictionary *dic) {
        
        [weakSelf theLocationDictionary:dic];
    }];
}


- (void)theLocationDictionary:(NSDictionary *)dic{
    
    NSLog(@"%@",dic);
    _locationDic = dic;
    NSLog(@"%@",_locationDic);
    
    [_tab refreshNewData];
    
}

@end
