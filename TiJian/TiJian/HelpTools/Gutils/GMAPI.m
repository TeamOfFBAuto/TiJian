//
//  GMAPI.m
//  TiJian
//
//  Created by gaomeng on 15/11/3.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "GMAPI.h"
#import "DataBase.h"

@implementation GMAPI
{
    BMKGeoCodeSearch *_geoSearch;
    BMKLocationService* _locService;//定位服务
    NSArray *_areaData;
}

-(void)setUpToolViewBlock:(upToolViewBlock)upToolViewBlock{
    _upToolViewBlock = upToolViewBlock;
}

-(void)setUpToolViewBlock1:(upToolViewBlock)upToolViewBlock1{
    _upToolViewBlock1 = upToolViewBlock1;
}


//出入宽或高和比例 想计算的值传0
+(CGFloat)scaleWithHeight:(CGFloat)theH width:(CGFloat)theW theWHscale:(CGFloat)theWHS{
    CGFloat value = 0;
    
    //  theW/theH = theWHS
    
    if (theH == 0) {//计算高
        value = theW/theWHS;
    }else if (theW == 0){
        value = theWHS * theH;
    }
    
    return value;
}

//提示浮层
+ (void)showAutoHiddenMBProgressWithText:(NSString *)text addToView:(UIView *)aView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:aView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.margin = 12.f;
    hud.yOffset = 0.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.5];
}

//时间转换 —— 年-月-日
+(NSString *)timechangeYMD:(NSString *)placetime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

//时间转换 —— 月-日
+(NSString *)timechangeMD:(NSString *)placetime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MM-dd"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

//hh:mm:ss
+(NSString *)timechangeYMDhms:(NSString *)placetime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}




//地区选择相关
//根据name找id
+ (int)cityIdForName:(NSString *)cityName//根据城市名获取id
{
    //打开数据库
    sqlite3 *db = [DataBase openDB];
    //创建操作指针
    sqlite3_stmt *stmt = nil;
    //执行SQL语句
    int result = sqlite3_prepare_v2(db, "select * from area where name = ?", -1, &stmt, nil);
    
    NSLog(@"All subcities result = %d %@",result,cityName);
    
    if (result == SQLITE_OK) {
        
        sqlite3_bind_text(stmt, 1, [cityName UTF8String], -1, nil);
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            
            int cityId = sqlite3_column_int(stmt, 1);
            
            return cityId;
        }
    }
    sqlite3_finalize(stmt);
    return 0;
}

//根据id找name
+ (NSString *)cityNameForId:(int)cityId{
    //打开数据库
    sqlite3 *db = [DataBase openDB];
    //创建操作指针
    sqlite3_stmt *stmt = nil;
    //执行SQL语句
    int result = sqlite3_prepare_v2(db, "select * from area where id = ?", -1, &stmt, nil);
    
    NSLog(@"All subcities result = %d %d",result,cityId);
    
    if (result == SQLITE_OK) {
        
        sqlite3_bind_int(stmt, 1, cityId);
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            
            const unsigned char *cityName = sqlite3_column_text(stmt, 0);
            
            return [NSString stringWithUTF8String:(const char *)cityName];
        }
    }
    sqlite3_finalize(stmt);
    return @"";
}




//获取appdelegate
+ (AppDelegate *)appDeledate
{
    AppDelegate *aa = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return aa;
}


//地图相关

+ (GMAPI *)sharedManager
{
    static GMAPI *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}

//开启定位
-(void)startDingwei{
    
    
    __weak typeof(self)weakSelf = self;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        
        NSLog(@"请打开您的位置服务!");
        
    }
    
    [weakSelf startLocation];
    
}


///开始定位
-(void)startLocation{
    
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    [_locService startUserLocationService];
}

///停止定位
-(void)stopLocation{
    
    
    [_locService stopUserLocationService];
    if (_locService) {
        _locService = nil;
    }
}

