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

@end
