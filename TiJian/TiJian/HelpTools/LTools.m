//
//  LCWTools.m
//  FBAuto
//
//  Created by lichaowei on 14-7-9.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "LTools.h"
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"
#import <RongIMKit/RongIMKit.h>
#import "Reachability.h"

@interface LTools ()
{
    NSString *requestUrl;
    NSData *requestData;
    BOOL isPostRequest;//是否是post请求
    NSString *_appid;
    NSString *_downUrl;//更新地址
}

@end

@implementation LTools
{
    NSMutableData *_data;
}

+ (id)shareInstance
{
    static dispatch_once_t once_t;
    static LTools *dataBlock;
    
    dispatch_once(&once_t, ^{
        dataBlock = [[LTools alloc]init];
    });
    
    return dataBlock;
}

+ (AppDelegate *)appDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

+ (UINavigationController *)rootNavigationController
{
    return (UINavigationController *)[LTools appDelegate].window.rootViewController;
}

#pragma mark - 判断是否是企业版本

+ (BOOL)isEnterprise
{
    if ([AppBunleIdentifier isEqualToString:@"com.medical.hema"]) {
        
        return NO;
        
    }else if ([AppBunleIdentifier isEqualToString:@"com.medical.hemaEnterprise"]){
        return YES;
    }
    
    return NO;
}

/**
 *  获取appName
 *
 *  @return
 */
+ (NSString *)getAppName
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app名称
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    
    return app_Name;
}



#pragma - mark MD5 加密

/**
 *  获取验证码的时候加此参数
 *
 *  @param phone 手机号
 *
 *  @return 手机号和特定字符串MD5之后的结果
 */
+ (NSString *)md5Phone:(NSString *)phone
{
//    13718570646_sea-food@_2015
    NSString *mdPhone = [NSString stringWithFormat:@"%@_he-ma@_2015",phone];
    
    return [self md5:mdPhone];
}

+ (NSString *) md5:(NSString *) text
{
    const char * bytes = [text UTF8String];
    unsigned char md5Binary[16];
    CC_MD5(bytes, (CC_LONG)strlen(bytes), md5Binary);
    
    NSString * md5String = [NSString
                            stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                            md5Binary[0], md5Binary[1], md5Binary[2], md5Binary[3],
                            md5Binary[4], md5Binary[5], md5Binary[6], md5Binary[7],
                            md5Binary[8], md5Binary[9], md5Binary[10], md5Binary[11],
                            md5Binary[12], md5Binary[13], md5Binary[14], md5Binary[15]
                            ];
    return md5String;
}


#pragma mark - 网络监控

/**
 *  判断网络wifi或者移动网络是否可用
 *
 *  @return YES or NO
 */
+ (BOOL)NetworkReachable
{
    NetworkStatus wifi = [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus];
    NetworkStatus gprs = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(wifi == NotReachable && gprs == NotReachable)
    {
        return NO;
    }
    return YES;
}

#pragma mark - 版本更新信息

- (void)versionForAppid:(NSString *)appid Block:(void(^)(BOOL isNewVersion,NSString *updateUrl,NSString *updateContent))version//是否有新版本、新版本更新下地址
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    //test FBLife 605673005 fbauto 904576362
    NSString *url = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@",appid];

    NSString *newStr = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    requestUrl = newStr;
    requestData = nil;
    isPostRequest = NO;
    
    
    NSURL *urlS = [NSURL URLWithString:newStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlS cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (data.length > 0) {
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:Nil];
            
            NSArray *results = [dic objectForKey:@"results"];
            
            if (results.count == 0) {
                version(NO,@"no",@"没有更新");
                return ;
            }
            
            //appStore 版本
            NSString *newVersion = [[[dic objectForKey:@"results"] objectAtIndex:0]objectForKey:@"version"];
            NSString *updateContent = [[[dic objectForKey:@"results"] objectAtIndex:0]objectForKey:@"releaseNotes"];
            //本地版本
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *currentVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            
            _downUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8",appid];
            
            BOOL isNew = NO;
            if (newVersion && ([newVersion compare:currentVersion] == 1)) {
                isNew = YES;
            }
            
            version(isNew,_downUrl,updateContent);
            
            if (isNew) {
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"版本更新" message:updateContent delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"立即更新", nil];
                [alert show];
            }
            
        }else
        {
            NSLog(@"data 为空 connectionError %@",connectionError);
            
            NSString *errInfo = @"网络有问题,请检查网络";
            switch (connectionError.code) {
                case NSURLErrorNotConnectedToInternet:
                    
                    errInfo = @"无网络连接";
                    break;
                case NSURLErrorTimedOut:
                    
                    errInfo = @"网络连接超时";
                    break;
                default:
                    break;
            }
            
            NSDictionary *failDic = @{RESULT_INFO: errInfo};
            
            NSLog(@"version erro %@",failDic);
            
        }
        
    }];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:_downUrl]];
    }
}

#pragma mark - NSUserDefault缓存

#pragma mark 缓存融云用户数据

