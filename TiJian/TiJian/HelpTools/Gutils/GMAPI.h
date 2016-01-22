//
//  GMAPI.h
//  TiJian
//
//  Created by gaomeng on 15/11/3.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+GJson.h"
#import "BMapKit.h"



@protocol GgetllocationDelegate <NSObject>
@optional
- (void)theLocationDictionary:(NSDictionary *)dic;
- (void)theLocationFaild:(NSDictionary *)dic;
@end


@interface GMAPI : NSObject<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>

@property(nonatomic,strong)NSDictionary *theLocationDic;
@property(nonatomic,assign)id<GgetllocationDelegate> delegate;



//出入宽或高和比例 想计算的值传0
+(CGFloat)scaleWithHeight:(CGFloat)theH width:(CGFloat)theW theWHscale:(CGFloat)theWHS;

//提示浮层
+ (void)showAutoHiddenMBProgressWithText:(NSString *)text addToView:(UIView *)aView;

//时间转换 —— 年-月-日
+(NSString *)timechangeYMD:(NSString *)placetime;
//时间转换 —— 月-日
+(NSString *)timechangeMD:(NSString *)placetime;

//时间转换 -- 年月日时分秒
+(NSString *)timechangeYMDhms:(NSString *)placetime;

//地区选择相关
//根据name找id
+ (int)cityIdForName:(NSString *)cityName;
//根据id找name
+ (NSString *)cityNameForId:(int)cityId;

//获取当前定位省份id 城市id
+(NSString *)getCurrentProvinceId;
+(NSString *)getCurrentCityId;

+(NSString *)getCurrentCityName;

//获取appdelegate
+ (AppDelegate *)appDeledate;

//地图相关
+ (GMAPI *)sharedManager;

//开启定位
-(void)startDingwei;


//NSUserDefault存
+ (void)cache:(id)dataInfo ForKey:(NSString *)key;

//NSUserDefault取
+ (id)cacheForKey:(NSString *)key;


//根据city_id查询province_id;
+(NSString*)getProvineIdWithCityId:(int)cityId;


//根据cityid 拿到city名 如果cityid是4个直辖市的区id 则取provinceName
+(NSString *)getCityNameOf4CityWithCityId:(int)cityId;





//判断是否为整形：
+ (BOOL)isPureInt:(NSString*)string;

//判断是否为浮点形：
+ (BOOL)isPureFloat:(NSString*)string;

//是否为数字
+(BOOL)isPureNum:(NSString*)string;



//设置最近搜索
+(void)setuserCommonlyUsedSearchWord:(NSString*)searchWorlds;






@end