//用户位置更新后，会调用此函数

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    if (userLocation) {
        self.theLocationDic = @{
                                @"lat":[NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude],
                                @"long":[NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude]
                                };
        
        
        
        
        
        BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
        reverseGeoCodeSearchOption.reverseGeoPoint = userLocation.location.coordinate;
        _geoSearch = [[BMKGeoCodeSearch alloc]init];
        BOOL flag = [_geoSearch reverseGeoCode:reverseGeoCodeSearchOption];
        
        _geoSearch.delegate = self;
        
        if (flag) {
            NSLog(@"反geo索引发送成功");
        }else{
            NSLog(@"反geo索引发送失败");
        }
        
        
        [self stopLocation];
        
        
        
    }
}



- (void)didFailToLocateUserWithError:(NSError *)error{
    //金领时代 40.041951,116.33934
    //天安门 39.915187,116.403877
    if (self.delegate && [self.delegate respondsToSelector:@selector(theLocationDictionary:)]) {
        self.theLocationDic = @{
                                @"lat":[NSString stringWithFormat:@"%f",40.041951],
                                @"long":[NSString stringWithFormat:@"%f",116.33934]
                                };
        [self.delegate theLocationFaild:self.theLocationDic];
    }
}





- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    NSLog(@"%s",__FUNCTION__);
    _geoSearch.delegate = nil;
    _geoSearch = nil;
    
    NSLog(@"省份：%@ 城市：%@ 区：%@",result.addressDetail.province,result.addressDetail.city,result.addressDetail.district);
    
    NSDictionary *dic = self.theLocationDic;
    self.theLocationDic = @{
                            @"lat":[dic stringValueForKey:@"lat"],
                            @"long":[dic stringValueForKey:@"long"],
                            @"province":result.addressDetail.province,
                            @"city":result.addressDetail.city
                            };
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(theLocationDictionary:)]) {
        [self.delegate theLocationDictionary:self.theLocationDic];
    }
    
}




//NSUserDefault存
+ (void)cache:(id)dataInfo ForKey:(NSString *)key
{
    NSLog(@"key===%@",key);
    @try {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:dataInfo forKey:key];
        [defaults synchronize];
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@",exception);
    }
    @finally {
    }
}

//NSUserDefault取
+ (id)cacheForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}


+(NSString *)getCurrentProvinceId{
    NSString *str;
    NSDictionary *dic = [GMAPI cacheForKey:USERLocation];
    str = [dic stringValueForKey:@"province"];
    
    if ([LTools isEmpty:str]) {
        str = @"1000";//北京
    }
    
    return str;
}
+(NSString *)getCurrentCityId{
    NSString *str;
    NSDictionary *dic = [GMAPI cacheForKey:USERLocation];
    str = [dic stringValueForKey:@"city"];
    if ([LTools isEmpty:str]) {
        str = @"1005";//海淀
    }
    return str;
}

+(NSString *)getCurrentCityName{
    NSString *ss = [self getCurrentCityId];
    NSString *cc = [self cityNameForId:[ss intValue]];
    return cc;
}



+(NSString*)getProvineIdWithCityId:(int)cityId{
    
    NSString *provinceId = [NSString stringWithFormat:@"%d00",cityId/100];
    return provinceId;
}

+(NSString *)getCityNameOf4CityWithCityId:(int)cityId{
    
    NSString *city_name = [self cityNameForId:cityId];
    
    if (cityId<1400) {
        NSString *p_id = [self getProvineIdWithCityId:cityId];
        city_name = [self cityNameForId:[p_id intValue]];
        
    }else{
        city_name = [self cityNameForId:cityId];
    }

    return city_name;
}




//判断是否为整形：
+ (BOOL)isPureInt:(NSString*)string{
    
    NSScanner* scan = [NSScanner scannerWithString:string];
    
    int val;
    
    return[scan scanInt:&val] && [scan isAtEnd];
    
}