/**
 *  获取融云未读消息num
 *
 *  @return
 */
+ (int)rongCloudUnreadNum
{
    int unreadMsgCount = [[RCIMClient sharedRCIMClient]getUnreadCount: @[@(ConversationType_CUSTOMERSERVICE),@(ConversationType_APPSERVICE)]];
    return unreadMsgCount;
}

/**
 *  更新未读消息显示
 *
 *  @param number 未读数
 */
+ (void)updateTabbarUnreadMessageNumber
{
    int unreadMsgCount = [[RCIMClient sharedRCIMClient]getUnreadCount: @[@(ConversationType_APPSERVICE)]];
//    @(ConversationType_CUSTOMERSERVICE),//客服1.0
    NSString *number_str = nil;
    
    //未登陆
    if (![LoginManager isLogin]) {
        unreadMsgCount = 0;
    }
    
    if (unreadMsgCount > 0) {
        number_str = [NSString stringWithFormat:@"%d",unreadMsgCount];
    }
    //通知消息
    int msgNum = [[LTools objectForKey:USER_MSG_NUM]intValue];
    
    int sum = msgNum + [number_str intValue];
    
    DDLOG(@"未读消息--客服:%d 通知:%d",unreadMsgCount,msgNum);
    
    UITabBarController *root = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    if ([root isKindOfClass:[UITabBarController class]]) {
        UINavigationController *unvc = [root.viewControllers objectAtIndex:2];
        
        if (sum <= 0) {
            unvc.tabBarItem.badgeValue = nil;
        }else
        {
            int temp = sum - msgNum;
            if (temp <= 0) {
                unvc.tabBarItem.badgeValue = nil;
            }else
            {
                unvc.tabBarItem.badgeValue = NSStringFromInt(sum - msgNum);//tabbar上个数暂时不显示 活动未读数据
            }
        }
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = sum;
    }
}

+ (void)cacheRongCloudUserName:(NSString *)userName forUserId:(NSString *)userId
{
    NSString *key = [NSString stringWithFormat:@"userName_%@",userId];
    [LTools setObject:userName forKey:key];
}
+ (NSString *)rongCloudUserNameWithUid:(NSString *)userId
{
    NSString *key = [NSString stringWithFormat:@"userName_%@",userId];
    return [LTools objectForKey:key];
}

+ (void)cacheRongCloudUserIcon:(NSString *)iconUrl forUserId:(NSString *)userId
{
    NSString *key = [NSString stringWithFormat:@"userIcon_%@",userId];
    [LTools setObject:iconUrl forKey:key];
}

+ (NSString *)rongCloudUserIconWithUid:(NSString *)userId
{
    NSString *key = [NSString stringWithFormat:@"userIcon_%@",userId];
    return [LTools objectForKey:key];
}

/**
 *  融云 记录更新数据时间
 *
 *  @param userId 用户id
 */
+ (void)cacheRongCloudTimeForUserId:(NSString *)userId
{
    NSString *key = [NSString stringWithFormat:@"updateTime_%@",userId];
    
    NSString *nowTime = [LTools timechangeToDateline];
    
    [LTools setObject:nowTime forKey:key];
}

/**
 *  是否需要更新userId对应的信息
 *
 *  @param userId
 *
 *  @return 是否
 */
+ (BOOL)rongCloudNeedRefreshUserId:(NSString *)userId
{
//    NSString *key = [NSString stringWithFormat:@"updateTime_%@",userId];
//
//    NSDate *oldDate = [LTools timeFromString:[LTools cacheForKey:key]];
//    
//    NSInteger between = [oldDate hoursBetweenDate:oldDate];
//    
//    if (between >= 1) { //大于一个小时需要更新
//        
//        NSLog(@"需要更新融云用户信息 %@ bew:%ld",oldDate,(long)between);
//        
//        return YES;
//    }
//    
    return NO;
}

#pragma - mark NSUserDefaults本地缓存

/**
 *  归档的方式 model必须遵循 NSSecureCoding
 *
 *  @param aModel
 *  @param modelKey
 */
+ (void)cacheModel:(id)aModel forKey:(NSString *)modelKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:aModel];
    [userDefaults setObject:data forKey:modelKey];
    [userDefaults synchronize];
}

+ (id)cacheModelForKey:(NSString *)modelKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefaults objectForKey:modelKey];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

//存
+ (void)setObject:(id)object forKey:(NSString *)key;
{
    if (!key) {
        return;
    }
    @try {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:nil forKey:key];
        [defaults setObject:object forKey:key];
        [defaults synchronize];
        
    }
    @catch (NSException *exception) {
        
        NSLog(@"exception %@",exception);
        
    }
    @finally {
        
    }
    
}

//取
+ (id)objectForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

+ (void)setBool:(BOOL)boo forKey:(NSString *)key;
{
    [[NSUserDefaults standardUserDefaults]setBool:boo forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (BOOL)boolForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:key];
}


#pragma mark - 常用视图快速创建

/**
 *  通过xib创建cell
 *
 *  @param identify  标识名称
 *  @param tableView
 *  @param cellName
 *
 *  @return cell
 */
