//
//  UpdateUserInfoController.h
//  TiJian
//
//  Created by lichaowei on 15/11/19.
//  Copyright © 2015年 lcw. All rights reserved.
//
/**
 *  更新用户信息
 */
#import "MyViewController.h"

//    user_name 昵称
//    real_name 真实姓名
//    birthday 1988-10-10
//    gender 型别 1男 2女
//    age 年龄
//    password 密码
//    id_card 身份证号
//    mobile 手机

typedef enum{
    UPDATEINFOTYPE_REALNAME = 0,//修改真实姓名
    UPDATEINFOTYPE_USERNAME,  //修改昵称
    UPDATEINFOTYPE_IDCARD, //修改身份证号
    UPDATEINFOTYPE_BIRTHDAY,  //修改出生日期
    UPDATEINFOTYPE_GENDER, //修改性别
    UPDATEINFOTYPE_AGE //修改年龄
    
}UPDATEINFOTYPE;

typedef void(^UPDATEUSERINFOBLOCK)(NSString *result);

@interface UpdateUserInfoController : MyViewController

@property(nonatomic,copy)UPDATEUSERINFOBLOCK updateBlock;
@property(nonatomic,assign)UPDATEINFOTYPE updateType;
@property(nonatomic,retain)NSString *content;

@end
