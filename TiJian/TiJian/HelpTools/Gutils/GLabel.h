//
//  GLabel.h
//  TiJian
//
//  Created by gaomeng on 16/4/10.
//  Copyright © 2016年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "HospitalModel.h"

@interface GLabel : UILabel

@property(nonatomic,strong)UserInfo *userInfo;
@property(nonatomic,strong)HospitalModel *hospitalModel;

@end