+ (UITableViewCell *)cellForIdentify:(NSString *)identify
                            cellName:(NSString *)cellName
                            forTable:(UITableView *)tableView
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:cellName owner:self options:nil]objectAtIndex:0];
    }
    return cell;
}

#pragma - mark 文字自适应高度、宽度计算

/**
 *  计算宽度
 */
+ (CGFloat)widthForText:(NSString *)text font:(CGFloat)size
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:size]};
    CGSize aSize = [text sizeWithAttributes:attributes];
    return aSize.width;
}

+ (CGFloat)widthForText:(NSString *)text boldFont:(CGFloat)size
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:size]};
    CGSize aSize = [text sizeWithAttributes:attributes];
    return aSize.width;
}

+ (CGFloat)widthForText:(NSString *)text height:(CGFloat)height font:(CGFloat)size
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:size]};
    CGSize aSize = [text boundingRectWithSize:CGSizeMake(MAXFLOAT,height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:Nil].size;
    return aSize.width;
}

+ (CGFloat)heightForText:(NSString *)text width:(CGFloat)width font:(CGFloat)size
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:size]};
    CGSize aSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:Nil].size;
    return aSize.height;
}

+ (CGFloat)heightForText:(NSString *)text width:(CGFloat)width Boldfont:(CGFloat)size
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:size]};
    CGSize aSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:Nil].size;
    return aSize.height;
}

#pragma mark - 验证有消息

//是否是字典
+ (BOOL)isDictinary:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    return NO;
}

#pragma - mark 判断为空或者是空格

+ (BOOL) isEmpty:(NSString *) str {
    
    if (![str isKindOfClass:[NSString class]]) {
        return YES;
    }
    
    if (!str) {
        
        return YES;
        
    } else {
        
        //A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
        
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        //Returns a new string made by removing from both ends of the receiver characters contained in a given character set.
        
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            
            return YES;
            
        } else {
            
            return NO;
            
        }
        
    }
    
}

#pragma - mark 验证邮箱、电话等有效性

/*匹配正整数*/
+ (BOOL)isValidateInt:(NSString *)digit
{
    NSString * digitalRegex = @"^[1-9]\\d*$";
    NSPredicate * digitalTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",digitalRegex];
    return [digitalTest evaluateWithObject:digit];
}

/*匹配整浮点数*/
+ (BOOL)isValidateFloat:(NSString *)digit
{
    NSString * digitalRegex = @"^[1-9]\\d*\\.\\d*|0\\.\\d*[1-9]\\d*$";
    NSPredicate * digitalTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",digitalRegex];
    return [digitalTest evaluateWithObject:digit];
}

/*邮箱*/
+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString * emailRegex = @"\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*";
    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isValidateName:(NSString *)userName
{
    NSString * emailRegex = @"^[\u4E00-\u9FA5a-zA-Z0-9_]{1,20}$";
    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    return [emailTest evaluateWithObject:userName];
}

//数字和字母 和 _ 6到12位
+ (BOOL)isValidatePwd:(NSString *)pwdString
{
    NSString * emailRegex = @"^[a-zA-Z0-9_]{6,12}$";
    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    return [emailTest evaluateWithObject:pwdString];
}

//验证身份证

+ (BOOL)isValidateIDCard:(NSString *)value {
    
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    int length =0;
    if (!value) {
        return NO;
    }else {
        length = (int)value.length;
        if (length !=15 && length !=18)
        {
            return NO;
        }
    }
    //省份代码
    NSArray *areasArray =@[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41", @"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];
    
    NSString *valueStart2 = [value substringToIndex:2];
    BOOL areaFlag = NO;
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag = YES;
            break;
        }
    }
    
    if (!areaFlag) {
        return false;
    }
    
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    
    int year = 0;
    switch (length) {
        case 15:
            year = [value substringWithRange:NSMakeRange(6,2)].intValue + 1900;
            
            if (year % 4 ==0 || (year % 100 == 0 && year % 4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                              options:NSMatchingReportProgress
                                                                range:NSMakeRange(0, value.length)];
            
            if(numberofMatch >0) {
                return YES;
            }else {
                return NO;
            }
        case 18:
            
            year = [value substringWithRange:NSMakeRange(6,4)].intValue;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                              options:NSMatchingReportProgress
                                                                range:NSMakeRange(0, value.length)];
            
            if(numberofMatch >0) {
                int S = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7 + ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4 + ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2 + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
                
                int Y = S %11;
                NSString *M =@"F";
                NSString *JYM =@"10X98765432";
                M = [JYM substringWithRange:NSMakeRange(Y,1)];// 判断校验位
                
                NSString *temp = [value substringWithRange:NSMakeRange(17,1)];
                //小写字母x判断
                if ([temp isEqualToString:@"x"]) {
                    temp = [temp uppercaseString];//转换为大写
                }
                
                if ([M isEqualToString:temp]) {
                    return YES;// 检测ID的校验位
                }else {
                    return NO;
                }
                
            }else {
                return NO;
            }
        default:
            return false;
    }
}

