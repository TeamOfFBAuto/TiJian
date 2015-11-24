//
//  UserInfo.h
//  YiYiProject
//
//  Created by lichaowei on 14/12/13.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "BaseModel.h"

/**
 *  用户信息 model
 */
@interface UserInfo : BaseModel<NSCoding>

@property(nonatomic,retain)NSString *id;
@property(nonatomic,retain)NSString *uid;
@property(nonatomic,retain)NSString *user_name;

@property(nonatomic,retain)NSString *real_name;//真实姓名

@property(nonatomic,retain)NSString *password;
@property(nonatomic,retain)NSString *admin_id;
@property(nonatomic,retain)NSString *user_grade;
@property(nonatomic,retain)NSString *gender; //1男 2 女
@property(nonatomic,retain)NSString *age;
@property(nonatomic,retain)NSString *email;
@property(nonatomic,retain)NSString *mobile;
@property(nonatomic,retain)NSString *dateline;
@property(nonatomic,retain)NSString *state;
@property(nonatomic,retain)NSString *type;
@property(nonatomic,retain)NSString *photo;

@property(nonatomic,retain)NSString *avatar;//头像
@property(nonatomic,retain)NSString *third_avatar;

@property(nonatomic,retain)NSString *third_photo;
@property(nonatomic,retain)NSString *thirdid;
@property(nonatomic,retain)NSString *score;
@property(nonatomic,retain)NSString *devicetoken;
@property(nonatomic,retain)NSString *job;
@property(nonatomic,retain)NSString *decription;
@property(nonatomic,retain)NSString *role;
@property(nonatomic,retain)NSString *birthday;
@property(nonatomic,retain)NSString *friends_num;
@property(nonatomic,retain)NSString *fans_num; //粉丝数
@property(nonatomic,retain)NSString *attend_num;//关注数
@property(nonatomic,retain)NSString *favor_num;
@property(nonatomic,retain)NSString *authcode;
@property(nonatomic,retain)NSString *attentions_num; //关注数
@property(nonatomic,retain)NSString *division_t;//值表示1=》待审核搭配师 2=》已是搭配师 0=》普通
@property(nonatomic,retain)NSString *gold_coin;
@property(nonatomic,retain)NSString *recommend_uid;
@property(nonatomic,retain)NSString *shopman;//shopman的值表示 1=》店主审核 2=》已是店主 0=》普通
@property(nonatomic,retain)NSString *user_banner;
@property(nonatomic,strong)NSString *tt_num;

@property(nonatomic,retain)NSString *mall_type;//店铺类型 2 精品店 3 品牌店  1 商场
@property(nonatomic,retain)NSString *mall_name;//店铺名称

@property(nonatomic,retain)NSString *brand_name;//品牌name

@property(nonatomic,retain)NSString *shop_id;//店铺id 可能会没有
@property(nonatomic,retain)NSString *mall_id;//id 一定有


@property(nonatomic,strong)NSString *is_sign;//是否签到

@property(nonatomic,assign)int relation;//0 互相未关注 1关注了别人 2别人关注你 3互相关注

//家人管理 model
@property(nonatomic,retain)NSString *appellation;//称谓
@property(nonatomic,retain)NSString *family_uid;//家人id
@property(nonatomic,retain)NSString *family_user_name;//家人name
@property(nonatomic,retain)NSString *id_card;//身份证号

/**
 *  归档的方式存model对象 重写了编码解码方法
 *
 *  @param aModel
 *  @param modelKey
 */
//- (void)cacheForKey:(NSString *)modelKey;

/**
 *  归档方式存储用户信息
 */
- (void)cacheUserInfo;

/**
 *  获取本地存储的用户信息
 *
 *  @return model
 */
+ (UserInfo *)userInfoForCache;

/**
 *  清除本地存储的用户信息
 */
+ (void)cleanUserInfo;

/**
 *  更新头像
 *
 *  @param avatar 头像地址
 */
+ (void)updateUserAvatar:(NSString *)avatar;

/**
 *  更新真实姓名
 */
+ (void)updateUserRealName:(NSString *)realName;

/**
 *  更新性别
 */
+ (void)updateUserSex:(NSString *)sex;

/**
 *  更新年龄
 */
+ (void)updateUserAge:(NSString *)age;

/**
 *  更新生日
 */
+ (void)updateUserBirthday:(NSString *)dateline;

/**
 *  更新生日
 */
+ (void)updateUserIdCard:(NSString *)idCard;

/**
 *  更新昵称
 */
+ (void)updateUserName:(NSString *)userName;

@end
