//
//  QuestionModel.h
//  TiJian
//
//  Created by lichaowei on 15/10/22.
//  Copyright © 2015年 lcw. All rights reserved.
//

/**
 *  个性定制 问题model
 */
#import "BaseModel.h"

@interface QuestionModel : BaseModel
@property(nonatomic,assign)int questionId;
@property(nonatomic,retain)NSString *questionName;
@property(nonatomic,assign)int type;//问题类型
@property(nonatomic,retain)NSString *result;//是否结束end,或者下一组合

@property(nonatomic,assign)int special_option_id;//问题对应的特殊选项
@property(nonatomic,assign)int select_option_type;//选项类型默认1  1=》多选一 2=》除特殊选项可多选，选特殊选项则其他都不能选 3=》除特殊选项单选，分别可以和特殊选项同时选中 4=》任意选择

/**
 *  以下为为拓展问题属性
 */
@property(nonatomic,assign)int gender;//性别 1男 2女
@property(nonatomic,assign)int start_age;//年龄条件最小年龄
@property(nonatomic,assign)int end_age;//年龄条件最大年龄
@property(nonatomic,assign)int is_end;//是否结束拓展

@end