/*手机及固话*/
+ (BOOL)isValidateMobile:(NSString *)mobileNum
{
    
    //    //手机号 13 14 15 17 18  后面9位
    //    NSString *mobie = @"^1[3-578]\\d{9}$";
    
    //手机号 1开头  后面10位
    NSString *mobie = @"^1\\d{10}$";
    
    //    /**
    //     * 手机号码
    //     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
    //     * 联通：130,131,132,152,155,156,185,186
    //     * 电信：133,1349,153,180,189
    //     */
    //    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    //    /**
    //     10         * 中国移动：China Mobile
    //     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
    //     12         */
    //    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    //    /**
    //     15         * 中国联通：China Unicom
    //     16         * 130,131,132,152,155,156,185,186
    //     17         */
    //    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    //    /**
    //     20         * 中国电信：China Telecom
    //     21         * 133,1349,153,180,189
    //     22         */
    //    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobie];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


#pragma - mark 小工具

/**
 *  根据6的屏幕计算比例宽度
 *
 *  @param aWidth 6上的宽
 *
 *  @return 等比例的宽
 */
+ (CGFloat)fitWidth:(CGFloat)aWidth
{
    return (aWidth * DEVICE_WIDTH) / 375;
}

/**
 *  根据6的屏幕计算比例高度
 *
 *  @param aWidth 6上的高
 *
 *  @return 等比例的高
 */
+ (CGFloat)fitHeight:(CGFloat)aHeight
{
    return (aHeight * DEVICE_HEIGHT) / 667;
}

/**
 *  根据6的宽度等比例适配size
 */
+ (CGSize)fitWidthForSize:(CGSize)size
{
    CGFloat radio = DEVICE_WIDTH / 375.f;
    return CGSizeMake(size.width * radio, size.height * radio);
}

/**
 *  根据6的高度等比例适配size
 */
+ (CGSize)fitHeightForSize:(CGSize)size
{
    CGFloat radio = DEVICE_HEIGHT / 667;
    return CGSizeMake(size.width * radio, size.height * radio);
}

/**
 *  根据color id获取优惠劵背景图
 *
 *  @param color color 的id
 *
 *  @return image
 */
+ (UIImage *)imageForCoupeColorId:(NSString *)color
{
    UIImage *aImage = [UIImage imageNamed:@"youhuiquan_r.png"];
    if ([color intValue] == 1) {
        aImage = [UIImage imageNamed:@"youhuiquan_r.png"];
    }else if ([color intValue] == 2){
        aImage = [UIImage imageNamed:@"youhuiquan_y.png"];
    }else if ([color intValue] == 3){
        aImage = [UIImage imageNamed:@"youhuiquan_b.png"];
    }
    return aImage;
}

/**
 *  返回距离 大于1000 为km,小于m
 *
 *  @param distance 距离
 *
 *  @return
 */
+ (NSString *)distanceString:(NSString *)distance
{
    if (!distance ||
        ([distance isKindOfClass:[NSString class]] && [LTools isEmpty:distance])
        ) {
        return nil;
    }
    NSString *distanceStr;
    
    double dis = [distance doubleValue];
    
    if (dis > 1000) {
        
        distanceStr = [NSString stringWithFormat:@"%.1fkm",dis/1000];
    }else
    {
        distanceStr = [NSString stringWithFormat:@"%@m",distance];
    }
    return distanceStr;
}


#pragma - mark 时间相关

/**
 *  时间戳转化为格式时间
 *
 *  @param placetime 时间线
 *  @param format    时间格式 @"yyyy-MM-dd HH:mm:ss" HH代表24小时制 12代表12小时进制
 *
 *  @return 返回时间字符串
 */
+(NSString *)timeString:(NSString *)placetime
             withFormat:(NSString *)format
{
    if (!placetime) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

/**
 *  NSDate转指定格式string
 *
 *  @param date   日期
 *  @param format 格式
 *
 *  @return
 */
+(NSString *)timeDate:(NSDate *)date
             withFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    NSString *confromTimespStr = [formatter stringFromDate:date];
    return confromTimespStr;
}

/**
 *  获取当前时间戳
 */
+(NSString *)timechangeToDateline
{
    return [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
}

/**
 *  NSDate对应的时间戳
 *  @return
 */
+(NSString *)timeDatelineWithDate:(NSDate *)date
{
    return [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
}

/**
 *  时间转化为对应的时间戳
 *
 *  @param string 时间
 *  @param format 格式
 *
 *  @return
 */
+(NSString *)timeDatelineWithString:(NSString *)string
                             format:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    
    NSDate *date = [formatter dateFromString:string];
    
    return [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
}

/**
 *  显示间隔时间 一天内显示时分、几天前、几周前、大于一周 显示具体日期
 *
 *  @param myTime 时间线
 *  @param format 时间格式 “HH:mm”
 *
 *  @return
 */
+ (NSString*)showIntervalTimeWithTimestamp:(NSString*)myTime
                        withFormat:(NSString *)format{
    
    NSString *timestamp;
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now,  [myTime integerValue]);
    
    //小于一天的显示时、分
    
    if (distance < 60 * 60 * 24) {
        
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm"];
        }
        NSDate *date = [NSDate dateWithTimeIntervalSince1970: [myTime integerValue]];
        
        timestamp = [dateFormatter stringFromDate:date];
    }else if (distance < 60 * 60 * 24 * 2) {
        
        timestamp = [NSString stringWithFormat:@"昨天"];
        
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        timestamp = [NSString stringWithFormat:@"%d%@", distance,@"天前"];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        timestamp = [NSString stringWithFormat:@"%d%@", distance, @"周前"];
    }else
    {
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:format];
        }
        NSDate *date = [NSDate dateWithTimeIntervalSince1970: [myTime integerValue]];
        timestamp = [dateFormatter stringFromDate:date];
    }
    
    return timestamp;
}

