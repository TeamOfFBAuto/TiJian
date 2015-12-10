//
//  UserInfo.m
//  YiYiProject
//
//  Created by lichaowei on 14/12/13.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "UserInfo.h"
#import <objc/runtime.h>

@implementation UserInfo

/**
 *  编码
 *
 *  @param coder
 */
- (void)encodeWithCoder:(NSCoder *)coder
{
    //    [super encodeWithCoder:coder];
    unsigned int num = 0;
    Ivar *ivars = class_copyIvarList([self class], &num);
    
    for (int i = 0; i < num; i ++) {
        
        //取出i位置成员变量
        Ivar ivar = ivars[i];
        
        //查看成员变量
        const char *name = ivar_getName(ivar);
        
        //归档
        
        NSString *key = [NSString stringWithUTF8String:name];
        
//        NSLog(@"归档 key %@",key);
        
        id value = [self valueForKey:key];
        
        [coder encodeObject:value forKey:key];
    }
    free(ivars);
    
}

/**
 *  解码
 *
 *  @param coder
 *
 *  @return
 */
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        unsigned int num = 0;
        Ivar *ivars = class_copyIvarList([self class], &num);
        
        for (int i = 0; i < num; i ++) {
            
            Ivar ivar = ivars[i];
            
            const char *name = ivar_getName(ivar);
            
            NSString *key = [NSString stringWithUTF8String:name];
            
            //解档
            
            id value = [coder decodeObjectForKey:key];
            
            if (value == nil ||[value isKindOfClass:[NSNull class]]) {
                value = @"";
            }
            
            [self setValue:value forKey:key];
        }
    }
    return self;
}

/**
 *  归档的方式存model对象 重写了编码解码方法
 *
 *  @param aModel
 *  @param modelKey
 */
- (void)cacheForKey:(NSString *)modelKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [userDefaults setObject:data forKey:modelKey];
    [userDefaults synchronize];
}

/**
 *  归档方式存储用户信息
 */
- (void)cacheUserInfo
{
    [self cacheForKey:USERINFO_MODEL];
}

/**
 *  获取本地存储的用户信息
 *
 *  @return model
 */
+ (UserInfo *)userInfoForCache
{
    return [self cacheResultForKey:USERINFO_MODEL];
}

/**
 *  清除本地存储的用户信息
 */
+ (void)cleanUserInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:USERINFO_MODEL];
    [userDefaults synchronize];
}

/**
 *  获取存在本地的model
 *
 *  @param modelKey key
 *
 *  @return
 */
+ (id)cacheResultForKey:(NSString *)modelKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefaults objectForKey:modelKey];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}


#pragma mark - 获取用户信息

+ (NSString *)getAuthkey
{
    NSString *value = [LTools objectForKey:USER_AUTHOD];
    if (value) {
        return value;
    }
    return @"";
}

+ (NSString *)getUserId
{
    UserInfo *userInfo = [UserInfo cacheResultForKey:USERINFO_MODEL];
    NSString *value = userInfo.uid;
    if (value) {
        return value;
    }
    return @"";
}

+ (BOOL)getCustomState
{
    UserInfo *userInfo = [UserInfo cacheResultForKey:USERINFO_MODEL];
    NSString *value = userInfo.customed;
    if ([value intValue] == 1) {
        return YES;
    }
    return NO;
}

#pragma mark - 用户信息更新

/**
 *  更新头像
 *
 *  @param avatar 头像地址
 */
+ (void)updateUserAvatar:(NSString *)avatar
{
    UserInfo *userInfo = [UserInfo cacheResultForKey:USERINFO_MODEL];
    userInfo.avatar = avatar;
    [userInfo cacheForKey:USERINFO_MODEL];
    
    //融云信息更新
    RCUserInfo *r_userInfo = [[RCUserInfo alloc]initWithUserId:userInfo.uid name:userInfo.user_name portrait:userInfo.avatar];
    [[RCIM sharedRCIM]refreshUserInfoCache:r_userInfo withUserId:userInfo.uid];
    
}

/**
 *  更新真实姓名
 */
+ (void)updateUserRealName:(NSString *)realName
{
    if (!realName) {
        return;
    }
    UserInfo *userInfo = [UserInfo cacheResultForKey:USERINFO_MODEL];
    userInfo.real_name = realName;
    [userInfo cacheForKey:USERINFO_MODEL];
    
}

/**
 *  更新性别
 */
+ (void)updateUserSex:(NSString *)sex
{
    if (!sex) {
        return;
    }
    UserInfo *userInfo = [UserInfo cacheResultForKey:USERINFO_MODEL];
    userInfo.gender = sex;
    [userInfo cacheForKey:USERINFO_MODEL];
}

/**
 *  更新年龄
 */
+ (void)updateUserAge:(NSString *)age
{
    if (!age) {
        return;
    }
    UserInfo *userInfo = [UserInfo cacheResultForKey:USERINFO_MODEL];
    userInfo.age = age;
    [userInfo cacheForKey:USERINFO_MODEL];
}

/**
 *  更新生日
 */
+ (void)updateUserBirthday:(NSString *)dateline
{
    if (!dateline) {
        return;
    }
    UserInfo *userInfo = [UserInfo cacheResultForKey:USERINFO_MODEL];
    userInfo.birthday = dateline;
    [userInfo cacheForKey:USERINFO_MODEL];
}

/**
 *  更新身份证号
 */
+ (void)updateUserIdCard:(NSString *)idCard
{
    if (!idCard) {
        return;
    }
    UserInfo *userInfo = [UserInfo cacheResultForKey:USERINFO_MODEL];
    userInfo.id_card = idCard;
    [userInfo cacheForKey:USERINFO_MODEL];
}

/**
 *  更新昵称
 */
+ (void)updateUserName:(NSString *)userName
{
    if (!userName) {
        return;
    }
    UserInfo *userInfo = [UserInfo cacheResultForKey:USERINFO_MODEL];
    userInfo.user_name = userName;
    [userInfo cacheForKey:USERINFO_MODEL];
}

/**
 *  更新积分
 */
+ (void)updateUserScrore:(NSString *)score
{
    if (!score) {
        return;
    }
    UserInfo *userInfo = [UserInfo cacheResultForKey:USERINFO_MODEL];
    userInfo.score = score;
    [userInfo cacheForKey:USERINFO_MODEL];
}

/**
 *  更新个性化定制状态
 */
+ (void)updateUserCustomed:(NSString *)customed
{
    if (!customed) {
        return;
    }
    UserInfo *userInfo = [UserInfo cacheResultForKey:USERINFO_MODEL];
    userInfo.customed = customed;
    [userInfo cacheForKey:USERINFO_MODEL];
}

@end
