//
//  IgnoreConditionModel.h
//  TiJian
//
//  Created by lichaowei on 15/10/30.
//  Copyright © 2015年 lcw. All rights reserved.
//

/**
 *  答案忽略条件
 */
#import "BaseModel.h"

@interface IgnoreConditionModel : BaseModel

@property(nonatomic,assign)int group_id;
@property(nonatomic,assign)int question_id;
@property(nonatomic,retain)NSString *ignore_option_ids;//问题中需要忽略的选项
@property(nonatomic,retain)NSString *ignore_conditions;//忽略条件json串

//拼接组合答案串（需要忽略问题查找流程）
//根据组合id 获取需要忽略的条件
//根据忽略的条件（有多种情况，满足其一即可）找到对应的需要忽略的问题id和对应的选项

@end