+(NSString*)timestamp:(NSString*)myTime{
    
    NSString *timestamp;
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now,  [myTime integerValue]);
    if (distance < 0) distance = 0;
    
    if (distance < 60) {
        timestamp = [NSString stringWithFormat:@"%d%@", distance, @"秒钟前"];
    }
    else if (distance < 60 * 60) {
        distance = distance / 60;
        timestamp = [NSString stringWithFormat:@"%d%@", distance, @"分钟前"];
    }
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        timestamp = [NSString stringWithFormat:@"%d%@", distance,@"小时前"];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        timestamp = [NSString stringWithFormat:@"%d%@", distance,@"天前"];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        timestamp = [NSString stringWithFormat:@"%d%@", distance, @"周前"];
    }else
    {
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        }
        NSDate *date = [NSDate dateWithTimeIntervalSince1970: [myTime integerValue]];
        
        timestamp = [dateFormatter stringFromDate:date];
    }
    
    return timestamp;
}


+ (NSString *)currentTime
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    [outputFormatter setLocale:[NSLocale currentLocale]];
    
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *date = [outputFormatter stringFromDate:[NSDate date]];
    
    NSLog(@"时间 === %@",date);
    return date;
}

/**
 *  字符串格式转换NSDate
 *
 *  @param string 2016-05-13
 *  @param format @"yyyy-MM-dd"
 *
 *  @return
 */
+ (NSDate *)dateFromString:(NSString *)string
                withFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    if (!format) {
        format = @"yyyy-MM-dd";
    }
    formatter.dateFormat = format;
    return [formatter dateFromString:string];
}

/**
 *  是否需要更新
 *
 *  @param hours      时间间隔
 *  @param recordDate 上次记录时间
 *
 *  @return 是否需要更新
 */
+ (BOOL)needUpdateForHours:(CGFloat)hours
                recordDate:(NSDate *)recordDate
{
    if (recordDate) {
        
        NSTimeInterval timeIn = [recordDate timeIntervalSinceNow];
        
        CGFloat daySeconds = hours * 60 * 60.f;//秒数
        
        if ((timeIn * -1) >= daySeconds) { //预定时间
            
            return YES;
        }else
        {
            return NO;
        }
    }
    
    return YES;
}


#pragma - mark UIAlertView快捷方式

+ (void)alertText:(NSString *)text viewController:(UIViewController *)vc
{
    id obj=NSClassFromString(@"UIAlertController");
    if (obj) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:text preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        [alertController addAction:cancelAction];
        
        [vc presentViewController:alertController animated:YES completion:^{
            
        }];
        
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}


//alert 提示

