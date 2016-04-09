//
//  Gbtn.h
//  TiJian
//
//  Created by gaomeng on 15/12/1.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "HospitalModel.h"
@interface Gbtn : UIButton

@property(nonatomic,strong)NSIndexPath *theIndex;
@property(nonatomic,strong)UserInfo *userInfo;
@property(nonatomic,strong)HospitalModel *hospitalModel;
@end
