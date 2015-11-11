//
//  AddPeopleViewController.h
//  TiJian
//
//  Created by lichaowei on 15/11/6.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "MyViewController.h"

typedef enum {
    ACTIONSTYLE_ADD = 0,//添加
    ACTIONSTYLE_DETTAILT //详情
}ACTIONSTYLE;

@class UserInfo;
@interface AddPeopleViewController : MyViewController

@property(nonatomic,assign)ACTIONSTYLE actionStyle;
@property(nonatomic,retain)UserInfo *userModel;

@end