+ (void)alertText:(NSString *)text
{
    id obj=NSClassFromString(@"UIAlertController");
    if (obj) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:text preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        [alertController addAction:cancelAction];
        
        
        UIViewController *viewC = ((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController;
        
        [viewC presentViewController:alertController animated:YES completion:^{
            
        }];
        
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

#pragma - mark MBProgressHUD快捷方式

+ (void)showMBProgressWithText:(NSString *)text addToView:(UIView *)aView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:aView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.margin = 10.f;
//    hud.yOffset = 150.f;
//    hud.opacity = 0.7f;
    hud.removeFromSuperViewOnHide = YES;
//    hud.color = DEFAULT_TEXTCOLOR;
//    hud.labelFont = [UIFont systemFontOfSize:12];
    [hud setCornerRadius:3.f];
    [hud hide:YES afterDelay:1.f];
}

+ (MBProgressHUD *)MBProgressWithText:(NSString *)text addToView:(UIView *)aView
{
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:aView];
//    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
//    hud.margin = 15.f;
//    hud.yOffset = 0.0f;
    [aView addSubview:hud];
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

#pragma - mark 特殊

+ (BOOL)isLogin
{
    NSString *authey = [LTools objectForKey:USER_AUTHOD];
    
    if (authey.length > 0) {
        
        return YES;
    }
    return NO;
}

#pragma - mark 身份证安全性处理
/**
 *  处理身份证号
 *
 *  @param idCard 身份证号
 *
 *  @return
 */
+ (NSString *)safeStringWithIdCard:(NSString *)idCard
{
    NSMutableString *temp = [NSMutableString stringWithString:idCard];
    int index = 4;
    int length = (int)idCard.length;
    
    if (length < 8) { //小于八位不处理
        return idCard;
    }
    
    while (index < length - 4) {
        [temp replaceCharactersInRange:NSMakeRange(index, 1) withString:@"*"];
        index ++;
    }
    return temp;
}

#pragma - mark 非空字符串

/**
 *  NSNumber按照设置格式输出
 *
 *  @param number
 *  @param style  NSNumberFormatterRoundCeiling = kCFNumberFormatterRoundCeiling,//四舍五入，原值2.7999999999,直接输出3
 
 * NSNumberFormatterRoundFloor = kCFNumberFormatterRoundFloor,//保留小数输出2.8 正是想要的
 
 * NSNumberFormatterRoundDown = kCFNumberFormatterRoundDown,//加上了人民币标志，原值输出￥2.8
 
 * NSNumberFormatterRoundUp = kCFNumberFormatterRoundUp,//本身数值乘以100后用百分号表示,输出280%
 
 * NSNumberFormatterRoundHalfEven = kCFNumberFormatterRoundHalfEven,//原值表示，输出2.799999999E0
 
 * NSNumberFormatterRoundHalfDown = kCFNumberFormatterRoundHalfDown,//原值的中文表示，输出二点七九九九。。。。
 
 * NSNumberFormatterRoundHalfUp = kCFNumberFormatterRoundHalfUp //原值中文表示，输出第三
 *
 *  @return
 */

+(NSString *)numberToString:(long)number
                numberStyle:(NSNumberFormatterStyle)style
{
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle: style];
    NSString *numberString = [numberFormatter stringFromNumber: [NSNumber numberWithInteger: number]];
    return numberString;
}

/**
 *  排除NSNull null 和 (null)
 *
 *  @param text
 *
 *  @return 空格
 */
+ (NSString *)NSStringNotNull:(NSString *)text
{
    if (![text isKindOfClass:[NSString class]]) {
        return @"";
    }else if ([text isEqualToString:@"(null)"] || [text isEqualToString:@"null"] || [text isKindOfClass:[NSNull class]]){
        return @"";
    }
    return text;
}

/**
 *  判断是否为null、NSNull活着nil
 *
 *  @return
 */
+ (BOOL)NSStringIsNull:(NSString *)text
{
    if (!text) {
        return YES;
    }
    if ([text isEqualToString:@"(null)"] ||
        [text isEqualToString:@"null"] ||
        [text isKindOfClass:[NSNull class]]){
        return YES;
    }
    
    NSMutableString *str = [NSMutableString stringWithString:text];
    [str replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, str.length)];
    if (str.length == 0) {
        return YES;
    }
    return NO;
}

/**
 *  去除开头的空格
 */
+ (NSString *)stringHeadNoSpace:(NSString *)string
{
    string = string.length == 0 ? @"" : string;
    NSMutableString *mu_str = [NSMutableString stringWithString:string];
    [mu_str replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, mu_str.length)];
    return mu_str;
}

/**
 *  给字符串加逗号
 *
 *  @param string 源字符串 如： 123456.78 或者 123456
 *
 *  @return 逗号分割字符串  1,234,567.89 或者 123,456
 */

+ (NSString *)NSStringAddComma:(NSString *)string{//添加逗号
    
    if (string == nil) {
        return @"";
    }
    
    NSRange range = [string rangeOfString:@"."];
    
    NSMutableString *temp = [NSMutableString stringWithString:string];
    int i;
    if (range.length > 0) {
        //有.
        
        i = (int)range.location;
        
    }else
    {
        i = (int)string.length;
    }
    
    while ((i-=3) > 0) {
        
        [temp insertString:@"," atIndex:i];
    }
    
    return temp;
    
}

/**
 *  行间距string
 */

+ (NSAttributedString *)attributedString:(NSString *)string
                            lineSpaceing:(CGFloat)lineSpage
{
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:lineSpage];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [string length])];
    
    return attributedString1;
}

/**
 *  行间距string 字体大小
 */

+ (NSAttributedString *)attributedString:(NSString *)string
                            lineSpaceing:(CGFloat)lineSpage
                                fontSize:(CGFloat)fontSize
{
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:lineSpage];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [string length])];
    
    [attributedString1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:NSMakeRange(0, [string length])];
    
    return attributedString1;
}

/**
 *  行间距string 字体大小 字体颜色
 */

+ (NSAttributedString *)attributedString:(NSString *)string
                            lineSpaceing:(CGFloat)lineSpage
                                fontSize:(CGFloat)fontSize
                               textColor:(UIColor *)textColor
{
    NSMutableAttributedString * attributedString1 = (NSMutableAttributedString *)[self attributedString:string lineSpaceing:lineSpage fontSize:fontSize];
    
    [attributedString1 addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, [string length])];
    
    return attributedString1;
}


