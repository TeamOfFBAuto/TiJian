//
//  ActivityModel.h
//  TiJian
//
//  Created by lichaowei on 16/1/6.
//  Copyright © 2016年 lcw. All rights reserved.
//
/**
 *  活动model
 */
#import "BaseModel.h"

@interface ActivityModel : BaseModel

@property(nonatomic,retain)NSString *activity_id;
@property(nonatomic,retain)NSString *title;//标题
@property(nonatomic,retain)NSString *summary;//摘要
@property(nonatomic,retain)NSString *cover_pic;
@property(nonatomic,retain)NSString *start_time;
@property(nonatomic,retain)NSString *end_time;
@property(nonatomic,retain)NSString *add_time;
@property(nonatomic,retain)NSString *url;
@property(nonatomic,retain)NSString *status;
@property(nonatomic,retain)NSString *cover_width;
@property(nonatomic,retain)NSString *cover_height;

@end
