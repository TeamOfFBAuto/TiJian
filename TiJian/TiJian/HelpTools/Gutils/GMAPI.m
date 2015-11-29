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
    return str;
}
+(NSString *)getCurrentCityId{
    NSString *str;
    NSDictionary *dic = [GMAPI cacheForKey:USERLocation];
    str = [dic stringValueForKey:@"city"];
    return str;
}



@end