/**
 *  关键词特殊显示
 *
 *  @param content   源字符串
 *  @param aKeyword  关键词
 *  @param textColor 关键词颜色
 */
+ (NSAttributedString *)attributedString:(NSString *)content
                                 keyword:(NSString *)aKeyword
                                   color:(UIColor *)textColor
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:content];
    
    if (content.length < aKeyword.length) {
        return string;
    }
    
    for (int i = 0; i <= content.length - aKeyword.length; i ++) {
        
        NSRange tmp = NSMakeRange(i, aKeyword.length);
        
        NSRange range = [content rangeOfString:aKeyword options:NSCaseInsensitiveSearch range:tmp];
        
        if (range.location != NSNotFound) {
            [string addAttribute:NSForegroundColorAttributeName value:textColor range:range];
        }
    }
    
    return string;
}


/**
 *  关键词特殊显示
 *
 *  @param content   源字符串
 *  @param aKeyword  关键词
 *  @param textColor 关键词颜色
 *  @param keywordFontSize 关键字大小
 */
+ (NSAttributedString *)attributedString:(NSString *)content
                                 keyword:(NSString *)aKeyword
                                   color:(UIColor *)textColor
                         keywordFontSize:(CGFloat)keywordFontSize
{
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:content];
    
    if (content.length < aKeyword.length) {
        return string;
    }
    
    for (int i = 0; i <= content.length - aKeyword.length; i ++) {
        
        NSRange tmp = NSMakeRange(i, aKeyword.length);
        
        NSRange range = [content rangeOfString:aKeyword options:NSCaseInsensitiveSearch range:tmp];
        
        if (range.location != NSNotFound) {
            [string addAttribute:NSForegroundColorAttributeName value:textColor range:range];
            [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:keywordFontSize] range:range];
        }
    }
    
    return string;
}

/**
 *  每次只给一个关键词加高亮颜色
 *
 *  @param attibutedString 可以为空
 *  @param string          attibutedString 为空时,用此进行初始化;并且用于找到关键词的range
 *  @param keyword         需要高亮的部分
 *  @param color           高亮的颜色
 *
 *  @return NSAttributedString
 */
+ (NSAttributedString *)attributedString:(NSMutableAttributedString *)attibutedString
                          originalString:(NSString *)string
                              AddKeyword:(NSString *)keyword
                                   color:(UIColor *)color
{
    if (attibutedString == nil) {
        attibutedString = [[NSMutableAttributedString alloc]initWithString:string];
    }
    
    if (keyword.length == 0) {
        keyword = @"";
    }
    
    NSRange range = [string rangeOfString:keyword options:NSCaseInsensitiveSearch range:NSMakeRange(0, string.length)];
    
    [attibutedString addAttribute:NSForegroundColorAttributeName value:color range:range];
    
    return attibutedString;
}

/**
 *  给关键字设置颜色、下划线、字体大小
 *
 *  @param content          目标string
 *  @param underlineKeyword 关键词
 *  @param textColor        颜色
 *  @param keywordFontSize  字体大小
 *
 *  @return
 */
+ (NSAttributedString *)attributedString:(NSString *)content
                        underlineKeyword:(NSString *)underlineKeyword
                                   color:(UIColor *)textColor
                         keywordFontSize:(CGFloat)keywordFontSize
{
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:content];
    
    if (content.length < underlineKeyword.length) {
        return string;
    }
    
    for (int i = 0; i <= content.length - underlineKeyword.length; i ++) {
        
        NSRange tmp = NSMakeRange(i, underlineKeyword.length);
        
        NSRange range = [content rangeOfString:underlineKeyword options:NSCaseInsensitiveSearch range:tmp];
        
        if (range.location != NSNotFound) {
            [string addAttribute:NSForegroundColorAttributeName value:textColor range:range];
            [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:keywordFontSize] range:range];
            //下划线
            [string addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:range];
        }
    }
    
    return string;
}

#pragma - mark 获取JSONString
/**
 *  object转化为JSON字符串
 *
 *  @param object
 *
 *  @return
 */