//判断是否为浮点形：
+ (BOOL)isPureFloat:(NSString*)string{
    
    NSScanner* scan = [NSScanner scannerWithString:string];
    
    float val;
    
    return[scan scanFloat:&val] && [scan isAtEnd];
    
}

//是否为数字
+(BOOL)isPureNum:(NSString*)string{
    
    BOOL bb = NO;
    
    if ([self isPureInt:string] || [self isPureFloat:string]) {
        bb = YES;
    }
    
    return bb;
}


//设置最近搜索
+(void)setuserCommonlyUsedSearchWord:(NSString*)searchWorlds{
    
    
    NSArray *arr = [GMAPI cacheForKey:USERCOMMONLYUSEDSEARCHWORD];
    if (!arr) {
        NSMutableArray *adressArray = [[NSMutableArray alloc]initWithCapacity:5];
        [adressArray addObject:searchWorlds];
        [GMAPI cache:(NSArray*)adressArray ForKey:USERCOMMONLYUSEDSEARCHWORD];
    }else{
        BOOL isHave = NO;
        for (NSString*str in arr) {
            if ([str isEqualToString:searchWorlds]) {
                isHave = YES;
                continue;
            }
        }
        
        NSMutableArray *adressMutabelArray = [NSMutableArray arrayWithArray:arr];
        
        if (isHave) {//有
            
        }else{//没有
            if (arr.count<20) {
                [adressMutabelArray addObject:searchWorlds];
                
            }else{
                [adressMutabelArray removeObjectAtIndex:0];
                [adressMutabelArray addObject:searchWorlds];
            }
            
            [GMAPI cache:(NSArray*)adressMutabelArray ForKey:USERCOMMONLYUSEDSEARCHWORD];
            
            
        }
        
    }
}



-(UIView *)creatThreeBtnUpToolView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, -50, DEVICE_WIDTH, 50)];
    view.backgroundColor = [UIColor whiteColor];
    
    
    NSArray *titleArray = @[@"足迹",@"搜索",@"首页"];
    NSArray *imageArray = @[[UIImage imageNamed:@"uptool_zuji.png"],[UIImage imageNamed:@"uptool_search.png"],[UIImage imageNamed:@"uptool_homepage.png"]];
    for (int i = 0; i<3; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:RGBCOLOR(152, 153, 154) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        CGFloat w = DEVICE_WIDTH/3;
        btn.tag = 10+i;
        [btn setFrame:CGRectMake(i*w, 0, DEVICE_WIDTH/3, 50)];
        [view addSubview:btn];
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        [btn setImage:imageArray[i] forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -25, -25, 0)];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(5, 18, 25, 0)];
        [btn addTarget:self action:@selector(upToolBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    
    
    return view;
}

-(UIView *)creatTwoBtnUpToolView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, -50, DEVICE_WIDTH, 50)];
    view.backgroundColor = [UIColor whiteColor];
    
    NSArray *titleArray = @[@"搜索",@"首页"];
    NSArray *imageArray = @[[UIImage imageNamed:@"uptool_search.png"],[UIImage imageNamed:@"uptool_homepage.png"]];
    
    for (int i = 0; i<2; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat w = DEVICE_WIDTH/2;
        [btn setTitleColor:RGBCOLOR(152, 153, 154) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.tag = 20+i;
        [btn setFrame:CGRectMake(i*w, 0, w, 50)];
        [view addSubview:btn];
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        [btn setImage:imageArray[i] forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -25, -25, 0)];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(5, 18, 25, 0)];
        [btn addTarget:self action:@selector(upToolBtnClicked1:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    return view;
}

-(void)upToolBtnClicked:(UIButton*)sender{
    self.upToolViewBlock(sender.tag);
}

-(void)upToolBtnClicked1:(UIButton*)sender{
    self.upToolViewBlock1(sender.tag);
}



@end
