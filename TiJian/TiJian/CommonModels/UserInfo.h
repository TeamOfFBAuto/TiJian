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
@property(nonatomic,retain)NSString *type;//1普通 2查询报告 type=3标识go健康
@property(nonatomic,retain)NSString *photo;

@property(nonatomic,retain)NSString *is_vip;//是否是vip

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

//体检报告
@property(nonatomic,retain)NSString *checkup_time;//体检时间
@property(nonatomic,retain)NSString *report_id;//报告id
@property(nonatomic,retain)NSString *is_read;//是否解读
@property(nonatomic,retain)NSArray *img;//报告图片
@property(nonatomic,retain)NSString *url;//解读详情
@property(nonatomic,retain)NSString *customed;//是否个性化定制过

@property(nonatomic,retain)NSString *longtitude;//经度 记录用户当前位置
@property(nonatomic,retain)NSString *latitude;//维度

@property(nonatomic,assign)BOOL mySelf;//是否当前用户


/**
 *  归档的方式存model对象 重写了编码解码方法
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


#pragma mark - 用户信息获取

+ (NSString *)getAuthkey;
/**
 *  获取vip状态
 *
 *  @return
 */
+ (BOOL)getVipState;
+ (NSString *)getDeviceToken;
+ (NSString *)getUserId;
+ (BOOL)getCustomState;//是否定制化过
/**
 *  获取经度
 *
 *  @return
 */
+ (NSString *)getLontitude;

/**
 *  获取维度
 *
 *  @return
 */
+ (NSString *)getLatitude;

#pragma mark - 用户信息更新

/**
 *  更新用户当前坐标
 */
+ (void)updateUserLontitude:(NSString *)longtitude
                   latitude:(NSString *)latitude;

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

/**
 *  更新积分
 */
+ (void)updateUserScrore:(NSString *)score;
/**
 *  更新个性化定制状态
 */
+ (void)updateUserCustomed:(NSString *)customed;

@end