+ (NSString *)JSONStringWithObject:(id)object
{
    if (!object) {
        return nil;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        
        //使用这个方法的返回，我们就可以得到想要的JSON串
        NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    
    NSLog(@"%s:%@",__FUNCTION__,error);
    return nil;
}

#pragma - mark 图片处理相关

#pragma mark 切图

+(UIImage *)scaleToSizeWithImage:(UIImage *)img size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

//根据url获取SDWebImage 缓存的图片

+ (UIImage *)sd_imageForUrl:(NSString *)url
{
    //    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    //    NSString *imageKey = [manager cacheKeyForURL:[NSURL URLWithString:url]];
    //
    //    SDImageCache *cache = [SDImageCache sharedImageCache];
    //    UIImage *cacheImage = [cache imageFromDiskCacheForKey:imageKey];
    //
    //    return cacheImage;
    
    return nil;
}

#pragma - mark 图片比例计算

/**
 *  计算等比例高度
 *
 *  @param image_height   图片的高度
 *  @param image_width    图片的宽度
 *  @param show_Width     实际显示宽度
 *
 *  @return 实际显示高度
 */
+ (CGFloat)heightForImageHeight:(CGFloat)image_height
                     imageWidth:(CGFloat)image_width
                      showWidth:(CGFloat)show_Width
{
    float rate;
    
    if (image_width == 0.0 || image_height == 0.0) {
        image_width = image_height;
    }else
    {
        rate = image_height/image_width;
    }
    
    CGFloat imageHeight = show_Width * rate;
    
    return imageHeight;
    
}


#pragma mark - 动画

/**
 *  view先变大再恢复原样
 *
 *  @param annimationView 需要做动画的view
 *  @param duration       动画时间
 *  @param scacle         变大比例
 */
+ (void)animationToBigger:(UIView *)annimationView
                 duration:(CGFloat)duration
                   scacle:(CGFloat)scacle
{
    //下边是嵌套使用,先变大再恢复的动画效果.
    [UIView animateWithDuration:duration animations:^{
        CGAffineTransform newTransform = CGAffineTransformMakeScale(scacle, scacle);
        [annimationView setTransform:newTransform];
        
    }
                     completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:0.1 animations:^{
                             
                             [annimationView setTransform:CGAffineTransformIdentity];
                             
                         } completion:^(BOOL finished){
                             
                             
                         }];
                     }];
}


#pragma mark - 身份证信息处理
/**
 *  根据身份证号获取生日(18位身份证 7-14为出生日期)
 *
 *  @param numberStr
 *
 *  @return
 */
+ (NSString *)getIdCardbirthday:(NSString *)numberStr
{
    NSMutableString *result = [NSMutableString stringWithCapacity:0];
    NSString *year = nil;
    NSString *month = nil;
    
    BOOL isAllNumber = YES;
    NSString *day = nil;
    
    if([numberStr length] != 15 && [numberStr length] !=18)
        return result;
    
    /**
     *  15位身份证号码
     */
    if ([numberStr length] == 15) {
        
        //**截取前12位
        NSString *fontNumer = [numberStr substringWithRange:NSMakeRange(0, 11)];
        
        //**检测前12位否全都是数字;
        const char *str = [fontNumer UTF8String];
        const char *p = str;
        while (*p!='\0') {
            if(!(*p>='0'&&*p<='9'))
                isAllNumber = NO;
            p++;
        }
        if(!isAllNumber)
            return result;
        
        year = [NSString stringWithFormat:@"19%@",[numberStr substringWithRange:NSMakeRange(6, 2)]];
        month = [numberStr substringWithRange:NSMakeRange(8, 2)];
        day = [numberStr substringWithRange:NSMakeRange(10,2)];
    }else if ([numberStr length] == 18)
    {
        //**截取前14位
        NSString *fontNumer = [numberStr substringWithRange:NSMakeRange(0, 13)];
        
        //**检测前14位否全都是数字;
        const char *str = [fontNumer UTF8String];
        const char *p = str;
        while (*p!='\0') {
            if(!(*p>='0'&&*p<='9'))
                isAllNumber = NO;
            p++;
        }
        if(!isAllNumber)
            return result;
        
        year = [numberStr substringWithRange:NSMakeRange(6, 4)];
        month = [numberStr substringWithRange:NSMakeRange(10, 2)];
        day = [numberStr substringWithRange:NSMakeRange(12,2)];
    }
    
    [result appendString:year];
    [result appendString:@"-"];
    [result appendString:month];
    [result appendString:@"-"];
    [result appendString:day];
    return result;
}

/**
 *  根据身份证号获取性别,18位(17位代表性别)15位(15位代表性别)奇数为男,偶数为女。
 *
 *  @param numberStr
 *
 *  @return Gender
 */
+(Gender)getIdCardSex:(NSString *)numberStr
{
    int length = (int)[numberStr length];
    
    int sexInt = 1;
    
    if (length == 15)
    {
        sexInt=[[numberStr substringWithRange:NSMakeRange(14,1)] intValue];
    }else if (length == 18) {
        
        sexInt=[[numberStr substringWithRange:NSMakeRange(16,1)] intValue];
    }
    
    if(sexInt % 2 == 0) //偶数为女
    {
        return Gender_Girl;//女
    }
    else
    {
        return Gender_Boy;//男
    }
    
    return Gender_NO;
}
/**
 *  根据省份证号获取年龄
 *
 *  @param numberStr
 *
 *  @return
 */
+(NSString *)getIdCardAge:(NSString *)numberStr
{
    NSDateFormatter *formatterTow = [[NSDateFormatter alloc]init];
    [formatterTow setDateFormat:@"yyyy-MM-dd"];
    NSDate *bsyDate = [formatterTow dateFromString:[LTools getIdCardbirthday:numberStr]];
    
    NSTimeInterval dateDiff = [bsyDate timeIntervalSinceNow];
    
    int age = trunc(dateDiff/(60*60*24))/365;
    
    return [NSString stringWithFormat:@"%d",-age];
}

@end
