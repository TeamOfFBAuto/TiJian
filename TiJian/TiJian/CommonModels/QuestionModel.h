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
@property(nonatomic,retain)NSString *questionId;
@property(nonatomic,retain)NSString *result;//是否结束end,或者下一组合
//@property(nonatomic,retain)

@end
