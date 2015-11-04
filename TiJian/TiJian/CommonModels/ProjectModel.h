//
//  ProjectModel.h
//  TiJian
//
//  Created by lichaowei on 15/11/4.
//  Copyright © 2015年 lcw. All rights reserved.
//
/**
 *  体检项目model
 */
#import "BaseModel.h"

@interface ProjectModel : BaseModel

@property(nonatomic,retain)NSString *project_id;
@property(nonatomic,retain)NSString *category_id;
@property(nonatomic,retain)NSString *add_time;
@property(nonatomic,retain)NSString *is_after_dinner;
@property(nonatomic,retain)NSString *project_desc;
@property(nonatomic,retain)NSString *project_name;
@property(nonatomic,retain)NSString *status;

@end
