//
//  HospitalModel.h
//  TiJian
//
//  Created by lichaowei on 15/11/12.
//  Copyright © 2015年 lcw. All rights reserved.
//
/**
 *  分院model
 */
#import "BaseModel.h"

@interface HospitalModel : BaseModel

@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSString *time;

@property(nonatomic,retain)NSArray *usersArray;//对应的user

@end
